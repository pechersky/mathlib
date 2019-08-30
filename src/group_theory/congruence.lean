/-
Copyright (c) 2019 Amelia Livingston. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Amelia Livingston
-/
import group_theory.submonoid order.order_iso algebra.pi_instances data.equiv.algebra

variables {M : Type*} {N : Type*} {P : Type*} [monoid M] [monoid N] [monoid P]

set_option old_structure_cmd true

namespace mul_equiv
--not sure where to put this; would need to import group_theory.submonoid to put it in data.equiv.algebra and vice versa.
/-- Makes the natural isomorphism between two equal submonoids. -/
def submonoid_congr {A B : submonoid M} (h : A = B) : A ≃* B :=
{ map_mul' := λ x y, rfl,
  ..equiv.set_congr $ submonoid.ext'_iff.2 h }

end mul_equiv

variables (M)

/-- Defining congruence relations on monoids as equivalence relations which 
    preserve multiplication. -/
structure con :=
(r : M → M → Prop)
(r_iseqv : equivalence r)
(r_mul : ∀ {w x y z}, r w x → r y z → r (w * y) (x * z))

/-- Defining congruence relations on additive monoids as equivalence relations which 
    preserve addition. -/
structure add_con {M : Type*} [add_monoid M] :=
(r : M → M → Prop)
(r_iseqv : equivalence r)
(r_add : ∀ {w x y z}, r w x → r y z → r (w + y) (x + z))

attribute [to_additive add_con] con
attribute [to_additive add_con.r] con.r
attribute [to_additive add_con.cases_on] con.cases_on
attribute [to_additive add_con.has_sizeof_inst] con.has_sizeof_inst
attribute [to_additive add_con.mk] con.mk
attribute [to_additive add_con.mk.inj] con.mk.inj
attribute [to_additive add_con.mk.inj_arrow] con.mk.inj_arrow
attribute [to_additive add_con.mk.inj_eq] con.mk.inj_eq
attribute [to_additive add_con.mk.sizeof_spec] con.mk.sizeof_spec
attribute [to_additive add_con.r_iseqv] con.r_iseqv
attribute [to_additive add_con.no_confusion] con.no_confusion
attribute [to_additive add_con.no_confusion_type] con.no_confusion_type
attribute [to_additive add_con.r_add] con.r_mul
attribute [to_additive add_con.rec] con.rec
attribute [to_additive add_con.rec_on] con.rec_on
attribute [to_additive add_con.sizeof] con.sizeof

namespace con

variables {M}

@[to_additive]
instance : has_coe_to_fun (con M) := ⟨_, λ c, λ m n, c.r m n⟩

/-- Simplification lemmas so congruence relations can be easily treated as functions. -/
@[simp, to_additive] lemma rel_coe {c : con M} : c.r = (c : M → M → Prop) := rfl
@[simp, refl, to_additive] lemma refl (c : con M) (x) : c.1 x x := c.2.1 x
@[simp, symm, to_additive] lemma symm (c : con M) : ∀ {x y}, c x y → c.1 y x := λ _ _ h, c.2.2.1 h
@[simp, trans, to_additive] lemma trans (c : con M) : ∀ {x y z}, c x y → c y z → c.1 x z := 
λ  _ _ _ hx hy, c.2.2.2 hx hy
@[simp, to_additive] lemma mul (c : con M) : ∀ {w x y z}, c w x → c y z → c (w*y) (x*z) :=
λ _ _ _ _ h1 h2, c.3 h1 h2
@[simp, to_additive] lemma iseqv (c : con M) : equivalence c := c.2

/-- Two congruence relations are equal if their underlying functions are equal. -/
@[to_additive] lemma r_inj {c d : con M} (H : c.r = d.r) : c = d :=
by cases c; cases d; simp * at *
run_cmd tactic.add_doc_string `add_con.r_inj'
  "Two congruence relations are equal if their underlying functions are equal."

/-- Two congruence relations are equal if their underlying functions are equal for all arguments. -/
@[extensionality, to_additive] lemma ext {c d : con M} (H : ∀ x y, c x y ↔ d x y) :
  c = d := r_inj $ by ext x y; exact H x y
run_cmd tactic.add_doc_string `add_con.ext'
  "Two congruence relations are equal if their underlying functions are equal."
    
/-- Two congruence relations are equal iff their underlying functions are equal for all arguments. -/
@[to_additive] lemma ext_iff {c d : con M} : (∀ x y, c x y ↔ d x y) ↔ c = d :=
⟨λ h, ext h, λ h x y, h ▸ iff.rfl⟩
run_cmd tactic.add_doc_string `add_con.ext_iff'
  "Two congruence relations are equal iff their underlying functions are equal."
    
variables (M)

/-- The submonoid of M × M defined by a congruence relation on a monoid M. -/
@[to_additive add_con.add_submonoid] protected def submonoid (c : con M) : submonoid (M × M) :=
{ carrier := { x | c x.1 x.2 },
  one_mem' := c.iseqv.1 1,
  mul_mem' := λ _ _ hx hy, c.mul hx hy }
run_cmd tactic.add_doc_string `add_submonoid.add_submonoid'
  "The submonoid of M × M defined by a congruence relation on an additive monoid M."

variables {M}

/-- Makes a congruence relation on a monoid M from a submonoid of M × M which is 
    also an equivalence relation. -/
@[to_additive of_add_submonoid] 
def of_submonoid (N : submonoid (M × M)) (H : equivalence (λ x y, (x, y) ∈ N)) : con M :=
{ r := λ x y, (x, y) ∈ N,
  r_iseqv := H,
  r_mul := λ _ _ _ _ h1 h2, N.mul_mem h1 h2 }
run_cmd tactic.add_doc_string `add_con.of_add_submonoid'
  "Makes a congruence relation on an additive monoid M from a submonoid of M × M which is also an equivalence relation."

/-- The kernel of a monoid homomorphism as a congruence relation. -/
@[to_additive] def ker (f : M →* P) : con M :=
{ r := λ x y, f x = f y,
  r_iseqv := ⟨λ _, rfl, λ _ _ h, h.symm, λ _ _ _ hx hy, eq.trans hx hy⟩,
  r_mul := λ _ _ _ _ h1 h2, by rw [f.map_mul, h1, h2, f.map_mul] }
run_cmd tactic.add_doc_string `add_con.ker'
  "Two congruence relations are equal if their underlying functions are equal."
    
end con

namespace submonoid

--not sure where to put this, similarly to submonoid_congr.
def diag : submonoid (M × M) :=
{ carrier := { x | x.1 = x.2 },
  one_mem' := rfl,
  mul_mem' := λ x y h1 h2, by simp only [set.mem_set_of_eq, *, prod.fst_mul, prod.snd_mul] at *}

end submonoid

variables {M}

def monoid_hom.ker' (f : M →* P) : submonoid (M × M) := (con.ker f).submonoid M

namespace monoid_hom

lemma mem_ker' (f : M →* P) (x y) :
  (x, y) ∈ f.ker' ↔ f x = f y := ⟨λ h, h, λ h, h⟩

theorem injective_iff_ker'_diag (f : M →* P) :
  function.injective f ↔ f.ker' = submonoid.diag M :=
⟨λ h, submonoid.ext (λ x, ⟨λ hx, h hx, λ hx, congr_arg f $ hx⟩),
 λ h x y hf, show (x, y) ∈ submonoid.diag M, by rwa ←h⟩

theorem ker_eq_ker' {G} {H} [group G] [group H] (f : G →* H) {x} :
  (∃ y, y ∈ f.ker' ∧ x = (y : G × G).1 * y.2⁻¹) ↔ f x = 1 :=
⟨λ ⟨y, hm, hxy⟩, by
  rw [hxy, f.map_mul, f.map_inv, show f y.1 = f y.2, from hm, mul_right_inv],
 λ hx, ⟨(x,1), show f x = f 1, from f.map_one.symm ▸ hx, by simp only [mul_one, one_inv]⟩⟩

end monoid_hom

namespace con

variables {M}

protected def prod (c : con M) (d : con N) : con (M × N) :=
{ r := λ x y, c x.1 y.1 ∧ d x.2 y.2,
  r_iseqv := ⟨λ x, ⟨c.refl x.1, d.refl x.2⟩, λ _ _ h, ⟨c.symm h.1, d.symm h.2⟩,
            λ _ _ _ h1 h2, ⟨c.trans h1.1 h2.1, d.trans h1.2 h2.2⟩⟩,
  r_mul := λ _ _ _ _ h1 h2, ⟨c.mul h1.1 h2.1, d.mul h1.2 h2.2⟩ }

def pi {ι : Type*} {f : ι → Type*} [Π i, monoid (f i)] 
  (C : Π i, con (f i)) : con (Π i, f i) :=
{ r := λ x y, ∀ i, (C i) (x i) (y i),
  r_iseqv := ⟨λ x i, (C i).refl (x i), λ _ _ h i, (C i).symm (h i),
              λ _ _ _ h1 h2 i, (C i).trans (h1 i) (h2 i)⟩,
  r_mul := λ _ _ _ _ h1 h2 i, (C i).mul (h1 i) (h2 i) }

lemma ker_rel (f : M →* P) {x y} : con.ker f x y ↔ f x = f y := iff.rfl

variable (c : con M)

def subtype (A : submonoid M) : con A :=
⟨λ x y, c x y, ⟨λ x, c.refl x, λ x y h, c.symm h, λ x y z h1 h2, c.trans h1 h2⟩,
 λ w x y z h1 h2, c.mul h1 h2⟩

@[simp] lemma subtype_apply {A : submonoid M} {x y} : c.subtype A x y ↔ c x y := iff.rfl

def setoid : setoid M := ⟨c.r, c.iseqv⟩

@[simp] lemma setoid_eq : (setoid c).r = c := rfl

def quotient := quotient $ setoid c

instance : has_coe M (c.quotient) := ⟨@quotient.mk _ c.setoid⟩

instance [d : ∀ a b, decidable (c a b)] : decidable_eq c.quotient :=
@quotient.decidable_eq M c.setoid d

@[elab_as_eliminator, reducible]
protected def lift_on' {β} {c : con M} (q : c.quotient) (f : M → β)
  (h : ∀ a b, c a b → f a = f b) : β := quotient.lift_on' q f h

@[elab_as_eliminator, reducible]
protected def lift_on₂' {β} {c : con M} {d : con N} (q₁ : c.quotient) (q₂ : d.quotient)
  (f : M → N → β) (h : ∀ a₁ a₂ b₁ b₂, c a₁ b₁ → d a₂ b₂ → f a₁ a₂ = f b₁ b₂) : β :=
quotient.lift_on₂' q₁ q₂ f h

variables {c}

@[elab_as_eliminator]
lemma ind {C : c.quotient → Prop} (H : ∀ x : M, C x) : ∀ q, C q :=
quotient.ind' H

@[elab_as_eliminator]
lemma ind₂ {d : con N} {C : c.quotient → d.quotient → Prop}
  (H : ∀ (x : M) (y : N), C x y) : ∀ p q, C p q :=
quotient.ind₂' H

@[elab_as_eliminator]
lemma induction_on {C : c.quotient → Prop} (q : c.quotient) (H : ∀ x : M, C x) : C q :=
quotient.induction_on' q H

@[elab_as_eliminator]
lemma induction_on₂ {d : con N} {C : c.quotient → d.quotient → Prop}
  (p : c.quotient) (q : d.quotient) (H : ∀ (x : M) (y : N), C x y) : C p q :=
quotient.induction_on₂' p q H

instance : inhabited c.quotient := ⟨((1 : M) : c.quotient)⟩

variables (c)

@[simp] protected lemma eq (a b : M) : (a : c.quotient) = b ↔ c a b :=
quotient.eq'

instance monoid : monoid c.quotient :=
{ one := ((1 : M) : c.quotient),
  mul := λ x y, quotient.lift_on₂' x y (λ w z, (((w*z) : M) : c.quotient))
         $ λ _ _ _ _ h1 h2, (c.eq _ _).2 $ c.mul h1 h2,
  mul_assoc := λ x y z, quotient.induction_on₃' x y z
               $ λ _ _ _, congr_arg coe $ mul_assoc _ _ _,
  mul_one := λ x, quotient.induction_on' x $ λ _, congr_arg coe $ mul_one _,
  one_mul := λ x, quotient.induction_on' x $ λ _, congr_arg coe $ one_mul _ }

def mk' : M →* c.quotient := ⟨coe, rfl, λ _ _, rfl⟩

variables (x y : M)

@[simp] lemma mk'_ker : con.ker c.mk' = c := ext $ λ _ _, c.eq _ _

lemma mk'_submonoid : c.mk'.ker' = c.submonoid M :=
submonoid.ext $ λ _, ⟨λ h, (c.eq _ _).1 h, λ h, (c.eq _ _).2 h⟩

lemma mk'_surjective : function.surjective c.mk' :=
by apply ind; exact λ x, ⟨x, rfl⟩

@[simp] lemma mk'_one : c.mk' 1 = 1 := rfl
@[simp] lemma mk'_mul : c.mk' (x * y) = c.mk' x * c.mk' y := rfl
@[simp] lemma mk'_pow : ∀ n : ℕ, c.mk' (x ^ n) = (c.mk' x) ^ n
| 0 := c.mk'.map_one
| (m + 1) := by rw [pow_succ, c.mk'.map_mul, mk'_pow m]; refl
@[simp] lemma comp_mk'_apply (g : c.quotient →* P) {x} : g.comp c.mk' x = g x := rfl

@[simp] lemma coe_one : ((1 : M) : c.quotient) = 1 := rfl
@[simp] lemma coe_mul : (x : c.quotient) * (y : c.quotient) = ((x * y : M) : c.quotient)  := rfl
lemma coe_pow : ∀ n : ℕ, (x ^ n : c.quotient) = (x : c.quotient) ^ n
| 0            := pow_zero _
| (nat.succ n) := by rw pow_succ _

@[simp] lemma lift_on_beta {β} (c : con M) (f : M → β)
  (h : ∀ a b, c a b → f a = f b) (x : M) :
con.lift_on' (x : c.quotient) f h = f x := rfl

variable {f : M →* P}

lemma ker_apply_eq_preimage (m) : (con.ker f) m = f ⁻¹' {f m} :=
set.ext $ λ x,
  ⟨λ h, set.mem_preimage.2 (set.mem_singleton_iff.2 h.symm),
   λ h, (set.mem_singleton_iff.1 (set.mem_preimage.1 h)).symm⟩

def congr {c d : con M} (h : c = d) :  c.quotient ≃* d.quotient :=
{ map_mul' := λ x y, by rcases x; rcases y; refl,
  ..quotient.congr (equiv.refl M) $ by apply ext_iff.2 h }

open lattice

instance : has_le (con M) := ⟨λ c d, c.submonoid M ≤ d.submonoid M⟩

instance to_submonoid : has_coe (con M) (submonoid (M × M)) := ⟨λ c, c.submonoid M⟩

lemma le_def' {c d : con M} : c ≤ d ↔ (c : submonoid (M × M)) ≤ d := iff.rfl

lemma le_def (c d : con M) : c ≤ d ↔ (∀ x y, c x y → d x y) :=
⟨λ h x y hc, (submonoid.le_def ↑c ↑d).1 (le_def'.1 h) (x, y) hc,
 λ h, le_def'.2 $ (submonoid.le_def ↑c ↑d).2 $ λ x hc, h x.1 x.2 hc⟩

instance : has_mem (M × M) (con M) := ⟨λ x c, x ∈ (↑c : set (M × M))⟩

@[simp] lemma mem_coe {c : con M} {x y} :
  (x, y) ∈ (↑c : submonoid (M × M)) ↔ (x, y) ∈ c := iff.rfl

lemma mem_iff_rel {c : con M} {x y} : (x, y) ∈ c ↔ c x y := iff.rfl

theorem to_submonoid_inj (c d : con M) (H : (c : submonoid (M × M)) = d) : c = d :=
ext $ λ x y, show (x,y) ∈ (c : submonoid (M × M)) ↔ (x,y) ∈ ↑d, by rw H

instance : partial_order (con M) :=
{ le := (≤),
  lt := λ c d, c ≤ d ∧ ¬d ≤ c,
  le_refl := λ c, le_def'.2 $ lattice.complete_lattice.le_refl ↑c,
  le_trans := λ c1 c2 c3 h1 h2, le_def'.2 $ complete_lattice.le_trans ↑c1 ↑c2 ↑c3 h1 h2,
  lt_iff_le_not_le := λ _ _, ⟨λ h, h, λ h, h⟩,
  le_antisymm := λ c d h1 h2, to_submonoid_inj c d $ complete_lattice.le_antisymm ↑c ↑d h1 h2 }

instance : has_bot (con M) :=
⟨of_submonoid (submonoid.diag M) ⟨λ _, rfl, λ _ _ h, h.symm, λ _ _ _ h1 h2, h1.trans h2⟩⟩

@[simp] lemma bot_coe : ↑(⊥ : con M) = (submonoid.diag M) := rfl

@[simp] lemma mem_bot {x y} : (x, y) ∈ (⊥ : con M) ↔ x = y := iff.rfl

instance order_bot : order_bot (con M) :=
{ bot := @has_bot.bot (con M) _,
  bot_le := λ c, le_def'.2 $ (submonoid.le_def ↑⊥ ↑c).2 $ λ x h,
                 (show c x.1 x.2, by rw (mem_bot.1 h); apply c.refl),
  ..con.partial_order }

instance : has_top (con M) := ⟨con.ker (@monoid_hom.one M P _ _)⟩

@[simp] lemma top_coe : ↑(⊤ : con M) = (⊤ : submonoid (M × M)) :=
submonoid.ext $ λ x, ⟨λ h, submonoid.mem_top x, λ h, rfl⟩

@[simp] lemma mem_top {x y} : (x, y) ∈ (⊤ : con M) :=
by rw [←mem_coe, top_coe]; apply submonoid.mem_top

instance order_top : order_top (con M) :=
{ top := has_top.top (con M),
  le_top := λ c, le_def'.2 (by rw top_coe; exact complete_lattice.le_top ↑c),
  ..con.partial_order }

instance : has_inf (con M) :=
⟨λ c d, of_submonoid (↑c ⊓ ↑d)
  ⟨λ x, submonoid.mem_inf.2 ⟨c.refl x, d.refl x⟩,
   λ _ _ h, submonoid.mem_inf.2 ⟨c.symm (submonoid.mem_inf.1 h).1, d.symm (submonoid.mem_inf.1 h).2⟩,
   λ _ _ _ h1 h2, submonoid.mem_inf.2
     ⟨c.trans (submonoid.mem_inf.1 h1).1 (submonoid.mem_inf.1 h2).1,
      d.trans (submonoid.mem_inf.1 h1).2 (submonoid.mem_inf.1 h2).2⟩⟩⟩

lemma mem_inf (c d : con M) (x y) : has_inf.inf c d x y ↔ c x y ∧ d x y :=
⟨λ h, ⟨h.1, h.2⟩, λ h, ⟨h.1, h.2⟩⟩

instance : has_Inf (con M) :=
⟨λ s, of_submonoid (Inf (coe '' s))
  ⟨λ x, submonoid.mem_Inf.2 $ λ p ⟨c, hs, hc⟩, hc ▸ (mem_coe.2 $ c.refl x),
   λ _ _ h, submonoid.mem_Inf.2 $
     λ p ⟨c, hs, hc⟩, hc ▸ (mem_coe.2 $ c.symm $ submonoid.mem_Inf.1 h ↑c $ ⟨c, hs, rfl⟩),
   λ _ _ _ h1 h2, submonoid.mem_Inf.2 $ λ p ⟨c, hs, hc⟩, hc ▸ (mem_coe.2 $ c.trans
     (submonoid.mem_Inf.1 h1 ↑c ⟨c, hs, rfl⟩) $ submonoid.mem_Inf.1 h2 ↑c ⟨c, hs, rfl⟩)⟩⟩

lemma Inf_eq (s : set (con M)) :
  ((Inf s : con M) : submonoid (M × M)) = Inf (coe '' s) :=
by ext x; cases x; refl

lemma Inf_le' {s : set (con M)} : c ∈ s → Inf s ≤ c :=
λ h, le_def'.2 $ (Inf_eq s).symm ▸ (submonoid.Inf_le'
     (show (c : submonoid (M × M)) ∈ coe '' s, by {use c, exact ⟨h, rfl⟩}))

lemma le_Inf' (s : set (con M)) : (∀d ∈ s, c ≤ d) → c ≤ Inf s :=
λ h, le_def'.2 $ (Inf_eq s).symm ▸ (submonoid.le_Inf' $ λ d' ⟨d, hs, hd⟩, hd ▸ (le_def'.1 $ h d hs))

lemma mem_Inf (S : set (con M)) (x y) : (Inf S) x y ↔ (∀ p : con M, p ∈ S → p x y) :=
⟨λ h p hp, (le_def _ _).1 (Inf_le' p hp) x y h,
  by { rw [show Inf S x y ↔ (x, y) ∈ Inf S, from iff.rfl, ←mem_coe, Inf_eq, submonoid.mem_Inf],
       rintro h p' ⟨q, hm, hq⟩, rw ←hq, exact mem_coe.2 (h q hm) }⟩

instance : has_sup (con M) := ⟨λ c d, Inf { x | c ≤ x ∧ d ≤ x}⟩

instance : complete_lattice (con M) :=
{ sup := has_sup.sup,
  le_sup_left := λ c d, le_Inf' c { x | c ≤ x ∧ d ≤ x} $ λ x hx, hx.1,
  le_sup_right := λ c d, le_Inf' d { x | c ≤ x ∧ d ≤ x} $ λ x hx, hx.2,
  sup_le := λ _ _ c h1 h2, Inf_le' c ⟨h1, h2⟩,
  inf := has_inf.inf,
  inf_le_left := λ c d, le_def'.2 $ complete_lattice.inf_le_left ↑c ↑d,
  inf_le_right := λ c d, le_def'.2 $ complete_lattice.inf_le_right ↑c ↑d,
  le_inf := λ c1 c2 c3 h1 h2, le_def'.2 $
    complete_lattice.le_inf ↑c1 ↑c2 ↑c3 (le_def'.1 h1) (le_def'.1 h2),
  Sup := λ tt, Inf {t | ∀t'∈tt, t' ≤ t},
  Inf := has_Inf.Inf,
  le_Sup := λ _ _ hs, le_Inf' _ _ $ λ c' hc', hc' _ hs,
  Sup_le := λ _ _ hs, Inf_le' _ hs,
  Inf_le := λ  _ _, Inf_le' _,
  le_Inf := λ _ _, le_Inf' _ _,
  ..con.partial_order,
  ..con.order_top, ..con.order_bot }

def closure (s : set (M × M)) : con M := Inf {c : con M | s ≤ (c : submonoid (M × M))}

def fg := ∃ s : finset (M × M), c = closure s.to_set

variables (c f)

def lift (H : ∀ x y, c x y → f x = f y) : c.quotient →* P :=
{ to_fun := λ x, con.lift_on' x f $ λ a b h, H a b h,
  map_one' := by rw ←f.map_one; refl,
  map_mul' := λ x y, con.induction_on₂ x y $
                λ m n, by simp only [f.map_mul, con.lift_on_beta, con.coe_mul]}

def lift_of_le_ker (H : c.submonoid M ≤ f.ker') : c.quotient →* P :=
c.lift f $ (con.le_def _ _).1 H

def ker_lift (f : M →* P) : (con.ker f).quotient →* P :=
(con.ker f).lift f $ λ x y h, h

variables {c f}

@[simp] lemma lift_mk' (H : ∀ x y, c x y → f x = f y) (m) :
  c.lift f H (c.mk' m) = f m := rfl

@[simp] lemma lift_coe (H : ∀ x y, c x y → f x = f y) (m : M) :
  c.lift f H m = f m := rfl

@[simp] theorem lift_comp_mk' (H : ∀ x y, c x y → f x = f y) :
  (c.lift f H).comp c.mk' = f := by ext; refl

@[simp] lemma lift_apply_mk' (f : c.quotient →* P) :
  c.lift (f.comp c.mk') (λ x y h, by simp [(c.eq _ _).2 h]) = f :=
by ext; rcases x; refl

lemma lift_funext (f g : c.quotient →* P) (h : ∀ a : M, f a = g a) : f = g :=
by { rw [←lift_apply_mk' f, ← lift_apply_mk' g], congr' 1, ext, apply h x }

theorem lift_unique (H : ∀ x y, c x y → f x = f y) (g : c.quotient →* P)
  (Hg : g.comp c.mk' = f) : g = c.lift f H :=
lift_funext g (c.lift f H) $ λ x, by rw [lift_coe H, ←con.comp_mk'_apply, Hg]

theorem lift_range (H : ∀ x y, c x y → f x = f y) : (c.lift f H).range = f.range :=
submonoid.ext $ λ x,
  ⟨λ ⟨y, hy⟩, by revert hy; rcases y; exact
     (λ hy, ⟨y, hy.1, by rw [hy.2.symm, (lift_coe H _).symm]; refl⟩),
   λ ⟨y, hy⟩, ⟨↑y, hy.1, by rw ←hy.2; refl⟩⟩

@[simp] lemma ker_lift_mk {x : M} :  ker_lift f x = f x := rfl

lemma ker_lift_range_eq : (ker_lift f).range = f.range :=
lift_range $ λ x y h, h

lemma injective_ker_lift (f : M →* P) : function.injective (ker_lift f) :=
λ x y, con.induction_on₂ x y $ λ _ _ h, ((con.ker f).eq _ _).2 $ by rwa ker_lift_mk at h

def map (c d : con M) (h : c ≤ d) : c.quotient →* d.quotient :=
c.lift d.mk' $ λ x y hc, show (con.ker d.mk') x y, from
  (mk'_ker d).symm ▸ ((le_def c d).1 h x y hc)

@[simp] lemma map_apply {c d : con M} (h : c ≤ d) (x) :
  c.map d h x = c.lift d.mk'
    (λ x y, (le_def c $ con.ker d.mk').1 ((mk'_ker d).symm ▸ h) x y) x := rfl


variables (c)

lemma rel {x y} (h : @setoid.r M c.setoid x y) : c x y := h

def to_con (d : {d // c ≤ d}) : con c.quotient :=
{ r := λ x y, con.lift_on₂' x y d.1 $ λ p q r s hp hq, iff_iff_eq.1
         ⟨λ h', d.1.trans (d.1.symm ((le_def c d.1).1 d.2 p r $ rel c hp)) $
                d.1.trans h' ((le_def c d.1).1 d.2 q s $ rel c hq),
          λ h', d.1.trans ((le_def c d.1).1 d.2 p r $ rel c hp) (d.1.trans h' $
                d.1.symm ((le_def c d.1).1 d.2 q s $ rel c hq))⟩,
  r_iseqv := ⟨λ x, quotient.induction_on' x $ λ y, d.1.refl y,
              λ x y, quotient.induction_on₂' x y $ λ _ _ h', d.1.symm h',
              λ x y z, quotient.induction_on₃' x y z $ λ _ _ _ h1 h2, d.1.trans h1 h2⟩,
  r_mul := λ w x y z, quotient.induction_on₂' w x $
             λ _ _, quotient.induction_on₂' y z $ λ _ _ h1 h2, d.1.mul h1 h2 }

def of_con (d : con c.quotient) : con M :=
{ r := λ x y, d ↑x ↑y,
  r_iseqv := ⟨λ x, d.refl ↑x, λ _ _ h, d.symm h, λ _ _ _ h1 h2, d.trans h1 h2⟩,
  r_mul := by intros; rw [←coe_mul, ←coe_mul]; exact d.mul a a_1 }

lemma le_of_con (d : con c.quotient) : c ≤ c.of_con d :=
(le_def c $ c.of_con d).2 $ λ x y h, show d x y, from ((c.eq _ _).2 h) ▸ d.refl x

theorem left_inverse (d : {d // c ≤ d}) : c.of_con (c.to_con d) = d.1 :=
by ext; refl

theorem right_inverse (d : con c.quotient) : c.to_con ⟨(c.of_con d), (c.le_of_con d)⟩ = d :=
by ext; rcases x; rcases y; refl

variables {f c}

lemma ker_eq_of_equiv (h : c.quotient ≃* P) (f : M →* P) (H : ∀ x y, c x y → f x = f y) 
  (hh : h.to_monoid_hom = c.lift f H) : con.ker f = c :=
le_antisymm ((le_def _ _).2 $ λ x y hk, by 
    rw [con.ker_rel, ←lift_coe H x, ←lift_coe H y, ←hh] at hk;
    exact (c.eq _ _).1 (h.to_equiv.injective hk))
  ((le_def _ _).2 $ λ x y h, H x y h)
 
variables (c)

noncomputable def quotient_ker_equiv_range (f : M →* P) : (con.ker f).quotient ≃* f.range :=
{ map_mul' := monoid_hom.map_mul _,
  ..@equiv.of_bijective _ _
      ((@mul_equiv.to_monoid_hom (ker_lift f).range _ _ _ (mul_equiv.submonoid_congr ker_lift_range_eq)).comp
        (ker_lift f).range_mk) $
      function.bijective_comp (equiv.bijective _)
        ⟨λ x y h, injective_ker_lift f $ by rcases x; rcases y; injections, 
         λ ⟨w, z, hzm, hz⟩, ⟨z, by rcases hz; rcases _x; refl⟩⟩ }

lemma lift_surjective_of_surjective (hf : function.surjective f) : function.surjective (ker_lift f) :=
λ y, exists.elim (hf y) $ λ w hw, ⟨w, hw⟩

noncomputable def quotient_ker_equiv_of_surjective (f : M →* P) (hf : function.surjective f) :
  (con.ker f).quotient ≃* P :=
{ map_mul' := monoid_hom.map_mul _,
  ..(@equiv.of_bijective _ _ (ker_lift f) ⟨injective_ker_lift f, lift_surjective_of_surjective hf⟩) }

lemma subtype_eq (A : submonoid M) : c.subtype A = con.ker (c.mk'.comp A.subtype) :=
con.ext $ λ x y,
  ⟨λ h, show ((x : M) : c.quotient) = (y : M), from (c.eq _ _).2 $ c.subtype_apply.2 h,
   λ h, by rw [subtype_apply, ←mk'_ker c]; simpa using h⟩

noncomputable def submonoid_quotient_equiv (A : submonoid M) :
  (c.subtype A).quotient ≃* (c.mk'.comp A.subtype).range :=
mul_equiv.trans (congr (subtype_eq c A)) $ quotient_ker_equiv_range (c.mk'.comp A.subtype)

lemma surjective_of_con_lift (d : con M) (h : c ≤ d) : function.surjective (c.map d h) :=
λ x, by rcases x; exact ⟨x, rfl⟩

noncomputable def quotient_quotient_equiv_quotient (c d : con M) (h : c ≤ d) :
  (con.ker (c.map d h)).quotient ≃* d.quotient :=
quotient_ker_equiv_of_surjective _ $ surjective_of_con_lift c d h

def correspondence : ((≤) : {d // c ≤ d} → {d // c ≤ d} → Prop) ≃o
((≤) : con c.quotient → con c.quotient → Prop) :=
{ to_fun := λ d, c.to_con d,
  inv_fun := λ d, subtype.mk (c.of_con d) (c.le_of_con d),
  left_inv := λ d, by simp [c.left_inverse d],
  right_inv := λ d, by simp [c.right_inverse d],
  ord := λ a b,
    ⟨λ hle, (le_def _ _).2 $ λ x y, con.induction_on₂ x y $
       λ w z h, by apply (le_def _ _).1 hle w z h,
     λ H, (le_def _ _).2 $ λ p q h, by apply (le_def _ _).1 H (p : _) (q : _) h⟩ }

end con
