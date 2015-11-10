//! zinc

library DefenderUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState {
    public struct DefenderUpgrades extends UpgradeDefinition {
        module UpgradeModule;
		
		public static method isWall(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h02A' || id == 'h00K' || id == 'h00J' || 
				   id == 'h00I' || id == 'h02V' || id == 'h02U' || 
				   id == 'h01D' || id == 'h028' || id == 'h01E' || 
				   id == 'h03B' || id == 'h003' || id == 'h00L' || 
				   id == 'h01Y' || id == 'h006' || id == 'h005' || 
				   id == 'h01S' || id == 'h030' || id == 'h041' || 
				   id == 'h03C' || id == 'h015' || id == 'h042' || 
				   id == 'h034' || id == 'h026' || id == 'h00V' || 
				   id == 'h01R' || id == 'h031' || id == 'h02Z' || 
				   id == 'h02X' || id == 'h00U' || id == 'h01L' || 
				   id == 'h00G' || id == 'h00H' || id == 'h02Y' || 
				   id == 'h027' || id == 'h000' || id == 'u011' || 
				   id == 'h014';
        }
		
        public method setup() {
            Upgrades.begin("Health Upgrade", "all");
				Upgrades.addEx('q209', UnitManager.isDefender);
					Upgrades.addEffect(UpgradeHPEffect.create(100));
				Upgrades.addEx('q210', UnitManager.isDefender);
					Upgrades.continueEffect();
				Upgrades.addEx('q211', UnitManager.isDefender);
					Upgrades.continueEffect();
				Upgrades.addEx('q212', UnitManager.isDefender);
					Upgrades.continueEffect();
				Upgrades.setLastAsRecursive();
				Upgrades.addEx('q260', UnitManager.isDefender);
					Upgrades.continueEffect();
			Upgrades.end();
			
			Upgrades.begin("Backpack", "all");
				Upgrades.addEx('q010', UnitManager.isDefender);
					Upgrades.addEffect(UpgradeAbilityEffect.create('A013'));
				Upgrades.addEx('q011', UnitManager.isDefender);
					Upgrades.continueEffect();
            Upgrades.end();
			
			Upgrades.begin("Basic Reinforcement", "all");
				Upgrades.addEx('q013', thistype.isWall);
					Upgrades.addEffect(UpgradeHPEffect.create(50));
				Upgrades.addEx('q014', thistype.isWall);
					Upgrades.continueEffect();
            Upgrades.end();
			
            Upgrades.begin("Enhanced Defenses", "all");
				Upgrades.addEx('q236', thistype.isWall);
					Upgrades.addEffect(UpgradeHPEffect.create(150));
            Upgrades.end();
        }
    }
	
	public struct ManaVialUpgrade extends UpgradeDefinition {
		module UpgradeModule;
		private static DefenderRace Faerie = 0;
		private static DefenderRace Morphling = 0;
		
		public static method isFaerieOrMorphling(unit u) -> boolean {
			integer i = GetUnitTypeId(u);
			return Faerie.isWidgetId(i) || Morphling.isWidgetId(i);
		}
		
		public method setup() {
			thistype.Faerie = DefenderRace.fromName("Faerie");
			thistype.Morphling = DefenderRace.fromName("Morphling");
			
			Upgrades.begin("Mana Vial", "all");
				Upgrades.addWithData('q094', thistype.isFaerieOrMorphling, DefaultUpgrades.incrMaxMana, DefaultUpgrades.decrMaxMana, 50);
				Upgrades.addWithData('q095', thistype.isFaerieOrMorphling, DefaultUpgrades.incrMaxMana, DefaultUpgrades.decrMaxMana, 50);
				Upgrades.setLastAsRecursive();
				Upgrades.addWithData('q096', thistype.isFaerieOrMorphling, DefaultUpgrades.incrMaxMana, DefaultUpgrades.decrMaxMana, 50);
            Upgrades.end();
		}
	}
	
	// Infantry Survival Training
    public struct InfantryUpgrade extends UpgradeDefinition {
        module UpgradeModule;
        public static method isInfantry(unit u) -> boolean {
            return thistype.isStoneThrower(u) ||
				   thistype.isHeadHunter(u) ||
				   thistype.isTracker(u) ||
				   thistype.isShaman(u) ||
				   thistype.isSpearloc(u);   
        }
		
		public static method isStoneThrower(unit u) -> boolean {
			return GetUnitTypeId(u) == 'e01A';
		}
		
		public static method isHeadHunter(unit u) -> boolean {
			return GetUnitTypeId(u) == 'h04G';
		}
		
		public static method isTracker(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
			return id == 'n01I' || id == 'n014';
		}
		
		public static method isShaman(unit u) -> boolean {
			return GetUnitTypeId(u) == 'n021';
		}
		
		public static method isSpearloc(unit u) -> boolean {
			return GetUnitTypeId(u) == 'h04E';
		}
		
        public method setup() {
            Upgrades.begin("Infantry Survival Training", "all");
            Upgrades.addWithData('q239', thistype.isInfantry, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 150);
            Upgrades.end();
			
			// Disabled for now!
			
			// Makrura
            // Level 1 - Increases the maximum hit points of Stone Throwers by 200, mana by 2, damage by 20, and attack range by 250.
			Upgrades.begin("Stone Thrower Adept Training", "all");
            Upgrades.add('q047', thistype.isInfantry, 0, 0);
            Upgrades.end();
			
			// Troll
            // Level 1 - Increases the maximum hit points of Head Hunters by 200, damage by 10, and attack range by 400.
			Upgrades.begin("Head Hunter Adept Training", "all");
            Upgrades.add('q039', thistype.isInfantry, 0, 0);
            Upgrades.end();
			
			// Gnoll
            // Level 1 - Increases the maximum hit points of Trackers by 150, attack range by 250, and sight range by 200.
			Upgrades.begin("Tracker Adept Training", "all");
            Upgrades.add('q045', thistype.isInfantry, 0, 0);
            Upgrades.end();
    
			// Murloc
            // Level 1 - Increases the maximum hit points of Spearlocs by 250, mana by 3, and attack damage by 25.
            Upgrades.begin("Spearloc Adept Training", "all");
            Upgrades.add('q043', thistype.isInfantry, 0, 0);
            Upgrades.end();
        }
    }
	
	
	
	    // Harvesting
    public struct Upgrade29Upgrade extends UpgradeDefinition {
        module UpgradeModule;
		public static method isNormalWorker(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h033' || id == 'h02T' || id == 'h044' || 
				   id == 'h022' || id == 'h00C' || id == 'h00Y' || 
				   id == 'h00A' || id == 'h04F' || id == 'e014' || 
				   id == 'h03R' || id == 'h00W' || id == 'h00B' || 
				   id == 'h038' || id == 'h01X';
        }
		
        public static method isNatureWorker(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'e005' || id == 'e01C' || id == 'e01E' || id == 'e01F' || id == 'e01G';
        }
		
		public static method isRadioWorker(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'e00G' || id == 'e01H' || id == 'e01I' || id == 'e01J' || id == 'e01K';
        }
		
		public static method isHealthUpgradableWorker(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h033' || id == 'h02T' || id == 'h044' || 
				   id == 'h00C' || id == 'h00Y' || id == 'e00G' ||
				   id == 'h00A' || id == 'h04F' || id == 'e014' ||
				   id == 'h03R' || id == 'h00W' || id == 'h01X' ||
				   id == 'h00B' || id == 'e005' || id == 'h038';
        }
		
		public static method incrHarvestAbilities(unit u) {
			// Normal
			IncUnitAbilityLevel(u, 'A0PA');
			IncUnitAbilityLevel(u, 'A0D1');
			IncUnitAbilityLevel(u, 'A039');
			IncUnitAbilityLevel(u, 'A07H');
			IncUnitAbilityLevel(u, 'A0NP');
		}
		
		public static method decrHarvestAbilities(unit u) {
			// Normal
			DecUnitAbilityLevel(u, 'A0PA');
			DecUnitAbilityLevel(u, 'A0D1');
			DecUnitAbilityLevel(u, 'A039');
			DecUnitAbilityLevel(u, 'A07H');
			DecUnitAbilityLevel(u, 'A0NP');
		}
		
        public method setup() {
			// Nature
            Upgrades.begin("Lumber Harvesting", "all");
            //Upgrades.addUnitConversion('q051', thistype.isNatureWorker, 'S00I', 'S00J');
            //Upgrades.addUnitConversion('q052', thistype.isNatureWorker, 'S00K', 'S00I');
            //Upgrades.addUnitConversion('q053', thistype.isNatureWorker, 'S00L', 'S00K');
            //Upgrades.addUnitConversion('q054', thistype.isNatureWorker, 'S00M', 'S00L');
			Upgrades.addRequirement('q051');
			Upgrades.addRequirement('q052');
			Upgrades.addRequirement('q053');
			Upgrades.addRequirement('q054');
            Upgrades.end();
			
			// Radioactive
            Upgrades.begin("Lumber Harvesting", "all");
            //Upgrades.addUnitConversion('q279', thistype.isRadioWorker, 'S00O', 'S00N');
            //Upgrades.addUnitConversion('q280', thistype.isRadioWorker, 'S00P', 'S00O');
            //Upgrades.addUnitConversion('q281', thistype.isRadioWorker, 'S00Q', 'S00P');
            //Upgrades.addUnitConversion('q282', thistype.isRadioWorker, 'S00R', 'S00Q');
			Upgrades.addRequirement('q279');
			Upgrades.addRequirement('q280');
			Upgrades.addRequirement('q281');
			Upgrades.addRequirement('q282');
            Upgrades.end();			
			
			// All Others
			Upgrades.begin("Lumber Harvesting", "all");
            Upgrades.add('q232', thistype.isNormalWorker, thistype.incrHarvestAbilities, thistype.decrHarvestAbilities);
            Upgrades.add('q233', thistype.isNormalWorker, thistype.incrHarvestAbilities, thistype.decrHarvestAbilities);
            Upgrades.add('q234', thistype.isNormalWorker, thistype.incrHarvestAbilities, thistype.decrHarvestAbilities);
            Upgrades.add('q235', thistype.isNormalWorker, thistype.incrHarvestAbilities, thistype.decrHarvestAbilities);
            Upgrades.end();
			
			// Health Upgrades
			Upgrades.begin("Harvester Survival Training", "all");
            Upgrades.addWithData('q202', thistype.isHealthUpgradableWorker, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
            Upgrades.addWithData('q203', thistype.isHealthUpgradableWorker, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
            Upgrades.end();
        }
    }
}

//! endzinc