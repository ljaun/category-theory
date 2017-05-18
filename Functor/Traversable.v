Set Warnings "-notation-overridden".

Require Import Category.Lib.
Require Export Category.Functor.Strong.
Require Export Category.Functor.Structure.Monoidal.
Require Export Category.Functor.Structure.Monoidal.Id.
Require Export Category.Functor.Structure.Monoidal.Compose.
Require Export Category.Functor.Structure.Monoidal.Pure.
Require Export Category.Structure.Monoidal.Internal.Product.
Require Export Category.Functor.Product.
Require Export Category.Functor.Product.Internal.
Require Export Category.Functor.Applicative.

Generalizable All Variables.
Set Primitive Projections.
Set Universe Polymorphism.

Class LaxMonoidalTransformation `{C : Category} `{@Monoidal C}
      {F : C ⟶ C} `{@LaxMonoidalFunctor _ _ _ _ F}
      {G : C ⟶ C} `{@LaxMonoidalFunctor _ _ _ _ G} (N : F ⟹ G) := {
  lax_pure_transform : lax_pure[G] ≈ transform[N] _ ∘ lax_pure[F];

  lax_ap_transform {X Y} :
    lax_ap[G] ∘ transform[N] X ⨂ transform[N] Y ≈ transform[N] _ ∘ lax_ap[F]
}.

Set Warnings "-non-primitive-record".

Class ApplicativeTransformation `{C : Category}
      `{@Cartesian C} `{@Terminal C} `{@Closed C _}
      {F : C ⟶ C} `{@Applicative _ _ _ _ F}
      {G : C ⟶ C} `{@Applicative _ _ _ _ G} (N : F ⟹ G) := {
  is_strong_transformation :>
    @StrongTransformation C InternalProduct_Monoidal _ _ _ _ N;
  is_lax_monoidal_transformation :>
    @LaxMonoidalTransformation C InternalProduct_Monoidal _ _ _ _ N
}.

Section Traversable.

Context `{C : Category}.
Context `{@Cartesian C}.
Context `{@Terminal C}.
Context `{@Closed C _}.
Context `{F : C ⟶ C}.

Local Obligation Tactic := idtac.

Program Instance Id_Applicative : @Applicative C _ _ _ (Id[C]) := {
  is_strong := Id_StrongFunctor;
  is_lax_monoidal := @Id_LaxMonoidalFunctor C InternalProduct_Monoidal
                                            C InternalProduct_Monoidal
}.

Program Instance Compose_Applicative
        `{G : C ⟶ C} `{@Applicative C _ _ _ G}
        `{H : C ⟶ C} `{@Applicative C _ _ _ H} :
  @Applicative C _ _ _ (Compose G H) := {
  is_strong := Compose_StrongFunctor G H _ _;
  is_lax_monoidal :=
    (* jww (2017-05-16): The order of arguments here is reversed *)
    @Compose_LaxMonoidalFunctor C InternalProduct_Monoidal
                                C InternalProduct_Monoidal H
                                C InternalProduct_Monoidal G _ _
}.

Class Traversable := {
  sequence `{G : C ⟶ C} `{@Applicative C _ _ _ G} : F ○ G ⟹ G ○ F;

  sequence_naturality `{G : C ⟶ C} `{@Applicative C _ _ _ G}
                      `{H : C ⟶ C} `{@Applicative C _ _ _ H} (N : G ⟹ H)
                      (f : @ApplicativeTransformation C _ _ _ _ _ _ _ N) {X} :
    transform[N] (F X) ∘ transform[@sequence G _] X
      ≈ transform[@sequence H _] X ∘ fmap[F] (transform[N] _);

  sequence_Id {X} : transform[@sequence Id _] X ≈ id;
  sequence_Compose `{G : C ⟶ C} `{@Applicative C _ _ _ G}
                   `{H : C ⟶ C} `{@Applicative C _ _ _ H} {X} :
    transform[@sequence (Compose G H) _] X
      ≈ fmap[G] (transform[sequence] X) ∘ transform[sequence] _
}.

End Traversable.

Arguments Traversable {_ _ _ _} F.

Program Instance Id_Traversable `{C : Category}
        `{@Cartesian C} `{@Terminal C} `{@Closed C _} (x : C) :
  Traversable (@Id C) := {
  sequence := fun _ _ => {| transform := fun _ => id |}
}.

Require Import Category.Functor.Constant.

Program Instance Constant_Traversable `{C : Category}
        `{@Cartesian C} `{@Terminal C} `{@Closed C _} (x : C) :
  Traversable (@Constant C C x) := {
  sequence := fun G _ => {| transform := fun _ => pure[G] |}
}.
Next Obligation.
  unfold pure.
  simpl; normal.
  rewrite <- !comp_assoc.
  rewrite <- !fork_comp.
  normal.
  rewrite <- naturality.
  rewrite !fork_comp.
  rewrite <- !comp_assoc.
  apply compose_respects; [reflexivity|].
  rewrite !comp_assoc.
  apply compose_respects; [|reflexivity].
  rewrite lax_pure_transform.
  rewrite <- strength_transform; simpl.
  rewrite <- !comp_assoc; cat.
  rewrite <- !fork_comp; cat.
  rewrite <- !comp_assoc; cat.
Qed.
Next Obligation.
  unfold pure, bimap; simpl; cat.
Qed.
Next Obligation.
  unfold pure; simpl.
  normal.
  rewrite <- !comp_assoc.
  rewrite !fmap_comp.
  rewrite <- !comp_assoc.
  apply compose_respects; [reflexivity|].
  rewrite !comp_assoc.
  apply compose_respects; [|reflexivity].
  rewrite <- !comp_assoc.
  apply compose_respects; [reflexivity|].
  rewrite !comp_assoc.
  rewrite <- !fmap_comp.
  rewrite <- !fork_comp; cat.
  rewrite <- !comp_assoc; cat.
  rewrite (comp_assoc exr).
  rewrite exr_fork.
  rewrite one_comp.
  normal.
  pose proof (@strength_natural C InternalProduct_Monoidal G _).
  simpl in X0.
  specialize
    (X0 x x id 1 (H3 I)
        (@lax_pure C C InternalProduct_Monoidal
                   InternalProduct_Monoidal H3 _ ∘ (@one C H0 1))).
  normal.
  rewrite <- !fork_comp in X0.
  rewrite !fork_exl_exr in X0.
  normal.
  rewrite <- (@one_comp _ _ _ _ exr).
  normal.
  rewrite X0; clear X0.
  rewrite <- !comp_assoc.
  simpl.
  rewrite (@one_unique _ _ _ _ id).
  rewrite <- !fork_comp; cat.
  rewrite <- !comp_assoc; cat.
Qed.
