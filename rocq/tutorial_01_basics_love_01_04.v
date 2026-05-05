(*
============================================================================
Tutorial 01 - Rocq basics beside Lean LoVe chapters 1-4
============================================================================

Goal:
  This file introduces Rocq using the same early landmarks as the Lean LoVe
  course:

    LoVe 1: types, terms, functions, currying
    LoVe 2: inductive datatypes, recursive programs, theorem statements
    LoVe 3: backward proofs with tactics
    LoVe 4: forward proofs and proof terms

How to use:
  - Step through the file in an editor with Rocq support, or run:

        rocq compile tutorial_01_basics_love_01_04.v -output-directory .

    Older Coq installations may use:

        coqc tutorial_01_basics_love_01_04.v -output-directory .

Mental translation table:

  Lean                       Rocq
  ----                       ----
  #check t                   Check t.
  #eval t                    Compute t.
  def f ... := ...           Definition f ... := ...
  inductive T where ...      Inductive T : Type := ...
  theorem name : P := ...    Theorem name : P. Proof. ... Qed.
  by intro; exact ...        Proof. intro ...; exact ... Qed.
  rfl                        reflexivity
  exact h                    exact h
  apply h                    apply h
  constructor / cases        constructor / destruct

Rocq is the new name of Coq. Most installed tools and library paths still use
the word "Coq", so you will see both names in the ecosystem.
============================================================================
*)

From Stdlib Require Import Arith.Arith.
From Stdlib Require Import Bool.Bool.
From Stdlib Require Import Lists.List.
From Stdlib Require Import Strings.String.
From Stdlib Require Import ZArith.ZArith.

Import ListNotations.
Open Scope string_scope.
Open Scope nat_scope.

(*
----------------------------------------------------------------------------
0. Quick reference - commands used in this tutorial
----------------------------------------------------------------------------

`Definition` gives a name to a value, function, or proof term.

    Definition name : type := body.

Use it for non-recursive programs such as `identity`, `double`, and
`fst_of_two_props_term`.
*)

Definition reference_add_two (n : nat) : nat :=
  n + 2.

(*
`Fixpoint` gives a name to a recursive function. Rocq checks that recursive
calls are structurally smaller, which is why functions such as `fib`, `append`,
and `reverse` recurse on a direct subpart of their input.

    Fixpoint name (x : type) : result_type :=
      match x with
      | ...
      end.
*)

Fixpoint reference_length {A : Type} (xs : list A) : nat :=
  match xs with
  | [] => 0
  | _ :: rest => S (reference_length rest)
  end.

(*
`Theorem` starts a proof obligation. The theorem statement is the type of the
proof we must build. Between `Proof.` and `Qed.`, tactics gradually construct
that proof.

    Theorem name : proposition.
    Proof.
      ...
    Qed.
*)

Theorem reference_add_two_zero :
    reference_add_two 0 = 2.
Proof.
  reflexivity.
Qed.

(*
`Compute` asks Rocq to evaluate an expression. It is useful for examples and
sanity checks, but it is not a proof by itself.
*)

Compute reference_add_two 5.
Compute reference_length [true; false; true].

(*
`Check` asks Rocq for the type of a name or expression. It is the fastest way
to inspect what Rocq thinks you have written.
*)

Check reference_add_two.
Check reference_length.
Check reference_add_two_zero.

(*
----------------------------------------------------------------------------
1. LoVe 1 - types, terms, functions, and currying
----------------------------------------------------------------------------

Lean has universes such as `Type`; Rocq does too.
*)

Check nat.
Check bool.
Check string.
Check Type.
Check Prop.

Check 0%nat.
Check true.
Check "hello".

(*
Functions are written with arrows. As in Lean and Haskell, arrows associate to
the right:

    A -> B -> C

means:

    A -> (B -> C)
*)

Definition identity {A : Type} (x : A) : A :=
  x.

Definition constant {A B : Type} (x : A) (_ : B) : A :=
  x.

Definition flip_arguments {A B C : Type}
    (f : A -> B -> C) (y : B) (x : A) : C :=
  f x y.

