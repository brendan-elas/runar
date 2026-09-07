import { SmartContract, assert } from 'runar-lang';

/**
 * IntegerBoundary -- pins the seven tiers to one arbitrary-precision integer
 * domain (issue #162).
 *
 * Every literal here fits a signed 64-bit slot, and every folded RESULT
 * escapes one:
 *
 *   p  (2^32-1)^2   = 18446744065119617025          just past 2^63
 *   q  2^63         = 9223372036854775808           first value past a signed i64
 *   r  2^64         = 18446744073709551616          past an unsigned one too
 *   s  (2^63-1)^2   = 85070591730234615847396907784232501249   126 bits
 *
 * That shape is deliberate. A tier can parse every literal in this file with
 * a 64-bit integer type and still get the answer wrong, because the defect
 * lives in the constant folder and the load-const emitter rather than in the
 * lexer. The Zig tier used to abort outright on `s` and silently emit a
 * wrapped value for products past 2^128.
 *
 * Keeping the literals 64-bit-expressible is also what lets this fixture
 * exist in all nine formats: the Java surface builds bigints through
 * `Bigint.of(long)`, so it cannot write 2^64 directly -- but it can fold its
 * way there.
 */
class IntegerBoundary extends SmartContract {
  readonly target: bigint;

  constructor(target: bigint) {
    super(target);
    this.target = target;
  }

  public verify(delta: bigint): void {
    const p: bigint = 4294967295n * 4294967295n;
    const q: bigint = 9223372036854775807n + 1n;
    const r: bigint = 4294967296n * 4294967296n;
    const s: bigint = 9223372036854775807n * 9223372036854775807n;
    assert(p + q + r + s + delta === this.target);
  }
}
