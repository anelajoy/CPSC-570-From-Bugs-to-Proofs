# System specification with TLA+ and PlusCal

```{note}
**Chapter roles (Spring 2026)**  
Author: Jack de Bruyn · Reviewer: Nataniel Farzan  
See [Chapter assignments](0-chapter-assignments.md).
```

This chapter introduces **TLA+** and **PlusCal** for specifying and reasoning about concurrent and distributed systems.

## Goals

- Explain when TLA+ is an appropriate specification language.
- Walk through a small, runnable example (the Toolbox or command-line workflow).
- Explore a further aspect depending on your interest.
- Link to tutorials, video lectures, and the TLA+ community resources.


## Draft

## Intro

TLA+ is a specification language that is used for modeling systems and programs. TLA+ relies on temporal logic so it is especially useful for systems that are distributed or otherwise rely on concurrency. It exsists at a level of abstraction above the code of a program, so can be a bit challenging for traditionally trained engineers to get into. Using TLA+ is a lot like creating a blueprint for a given system.

TLA+ is best used when you are trying to design a system that is concurrent or otherwise relies on temporality. It can help you to specify, in formal logic rather than informal language, exactly what your system can and should do. From there you can utilize the model checking software TLC to determine whether your program has any logical errors before you've even written it. This will allow you to begin writing your code with a plan in mind that is guaranteed to be logically sound.

Pluscal is a specification language designed for detailing algorithms. It can be used as a more intuitive interface for TLA+ since it more closely resembles a traditional programming langauge and directly transpiles into TLA+. Pluscal is better for sequential algorithms specifically.

The following is a short Pluscal program that defines a one bit clock, taken from the [wikipedia](https://en.wikipedia.org/wiki/PlusCal) page on Pluscal.

```pluscal
-- fair algorithm OneBitClock {
  variable clock \in {0, 1};
  {
    while (TRUE) {
      if (clock = 0)
        clock := 1
      else 
        clock := 0    
    }
  }
}
```

## Example

The following is a Pluscal specification for a mutex lock. Mutex locks are a common structure in programming that can help prevent concurrency errors.

```pluscal
------------------------------ MODULE MutexLock ------------------------------
EXTENDS Naturals, Sequences, TLC

CONSTANT N \* Number of processes

ASSUME N \in Nat /\ N > 0

(*
--algorithm Mutex
variables
    lockOwner = 0,          \* 0 means unlocked, otherwise process id
    waiting = [i \in 1..N |-> FALSE],
    inCS = [i \in 1..N |-> FALSE],
    Proc \in 1..N;

\*process (Proc \in 1..N)
begin Loop:
    while TRUE do

Try:
        waiting[Proc] := TRUE;

Acquire:
        await lockOwner = 0;
        lockOwner := Proc;
        waiting[Proc] := FALSE;

Critical:
        inCS[Proc] := TRUE;

Exit:
        inCS[Proc] := FALSE;
        lockOwner := 0;

Remainder:
        skip;

    end while;
\*end process;
end algorithm;
*)

=============================================================================
```

This code can be copy and pasted into TLC or the TLA+ toolbox and then converted into TLA+ code.

Converting it to TLA+ should give you the following code:

```TLA+
VARIABLES lockOwner, waiting, inCS, Proc, pc

vars == << lockOwner, waiting, inCS, Proc, pc >>

Init == (* Global variables *)
        /\ lockOwner = 0
        /\ waiting = [i \in 1..N |-> FALSE]
        /\ inCS = [i \in 1..N |-> FALSE]
        /\ Proc \in 1..N
        /\ pc = "Loop"

Loop == /\ pc = "Loop"
        /\ pc' = "Try"
        /\ UNCHANGED << lockOwner, waiting, inCS, Proc >>

Try == /\ pc = "Try"
       /\ waiting' = [waiting EXCEPT ![Proc] = TRUE]
       /\ pc' = "Acquire"
       /\ UNCHANGED << lockOwner, inCS, Proc >>

Acquire == /\ pc = "Acquire"
           /\ lockOwner = 0
           /\ lockOwner' = Proc
           /\ waiting' = [waiting EXCEPT ![Proc] = FALSE]
           /\ pc' = "Critical"
           /\ UNCHANGED << inCS, Proc >>

Critical == /\ pc = "Critical"
            /\ inCS' = [inCS EXCEPT ![Proc] = TRUE]
            /\ pc' = "Exit"
            /\ UNCHANGED << lockOwner, waiting, Proc >>

Exit == /\ pc = "Exit"
        /\ inCS' = [inCS EXCEPT ![Proc] = FALSE]
        /\ lockOwner' = 0
        /\ pc' = "Remainder"
        /\ UNCHANGED << waiting, Proc >>

Remainder == /\ pc = "Remainder"
             /\ TRUE
             /\ pc' = "Loop"
             /\ UNCHANGED << lockOwner, waiting, inCS, Proc >>

Next == Loop \/ Try \/ Acquire \/ Critical \/ Exit \/ Remainder

Spec == Init /\ [][Next]_vars

```

From here, you can run the code and model the mutex lock. You should see that only one process will ever be in the critical zone at a time.

## Case Study

For a more in depth look at the real world applications of TLA+, there was a particularly stubborn bug in the glibc libary. The essence of the bug is that sometimes the function pthread_cond_signal() wouldn't do anything (1). This is bad because that funciton is used by threads to communicate with each other, so if a thread tries to call the function and it randomly fails, that could cause the whole program to lock up (1). This function is used near universally, many programming languages make use of this function via wrapper calls, so it was imperative that the source of this bug be found and dealt with (1). A workaround was quickly devised, but it required calling a function that was computationally expensive, so the need for a proper fix remained.

A man named Malte Skarupke took it upon himself to see if it was possible to find the source of this bug using TLA+. He firstly worked his way through the problem area of the glibc code, translating the sections he wanted to test into TLA+ code. 

Initally the code didn't produce any bugs, but after some simplifications and increasing the number of times a process is signaled up to four, a bug finally occured. The program reached a deadlock state where both processes were sleeping at a futex lock while there was still work to do, and the program was unable to wake either process up because it thought they were located in a signal group that neither process was actually apart of.

From here Skarupke used the TLA+ file he had written to experiemnt around with different potential solutions to the bug, relying on the TLA+ model checker to determine if any of the changes resolved the bug or not. He was eventually able to come up with a fix for the bug that relied on processes declaring themselves to be asleep just before they finished their last piece of work. This change not only fixed the bug, but also allow Skarupke to simplify the glibc code significantly. He would go on to submit his findings to the developers of the glibc library.

This story shows that TLA+ is a very capable tool for verification. As Skarupke describes, TLA+ has an incredible ability to narrow in on the exact faults within your program, along with providing you the shortest possible path that results in said bug (1). Additionally, thanks to the exisitance of pluscal, it's fairly easy to transfer a C or C++ program into TLA+ code. This allows you to more easily search your own code for bugs and quickly stress test solutions.

## Further Reasources

- The [TLA+ homepage](https://lamport.azurewebsites.net/tla/tla.html), which contains an overview of the system as well as download links.

- A [Wikipedia article](https://en.wikipedia.org/wiki/TLA%2B). This a good place to start if you would like a basic overview of the language.

## References

https://probablydance.com/2020/10/31/using-tla-in-the-real-world-to-understand-a-glibc-bug/

https://github.com/skarupke/glibc_cv_tla_plus

