# Relational modeling with Alloy

```{note}
**Chapter roles (Spring 2026)**  
Author: Jake Triester · Reviewer: Michael Smith  
See [Chapter assignments](0-chapter-assignments.md).
```

This chapter introduces **Alloy** for lightweight formal modeling of structures and behaviors as relations.

## Goals

- Explain Alloy’s relational style.
- Present a small model, instance visualization, and a checked assertion or property.
- Explore a further aspect depending on your interest.
- Point readers to the Alloy Analyzer documentation and tutorials.

## Draft

## Intro

Alloy is a formal specification language made for describing software structures and behavior. It was created at MIT by Daniel Jackson in the late 1990's. Alloy is not a programming language, i.e. you don't use it to build running software. Instead, you use it to describe the structure and rules of a system, and then use the **Alloy Analyzer** tool to find examples, counterexamples, and/or logical contradictions in your design.

## Alloy's Relational Style

While most programming languages make you think in terms of objects and variables, Alloy makes you think in terms of relations. 

Everything in Alloy is a relation. It doesn't matter if it is one value (a relation with one element), two values (a binary relation), or many many more. Alloy relies on relations to be able to solve many problems.

### Signatures

The basic building block in Alloy is a **signature** (`sig`), which declares a set of featureless objects to exist in your model (called atoms).

For example

```alloy
sig Person{}
sig File{}
```

What this says it that in our model, there exists a kind of thing (object) called Person, and something else called File. When the Alloy Analyzer is used, it will create concrete atoms (Person0, Person1, File0, etc.) when it builds an instance of the model.

### Fields

Inside of a signature, you can declare fields that define relations between different atoms; there are a few keywords that let you constrain how the relation works:

| Keyword | Meaning              |
|---------|----------------------|
| `one`   | Exactly one          |
| `lone`  | Zero or one          |
| `some`  | One or more          |
| `set`   | Zero or more (default) |

In our example, we can create a few fields in our `Person` signature like this:

```alloy
sig Person {
    owns: set File,
    manager: lone Person
}
```

Using the keywords, we can interpret these fields as meaning:
- Each Person owns a *set* of files (zero or more)
- Each Person has *at most one* manager (who is a Person)

Similar to object oriented programming, you can use the dot (`.`) operator to navigate relations. For example, `p.owns` gives you the set of all files owned by `Person p`. You can also use `Person.owns` to give the set of all files owned by any `Person`.

### Facts

Once you have defined the atoms in your model, and how they relate to each other, you need to state the rules. This is where a `fact` comes in. A `fact` is a constraint that must always be true in every instance.

Continuing our example:

```alloy
fact NoSelfManagement {
  no p: Person | p in p.manager
}

fact OwnershipIsExclusive {
  all f: File | lone owns.f
}
```

These facts tell us the following:
- No person can be their own manager
- Every file is owned by at most one person

To create these facts, you can think of it as a 3 step process:
1. Declare your variable (`no p: Person` or `all f: File`)
2. Write the `|` symbol
3. Write the property/condition about your variable (`p in p.manager` or `lone owns.f`)

### Predicates

A **predicate** (written as `pred`) is a named, reusable condiion. Predicaes do not necessarily contrain the model on their own, but can be invoked with the `run` command, or used inside other constraints.

For example:

```alloy 
pred HasNoManager[p: Person] {
  -- p has no manager (they're at the top of the hierarchy)
  no p.manager
}
```

This can be run with `run HasNoManager for 4 Person, 4 File`, and the Alloy Analyzer will show you a world where at least one person has no manager.

### Assertions

An **Assertion** (written as `assert`) states some properts that you believe must hold given your facts. Then, you can ask the Analyzer to try to find a counterexample that satisfies all facts, but violates the assertion.

For example:

```alloy
assert ManagerOwnsAtLeastOneFile {
  -- Every person who manages someone owns at least some file
  all p: Person | (some p.~manager) implies (some p.owns)
}

check ManagerOwnsAtLeastOneFile for 4
```

Firstly, a new symbol that we can see here is the `~` symbol in `~manager`, which means the *reverse* of the manager relation (people managed by `p`). When we run `check ManagerOwnsAtLeastOneFile for 4`, this means that we are asking the Analyzer to find a counterexample for up to 4 atoms per type. If it reports "No counterexample found", that is strong evidence that your assertion holds, but it is not necessarily proof. However, in our example, it **will** find a counterexample because there is no fact enforcing that a manager must own a file, proving that the assertion is false.

## A Small Full Model

Now that we understand all of the keywords and how to use them, here is an example of a realistic model, a file system with owners and read/write permissions:

```alloy
-- Signatures
sig Person {}

sig File {
  owner: one Person,
  readers: set Person,
  writers: set Person
}

-- Facts
fact WritersCanAlwaysRead {
  -- Anyone who can write to a file can also read it
  all f: File | f.writers in f.readers
}

fact OwnerHasWriteAccess {
  -- The owner of a file always has write access
  all f: File | f.owner in f.writers
}

-- Predicate: a scenario with at least one shared file
pred SharedFileExists {
  some f: File | #f.readers > 1
}

-- Assertion: owners always have read access (should follow from our facts)
assert OwnerCanAlwaysRead {
  all f: File | f.owner in f.readers
}

check OwnerCanAlwaysRead for 4

run SharedFileExists for 3 Person, 3 File
```

When you run the line `check OwnerCanAlwaysRead for 4`, the Analyzer will find no counterexample because the `OwnerHasWriteAccess` fact guarantees that `f.owner in f.writers`, and the `WritersCanAlwaysRead` fact guarantees that `f.writers in f.readers`, so by transitivity, the owner is always a reader. The Analyzer went through this chain of reasoning automatically and confirmed that there was no counterexample.

When you run the line `run SharedFileExists for 3 Person, 3 File`, the Alloy Analyzer will display an instance visualization. This will look like a graph with some concrete atoms and some arrows showing their relations. Since a graph has been made, you know that there exists at least one scenario that satisfies your model and predicate, and it gives you an intuitive picture of what this scenario looks like.



