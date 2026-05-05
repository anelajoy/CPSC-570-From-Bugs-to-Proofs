(*
============================================================================
Homework - Extending Rocq extraction to Haskell
============================================================================

Submit this file with every `Admitted` replaced by a real definition or proof.
Do not change the names or type signatures.

Prerequisite:
  tutorial_02_extraction_haskell.v

How to check your work:

    rocq compile tutorial_02_extraction_haskell.v -output-directory .
    rocq compile hw_extraction_haskell.v -output-directory .

Compiling this homework should write:

    HomeworkExtraction.hs

Open the generated Haskell file and identify the functions you completed in
Rocq.
============================================================================
*)

From Stdlib Require Import Arith.Arith.
From Stdlib Require Import Bool.Bool.
From Stdlib Require Import Lists.List.
From Stdlib Require Import Strings.String.
Require Import Stdlib.extraction.Extraction.

Require Import tutorial_02_extraction_haskell.

Import ListNotations.
Open Scope string_scope.

(*
----------------------------------------------------------------------------
Part 1 - Count items and prove an append theorem
----------------------------------------------------------------------------

Fill in `count_items` recursively over the list of line items.

Then prove `count_items_app` by induction on `xs`.
*)

Definition count_items (xs : list line_item) : nat.
Admitted.

Definition order_item_count (o : order) : nat :=
  count_items (items o).

Example count_items_sample_order :
    order_item_count sample_order = 1.
Proof.
Admitted.

Theorem count_items_app :
    forall xs ys : list line_item,
      count_items (xs ++ ys) = count_items xs + count_items ys.
Proof.
Admitted.

(*
----------------------------------------------------------------------------
Part 2 - Check positive quantities and prove another list theorem
----------------------------------------------------------------------------

Fill in `quantity_is_positive` and `all_quantities_positive`.

The intended behavior is:

  - an item with quantity 0 is not positive;
  - an item with quantity 1, 2, 3, ... is positive;
  - an empty list has all quantities positive;
  - a nonempty list has all quantities positive exactly when the first item
    and the rest of the list do.

Then prove `all_quantities_positive_app` by induction on `xs`.
*)

Definition quantity_is_positive (item : line_item) : bool.
Admitted.

Definition all_quantities_positive (xs : list line_item) : bool.
Admitted.

Example sample_order_quantities_positive :
    all_quantities_positive (items sample_order) = true.
Proof.
Admitted.

Example empty_order_quantities_positive :
    all_quantities_positive (items empty_order) = true.
Proof.
Admitted.

Theorem all_quantities_positive_app :
    forall xs ys : list line_item,
      all_quantities_positive (xs ++ ys) =
        andb (all_quantities_positive xs) (all_quantities_positive ys).
Proof.
Admitted.

(*
----------------------------------------------------------------------------
Part 3 - Build an exportable summary and extract it to Haskell
----------------------------------------------------------------------------

Fill in `homework_summary_of_order`. It should combine the functions from this
homework with the verified functions from tutorial 2.

After all definitions and proofs are complete, compile this file and inspect
`HomeworkExtraction.hs`.
*)

Record homework_summary : Type := {
  homework_order_id : nat;
  homework_customer : string;
  homework_item_count : nat;
  homework_total_quantity : nat;
  homework_valid : bool;
  homework_quantities_positive : bool;
  homework_rush_fee : bool
}.

Definition homework_summary_of_order (o : order) : homework_summary.
Admitted.

Example homework_summary_empty_order :
    homework_summary_of_order empty_order =
      {| homework_order_id := 571;
         homework_customer := "Grace";
         homework_item_count := 0;
         homework_total_quantity := 0;
         homework_valid := false;
         homework_quantities_positive := true;
         homework_rush_fee := false |}.
Proof.
Admitted.

Extraction Language Haskell.
Extraction
  "HomeworkExtraction.hs"
  count_items
  order_item_count
  all_quantities_positive
  homework_summary_of_order
  sample_order
  empty_order.
