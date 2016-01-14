//! zinc

library DraeneiUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState {
          // Arcane Gem
    public struct DraeneiUpgrades extends UpgradeDefinition {
        module UpgradeModule;
        
        public static method isHunter(unit u) -> boolean {
            return DefenderRace.fromName("Draenei").isChildId(GetUnitTypeId(u));
        }
        
        public static method isTowerWithMana(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'o02C' || id == 'o02D' || id == 'o02B';
        }
        
        public static method isTowerWithManaOrWall(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return thistype.isTowerWithMana(u) || id == 'h03X' || id == 'u014';
        }
        
        public static method incrManaHandling(unit u) {
            AddUnitMaxState(u, UNIT_STATE_MAX_MANA, 50);
            AddUnitBonus(u, BONUS_MANA_REGEN_PERCENT, 20);
        }
        
        public static method decrManaHandling(unit u) {
            AddUnitMaxState(u, UNIT_STATE_MAX_MANA, -50);
            AddUnitBonus(u, BONUS_MANA_REGEN_PERCENT, -20);
        }
        
        public method setup() {
            Upgrades.begin("Arcane Gem", "all");
            Upgrades.addRequirement('q136');
            Upgrades.end();
            
            Upgrades.begin("Adept Hunter Training", "all");
            Upgrades.add('q132', thistype.isHunter, function(unit u) {
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 200);
                AddUnitMaxState(u, UNIT_STATE_MAX_MANA, 400);
                AddUnitBonus(u, BONUS_DAMAGE, 20);
                AddUnitBonus(u, BONUS_ATTACK_SPEED, 15);
            }, function(unit u) {
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -200);
                AddUnitMaxState(u, UNIT_STATE_MAX_MANA, -400);
                AddUnitBonus(u, BONUS_DAMAGE, -20);
                AddUnitBonus(u, BONUS_ATTACK_SPEED, -15);
            });
            Upgrades.end();
            
            Upgrades.begin("Crystal Focusing", "all");
            Upgrades.add('q201', thistype.isTowerWithMana, function(unit u) {
                IncUnitAbilityLevel(u, 'A0DV');
            }, function(unit u) {
                DecUnitAbilityLevel(u, 'A0DV');
            });
            Upgrades.end();
            
            Upgrades.begin("Mana Handling", "all");
                Upgrades.add('q146', thistype.isTowerWithManaOrWall, thistype.incrManaHandling, thistype.decrManaHandling);
                Upgrades.add('q147', thistype.isTowerWithManaOrWall, thistype.incrManaHandling, thistype.decrManaHandling);
                Upgrades.add('q148', thistype.isTowerWithManaOrWall, thistype.incrManaHandling, thistype.decrManaHandling);
                Upgrades.add('q149', thistype.isTowerWithManaOrWall, thistype.incrManaHandling, thistype.decrManaHandling);
            Upgrades.end();
            
            Upgrades.begin("Advanced Unit Shielding", "all");
                Upgrades.add('q133', function(unit u) -> boolean {
                    integer id = GetUnitTypeId(u);
                    return id == 'u00W' || id == 'n01Y';
                }, function(unit u) {
                    AddUnitMaxState(u, UNIT_STATE_MAX_MANA, 50);
                    IncUnitAbilityLevel(u, 'A0DW');
                }, function(unit u) {
                    AddUnitMaxState(u, UNIT_STATE_MAX_MANA, -50);
                    DecUnitAbilityLevel(u, 'A0DW');
                });
            Upgrades.end();
            
            Upgrades.begin("Battle Construct Design", "all");
            Upgrades.addRequirement('q130');
            Upgrades.end();
            
            Upgrades.begin("Energy Manipulation Systems", "all");
            Upgrades.addWithData('q134', thistype.isHunter, DefaultUpgrades.incrMaxMana, DefaultUpgrades.decrMaxMana, 200);
            Upgrades.end();
        }
    }
}

//! endzinc