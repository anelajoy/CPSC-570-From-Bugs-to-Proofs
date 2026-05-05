# Program extraction with Rocq

```{note}
**Chapter roles (Spring 2026)**  
Author: Nayeli Castro · Reviewer: Khoa Nguyen  
See [Chapter assignments](0-chapter-assignments.md).
```

This chapter introduces **Rocq** (formerly known as Coq) with emphasis on constructive proofs and extracting runnable programs.

## Goals

- Motivate program extraction: how a constructive proof that an object *exists* can be turned into executable code (e.g. via Rocq’s extraction to OCaml or Haskell), and why that matters for building correct-by-construction components rather than treating the prover as a black box.
- Show a minimal development ending in extracted code or a verified function.
- Explore a further aspect depending on your interest.
- Link to Rocq / Coq documentation and community-maintained learning paths.

## Draft

## Background

**Rocq** (formerly known as Coq) is a program developed to provide interactive and computational proof assistance to users developing their own theorems. Rocq works as an interactive theorem prover through machine-assisted and machine-augmented proof checking, and it is often used by developers to find formal proofs through proof automation, express and check mathematical insertions, and perform program extraction through proving the existence of a mathematical object in its formal specification. As a program that has existed and been used since 1989, Rocq has established itself as an important computational tool available to developers and mathematicians that are in need of proving complex theorems or extracting code that may be difficult or impossible through human-performed techniques.[^1]

## Basic Theory

Rocq differs from other unique programming langauges as it is mainly used for proof assistance. Due to that, its language is formatted in such a way that it would make it easier to write theorems. The Rocq Language itself contains features such as implicit arguments and notations, which are then translated into the the core language, **CoC** , into a definition that the **Rocq Kernel** can read and interpret. CoC, or Calculus of Constructions, is a type theory that may serve as both a programming language and mathematical framework. It has the ability to define functions from terms to terms, terms to types, types to types, and types to terms. CoC was developed alongside Rocq and became the main theory that the interactive theorem prover follows.[^2][^3]

The Rocq Kernel itself is the most important part of Rocq, as it serves as being the smaller critical component of the entire system that focuses on checking important CoC concepts such as **terms** and **types** that are written within the program.[^2]

**Terms** are the basic expressions used in Rocq. They may be used to represent proofs, mathematical expressions, propositions, and even executable programs and program types. Every term needs to be associated wih a type. **Types** in Rocq represent logical propositions as well as the program that is the proof of those propositions, therefore making all types be terms, but not all terms are types. The Rocq Kernel checks whether a term has an associated type and if that type follows a certain *typing rule*.[^4]

**Terms** are declared using commands such as *Definition*, *FixPoint*, *Theorem*, and *Compute*. 

- *Definition* gives a name to a value, function, or proof term. They are used for *non-recursive programs*.

```rocq
(* Definitions, as well as other terms, follow this basic syntax: *)
Definition name : type := body.

(* An example of a Definition *)
Definition reference_add_two (n : nat) : nat :=
  n + 2.
```

## References

[^1]: Introduction and Contents from The Rocq Prover Reference Manual. (Link)[https://rocq-prover.org/doc/V9.2.0/refman/index.html]

[^2]: Core Language from The Rocq Prover Reference Manual. (Link)[https://rocq-prover.org/doc/V9.2.0/refman/language/core/index.html]

[^3]: Calculus of Constructions Wikipedia Page. (Link)[https://en.wikipedia.org/wiki/Calculus_of_constructions]

[^4]: Basic Notions and Conventions from The Rocq Prover Reference Manual. (Link)[https://rocq-prover.org/doc/V9.2.0/refman/language/core/basic.html#term-term]

[^5]: From Bugs to Proofs tutorial_01_basics_love_01_04.v Github file. (Link)[https://github.com/LEAP-at-Chapman/CPSC-570-From-Bugs-to-Proofs/blob/main/rocq/tutorial_01_basics_love_01_04.v]
