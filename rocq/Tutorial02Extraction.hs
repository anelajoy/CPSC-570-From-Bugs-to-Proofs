module Tutorial02Extraction where

import qualified Prelude

data Bool =
   True
 | False

andb :: Bool -> Bool -> Bool
andb b1 b2 =
  case b1 of {
   True -> b2;
   False -> False}

negb :: Bool -> Bool
negb b =
  case b of {
   True -> False;
   False -> True}

data Nat =
   O
 | S Nat

data List a =
   Nil
 | Cons a (List a)

length :: (List a1) -> Nat
length l =
  case l of {
   Nil -> O;
   Cons _ l' -> S (length l')}

app :: (List a1) -> (List a1) -> List a1
app l m =
  case l of {
   Nil -> m;
   Cons a l1 -> Cons a (app l1 m)}

add :: Nat -> Nat -> Nat
add n m =
  case n of {
   O -> m;
   S p -> S (add p m)}

eqb :: Nat -> Nat -> Bool
eqb n m =
  case n of {
   O -> case m of {
         O -> True;
         S _ -> False};
   S n' -> case m of {
            O -> False;
            S m' -> eqb n' m'}}

data Ascii0 =
   Ascii Bool Bool Bool Bool Bool Bool Bool Bool

data String =
   EmptyString
 | String0 Ascii0 String

data Line_item =
   Build_line_item String Nat

quantity :: Line_item -> Nat
quantity l =
  case l of {
   Build_line_item _ quantity0 -> quantity0}

data Order =
   Build_order Nat String Bool (List Line_item)

order_id :: Order -> Nat
order_id o =
  case o of {
   Build_order order_id0 _ _ _ -> order_id0}

customer :: Order -> String
customer o =
  case o of {
   Build_order _ customer0 _ _ -> customer0}

rush :: Order -> Bool
rush o =
  case o of {
   Build_order _ _ rush0 _ -> rush0}

items :: Order -> List Line_item
items o =
  case o of {
   Build_order _ _ _ items0 -> items0}

data Validation =
   Valid
 | Invalid (List String)

merge_validation :: Validation -> Validation -> Validation
merge_validation v1 v2 =
  case v1 of {
   Valid -> v2;
   Invalid es1 ->
    case v2 of {
     Valid -> Invalid es1;
     Invalid es2 -> Invalid (app es1 es2)}}

validate_item :: Line_item -> Validation
validate_item item =
  case eqb (quantity item) O of {
   True -> Invalid (Cons (String0 (Ascii True False False False True True
    True False) (String0 (Ascii True False True False True True True False)
    (String0 (Ascii True False False False False True True False) (String0
    (Ascii False True True True False True True False) (String0 (Ascii False
    False True False True True True False) (String0 (Ascii True False False
    True False True True False) (String0 (Ascii False False True False True
    True True False) (String0 (Ascii True False False True True True True
    False) (String0 (Ascii False False False False False True False False)
    (String0 (Ascii True False True True False True True False) (String0
    (Ascii True False True False True True True False) (String0 (Ascii True
    True False False True True True False) (String0 (Ascii False False True
    False True True True False) (String0 (Ascii False False False False False
    True False False) (String0 (Ascii False True False False False True True
    False) (String0 (Ascii True False True False False True True False)
    (String0 (Ascii False False False False False True False False) (String0
    (Ascii False False False False True True True False) (String0 (Ascii True
    True True True False True True False) (String0 (Ascii True True False
    False True True True False) (String0 (Ascii True False False True False
    True True False) (String0 (Ascii False False True False True True True
    False) (String0 (Ascii True False False True False True True False)
    (String0 (Ascii False True True False True True True False) (String0
    (Ascii True False True False False True True False)
    EmptyString))))))))))))))))))))))))) Nil);
   False -> Valid}

validate_items :: (List Line_item) -> Validation
validate_items xs =
  case xs of {
   Nil -> Valid;
   Cons item rest ->
    merge_validation (validate_item item) (validate_items rest)}

validate_order :: Order -> Validation
validate_order o =
  case items o of {
   Nil -> Invalid (Cons (String0 (Ascii True True True True False True True
    False) (String0 (Ascii False True False False True True True False)
    (String0 (Ascii False False True False False True True False) (String0
    (Ascii True False True False False True True False) (String0 (Ascii False
    True False False True True True False) (String0 (Ascii False False False
    False False True False False) (String0 (Ascii False False False True
    False True True False) (String0 (Ascii True False False False False True
    True False) (String0 (Ascii True True False False True True True False)
    (String0 (Ascii False False False False False True False False) (String0
    (Ascii False True True True False True True False) (String0 (Ascii True
    True True True False True True False) (String0 (Ascii False False False
    False False True False False) (String0 (Ascii True False False True False
    True True False) (String0 (Ascii False False True False True True True
    False) (String0 (Ascii True False True False False True True False)
    (String0 (Ascii True False True True False True True False) (String0
    (Ascii True True False False True True True False)
    EmptyString)))))))))))))))))) Nil);
   Cons _ _ -> validate_items (items o)}

total_quantity_items :: (List Line_item) -> Nat
total_quantity_items xs =
  case xs of {
   Nil -> O;
   Cons item rest -> add (quantity item) (total_quantity_items rest)}

total_quantity :: Order -> Nat
total_quantity o =
  total_quantity_items (items o)

order_has_rush_fee :: Order -> Bool
order_has_rush_fee o =
  andb (rush o) (negb (eqb (total_quantity o) O))

data Summary =
   Build_summary Nat String Nat Nat Bool Bool

validation_is_valid :: Validation -> Bool
validation_is_valid v =
  case v of {
   Valid -> True;
   Invalid _ -> False}

order_summary :: Order -> Summary
order_summary o =
  Build_summary (order_id o) (customer o) (length (items o))
    (total_quantity o) (validation_is_valid (validate_order o))
    (order_has_rush_fee o)

sample_item :: Line_item
sample_item =
  Build_line_item (String0 (Ascii True False False False False False True
    False) (String0 (Ascii False True False False False False True False)
    (String0 (Ascii True True False False False False True False) (String0
    (Ascii True False True True False True False False) (String0 (Ascii True
    False False False True True False False) (String0 (Ascii False True False
    False True True False False) (String0 (Ascii True True False False True
    True False False) EmptyString))))))) (S (S O))

sample_order :: Order
sample_order =
  Build_order (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    O))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
    (String0 (Ascii True False False False False False True False) (String0
    (Ascii False False True False False True True False) (String0 (Ascii True
    False False False False True True False) EmptyString))) True (Cons
    sample_item Nil)

empty_order :: Order
empty_order =
  Build_order (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
    O)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
    (String0 (Ascii True True True False False False True False) (String0
    (Ascii False True False False True True True False) (String0 (Ascii True
    False False False False True True False) (String0 (Ascii True True False
    False False True True False) (String0 (Ascii True False True False False
    True True False) EmptyString))))) False Nil

