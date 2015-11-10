//TESH.scrollpos=9
//TESH.alwaysfold=0
//! zinc

// TLAE
library LucidiousHealNew requires GenericTitanTargets {
    private struct LucidiousHeal extends GenericTitanHeal {
        module GenericTitanBounceHeal;
        
        method abilityId() -> integer {
            return 'TLAE';
        }
        
        public method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitHealable(u, this.caster);
        }
    }
}


//! endzinc