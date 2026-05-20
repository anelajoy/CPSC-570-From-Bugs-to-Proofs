# Program analysis in Dafny

```{note}
**Chapter roles (Spring 2026)**  
Author: Khoa Nguyen · Reviewer: Kaye Galang  
See [Chapter assignments](0-chapter-assignments.md).
```

This chapter introduces **Dafny** for specifying and verifying imperative and functional programs with automated theorem proving.

## Introduction

**Dafny** is a "verification-aware programming language". "Verification-aware" means that the language is designed to incorporate formal verfication directly into their development and runtime operations. This is particularly useful when a system is needed to be "provably correct", i.e. mathematically proven to be correct, and not just "probably correct". **Dafny** natively support recodring specifications and integrates static program verfifier. It empowers developers to write provably correct code with respect to their specifications through combining sophisticated automated reasoning with familiar programming idioms and tools. It compiles to popular coding languages such as C#, Java, JavaScript, Go, and Python, allowing integration with existing workflows [1].

**Dafny** was created by K. Rustan M. Leino at Microsoft Research, building on his earlier work on ESC/Modula-3, ESC/Java, and Spec#. Leino has since moved to Amazon Web Services, where his team applies Dafny to security-critical infrastructure, including the AWS Encryption SDK and the Cedar policy engine [2]-[3].

Under the hood, Dafny translates programs to the Boogie intermediate verification language and then dispatches proof obligations to the Z3 SMT (Satisfiability Modulo Theories) solver. If Z3 can construct a proof, the program is verified. If not, Dafny reports a counterexample directly in the editor, enabling immediate feedback much like a type-checker does today [2],[4].

### Why Use Dafny?

#### From Testing to Proof
Conventional testing checks behaviour on a finite set of inputs. Formal verification proves behaviour over all possible inputs. Dafny makes rigorous verification an integral part of development, thus reducing costly late-stage bugs that testing alone may miss.

#### Integrated with Developer-Friendly Workflow

Unlike standalone theorem provers such as Coq or Isabelle/HOL, Dafny embeds specifications directly into the source code. The VSCode extension applies the verifier continuously in the background, flagging problems as the programmer types. Specifications and ghost constructs are stripped out at compile time, so they carry zero runtime overhead.

#### Compile to Real Languages

Because Dafny compiles to C#, Java, JavaScript, Go, and Python, teams do not need to abandon their existing technology stacks. The verified Dafny source becomes a trustworthy blueprint whose compiled output can be dropped into production systems.

## Hoare-style Reasoning

Hoare logic, or Floyd-Hoare Logic or Hoare-rules, serves as the foundation for **Dafny** logic. The central idea was the Hoare Triple:

``` { P } C { Q } ```

P is the precondition, describing the state of the world. C is the command to be executed. Q is the postcondition, describing the state of the world after command is executed. A Hoare Triple is valid if P holds before C runs and C terminates, then Q is guaranteed to hold after C.
Hoare logic is essential for mathematically proving program correctness, ensuring that if prerequisites are met, a program's execution produces the desired results. **Dafny** integrates Hoare logic directly in its syntax. Under the hood, **Dafny** translates Hoare-style specifications into Boogie's intermidiate language, then hands the proof obligations to the Z3 SMT solver. 

The preconditions are the ``requires`` clauses, using the ``requires`` keyword. A ``requires`` clause states what must be true for a method to be called correctly. If a caller violates the precondition, Dafny will report a verfication error at the call site, not inside the method. This seperates caller obligations from implementer guarantees. The commands exist within the curly brackets, indicating what the method does, similar to other programming languages that also utilize curly brackets to indicate code blocks. 
```
  method Divide(a: int, b: int) returns (result: int)
    requires b != 0
  {
    result := a / b;
  }
```
It is never correct to divide a number by zero (0), or rather the answer is undefined if a division by zero occured. In the above example, since we are dividing ``a`` by ``b``, we must require that ``b`` cannot be zero (0).

The postconditions are indicated by the ``ensures`` keyword. An ``ensures`` clause states what a method promises to deliver. **Dafny** proves that every return path of the method satisfies the postcondition, given the preconditions hold. 
```
  method Abs(x: int) returns (y: int)
    ensures y >= 0
    ensures (x >= 0 ==> y == x) && (x < 0 ==> y == -x)
  {
    if x < 0 { y := -x; } else { y := x; }
  }
```
In the case of absolute value, any number can satisfy the operation or any number can have an absolute value, so preconditions are not required. However, we must ensures that if the input is positive, the output must be equal to the input and if the input is negative, the output must be equal to the opposite of the input. This way, we can guarantee that the method is mathematically correct. 

**Dafny** supports proofs of imperative programs based on the ideas of Hoare logic, where loop invariants and loop variants are supplied via invariant and decreases clauses respectively. An invariant, or loop invariant, is a condition that is always true before and after a loop iteration is executed. The treatment of loop invariants in **Dafny** differs subtly from traditional Hoare logic. Variable mutated in a loop having any prior facts about them are discarded at loop entry, so all necessary information must be written explicity in the invariant, using the ``invariant`` keyword. An invariant must satisfy three properties: 
- It is implied by the precondition.
- It is presevered by each iteration of the loop body.
- Together with the negated loop condition, it implies the postcondition.

