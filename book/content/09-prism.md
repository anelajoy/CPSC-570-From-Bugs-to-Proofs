# Probabilistic model checking with PRISM

```{note}
**Chapter roles (Spring 2026)**  
Author: Anela Quiroz · Reviewer: Kalin Richardson  
See [Chapter assignments](0-chapter-assignments.md).
```

This chapter introduces **PRISM** for modeling and analyzing systems with probabilistic or stochastic behavior.

## Goals

- Contrast discrete-time and continuous-time Markov models at a high level.
- Present a small PRISM model with a quantitative property (reachability reward, steady-state, etc.).
- Explore a further aspect depending on your interest.
- Link to the PRISM manual, case studies, and benchmark suites.

## Draft

## 1. Idea

Probabilistic model checking is a formal verification technique for establishing the correctness, performance, and reliablility of systems that exhibit stochastic behavior. A precise mathematical model of a real-life system is constructed first, then formal specifications of properties are automatically analyzed against it. The exploration is exhaustive and combines graph-theoretic algorithms with numerical methods. 

Unlike classical model checking, which asks *"can this bad state be reached?"*, probabilistic model checking asks:

- *With what **probability** does an attack succeed?*
- *What is the **expected number of steps** to crack a PIN?*
- *What is the **optimal strategy** for an adversary — or a defender?*

PRISM has been applied across many domains, inculding communication and multimedia protocols, randomized distributed algorithms, security protocols, and biological systems. 

The case study in this chapter, PIN cracking in banking ATM netowrks, illustrates how PRISM handles a real-world security scenario using Markov Decision Proccesses (MDPs)

## 2. Basic Theory 

There are different types of probabilistic models PRISM can build and analyze:

| Model | Time       | Nondeterminism    | Use Case                              |
|-------|------------|-------------------|---------------------------------------|
| DTMC  | Discrete   | No                | Randomized protocols, games           |
| CTMC  | Continuous | No                | Performance, reliability              |
| MDP   | Discrete   | Yes               | Concurrent or adversarial systems     |
| PTA   | Continuous | Yes               | Real-time systems with clocks         |
| POMDP | Discrete   | Yes (partial obs) | Planning under uncertainty            |
| POPTA | Continuous | Yes (partial obs) | Real-time systems with hidden state   |

### 2.1 Discrete-Time vs. Continuous-Time Markov Models 

**Discrete-Time Markov Chains (DTMC)

**Continuous-Time Markov Chains (CTMC)

### 2.2 Property Specification

### 2.3 The PRISM Language

## 3. Case Study: PIN Cracking Schemes

## 4. History

## 5. PRISM Resources
- [PRISM Manual] (https://www.prismmodelchecker.org/manual/)
- [PRISM Case Studies] (https://www.prismmodelchecker.org/casestudies/index.php)
- [PRISM Benchmark Suites] (https://www.prismmodelchecker.org/benchmarks/)

## 6. References 


*(Replace this section with your exposition, examples, and references.)*
