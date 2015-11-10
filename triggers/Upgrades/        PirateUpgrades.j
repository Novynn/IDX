//! zinc

library PirateUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState {
    public struct PirateUpgrades extends UpgradeDefinition {
        module UpgradeModule;
		
        public static method isHunter(unit u) -> boolean {
            return DefenderRace.fromName("Pirate").isChildId(GetUnitTypeId(u));
        }
		
		public static method isExplosiveWall(unit u) -> boolean {
			return GetUnitTypeId(u) == 'u011';
		}
		
		public static method incrExplosives(unit u) {
			IncUnitAbilityLevel(u, 'A0FZ');
		}
		
		public static method decrExplosives(unit u) {
			DecUnitAbilityLevel(u, 'A0FZ');
		}
		
        public method setup() {
            Upgrades.begin("Incendiary", "all");
				Upgrades.addRequirement('q207');
            Upgrades.end();
			
            Upgrades.begin("Adept Hunter Training", "all");
            // Level 1 - Increases the movement speed of your Titan Hunter by 20, hit points by 300, adds an incendiary effect to your attack, and enables auxiliary cannons.
				Upgrades.add('q208', thistype.isHunter, function(unit u) {
					AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 300);
					AddUnitBonus(u, BONUS_MOVEMENT_SPEED, 20);
				}, function(unit u) {
					AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -300);
					AddUnitBonus(u, BONUS_MOVEMENT_SPEED, -20);
				});
            Upgrades.end();
			
            Upgrades.begin("Research Enhanced Explosives", "all");
				Upgrades.add('q213', thistype.isExplosiveWall, thistype.incrExplosives, thistype.decrExplosives);
				Upgrades.add('q214', thistype.isExplosiveWall, thistype.incrExplosives, thistype.decrExplosives);
				Upgrades.add('q215', thistype.isExplosiveWall, thistype.incrExplosives, thistype.decrExplosives);
            Upgrades.end();
        }
    }
}

//! endzinc