To prove total correctness (the program terminates and is correct), Dafny requires a ``decreases`` clause, using the ``decreases`` keyword. This expression is bounded below and strictly decreases with each loop iteration or recursive call. This prevents infinite loops by construction. **Dafny** can often infer simple decreases clauses automatically.

## Walkthrough with Binary Search

Binary search is one of computer science's most celebrated algorithms, one where many programmers leanr in their Algorithm and Data Structures classes, yet it is notorious for hiding subtle bugs. **Dafny** eliminates an entire class of these bugs by using mathematical (unbounded) integers, and its verifier catches logical errors that testing rarely finds.

### Specification
Before writing a single line of implementation, we state what binary search should do:
- Input (Precondition): a sorted sequence of integers and a key to search for.
- Output (Postcondition): an index in the sequence, or -1 if the key is not present.
- Correctness: if a valid index is returned, the element at that index equals the key. If -1 is returned, the key is absent from the entire sequence.

In **Dafny**, the precondition and postcondition capture these requirements precisely:
```
  predicate Sorted(q: seq<int>)
  {
    forall i, j :: 0 <= i < j < |q| ==> q[i] <= q[j]
  }
```
A predicate is a function that returns a boolean. In this example, it is checking that every elements in the list or sequence passed into the function is sorted in ascending order.  

```
  method BinarySearch(q: seq<int>, key: int) returns (index: int)
    requires Sorted(q)
    ensures index == -1 ==> forall i :: 0 <= i < |q| ==> q[i] != key
    ensures index != -1 ==> 0 <= index < |q| && q[index] == key
```

### Implementation

The method ``BinarySearch`` takes 2 arguments, a sequence of integer and a key to search.

The iterative body maintains two pointers, ``lo`` and ``hi``, narrowing the search window with each iteration:

```
method BinarySearch(q: seq<int>, key: int) returns (index: int)
  requires Sorted(q)
  ensures index == -1 ==> forall i :: 0 <= i < |q| ==> q[i] != key
  ensures index != -1 ==> 0 <= index < |q| && q[index] == key
{
  var lo := 0;
  var hi := |q|;
  index := -1;
  while lo < hi
    invariant 0 <= lo <= hi <= |q|
    invariant forall i :: 0 <= i < lo ==> q[i] < key
    invariant forall i :: 0 <= i < |q| ==> q[i] > key
    decreases hi - lo
  {
    var mid := (lo + hi) / 2;
    if q[mid] == key {
      index := mid;
      return;
    } else if q[mid] < key {
      lo := mid + 1;
    } else {
      hi := mid;
    }
  }
}
```

### Invariants and Decreases

Each of the three loop invariants plays a distinct role:

```
invariant 0 <= lo <= hi <= |q|
```
This invariant guarantees that ``lo`` and ``hi`` never escape the valid index range. Without it, **Dafny** cannot prove that the midpoint computation and the array accesses are safe. It ensures that, before the loop, ``lo = 0`` and ``hi = |q|`` holds and is preserved because each branch either increases ``lo`` or decreases ``hi`` within the window.

```
invariant forall i :: 0 <= i < lo ==> q[i] < key
```
Everything to the left of ``lo`` has already been ruled out, i.e. strictly smaller than the key. Because the sequence is sorted, once we move ``lo`` past position ``mid``, every element before ``lo`` is known to be less than ``key``.

```
invariant forall i :: 0 <= i < |q| ==> q[i] > key
```
Symmetrically, everything at or beyond ``hi`` is strictly greater. When ``lo`` and ``hi`` converge, invariants 2 and 3 together state that the key cannot be anywhere in the sequence, justifying the return of -1.

```
decreases hi - lo
```
The quantity ``hi - lo`` is a non-negative integer (by invariant 1) that strictly decreases every iteration. If the ``key`` is not found, ``mid`` is strictly between ``lo`` and ``hi``, so advancing ``lo`` or retreating ``hi`` always shrinks the window by at least 1. **Dafny** verifies this automatically.

### A Note on Overflow 

A notorious real-world bug in many binary search implementation is integer overflow in computing the midpoint. In languages with bounded integers, ``(lo + hi) / 2`` can overflow when ``lo`` and ``hi`` are large. **Dafny** uses mathematical integers that never overflow, so this entire class of bugs is excluded by the language's type system. **Dafny** verfier verifies that ``(lo + hi) / 2`` is used correctly without any explicit annotation from the programmer.

### What Dafny Checks

When this method is submitted to **Dafny**, the verifier checks all of the following automatically:

- The precondition Sorted is satisfied at every call site.
- Each loop invariant holds before the loop.
- Each loop invariant is preserved by the loop body.
- The decreases clause is strictly decreased each iteration.
- Both postconditions hold when the method returns, for every possible return path.
- All array/sequence accesses are within bound.
If any check fails, **Dafny** returns a counterexample, i.e. a specific assignment of values that witnesses the failure, rather than just a generic error message.

## Exploration - Dafny and Game Development




## References
- [1] https://dafny.org/dafny
- [2] https://en.wikipedia.org/wiki/Dafny 
- [3] https://www.amazon.science/working-at-amazon/rustan-leino-provides-proof-that-software-is-bug-free
- [4] https://en.wikipedia.org/wiki/Hoare_logic
- [5] https://dafny.org/latest/OnlineTutorial/guide