//! zinc

library RadioactiveUpgrades requires DefaultUpgrades {
    public struct RadioactiveUpgrades extends UpgradeDefinition {
        module UpgradeModule;
		
		public static method isHunter(unit u) -> boolean {
            return DefenderRace.fromName("Radioactive").isChildId(GetUnitTypeId(u));
        }
		
        public method setup() {
            Upgrades.begin("Radiation Poisoning", "all");
				Upgrades.addRequirement('q009');
            Upgrades.end();
			
            Upgrades.begin("Tower Enhancement", "all");
				Upgrades.addRequirement('q091');
            Upgrades.end();
			
            Upgrades.begin("Modular Systems", "all");
				Upgrades.addRequirement('q231');
            Upgrades.end();
			
            Upgrades.begin("Adept Hunter Training", "all");
				// Level 1 - Increases the movement speed of the hunter by 60, range by 200, and allows the hunter to use the Atomic Split ability. 
				Upgrades.add('q097', thistype.isHunter, function(unit u) {
					AddUnitBonus(u, BONUS_ATTACK_SPEED, 15); // 15%
					AddUnitBonus(u, BONUS_MOVEMENT_SPEED, 60); // 15%
					AddUnitBonus(u, BONUS_DAMAGE, 20);
				}, function(unit u) {
					AddUnitBonus(u, BONUS_ATTACK_SPEED, -15); // 15%
					AddUnitBonus(u, BONUS_MOVEMENT_SPEED, -60); // 15%
					AddUnitBonus(u, BONUS_DAMAGE, -20);
				});
            Upgrades.end();
			
            Upgrades.begin("Reinforced Armor", "all");
				Upgrades.addWithData('q098', thistype.isHunter, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
				Upgrades.addWithData('q099', thistype.isHunter, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
				Upgrades.addWithData('q100', thistype.isHunter, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
				Upgrades.addWithData('q101', thistype.isHunter, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
				Upgrades.addWithData('q102', thistype.isHunter, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
				Upgrades.addWithData('q103', thistype.isHunter, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
            Upgrades.end();
        }
    }
}

//! endzinc