# lio-example

A small Haskell project demonstrating the [LIO](https://hackage.haskell.org/package/lio)
(Labeled IO) information-flow control library, using a two-point security
lattice (`Low ⊑ High`) and the `toLabeled` combinator.

## What it demonstrates

- A custom `Label` instance, `HL = Low | High` — the classic two-point lattice
  (`src/HighLow.hs`).
- `toLabeled`: computing over a secret (`High`) value inside a delimited scope
  whose result is sealed into a `Labeled`, **without** raising the outer
  computation's current ("floating") label (`double` in `src/HighLowExample.hs`).
- Dispatching on the *label* of a value (via `labelOf`, which does not observe
  the contents and so does not taint the current label): `Low` inputs are
  doubled, `High` inputs are replaced by a default (`testDispatch` / `applyList`).
- Inspecting labeled results from trusted code with `showTCB` (`app/Main.hs`).

## A note on the LIO version

`toLabeled`/`toLabeledP` were **removed from upstream LIO in 0.9.0.0** (they are
susceptible to a termination covert channel; the modern replacements are
`lFork`/`lWait` in `LIO.Concurrent`). The most recent release that still
provides `toLabeled` is `lio-0.1.3`.

Because this example is specifically about `toLabeled`, the relevant core of
`lio-0.1.3` is **vendored** under [`vendor/lio/`](vendor/lio) and ported to
build on GHC 9.12 / `base` 4.21. Only the modules needed for the labeled-IO
monad are kept (`LIO`, `LIO.Safe`, `LIO.TCB`, `LIO.MonadCatch`, `LIO.MonadLIO`);
the `LIO.FS`, `LIO.Handle`, `LIO.DCLabel`, `LIO.LIORef` and `LIO.Concurrent`
modules (which depended on `cereal <0.4`, `SHA`, `unix`, `old-time`) are omitted.
The vendored package is wired into the build by [`cabal.project`](cabal.project).

## Prerequisites

- GHC 9.12.x and `cabal-install` 3.x (e.g. via [ghcup](https://www.haskell.org/ghcup/)).
  Developed and tested with GHC 9.12.2 and cabal 3.16.

No network access to Hackage is needed for the vendored `lio`; `cabal` builds it
from the local `vendor/lio` source.

## Build

```sh
cabal build all
```

## Run

```sh
cabal run exe:lio-example
```

The `exe:` qualifier disambiguates the executable from the library (both are
named `lio-example`). Add `-v0` to hide cabal's build chatter and show only the
program output:

```sh
cabal run -v0 exe:lio-example
```

### Expected output

`Main` builds the labeled input list `[42 Low, 100 High, 11 Low, 55 Low, 77 High]`,
runs `applyList` over it, and prints each result as `value {label}`:

```
applyList results (value {label}):
  84 {Low}      -- 42 Low  → doubled
  0 {High}      -- 100 High → replaced by defaultVal
  22 {Low}      -- 11 Low  → doubled
  110 {Low}     -- 55 Low  → doubled
  0 {High}      -- 77 High → replaced by defaultVal
```

## Layout

- `src/HighLow.hs` — the `HL` two-point lattice (`Label` instance), the trivial
  `NoPriv` privilege, and the `runHL`/`evalHL` runners.
- `src/HighLowExample.hs` — `double` (uses `toLabeled`), `defaultVal`,
  `testDispatch`, and `applyList`.
- `app/Main.hs` — executable entry point: builds the labeled inputs, runs
  `applyList`, and prints the results.
- `vendor/lio/` — vendored, ported core of `lio-0.1.3`.
- `cabal.project` — includes both the local package and `vendor/lio`.
- `lio-example.cabal` — package description.
```
