use runar::prelude::*;

/// IntegerBoundary -- pins the seven tiers to one arbitrary-precision integer
/// domain (issue #162). Every literal fits a signed 64-bit slot; every folded
/// result escapes one. See the TypeScript source for the full note.
#[runar::contract]
struct IntegerBoundary {
    #[readonly]
    target: Int,
}

impl IntegerBoundary {
    pub fn verify(&self, delta: Int) {
        let p = 4294967295 * 4294967295;
        let q = 9223372036854775807 + 1;
        let r = 4294967296 * 4294967296;
        let s = 9223372036854775807 * 9223372036854775807;
        assert!(p + q + r + s + delta == self.target);
    }
}
