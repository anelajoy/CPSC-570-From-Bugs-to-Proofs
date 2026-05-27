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

### 2.1 Discrete-Time Markov Chains (DTMCs)

A **Discrete-Time Markov Chain (DTMC)** model a system that transitions between states at each step, with each transition governed by a fixed probability. Formally, a DTMC is a tuple $(S, s_0, P, L)$ where:

- $S$ is a finite set of states,
- $s_0 \in S$ is the initial state,
- $P : S \times S \to [0,1]$ is a transition probability matrix, where $\sum_{s' \in S} P(s, s') = 1$ for all $s$,
- $L : S \to 2^{AP}$ is a labeling function over atomic propositions.

The key property is the **Markov property**: the probability of transitioning to the next state depends only on the current state, not on any histroy of previous states. This memoryless makes DTMCs tractable for automated analysis.

A simple example: a cluent repeatedly attemps to send a message. At each step, transmission succeeds with probability $p$ and fails with probability $1 - p$. This gives a two-state DTMC with self-loop on failure and an absorbing accepting state on success. The expected number of attempts is $1/p$, which PRISM can compute exactly.

### 2.2 Continuous-Time Markov Chains (CTMCs)

A **Continuous-Time Markov Chain (CTMC)** extends the DTMC idea to setting where transitions do not happen at uniform discrete ticks, but instead occur after exponentially disrupted delay. Each transition from state $s$ to state $s'$ is labeled with a **rate** $\lambda_{s,s'} > 0$. The time spent in state $s$ before any transition fires is exponenially distributed with rate $\sum_{s'} \lambda_{s,s'}$.

CTMCs are the powerhouse model for performance analysis and reliability engineering:

- *How long does the server stay available before a failure?*
- *What is the stead-state probability of the netowrk being overloaded?*
- *What fraction of time is a component in a degraded state?*

PRISM analyzes CTMCs using **Continuous Stochastic Logic (CSL)** which extends PCTL with time-bounded reachability and steady-state operators appropriate for continuous time.

### 2.3 Markov Decision Processes (MDPs)

When a system invovles both probabilisitc choices **and** nondeterministic choices:

For example, an adversary who picks the best possible attack. A plain Markov chain is insufficient. A **Markov Decision Process** augments a STMC with nondeterminism: in each state, an agent (scheduler, adversary, or protocol participant) chooses and action, and that action triggers a probability distribution over successor states.

MDPs allow PRISM to answer questions of the form

- *What is the **maximum** probability of reaching a failure state, over all possible adversary strategies?*
- *What is the **minimum** expected number of steps to complete, regardless of environment behavior?*

PRISM computes these bounds using value iteration and policy iteration over the MDP, returning both the optimal value and the optimal policy (stratefy) that achieves it.

### 2.4 Property Specification

PRISM uses a unified property specification language that incorporates several probabilistic temporal logics, most importantly:

- **PCTL** (Probabilistic Computation Tree Logic) - for DTMCs and MDPs
- **CSL** (Continuous Stochastic Logic) - for CTMCs
- **LTL / PCTL\*** - for more expressive path properties

The central operator is the **P operator**:

```
P bound [ path_proberty ]
```

where 'bound' is a comparison like `>=0.99` or `<=0.01`, and `path_property` is a temporal formula over the model's states. For example:

```
// Is the probability of eventually cracking the PIN at least 0.8?
Pmax>=0.8 [ F pin_cracked ]

// What is the exact maximum probability of cracking within 50 steps?
Pmax=? [ F<=50 pin_cracked ]
```
The **R operator** handles *reward* (or cost) based properties, allowing PRISM to compute expected cumulative costs or expected time:

```
//What is the expected number of queries until the PIN is revealed?
Rmin=? [ F pin_cracked ]
```

The **S operator** computes steady-state probabilities for CTMSs:

```
//In the long run, is the probability of server overlaod below 1%?
S<=0.01 [ overloaded ]
```

PRISM accepts both *verification* queries (does the model satisfy this bound?) and *quantitative* queries (what is the actual value?). The quantitative form uses `=?` in place of a comparison bound and is often the more informative choice. 

--- 

## 3 The PRISM Language

