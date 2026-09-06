package runar.examples.integerboundary;

import runar.lang.SmartContract;
import runar.lang.annotations.Public;
import runar.lang.annotations.Readonly;
import runar.lang.types.Bigint;

import static runar.lang.Builtins.assertThat;

/**
 * IntegerBoundary -- pins the seven tiers to one arbitrary-precision integer
 * domain (issue #162).
 *
 * <p>Every literal here fits a signed 64-bit slot, and every folded result
 * escapes one: (2^32-1)^2, 2^63, 2^64 and (2^63-1)^2. See the TypeScript
 * source for the full note.
 *
 * <p>This surface is why the fixture is shaped that way. {@code Bigint.of}
 * takes a {@code long}, so a Java-format contract cannot write 2^64 as a
 * literal at all -- but it can fold its way there from operands that do fit.
 */
class IntegerBoundary extends SmartContract {

    @Readonly Bigint target;

    IntegerBoundary(Bigint target) {
        super(target);
        this.target = target;
    }

    @Public
    void verify(Bigint delta) {
        Bigint p = Bigint.of(4294967295L).times(Bigint.of(4294967295L));
        Bigint q = Bigint.of(9223372036854775807L).plus(Bigint.of(1));
        Bigint r = Bigint.of(4294967296L).times(Bigint.of(4294967296L));
        Bigint s = Bigint.of(9223372036854775807L).times(Bigint.of(9223372036854775807L));
        assertThat(p.plus(q).plus(r).plus(s).plus(delta).eq(this.target));
    }
}
