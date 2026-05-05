(*
============================================================================
Tutorial 02 - Program extraction to Haskell
============================================================================

Goal:
  Rocq can extract verified functional programs to executable languages such as
  Haskell, OCaml, and Scheme. In this tutorial we write a small Rocq program,
  prove a few facts about it, and extract the computational parts to Haskell.

How to use:
  1. Step through this file interactively, or run:

        rocq compile tutorial_02_extraction_haskell.v

     Older Coq installations may use:

        coqc tutorial_02_extraction_haskell.v

  2. Compilation runs the `Extraction` command near the bottom and writes:

        Tutorial02Extraction.hs

  3. Inspect the generated Haskell. The extracted code contains the verified
     functions `validate_order`, `total_quantity`, and `order_summary`.

Important practical note:
  The default Haskell extraction is intentionally simple and faithful to Rocq's
  datatypes. For production Haskell, projects usually add extraction directives
  mapping Rocq strings, natural numbers, and booleans to efficient native
  Haskell types. This tutorial keeps the defaults so the generated code remains
  easy to connect back to the Rocq source.
============================================================================
*)

From Stdlib Require Import Arith.Arith.
From Stdlib Require Import Bool.Bool.
From Stdlib Require Import Lists.List.
From Stdlib Require Import Strings.String.
Require Import Stdlib.extraction.Extraction.

Import ListNotations.
Open Scope string_scope.

(*
----------------------------------------------------------------------------
1. A small domain model
----------------------------------------------------------------------------

Pretend we are building a tiny checkout service. We model line items, orders,
and validation results with ordinary Rocq datatypes.
*)

Record line_item : Type := {
  sku : string;
  quantity : nat
}.

Record order : Type := {
  order_id : nat;
  customer : string;
  rush : bool;
  items : list line_item
}.

Inductive validation : Type :=
  | Valid : validation
  | Invalid : list string -> validation.

(*
----------------------------------------------------------------------------
2. A Haskell-extractable program
----------------------------------------------------------------------------

Everything in this section is computational. After extraction, these
definitions become ordinary Haskell functions and datatypes.
*)

Definition merge_validation (v1 v2 : validation) : validation :=
  match v1, v2 with
  | Valid, Valid => Valid
  | Invalid es, Valid => Invalid es
  | Valid, Invalid es => Invalid es
  | Invalid es1, Invalid es2 => Invalid (List.app es1 es2)
  end.

Definition validate_item (item : line_item) : validation :=
  if (quantity item =? 0)%nat then
    Invalid ["quantity must be positive"]
  else
    Valid.

Fixpoint validate_items (xs : list line_item) : validation :=
  match xs with
  | [] => Valid
  | item :: rest => merge_validation (validate_item item) (validate_items rest)
  end.

Definition validate_order (o : order) : validation :=
  match items o with
  | [] => Invalid ["order has no items"]
  | _ => validate_items (items o)
  end.

Fixpoint total_quantity_items (xs : list line_item) : nat :=
  match xs with
  | [] => 0
  | item :: rest => quantity item + total_quantity_items rest
  end.

Definition total_quantity (o : order) : nat :=
  total_quantity_items (items o).

Definition order_has_rush_fee (o : order) : bool :=
  rush o && negb (total_quantity o =? 0)%nat.

Record summary : Type := {
  summary_order_id : nat;
  summary_customer : string;
  summary_item_count : nat;
  summary_total_quantity : nat;
  summary_valid : bool;
  summary_rush_fee : bool
}.

Definition validation_is_valid (v : validation) : bool :=
  match v with
  | Valid => true
  | Invalid _ => false
  end.

Definition order_summary (o : order) : summary :=
  {| summary_order_id := order_id o;
     summary_customer := customer o;
     summary_item_count := List.length (items o);
     summary_total_quantity := total_quantity o;
     summary_valid := validation_is_valid (validate_order o);
     summary_rush_fee := order_has_rush_fee o |}.

Definition sample_item : line_item :=
  {| sku := "ABC-123"; quantity := 2 |}.

Definition sample_order : order :=
  {| order_id := 570;
     customer := "Ada";
     rush := true;
     items := [sample_item] |}.

Definition empty_order : order :=
  {| order_id := 571;
     customer := "Grace";
     rush := false;
     items := [] |}.

Compute validate_order sample_order.
Compute total_quantity sample_order.
Compute order_summary empty_order.

(*
----------------------------------------------------------------------------
3. A few facts before extraction
----------------------------------------------------------------------------

Extraction erases proofs, but proofs still matter. They let us lock in facts
about the Rocq source program before generating Haskell.
*)

Theorem empty_order_is_invalid :
    validate_order empty_order = Invalid ["order has no items"].
Proof.
  reflexivity.
Qed.

Theorem sample_item_is_valid :
    validate_item sample_item = Valid.
Proof.
  reflexivity.
Qed.

Theorem sample_order_total_quantity :
    total_quantity sample_order = 2.
Proof.
  reflexivity.
Qed.

Theorem empty_order_has_no_rush_fee :
    order_has_rush_fee empty_order = false.
Proof.
  reflexivity.
Qed.

(*
----------------------------------------------------------------------------
4. Extraction to Haskell
----------------------------------------------------------------------------

This command asks Rocq to write Haskell for the computational definitions
reachable from the listed names.

After compiling this file, open `Tutorial02Extraction.hs`.
*)

Extraction Language Haskell.
Extraction
  "Tutorial02Extraction.hs"
  validate_order
  total_quantity
  order_summary
  sample_order
  empty_order.

(*
Suggested exercises:

1. Prove that `validate_items [sample_item] = Valid`.
2. Add a `total_items : order -> nat` function and extract it.
3. Add a `has_duplicate_sku : order -> bool` function.
4. Add custom extraction directives that map Rocq `bool` to Haskell `Bool`.
*)
