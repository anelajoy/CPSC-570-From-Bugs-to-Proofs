# Rocq Tutorials

These tutorials live at `CPSC-570-From-Bugs-to-Proofs/rocq`.

## Files

- `tutorial_01_basics_love_01_04.v` introduces Rocq in parallel with Lean LoVe chapters 1-4: types, terms, inductive programs, backward proofs, and forward proofs.
- `tutorial_02_extraction_haskell.v` introduces program extraction to Haskell using a small verified checkout program.
- `hw_extraction_haskell.v` is a three-part homework extending the extraction tutorial with list definitions, induction proofs, and Haskell extraction.

## Running

With a current Rocq installation:

```sh
rocq compile tutorial_01_basics_love_01_04.v -output-directory .
rocq compile tutorial_02_extraction_haskell.v -output-directory .
rocq compile hw_extraction_haskell.v -output-directory .
```

With older Coq command names:

```sh
coqc tutorial_01_basics_love_01_04.v -output-directory .
coqc tutorial_02_extraction_haskell.v -output-directory .
coqc hw_extraction_haskell.v -output-directory .
```

Compiling the extraction tutorial writes `TutorialExtraction.hs`.
Compiling the extraction homework writes `HomeworkExtraction.hs`.
