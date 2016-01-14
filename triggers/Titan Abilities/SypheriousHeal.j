//! zinc

library SypheriousHeal requires GenericTitanTargets {
    private struct SypheriousHeal extends GenericTitanHeal {
        module GenericTitanAreaHeal;
        
        method abilityId() -> integer {
            return 'TSAE';
        }
        
        method targetEffect() -> string {
            return "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl";
        }
        
        public method onCheckTarget(unit u) -> boolean {
            return IsUnitHealable(u, this.caster);
        }
    }
}

//! endzinc