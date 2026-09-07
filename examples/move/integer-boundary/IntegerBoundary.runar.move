module IntegerBoundary {
    use runar::types::{Int};

    // IntegerBoundary -- pins the seven tiers to one arbitrary-precision
    // integer domain (issue #162). Every literal fits a signed 64-bit slot;
    // every folded result escapes one. See the TypeScript source for the
    // full note.
    struct IntegerBoundary {
        target: Int,
    }

    public fun verify(contract: &IntegerBoundary, delta: Int) {
        let p = 4294967295 * 4294967295;
        let q = 9223372036854775807 + 1;
        let r = 4294967296 * 4294967296;
        let s = 9223372036854775807 * 9223372036854775807;
        assert_eq!(p + q + r + s + delta, contract.target);
    }
}