Check identity.
Check @identity.
Check constant.
Check flip_arguments.

Compute identity 5%nat.
Compute constant "kept" 42%nat.

(*
Anonymous functions use `fun`, like Lean's `fun x => ...`.
*)

Definition add_one : nat -> nat :=
  fun n => S n.

Compute add_one 4%nat.

(*
Rocq also supports dependent functions. The result type may mention the value
of an earlier argument.
*)

Definition choose_type (b : bool) : Type :=
  if b then nat else bool.

Definition default_for_choice (b : bool) : choose_type b :=
  match b with
  | true => 0%nat
  | false => false
  end.

Compute default_for_choice true.
Compute default_for_choice false.

(*
----------------------------------------------------------------------------
2. LoVe 2 - inductive datatypes and recursive programs
----------------------------------------------------------------------------
*)

Module MyNat.

Inductive t : Type :=
  | zero : t
  | succ : t -> t.

Check t.
Check zero.
Check succ.

Fixpoint add (m n : t) : t :=
  match n with
  | zero => m
  | succ n' => succ (add m n')
  end.

Fixpoint mul (m n : t) : t :=
  match n with
  | zero => zero
  | succ n' => add m (mul m n')
  end.

Fixpoint power (m n : t) : t :=
  match n with
  | zero => succ zero
  | succ n' => mul m (power m n')
  end.

Definition one : t := succ zero.
Definition two : t := succ one.
Definition three : t := succ two.

Compute add two three.
Compute mul two three.
Compute power two three.

Theorem add_zero_right (n : t) :
    add n zero = n.
Proof.
  reflexivity.
Qed.

Theorem add_zero_left (n : t) :
    add zero n = n.
Proof.
  induction n as [| n IH].
  - reflexivity.
  - simpl. rewrite IH. reflexivity.
Qed.

End MyNat.

(*
Rocq's standard natural numbers already exist as `nat`, with constructors
`O` and `S`. The following mirrors LoVe's recursive definitions over `Nat`.
*)

Fixpoint fib (n : nat) : nat :=
  match n with
  | 0 => 0
  | S n0 =>
      match n0 with
      | 0 => 1
      | S n' => fib n0 + fib n'
      end
  end%nat.

Fixpoint iter {A : Type} (z : A) (f : A -> A) (n : nat) : A :=
  match n with
  | 0 => z
  | S n' => f (iter z f n')
  end%nat.

Definition power_by_iter (m n : nat) : nat :=
  iter 1 (Nat.mul m) n.

Compute fib 8.
Compute power_by_iter 2 5.

(*
Lists are also inductive. Here is our own append and reverse, written with
pattern matching just like the Lean LoVe examples.
*)

Fixpoint append {A : Type} (xs ys : list A) : list A :=
  match xs with
  | [] => ys
  | x :: xs' => x :: append xs' ys
  end.

Fixpoint reverse {A : Type} (xs : list A) : list A :=
  match xs with
  | [] => []
  | x :: xs' => append (reverse xs') [x]
  end.

Compute append [3; 1] [4; 1; 5].
Compute reverse [3; 1; 4; 1; 5].

(*
Arithmetic expressions, mirroring LoVe 2's `AExp`.
*)

Inductive aexp : Type :=
  | ANum : Z -> aexp
  | AVar : string -> aexp
  | AAdd : aexp -> aexp -> aexp
  | ASub : aexp -> aexp -> aexp
  | AMul : aexp -> aexp -> aexp
  | ADiv : aexp -> aexp -> aexp.

Fixpoint eval_aexp (env : string -> Z) (e : aexp) : Z :=
  match e with
  | ANum n => n
  | AVar x => env x
  | AAdd e1 e2 => (eval_aexp env e1 + eval_aexp env e2)%Z
  | ASub e1 e2 => (eval_aexp env e1 - eval_aexp env e2)%Z
  | AMul e1 e2 => (eval_aexp env e1 * eval_aexp env e2)%Z
  | ADiv e1 e2 => (eval_aexp env e1 / eval_aexp env e2)%Z
  end.

