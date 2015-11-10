
//! zinc

library MorphlingUpgrades requires Upgrades, DefaultUpgrades, UnitManager, BonusMod {
    public struct MorphlingUpgrades extends UpgradeDefinition {
        module UpgradeModule;
		
		public static method isMorphling(unit u) -> boolean {
            return DefenderRace.fromName("Morphling").isWidgetId(GetUnitTypeId(u));
        }
		
		public static method incrBonusArmor(unit u) {
			AddUnitBonus(u, BONUS_ARMOR, 4);
		}
		
		public static method decrBonusArmor(unit u) {
			AddUnitBonus(u, BONUS_ARMOR, -4);
		}

        public method setup() {
            Upgrades.begin("Pulse Focusing", "all");
				Upgrades.addRequirement('q278');
            Upgrades.end();
     
            Upgrades.begin("Regeneration", "all");
            Upgrades.add('q219', thistype.isMorphling, function(unit u) {
					AddUnitBonus(u, BONUS_LIFE_REGEN, 4);
					AddUnitBonus(u, BONUS_MANA_REGEN, 4);
            }, function(unit u) {
					AddUnitBonus(u, BONUS_LIFE_REGEN, -4);
					AddUnitBonus(u, BONUS_MANA_REGEN, -4);
            });
            Upgrades.end();
			
            Upgrades.begin("Armored Skin", "all");
				Upgrades.add('q140', thistype.isMorphling, thistype.incrBonusArmor, thistype.decrBonusArmor);
				Upgrades.add('q141', thistype.isMorphling, thistype.incrBonusArmor, thistype.decrBonusArmor);
				Upgrades.add('q142', thistype.isMorphling, thistype.incrBonusArmor, thistype.decrBonusArmor);
				Upgrades.add('q143', thistype.isMorphling, thistype.incrBonusArmor, thistype.decrBonusArmor);
            Upgrades.end();
			
            Upgrades.begin("Animal Rage", "all");
				Upgrades.addRequirement('q093');
            Upgrades.end();
			
			Upgrades.begin("Battle Training", "all");
				Upgrades.addRequirement('q019');
				Upgrades.add('q020', thistype.isMorphling, function(unit u) {
					IncUnitAbilityLevel(u, 'A04P');
				}, function(unit u) {
					DecUnitAbilityLevel(u, 'A04P');
				});
				Upgrades.addRequirement('q021');
            Upgrades.end();
			
            Upgrades.begin("Enhanced Battle Training", "all");
				Upgrades.addRequirement('q023');
				Upgrades.addRequirement('q024');
            Upgrades.end();
			
			Upgrades.begin("Beast Form", "all");
				Upgrades.addRequirement('q026');
            Upgrades.end();
			
            Upgrades.begin("Expert Beast Training", "all");
				Upgrades.addRequirement('q089');
            Upgrades.end();
			
			Upgrades.begin("Deadly Spines", "all");
				Upgrades.addRequirement('q090');
            Upgrades.end();
			

			
            Upgrades.begin("Morphology", "all");
				Upgrades.add('q145', thistype.isMorphling, function(unit u) {
					IncUnitAbilityLevel(u, 'A07G');
					IncUnitAbilityLevel(u, 'A07E');
				}, function(unit u) {
					DecUnitAbilityLevel(u, 'A07G');
					DecUnitAbilityLevel(u, 'A07E');
				});
            Upgrades.end();
        }
    }
	
    public struct EnhancedDefensesUpgrade extends UpgradeDefinition {
        module UpgradeModule;
        public static method appliesTo(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h026' || id == 'h027';
        }
        public method setup() {
            Upgrades.begin("Enhanced Defenses", "all");
				Upgrades.addWithData('q005', thistype.appliesTo, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
				Upgrades.addWithData('q006', thistype.appliesTo, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
				Upgrades.addWithData('q007', thistype.appliesTo, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
				Upgrades.addWithData('q008', thistype.appliesTo, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
            Upgrades.end();
        }
    }
}

//! endzinc