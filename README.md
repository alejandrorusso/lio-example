# lio-example

A minimal Haskell project demonstrating the [LIO](https://hackage.haskell.org/package/lio)
(Labeled IO) information-flow control library with DCLabels.

## Build

```
cabal build
```

## Run

```
cabal run lio-example
```

## Layout

- `src/Example.hs` — library module with a small `DC` computation that labels
  two integers, unlabels them, and observes the resulting current label.
- `app/Main.hs` — executable entry point that runs the example.
- `lio-example.cabal` — package description.
