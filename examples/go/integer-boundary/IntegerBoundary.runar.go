//go:build ignore

package contract

import "runar"

// IntegerBoundary pins the seven tiers to one arbitrary-precision integer
// domain (issue #162). Every literal fits a signed 64-bit slot; every folded
// result escapes one. See the TypeScript source for the full note.
type IntegerBoundary struct {
	runar.SmartContract
	Target runar.Int `runar:"readonly"`
}

func (c *IntegerBoundary) Verify(delta runar.Int) {
	p := 4294967295 * 4294967295
	q := 9223372036854775807 + 1
	r := 4294967296 * 4294967296
	s := 9223372036854775807 * 9223372036854775807
	runar.Assert(p+q+r+s+delta == c.Target)
}
