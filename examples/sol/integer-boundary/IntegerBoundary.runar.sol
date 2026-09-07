pragma runar ^0.1.0;

// IntegerBoundary -- pins the seven tiers to one arbitrary-precision integer
// domain (issue #162). Every literal fits a signed 64-bit slot; every folded
// result escapes one. See the TypeScript source for the full note.
contract IntegerBoundary is SmartContract {
    int immutable target;

    constructor(int _target) {
        target = _target;
    }

    function verify(int delta) public {
        int p = 4294967295 * 4294967295;
        int q = 9223372036854775807 + 1;
        int r = 4294967296 * 4294967296;
        int s = 9223372036854775807 * 9223372036854775807;
        require(p + q + r + s + delta == target);
    }
}
