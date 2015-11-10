//! zinc

library OgreUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState, BonusMod {
          // Bloodlust
    public struct OgreUpgrades extends UpgradeDefinition {
        module UpgradeModule;
		
		private static DefenderRace Ogre = 0;
		public static method isHunter(unit u) -> boolean {
            return Ogre.isChildId(GetUnitTypeId(u));
        }
		
		public static method isCatapult(unit u) -> boolean {
			integer id = GetUnitTypeId(u);
			return id == 'o01W' || id == 'o012' || id == 'o019' || id == 'o01E';
		}
		
		public static method isWallOrCatapult(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return thistype.isCatapult(u) || id == 'h03B' || id == 'h03C';
		}
		
		public static method incrCatapultBonus(unit u) {
			AddUnitBonus(u, BONUS_DAMAGE, 2);
			AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 35);
			IncUnitAbilityLevel(u, 'A0AY');
		}
		public static method decrCatapultBonus(unit u) {
			AddUnitBonus(u, BONUS_DAMAGE, -2);
			AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -35);
			DecUnitAbilityLevel(u, 'A0AY');
		}
		
		public static method incrFortificationBonus(unit u) {
			AddUnitBonus(u, BONUS_ARMOR, 1);
		}
		
		public static method decrFortificationBonus(unit u) {
			AddUnitBonus(u, BONUS_ARMOR, -1);
		}
		
		public static method incrSpeedBonus(unit u) {
			AddUnitBonus(u, BONUS_MOVEMENT_SPEED, 75);
		}
		
		public static method decrSpeedBonus(unit u) {
			AddUnitBonus(u, BONUS_MOVEMENT_SPEED, -75);
		}
		
		private static method setupCatapultUpgrades() {
			UpgradeLevel up = 0;
			
            Upgrades.begin("Artillery Range Enhancement", "all");
			// Level 1
			up = Upgrades.addUnitConversion('q105', function(unit u) -> boolean {
				integer id = GetUnitTypeId(u);
				return id == 'o01W' || id == 'o012';
			}, 'S012', 'S013');
			
			up.learnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
				player p = pu.player();
                SetPlayerTechMaxAllowed(p, 'o012', -1); // Enable Enhanced
                SetPlayerTechMaxAllowed(p, 'o01W', 0); // Disable others
            };
			up.unlearnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
				player p = pu.player();
                SetPlayerTechMaxAllowed(p, 'o01W', -1); // Enable Normal
                SetPlayerTechMaxAllowed(p, 'o012', 0);
            };
			
			// Level 2
			up = Upgrades.addUnitConversion('q106', function(unit u) -> boolean {
				integer id = GetUnitTypeId(u);
				return id == 'o012' || id == 'o019';
			}, 'S014', 'S012');
			
			up.learnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
				player p = pu.player();
                SetPlayerTechMaxAllowed(p, 'o019', -1); // Enable Super
                SetPlayerTechMaxAllowed(p, 'o012', 0); // Disable others
            };
			up.unlearnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
				player p = pu.player();
                SetPlayerTechMaxAllowed(p, 'o012', -1); // Enable Enhanced
                SetPlayerTechMaxAllowed(p, 'o019', 0);
            };
			
			// Level 3
			up = Upgrades.addUnitConversion('q107', function(unit u) -> boolean {
				integer id = GetUnitTypeId(u);
				return id == 'o019' || id == 'o01E';
			}, 'S015', 'S014');
			
			up.learnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
				player p = pu.player();
                SetPlayerTechMaxAllowed(p, 'o01E', -1); // Enable Mega
                SetPlayerTechMaxAllowed(p, 'o019', 0); // Disable others
            };
			up.unlearnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
				player p = pu.player();
                SetPlayerTechMaxAllowed(p, 'o019', -1); // Enable Super
                SetPlayerTechMaxAllowed(p, 'o01E', 0);
            };
			
            Upgrades.end();
		}
	
        public method setup() {
			thistype.Ogre = DefenderRace.fromName("Ogre");
            Upgrades.begin("Bloodlust", "all");
				Upgrades.addRequirement('q230'); // No effects
            Upgrades.end();
			
			// Does this upgrade even still exist?
            Upgrades.begin("Armor Plating", "all");
				Upgrades.addWithData('q194', thistype.isCatapult, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 100);
				Upgrades.addWithData('q195', thistype.isCatapult, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 100);
				Upgrades.addWithData('q196', thistype.isCatapult, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 100);
				Upgrades.addWithData('q197', thistype.isCatapult, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 100);
				Upgrades.addWithData('q198', thistype.isCatapult, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 100);
				Upgrades.addWithData('q199', thistype.isCatapult, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 100);
				Upgrades.addWithData('q200', thistype.isCatapult, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 100);
            Upgrades.end();

            Upgrades.begin("Artillery Damage Bonus - (Tier 1)", "all");
				Upgrades.add('q175', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
				Upgrades.add('q176', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
				Upgrades.add('q177', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
				Upgrades.add('q178', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
				Upgrades.add('q179', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
            Upgrades.end();
			
            Upgrades.begin("Artillery Damage Bonus - (Tier 2)", "all");
				Upgrades.add('q182', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
				Upgrades.add('q183', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
				Upgrades.add('q184', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
				Upgrades.add('q185', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
				Upgrades.add('q186', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
            Upgrades.end();
			
            Upgrades.begin("Artillery Damage Bonus - (Tier 3)", "all");
				Upgrades.add('q188', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
				Upgrades.add('q189', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
				Upgrades.add('q190', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
				Upgrades.add('q191', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
				Upgrades.add('q192', thistype.isCatapult, thistype.incrCatapultBonus, thistype.decrCatapultBonus);
            Upgrades.end();

            Upgrades.begin("Fortification Upgrade", "all");
				Upgrades.add('q121', thistype.isWallOrCatapult, thistype.incrFortificationBonus, thistype.decrFortificationBonus);
				Upgrades.add('q122', thistype.isWallOrCatapult, thistype.incrFortificationBonus, thistype.decrFortificationBonus);
				Upgrades.add('q123', thistype.isWallOrCatapult, thistype.incrFortificationBonus, thistype.decrFortificationBonus);
				Upgrades.add('q124', thistype.isWallOrCatapult, thistype.incrFortificationBonus, thistype.decrFortificationBonus);
				Upgrades.add('q125', thistype.isWallOrCatapult, thistype.incrFortificationBonus, thistype.decrFortificationBonus);
            Upgrades.end();

            Upgrades.begin("Catapult Speed Boost", "all");
            Upgrades.add('q127', thistype.isCatapult, thistype.incrSpeedBonus, thistype.decrSpeedBonus);
            Upgrades.add('q128', thistype.isCatapult, thistype.incrSpeedBonus, thistype.decrSpeedBonus);
            Upgrades.end();
			
			thistype.setupCatapultUpgrades();

            Upgrades.begin("Adept Hunter Training", "all");
            // Level 1 - Increases the mana capacity of your Titan Hunter by 200, hit points by 400, attack damage by 20, and movement speed by 60. Also makes his attacks have a 15% chance to afflict a unit with Soul Burn.
            Upgrades.add('q117', thistype.isHunter, function(unit u) {
                AddUnitMaxState(u, UNIT_STATE_MAX_MANA, 200);
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 400);
				AddUnitBonus(u, BONUS_DAMAGE, 20);
				AddUnitBonus(u, BONUS_MOVEMENT_SPEED, 60);
            }, function(unit u) {
                AddUnitMaxState(u, UNIT_STATE_MAX_MANA, -200);
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -400);
				AddUnitBonus(u, BONUS_DAMAGE, -20);
				AddUnitBonus(u, BONUS_MOVEMENT_SPEED, -60);
            });
            Upgrades.end();
        }
    }
}

//! endzinc