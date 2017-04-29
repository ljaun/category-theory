Set Warnings "-notation-overridden".

Require Import Category.Lib.
Require Export Category.Theory.Functor.
Require Import Category.Structure.Initial.
Require Export Category.Instance.Cat.

Generalizable All Variables.
Set Primitive Projections.
Set Universe Polymorphism.
Unset Transparent Obligations.
Set Implicit Arguments.

Program Instance _0 : Category := {
  ob  := Empty_set;
  hom := fun _ _ => Empty_set;
  homset := fun _ _ => {| cequiv := eq |}
}.

Program Instance From_0 `(C : Category) : _0 ⟶ C.

Program Instance Cat_Initial : @Initial Cat := {
  Zero := _0;
  zero := From_0
}.
Next Obligation.
  constructive; try contradiction;
  simplify equiv; intros; contradiction.
Qed.