PRISM models are written in a **reactive modules** style: the system is broken into a set of synchronizing modules, each owning a set of typed variables, and behavior is described by guarded commands.

### 3.1 Modules and Variables

```prism
mdp

module Attacker
    guess : [0...9] init 0; // the attacker's current PIN guess
    done : bool init false;

    // Attacker nondeterministically chooses a digit to try
    [] !done -> (guess'=0);
    [] !done -> (guess'=1);
    // ... (commands for digits 2-9 omitted for brevity)
endmodule
```

Each line inside the module is a **command** of the form:

```
[action] guard -> prob_update;
```

- The optional `[action]` label enables synchronization between modeules.
- The `guard` is a Boolean expression over the modules's variables.
- The `prob_update` is a probabilistic update: `p1:(updates) + p2:(updates) + ...`, where the probabilities sum to 1.

### 3.2 A minimal DTMC Example: Randomized Self-Stabilization

The follwoing model encodes a simple randommized protocol where a node probabilistically flips its state until the system stabilizes:

```prism
dtmc

module Node 
    s : [0..2] init 0;
    // s=0: unstable, s=1: stabilizing, s=2: stable

    [] s=0 -> 0.5:(s'=1) + 0.5:(s'=0);
    [] s=1 -> 0.8:(s'=2) + 0.2:(s'=0);
    [] s=2 -> (s'=2);
endmodule

rewards "steps"
    s<2 : 1;
endrewards
```

With this model, we can ask:

```
// Expected steps to reach stable state
R{"steps"}=? [ F s=2 ]
```

### 3.3 Constants, Formulas, and Labels

PRISM provides several mechanisms to keep models manageable:

- **Constants** (`const int N = 4;`) for parameterized models
- **Formulas** (`formula active = (s>0 & !done);`) for derived Boolean expressions
- **Labels** (`label "success" = (s=2);`) for naming sets of states to reference in properties

```prism
const int PIN_LENGTH = 4;
const int MAX_GUESSES = 3;

formula locked = (attemps >= MAX_GUESSES);
label "cracked" = (pin_found = true);
label "locked_out" = locked;
```

---

## 4. Case Study: PIN Cracking Schemes

