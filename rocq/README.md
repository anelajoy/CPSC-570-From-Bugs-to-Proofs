# Rocq Tutorials

These tutorials live at `CPSC-570-From-Bugs-to-Proofs/rocq`.

## Files

- `tutorial_01_basics_love_01_04.v` introduces Rocq in parallel with Lean LoVe chapters 1-4: types, terms, inductive programs, backward proofs, and forward proofs.
- `tutorial_02_extraction_haskell.v` introduces program extraction to Haskell using a small verified checkout program.
- `hw_extraction_haskell.v` is a three-part homework extending the extraction tutorial with list definitions, induction proofs, and Haskell extraction.

## Running

With a current Rocq installation:

```sh
rocq compile tutorial_01_basics_love_01_04.v
rocq compile tutorial_02_extraction_haskell.v
rocq compile hw_extraction_haskell.v
```

With older Coq command names:

```sh
coqc tutorial_01_basics_love_01_04.v
coqc tutorial_02_extraction_haskell.v
coqc hw_extraction_haskell.v
```

Compiling the extraction tutorial writes `Tutorial02Extraction.hs`.
Compiling the extraction homework writes `HomeworkExtraction.hs`.
