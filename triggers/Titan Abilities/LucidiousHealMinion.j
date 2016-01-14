//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

// TLAE
library LucidiousHealMinion requires GenericTitanTargets {
    private struct LucidiousHealMinion extends GenericTitanHeal {
        module GenericTitanBounceHeal;
        
        method abilityId() -> integer {
            return 'TLNE';
        }
        
        method onSetup(integer level) {
            this.bounceRange = 600.0;
            this.bounceTimerDelay = 0.12;
            
            if (level == 1){
                this.damageAmount = 300.0;
                this.bounceCountMax = 1;
            }
            else if (level == 2){
                this.damageAmount = 400.0;
                this.bounceCountMax = 2;
            }
            else if (level == 3){
                this.damageAmount = 500.0;
                this.bounceCountMax = 2;
            }
            else if (level == 4){
                this.damageAmount = 600.0;
                this.bounceCountMax = 3;
            }
        }
        
        public method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitHealable(u, this.caster);
        }
    }
}


//! endzinc