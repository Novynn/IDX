//! zinc

library NatureUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState, BonusMod {
    public struct NatureUpgrades extends UpgradeDefinition {
        module UpgradeModule;
        public static method isMystic(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'e003' || id == 'e018';
        }
        
        public static method isSpear(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h00R' || id == 'h01W';
        }
        
        public static method isProtector(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h00T' || id == 'h01P';
        }
        
        public static method isArmyUnit(unit u) -> boolean {
            return thistype.isMystic(u) || thistype.isSpear(u) || thistype.isProtector(u);
        }
        
        public static method isHunter(unit u) -> boolean {
            return GetUnitTypeId(u) == 'H00S';
        }

        
        public method setup() {
            Upgrades.begin("Spear Thrower Training", "all");
            Upgrades.addRequirement('q046');
            Upgrades.end();
            
            Upgrades.begin("Ancient Mystics Training", "all");
            Upgrades.addRequirement('q048');
            Upgrades.end();
            
            Upgrades.begin("Venomous Protector Training", "all");
            Upgrades.addRequirement('q060');
            Upgrades.end();
            
            Upgrades.begin("Spear Thrower Adept Training", "all");
            Upgrades.addUnitConversion('q064', thistype.isSpear, 'S009', 'S00A');
            Upgrades.end();
            
            Upgrades.begin("Ancient Mystics Adept Training", "all");
            Upgrades.addUnitConversion('q042', thistype.isMystic, 'S00B', 'S00C');
            Upgrades.end();
            
            Upgrades.begin("Venomous Protector Adept Training", "all");
            Upgrades.addUnitConversion('q065', thistype.isProtector, 'S00G', 'S00H');
            Upgrades.end();
            
            Upgrades.begin("Enhanced Mystics Training", "all");
            Upgrades.add('q004', thistype.isMystic, function(unit u) {
                IncUnitAbilityLevel(u, 'A0IK');
                IncUnitAbilityLevel(u, 'A0IJ');
                AddUnitMaxState(u, UNIT_STATE_MAX_MANA, 2);
            }, function(unit u) {
                DecUnitAbilityLevel(u, 'A0IK');
                DecUnitAbilityLevel(u, 'A0IJ');
                AddUnitMaxState(u, UNIT_STATE_MAX_MANA, -2);
            });
            Upgrades.end();
            
            Upgrades.begin("Enhanced Poisonous Sap", "all");
            Upgrades.add('q038', thistype.isArmyUnit, function(unit u) {
                IncUnitAbilityLevel(u, 'A0H7');
            }, function(unit u) {
                DecUnitAbilityLevel(u, 'A0H7');
            });
            Upgrades.end();
            
            Upgrades.begin("Enhanced Protection", "all");
            Upgrades.add('q223', thistype.isProtector, function(unit u) {
                AddUnitBonus(u, BONUS_ARMOR, 3);
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 100);
            }, function(unit u) {
                AddUnitBonus(u, BONUS_ARMOR, -3);
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -100);
            });
            Upgrades.end();
            
            Upgrades.begin("Adept Hunter Training", "all");
            Upgrades.add('q104', thistype.isHunter, function(unit u) {
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 200);
                AddUnitBonus(u, BONUS_ATTACK_SPEED, 15); // 15%
                AddUnitBonus(u, BONUS_DAMAGE, 20);
            }, function(unit u) {
                AddUnitBonus(u, BONUS_ATTACK_SPEED, -15); // 15%
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -200);
                AddUnitBonus(u, BONUS_DAMAGE, -20);
            });
            Upgrades.end();
        }
    }
}

//! endzinc