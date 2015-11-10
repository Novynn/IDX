//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

// TLAE
library VoltronHeal requires GenericTitanTargets {
	private struct VoltronHeal extends GenericTitanHeal {
		module GenericTitanBounceHeal;
		
		method onSetup(integer level) {
			this.bounceCountMax = 0;
			
			if (level == 1){
                this.damageAmount = 200.0; // +200
            }
            else if (level == 2){
                this.damageAmount = 300.0; // +300
            }
            else if (level == 3){
                this.damageAmount = 500.0; // +300
            }
            else if (level == 4){
                this.damageAmount = 700.0; // +300
            }
		}
		
        method abilityId() -> integer {
            return 'TVAE';
        }
		
		method targetEffect() -> string {
			return "Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl";
		}
		
		method lightningEffect() -> string {
			return "CLSB";
		}
        
        public method onCheckTarget(unit u) -> boolean {
            return !IsUnitInGroup(u, this.bouncedUnits) && IsUnitHealable(u, this.caster);
        }
    }
}


//! endzinc