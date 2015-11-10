//! zinc

library DemonologistUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState, BonusMod {
	

    // Puppetry
    public struct DemonologistUpgrades extends UpgradeDefinition {
        module UpgradeModule;
		
		public static method isDemonologist(unit u) -> boolean {
            return DefenderRace.fromName("Demonologist").isWidgetId(GetUnitTypeId(u));
        }
		
        public static method isSummonedDemon(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'n00E' || id == 'U00S' || id == 'h01A' || 
				   id == 'e010' || id == 'n00F' || id == 'n00D';
        }
		
		public static method incrDemonicStrength(unit u) {
			if (GetUnitTypeId(u) == 'n00D') {
				AddUnitBonus(u, BONUS_DAMAGE, 5);
				AddUnitBonus(u, BONUS_ARMOR, 2);
			}
			else if (GetUnitTypeId(u) == 'n00E') {
				AddUnitBonus(u, BONUS_DAMAGE, 3);
				AddUnitBonus(u, BONUS_ARMOR, 2);
			}
			else if (GetUnitTypeId(u) == 'n00F') {
				AddUnitBonus(u, BONUS_DAMAGE, 10);
				AddUnitBonus(u, BONUS_ARMOR, 2);
			}
			else if (GetUnitTypeId(u) == 'h01A') {
				// Succubus
				AddUnitBonus(u, BONUS_DAMAGE, 5);
				AddUnitBonus(u, BONUS_ARMOR, 1);
			}
			else if (GetUnitTypeId(u) == 'e010') {
				// Fiend
				AddUnitBonus(u, BONUS_DAMAGE, 10);
				AddUnitBonus(u, BONUS_ARMOR, 1);
			}
			else if (GetUnitTypeId(u) == 'U00S') {
				// Balthasar
				AddUnitBonus(u, BONUS_DAMAGE, 10);
				AddUnitBonus(u, BONUS_ARMOR, 2);
			}
		}
		
		public static method decrDemonicStrength(unit u) {
			if (GetUnitTypeId(u) == 'n00D') {
				AddUnitBonus(u, BONUS_DAMAGE, -5);
				AddUnitBonus(u, BONUS_ARMOR, -2);
			}
			else if (GetUnitTypeId(u) == 'n00E') {
				AddUnitBonus(u, BONUS_DAMAGE, -3);
				AddUnitBonus(u, BONUS_ARMOR, -2);
			}
			else if (GetUnitTypeId(u) == 'n00F') {
				AddUnitBonus(u, BONUS_DAMAGE, -10);
				AddUnitBonus(u, BONUS_ARMOR, -2);
			}
			else if (GetUnitTypeId(u) == 'h01A') {
				// Succubus
				AddUnitBonus(u, BONUS_DAMAGE, -5);
				AddUnitBonus(u, BONUS_ARMOR, -1);
			}
			else if (GetUnitTypeId(u) == 'e010') {
				// Fiend
				AddUnitBonus(u, BONUS_DAMAGE, -10);
				AddUnitBonus(u, BONUS_ARMOR, -1);
			}
			else if (GetUnitTypeId(u) == 'U00S') {
				// Balthasar
				AddUnitBonus(u, BONUS_DAMAGE, -10);
				AddUnitBonus(u, BONUS_ARMOR, -2);
			}
		}
		
		public static method incrSummoning(unit u) {
			IncUnitAbilityLevel(u, 'A074');
			IncUnitAbilityLevel(u, 'A07A');
			IncUnitAbilityLevel(u, 'A07D');
		}
		
		public static method decrSummoning(unit u) {
			DecUnitAbilityLevel(u, 'A074');
			DecUnitAbilityLevel(u, 'A07A');
			DecUnitAbilityLevel(u, 'A07D');
		}
		
		private static DefenderRace demoRace = 0;
		
        public method setup() {
            Upgrades.begin("Puppetry", "all");
				Upgrades.addRequirement('q015');
            Upgrades.end();
            Upgrades.begin("Carrion Swarm", "all");
				Upgrades.addRequirement('q022');
            Upgrades.end();
            Upgrades.begin("Conflagration", "all");
				Upgrades.addRequirement('q025');
            Upgrades.end();
			Upgrades.begin("Ethereal Tearing", "all");
				Upgrades.addRequirement('q056');
            Upgrades.end();
			Upgrades.begin("Spirit Linking", "all");
				Upgrades.addRequirement('q061');
            Upgrades.end();
			Upgrades.begin("Demon Mastery", "all");
				Upgrades.addRequirement('q138');
            Upgrades.end();
			Upgrades.begin("Sacrifice", "all");
				Upgrades.addRequirement('q244');
            Upgrades.end();
			Upgrades.begin("Apprentice Demonology", "all");
				Upgrades.addRequirement('q252');
            Upgrades.end();
			Upgrades.begin("Enchantment", "all");
				Upgrades.addRequirement('q256');
				Upgrades.add('q283', thistype.isDemonologist, function(unit u) {
					IncUnitAbilityLevel(u, 'A0GT');
				}, function(unit u) {
					DecUnitAbilityLevel(u, 'A0GT');
				});
            Upgrades.end();
			
			Upgrades.begin("Demonic Strength", "all");
				Upgrades.add('q027', thistype.isSummonedDemon, thistype.incrDemonicStrength, thistype.decrDemonicStrength);
				Upgrades.add('q028', thistype.isSummonedDemon, thistype.incrDemonicStrength, thistype.decrDemonicStrength);
				Upgrades.add('q029', thistype.isSummonedDemon, thistype.incrDemonicStrength, thistype.decrDemonicStrength);
				Upgrades.add('q030', thistype.isSummonedDemon, thistype.incrDemonicStrength, thistype.decrDemonicStrength);
				Upgrades.add('q031', thistype.isSummonedDemon, thistype.incrDemonicStrength, thistype.decrDemonicStrength);
				Upgrades.add('q032', thistype.isSummonedDemon, thistype.incrDemonicStrength, thistype.decrDemonicStrength);
				Upgrades.add('q033', thistype.isSummonedDemon, thistype.incrDemonicStrength, thistype.decrDemonicStrength);
				Upgrades.add('q034', thistype.isSummonedDemon, thistype.incrDemonicStrength, thistype.decrDemonicStrength);
				Upgrades.add('q035', thistype.isSummonedDemon, thistype.incrDemonicStrength, thistype.decrDemonicStrength);
				Upgrades.add('q036', thistype.isSummonedDemon, thistype.incrDemonicStrength, thistype.decrDemonicStrength);
            Upgrades.end();
			
			Upgrades.begin("Enhanced Summoning Techniques", "all");
				Upgrades.addRequirement('q253');
				Upgrades.add('q254', thistype.isDemonologist, thistype.incrSummoning, thistype.decrSummoning);
				Upgrades.add('q255', thistype.isDemonologist, thistype.incrSummoning, thistype.decrSummoning);
            Upgrades.end();
			// Requires above!
			Upgrades.begin("Bound Summoning", "all");
				Upgrades.add('q059', thistype.isDemonologist, thistype.incrSummoning, thistype.decrSummoning);
            Upgrades.end();
			
			Upgrades.begin("Empowered Talismans", "all");
				Upgrades.addWithData('q137', function(unit u) -> boolean {
					integer id = GetUnitTypeId(u);
					DefenderRace r = thistype.demoRace;
					if (r == 0) {
						BJDebugMsg("|cffff0000ERROR - Failed to get DemonologistRace from DefenderRace.fromTypeId");
						return false;
					}
					
					return r.isWidgetId(id);
				}, DefaultUpgrades.incrMaxMana, DefaultUpgrades.decrMaxMana, 250);
            Upgrades.end();

            Upgrades.begin("Demonic Shielding", "all");
				Upgrades.addUnitConversion('q144', thistype.isDemonologist, 'S00S', 'S00T');
            Upgrades.end();
			
			thistype.demoRace = DefenderRace.fromName("Demonologist");
        }
    }

	// Enchanted Granite (Demonologist)
    public struct EnchantedGraniteUpgrade extends UpgradeDefinition {
        module UpgradeModule;
        public static method appliesTo(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h02A' || id == 'h01L';
        }
        public method setup() {
            Upgrades.begin("Enchanted Granite", "all");
            Upgrades.addWithData('q016', thistype.appliesTo, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
            Upgrades.addWithData('q017', thistype.appliesTo, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
            Upgrades.addWithData('q018', thistype.appliesTo, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
            Upgrades.end();
        }
    }
}

//! endzinc