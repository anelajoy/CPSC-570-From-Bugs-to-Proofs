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

## Basic Theory and Syntax Basics

Rocq differs from other unique programming langauges as it is mainly used for proof assistance. Due to that, its language is formatted in such a way that it would make it easier to write theorems. The Rocq Language itself contains features such as implicit arguments and notations, which are then translated into the the core language, **CoC** , into a definition that the **Rocq Kernel** can read and interpret. CoC, or Calculus of Constructions, is a type theory that may serve as both a programming language and mathematical framework. It has the ability to define functions from terms to terms, terms to types, types to types, and types to terms. CoC was developed alongside Rocq and became the main theory that the interactive theorem prover follows.[^2][^3]

The Rocq Kernel itself is the most important part of Rocq, as it serves as being the smaller critical component of the entire system that focuses on checking important CoC concepts such as **terms** and **types** that are written within the program.[^2]

**Terms** are the basic expressions used in Rocq. They may be used to represent proofs, mathematical expressions, propositions, and even executable programs and program types. Every term needs to be associated wih a type. **Types** in Rocq represent logical propositions as well as the program that is the proof of those propositions, therefore making all types be terms, but not all terms are types. The Rocq Kernel checks whether a term has an associated type and if that type follows a certain *typing rule*.[^4]

**Terms** are declared using commands such as *Definition*, *FixPoint*, *Theorem*, *Compute*, and *Check*.[^5]

- *Definition* gives a name to a value, function, or proof term. They are used for *non-recursive* function.

```rocq
(* Definitions, as well as other terms, follow this basic syntax:
Definition name : type := body.
*)

(* An example of a Definition *)
Definition reference_add_two (n : nat) : nat :=
  n + 2.
```

- *Fixpoint* gives a name to a *recursive* function. Recursive functions recurse within a subpart of their input due to recursive functions being structurally smaller. 

```rocq
(* Fixpoints follow this basic syntax: 
Fixpoint name (x : type) : result_type :=
      match x with
      | ...
      end.
*)

(* An example of a Fixpoint *)
Fixpoint reference_length {A : Type} (xs : list A) : nat :=
  match xs with
  | [] => 0
  | _ :: rest => S (reference_length rest)
  end.
```

- *Theorem* starts a proof obligation and contains a proposition that is proven within *Proof*, which makes Rocq go into Proof Mode, and *Qed*, which terminates Proof Mode. In Proof Mode and within the boundaries of *Proof* and *Qed*, *tactics* specify how to transform the current *proof state* (an unproven goal or proposition) in order eventually generate a complete proof. The list of tactics available in Rocq is found in the [Tactic Index](https://rocq-prover.org/doc/V9.2.0/refman/rocq-tacindex.html#tactic-index).

```rocq
(* Theorems follow this basic syntax:
Theorem name : proposition.
    Proof.
      ...
    Qed.
*)

(* An example of a Theorem *)
Theorem reference_add_two_zero :
    reference_add_two 0 = 2. (* The proposition we want to prove is that 'reference_add_two_zero' equals 2 when it takes in 0. *)
Proof. (* Begin the proof, go into Proof Mode *)
  reflexivity. (* The specified tactic method that will be used to reach the goal of the proposed theorem *)
Qed (* Terminate the proof, Exit Proof Mode *).
```

- *Compute* is used to evaluate an expression and is often used for checking the output of an expression for testing purposes. It is not a proof by itself.

```rocq
(* An example of how to use Compute *)
Compute reference_add_two 5.
Compute reference_length [true; false; true].
```

- *Check* is used to check the type or name of an expression. This term is often used to inspect what Rocq thinks the meaning or properties of an expression is.

```rocq
(* An example of how to use Check *)
Check reference_add_two.
Check reference_length.
Check reference_add_two_zero.
```

**Types** are used to construct logical foundations of mathematics by using foundations from *"type theory"* rather than the standard *"set theory"* due to Rocq's fundamental usage of CoC. Types may be seen as sets that contain terms, and a type that has at least one term is referred to an inhabited type. Types may also contain other types that apply to it. Due to the strict rule of terms needing an associated type, the Rocq Kernel always verifies that the rule is followed as well as making sure that the term and type are associated via one or several *typing rules*.[^4] 

**Typing rules** exist as a way to make terms follow *type discipline*, in which they then are verified within a *global environment* with a *local context*. 

## Introduction to Program Extraction with Rocq

TBA

## Theory and Action of Program Extraction

TBA

## Case Study

TBA

## References

[^1]: Introduction and Contents from The Rocq Prover Reference Manual. (Link)[https://rocq-prover.org/doc/V9.2.0/refman/index.html]

[^2]: Core Language from The Rocq Prover Reference Manual. (Link)[https://rocq-prover.org/doc/V9.2.0/refman/language/core/index.html]

[^3]: Calculus of Constructions Wikipedia Page. (Link)[https://en.wikipedia.org/wiki/Calculus_of_constructions]

[^4]: Basic Notions and Conventions from The Rocq Prover Reference Manual. (Link)[https://rocq-prover.org/doc/V9.2.0/refman/language/core/basic.html#term-term]

[^5]: From Bugs to Proofs tutorial_01_basics_love_01_04.v Github file. (Link)[https://github.com/LEAP-at-Chapman/CPSC-570-From-Bugs-to-Proofs/blob/main/rocq/tutorial_01_basics_love_01_04.v]