This case study is drawn from real-world research on the security of ATM banking networks, contributed to the PRISM case study library by Graham Steel. The full model files are available at the [PRISM PIN Cracking case study page](https://www.prismmodelchecker.org/casestudies/pincracking.php).

### 4.1 Background: ATM Netowrks and HSMs

Suppose a customer banks in the UK and uses their card at an ATM in Germany. The types PIN must travel encrypted across the international network to reach the issuing bank for authorization. Because different netowrk nodes use differnt encryption keys, the PIN is decrypted and re-encrypted at each intermediate node.

Exposing a PIN as plaintext in the memory of an ordinaty computer is considered an unacceptable security risk. All PIN processing therefore takes place inside **Hardware Security Modeules (HSMs)**. They are physically tamper-proof devices with a shielded enclosure housing a CPU, a dedicated cryptoprocessor, and a small amount of memory. If an intruder attempts to open the casing or inserts probes, the device auto-erases its memory in nanoseconds. The IBM 4758 is one well-known example.

The HSM exposes a strictly controlled API whose goal is to prevent even corrupt bank insiders from learning customer PINs. However, in recent research, it has shown that the API itself can be turned against its purpose.

### 4.2 PIN Block Formats

To be encrypted by algorithms such as 3DES, a PIN must first be packed into a 64-bit **PIN block**. Different banks use differnt formats.

**VISA-3 format** (for a 4-digit PIN):

```
P1 P2 P3 P4 F F F F F F F F F F F F
```

Each character is a 4-bit nybble. `P1`-`P4` are the PIN digits and `F` is the hex value F. A drawback of this format is that two customers with the same PIN produce the same encrypted block under the same key.

**ISO-0 format** (from ISO standard 9564) address this by XORing the PIN block against the customer's account number:

```
B1 = 0  4  P1 P2 P3 P4 F  F  F  F  F  F  F  F  F  F
B2 = 0  0  0  0  A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12
PIN Block = B1 XOR B2
```

The leading `0` in `B1` marks the format; `4` indicated PIN length. `A1`-`A12` are the 12 digits of the customers Personal Account Number (PAN). Two customers with the same PIN now produce different encrypted blcoked, since their PANs are different.

### 4.3 The Reformatting Attack
### 4.4 AnaBlock and the MDP Model
### 4.5 The PRISM Model

```prism
// Model for PIN Block attack analysis
// Auto generated by AnaBlock
// Author G. Steel, Aug 2005
 
mdp
 
module M1
 
  P3_could_be0 : bool init true;
  P3_could_be1 : bool init true;
  P3_could_be2 : bool init true;
  P3_could_be3 : bool init true;
  P3_could_be4 : bool init true;
  P3_could_be5 : bool init true;
  P3_could_be6 : bool init true;
  P3_could_be7 : bool init true;
  P3_could_be8 : bool init true;
  P3_could_be9 : bool init true;
  P3_guessed   : bool init false;
 
  PIN_Digit3 : [0..10] init 10;   // 10 = digit value unknown
  Digit_Count : [1..5] init 3;
 
  // Attacker issues xor_in(2): XOR the PAN digit with 2
  // If the true digit is 0,1,2,...,7 -> error (2/10 chance); else pass (8/10)
  [] !P3_guessed & Digit_Count=3 &
     P3_could_be0 & P3_could_be1 & P3_could_be2 & P3_could_be3 &
     P3_could_be4 & P3_could_be5 & P3_could_be6 & P3_could_be7 &
     P3_could_be8 & P3_could_be9
  ->
  // error case: digits 0–7 produce a hex result, so 2 of 10 pass the check
  2/10 : (Digit_Count'=4) &
         (P3_could_be0'=false) & (P3_could_be1'=false) &
         (P3_could_be2'=false) & (P3_could_be3'=false) &
         (P3_could_be4'=false) & (P3_could_be5'=false) &
         (P3_could_be6'=false) & (P3_could_be7'=false)
  +
  // pass case: digits 8,9 survive; 8 of 10 give a decimal result
  8/10 : (Digit_Count'=3) &
         (P3_could_be8'=false) & (P3_could_be9'=false);
 
  // Attacker issues xor_in(8): XOR the PAN digit with 8
  [] !P3_guessed & Digit_Count=3 &
     P3_could_be0 & P3_could_be1 & P3_could_be2 & P3_could_be3 &
     P3_could_be4 & P3_could_be5 & P3_could_be6 & P3_could_be7 &
     P3_could_be8 & P3_could_be9
  ->
  6/10 : (Digit_Count'=3) &
         (P3_could_be0'=false) & (P3_could_be1'=false) &
         (P3_could_be8'=false) & (P3_could_be9'=false)
  +
  4/10 : (Digit_Count'=3) &
         (P3_could_be2'=false) & (P3_could_be3'=false) &
         (P3_could_be4'=false) & (P3_could_be5'=false) &
         (P3_could_be6'=false) & (P3_could_be7'=false);
 
  // Attacker issues xor_in(10): XOR the PAN digit with 10
  [] !P3_guessed & Digit_Count=3 &
     P3_could_be0 & P3_could_be1 & P3_could_be2 & P3_could_be3 &
     P3_could_be4 & P3_could_be5 & P3_could_be6 & P3_could_be7 &
     P3_could_be8 & P3_could_be9
  ->
  6/10 : (Digit_Count'=3) &
         (P3_could_be2'=false) & (P3_could_be3'=false) &
         (P3_could_be8'=false) & (P3_could_be9'=false)
  +
  4/10 : (Digit_Count'=3) &
         (P3_could_be0'=false) & (P3_could_be1'=false) &
         (P3_could_be4'=false) & (P3_could_be5'=false) &
         (P3_could_be6'=false) & (P3_could_be7'=false);
 
endmodule
 
rewards
  [] true : 1;
endrewards
```

### 4.6 Properties and Analysis

## 5. History

## 6. PRISM Resources
- [PRISM Manual] (https://www.prismmodelchecker.org/manual/)
- [PRISM Case Studies] (https://www.prismmodelchecker.org/casestudies/index.php)
- [PRISM Benchmark Suites] (https://www.prismmodelchecker.org/benchmarks/)

## 6. References 


*(Replace this section with your exposition, examples, and references.)*