Definition demo_env (x : string) : Z :=
  if String.eqb x "x" then 3%Z
  else if String.eqb x "y" then 17%Z
  else 201%Z.

Definition demo_expression : aexp :=
  AMul (AAdd (AVar "x") (ANum 4%Z)) (AVar "y").

Compute eval_aexp demo_env demo_expression.

(*
Theorems can be stated before they are proved, but in course code we prefer
real proofs over placeholders such as `Admitted`.
*)

Theorem append_nil_right {A : Type} (xs : list A) :
    append xs [] = xs.
Proof.
  induction xs as [| x xs IH].
  - reflexivity.
  - simpl. rewrite IH. reflexivity.
Qed.

(*
----------------------------------------------------------------------------
3. LoVe 3 - backward proofs with tactics
----------------------------------------------------------------------------

Backward proofs start from the goal and work back toward assumptions.
*)

Theorem fst_of_two_props :
    forall A B : Prop, A -> B -> A.
Proof.
  intros A B ha hb.
  exact ha.
Qed.

Theorem prop_comp (A B C : Prop) (hab : A -> B) (hbc : B -> C) :
    A -> C.
Proof.
  intro ha.
  apply hbc.
  apply hab.
  exact ha.
Qed.

Theorem prop_comp_short (A B C : Prop) (hab : A -> B) (hbc : B -> C) :
    A -> C.
Proof.
  intro ha.
  exact (hbc (hab ha)).
Qed.

Theorem and_swap (A B : Prop) :
    A /\ B -> B /\ A.
Proof.
  intro hab.
  destruct hab as [ha hb].
  split.
  - exact hb.
  - exact ha.
Qed.

Theorem or_swap (A B : Prop) :
    A \/ B -> B \/ A.
Proof.
  intro hab.
  destruct hab as [ha | hb].
  - right. exact ha.
  - left. exact hb.
Qed.

Theorem exists_double_zero :
    exists n : nat, n + n = n.
Proof.
  exists 0.
  reflexivity.
Qed.

(*
`reflexivity` closes goals whose two sides compute to the same expression.
This is Lean's `rfl`.
*)

Definition double (n : nat) : nat :=
  n + n.

Theorem double_5_unfolds :
    double 5 = 5 + 5.
Proof.
  reflexivity.
Qed.

(*
----------------------------------------------------------------------------
4. LoVe 4 - forward proofs and proof terms
----------------------------------------------------------------------------

Forward proofs start with known facts, name intermediate results, and finish
with the goal.
*)

Theorem prop_comp_forward (A B C : Prop) (hab : A -> B) (hbc : B -> C) :
    A -> C.
Proof.
  intro ha.
  pose proof (hab ha) as hb.
  pose proof (hbc hb) as hc.
  exact hc.
Qed.

Theorem and_swap_forward (A B : Prop) :
    A /\ B -> B /\ A.
Proof.
  intro hab.
  pose proof (proj1 hab) as ha.
  pose proof (proj2 hab) as hb.
  exact (conj hb ha).
Qed.

(*
The same proof can be written as a term. This is the Curry-Howard view:
proofs are programs, propositions are types.
*)

Definition fst_of_two_props_term :
    forall A B : Prop, A -> B -> A :=
  fun A B ha hb => ha.

Definition and_swap_term (A B : Prop) :
    A /\ B -> B /\ A :=
  fun hab => conj (proj2 hab) (proj1 hab).

Check fst_of_two_props_term.
Check and_swap_term.

(*
Rocq's proof scripts and proof terms are interchangeable in spirit:
both construct a term whose type is the theorem statement.
*)

Print fst_of_two_props.
Print fst_of_two_props_term.

(*
Suggested exercises:

1. Prove `snd_of_two_props : forall A B : Prop, A -> B -> B`.
2. Define `pred_my_nat : MyNat.t -> MyNat.t`.
3. Add a simplifier for `aexp` that removes additions by zero.
4. Prove `append_assoc` for the custom `append`.
*)
