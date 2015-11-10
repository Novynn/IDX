//! zinc

library MurlocUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState {
    public struct MurlocUpgrades extends UpgradeDefinition {
        module UpgradeModule;
		
		public static DefenderRace Murloc = 0;
		
		public static method isHunter(unit u) -> boolean {
			return Murloc.isChildId(GetUnitTypeId(u));
		}
		
		public static method isTower(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'o001' || id == 'o01F' || id == 'o000' || thistype.isMegaTower(u);
        }
		
		public static method isMegaTower(unit u) -> boolean {
			integer id = GetUnitTypeId(u);
			return id == 'o004' || id == 'o01Z';
		}
		
        public method setup() {
			UpgradeLevel up = 0;
			thistype.Murloc = DefenderRace.fromName("Murloc");
			
            Upgrades.begin("Pulverize", "all");
				Upgrades.addRequirement('q204');
            Upgrades.end();
			
			Upgrades.begin("Flaming Arrows", "all");
            Upgrades.add('q242', thistype.isMegaTower, function(unit u) {
				UnitAddAbility(u, 'A068');
				UnitMakeAbilityPermanent(u, true, 'A068');
            }, function(unit u) {
				UnitMakeAbilityPermanent(u, false, 'A068');
				UnitRemoveAbility(u, 'A068');
            });
            Upgrades.end();

			// Register the Chaos abilities.
			// UpgradeUnitEffect['o004'] = 'S016'; // Mega Dart Tower
			// UpgradeUnitEffect['o01Z'] = 'S017'; // Mega Long Dart Tower
			
            Upgrades.begin("Long Darts", "all");
				// Level 1 - Increases the range of Murloc's Mega Dart Towers by 100.
				up = Upgrades.addUnitConversion('q240', thistype.isMegaTower, 'S017', 'S016');
					
				up.learnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
					player p = pu.player();
					SetPlayerTechMaxAllowed(p, 'o01Z', -1); // Enable Enhanced
					SetPlayerTechMaxAllowed(p, 'o004', 0); // Disable others
				};
				up.unlearnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
					player p = pu.player();
					SetPlayerTechMaxAllowed(p, 'o004', -1); // Enable Normal
					SetPlayerTechMaxAllowed(p, 'o01Z', 0);
				};
            Upgrades.end();
			
			
			
            
			
            Upgrades.begin("Adept Hunter Training", "all");
				// Level 1 - Increases the hit points of your titan hunter by 200, attack speed by 20%, and movement speed by 15.
				Upgrades.add('q243', thistype.isHunter, function(unit u) {
					AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 200);
					AddUnitBonus(u, BONUS_ATTACK_SPEED, 20); // 15%
					AddUnitBonus(u, BONUS_MOVEMENT_SPEED, 15);
				}, function(unit u) {
					AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -200);
					AddUnitBonus(u, BONUS_ATTACK_SPEED, -20); // 15%
					AddUnitBonus(u, BONUS_MOVEMENT_SPEED, 15);
				});
            Upgrades.end();
        }
    }
}

//! endzinc