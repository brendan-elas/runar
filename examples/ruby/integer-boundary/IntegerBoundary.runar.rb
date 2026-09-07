require 'runar'

# IntegerBoundary -- pins the seven tiers to one arbitrary-precision integer
# domain (issue #162). Every literal fits a signed 64-bit slot; every folded
# result escapes one. See the TypeScript source for the full note.
class IntegerBoundary < Runar::SmartContract
  prop :target, Bigint

  def initialize(target)
    super(target)
    @target = target
  end

  runar_public delta: Bigint
  def verify(delta)
    p = 4294967295 * 4294967295
    q = 9223372036854775807 + 1
    r = 4294967296 * 4294967296
    s = 9223372036854775807 * 9223372036854775807
    assert p + q + r + s + delta == @target
  end
end
