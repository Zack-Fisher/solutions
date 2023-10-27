# the modification and analysis of binary data

## use xxd! it's good.

it also comes stock with a vim install.

xxd will prettyprint nicely to stdout all the stuff in your binary.

```bash
xxd -g 4 test_a.sasm.bin | grep a9
```

we can then grep that however we need.

## editing hex

if you try to look around for a good hex editor, you'll be disappointed
that there really are none, outside of disassemblers that come with
way more stuff than you usually need.

use [hexvi](https://github.com/rr-/hexvi).

it's dead simple to modify and add commands yourself. if the link goes down,
get in contact with me and i'll try to provide my personal fork.

it's simple, and it has all the bindings you might need.

trying to do the weird xxd shit in nvim itself is a recipe for disaster,
it just flat out doesn't work.
