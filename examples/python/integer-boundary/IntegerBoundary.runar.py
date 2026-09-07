from runar import SmartContract, Bigint, public, assert_


class IntegerBoundary(SmartContract):
    """Pins the seven tiers to one arbitrary-precision integer domain (#162).

    Every literal fits a signed 64-bit slot; every folded result escapes one.
    See the TypeScript source for the full note.
    """

    target: Bigint

    def __init__(self, target: Bigint):
        super().__init__(target)
        self.target = target

    @public
    def verify(self, delta: Bigint):
        p: Bigint = 4294967295 * 4294967295
        q: Bigint = 9223372036854775807 + 1
        r: Bigint = 4294967296 * 4294967296
        s: Bigint = 9223372036854775807 * 9223372036854775807
        assert_(p + q + r + s + delta == self.target)
