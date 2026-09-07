const runar = @import("runar");

// IntegerBoundary -- pins the seven tiers to one arbitrary-precision integer
// domain (issue #162). Every literal fits a signed 64-bit slot; every folded
// result escapes one. See the TypeScript source for the full note.
pub const IntegerBoundary = struct {
    pub const Contract = runar.SmartContract;

    target: i64,

    pub fn init(target: i64) IntegerBoundary {
        return .{ .target = target };
    }

    pub fn verify(self: *const IntegerBoundary, delta: i64) void {
        const p = 4294967295 * 4294967295;
        const q = 9223372036854775807 + 1;
        const r = 4294967296 * 4294967296;
        const s = 9223372036854775807 * 9223372036854775807;
        runar.assert(p + q + r + s + delta == self.target);
    }
};
