//! Arbitrary-precision integer arithmetic for the constant folder (issue #162).
//!
//! The Rúnar integer domain is arbitrary-precision: post-Genesis BSV Script
//! has arbitrary-precision script numbers, the TS reference folder works on
//! native JS `bigint`, and Go / Rust / Python / Ruby / Java all follow. The
//! Zig tier's `ConstValue` splits the same domain across two representations
//! (`integer: i128` and `big_integer: []const u8` decimal text) purely as a
//! storage optimisation, so the folder cannot work on either one alone:
//!
//!   * folding only `.integer` skips every above-i128 operand, which made the
//!     Zig tier emit a runtime `OP_MUL` where the other six tiers emit a
//!     folded push;
//!   * folding `.integer` with Zig's fixed-width operators wraps, which made
//!     `pow(2n, 200n)` fold to `2^200 mod 2^128` == 0 and silently emit
//!     `OP_0`.
//!
//! `load` erases the representation split and `store` re-establishes it, so
//! callers can express the arithmetic once, at full precision, exactly as the
//! TS reference does.
//!
//! Every result allocated here is owned by the caller's allocator. The
//! compile pipeline runs inside the arena in `compiler_api.compileSource`,
//! which frees them when the compile returns.

const std = @import("std");
const types = @import("../ir/types.zig");

const Allocator = std.mem.Allocator;
const ConstValue = types.ConstValue;

pub const Big = std.math.big.int.Managed;

/// True when `v` carries an integer in either representation.
pub fn isInteger(v: ConstValue) bool {
    return v == .integer or v == .big_integer;
}

/// Load either integer representation at full precision. Returns null for
/// non-integer values and for `big_integer` text that does not parse (which
/// should be unreachable — the producers all write canonical decimal — but a
/// malformed IR input must decline to fold rather than abort).
///
/// The caller owns the returned value and must `deinit` it.
pub fn load(allocator: Allocator, v: ConstValue) !?Big {
    switch (v) {
        .integer => |i| {
            var m = try Big.init(allocator);
            errdefer m.deinit();
            try m.set(i);
            return m;
        },
        .big_integer => |s| {
            var m = try Big.init(allocator);
            errdefer m.deinit();
            m.setString(10, s) catch {
                m.deinit();
                return null;
            };
            return m;
        },
        else => return null,
    }
}

/// Normalise a full-precision result back into a `ConstValue`, honouring the
/// contract documented on `ConstValue.big_integer` in ir/types.zig: a value
/// that fits `i128` MUST land in `.integer`, and `.big_integer` is reserved
/// for the overflow case. Both representations serialise to the same
/// `"<decimal>n"` JSON text, so this choice is invisible cross-tier — but
/// keeping it stable means the ec-optimizer and the existing fold paths see
/// exactly the shapes they saw before.
pub fn store(allocator: Allocator, m: Big) !ConstValue {
    if (m.toConst().toInt(i128)) |i| {
        return .{ .integer = i };
    } else |_| {}
    return .{ .big_integer = try m.toString(allocator, 10, .lower) };
}

/// Convenience: build a `Big` holding `v`. Caller owns it.
pub fn fromI128(allocator: Allocator, v: i128) !Big {
    var m = try Big.init(allocator);
    errdefer m.deinit();
    try m.set(v);
    return m;
}

/// `a` cmp `b` at full precision.
pub fn order(a: Big, b: Big) std.math.Order {
    return a.toConst().order(b.toConst());
}

pub fn isZero(a: Big) bool {
    return a.toConst().eqlZero();
}

pub fn isNegative(a: Big) bool {
    return !a.toConst().positive and !a.toConst().eqlZero();
}

/// Truncating quotient, matching JS bigint `/` and Zig `@divTrunc`.
pub fn divTrunc(allocator: Allocator, a: Big, b: Big) !Big {
    var q = try Big.init(allocator);
    errdefer q.deinit();
    var r = try Big.init(allocator);
    defer r.deinit();
    try q.divTrunc(&r, &a, &b);
    return q;
}

/// Truncated remainder, matching JS bigint `%` (sign follows the dividend).
pub fn remTrunc(allocator: Allocator, a: Big, b: Big) !Big {
    var q = try Big.init(allocator);
    defer q.deinit();
    var r = try Big.init(allocator);
    errdefer r.deinit();
    try q.divTrunc(&r, &a, &b);
    return r;
}
