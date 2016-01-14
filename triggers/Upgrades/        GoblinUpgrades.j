//! zinc

library GoblinUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState {
          // Adept Hunter Training (Goblin)
    public struct GoblinUpgrades extends UpgradeDefinition {
        module UpgradeModule;
        public static method isHunter(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'H00Z';
        }
        
        public static method isCannonTower(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h012' || id == 'h04J' || id == 'h010' || id == 'h011';
        }
        
        public method setup() {
            UpgradeLevel up = 0;
            Upgrades.begin("Adept Hunter Training", "all");
            Upgrades.add('q055', thistype.isHunter, function(unit u) {
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 400);
                AddUnitBonus(u, BONUS_DAMAGE, 20);
                AddUnitBonus(u, BONUS_ATTACK_SPEED, 25);
                AddUnitBonus(u, BONUS_MOVEMENT_SPEED, 60);
            }, function(unit u) {
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -400);
                AddUnitBonus(u, BONUS_DAMAGE, -20);
                AddUnitBonus(u, BONUS_ATTACK_SPEED, -25);
                AddUnitBonus(u, BONUS_MOVEMENT_SPEED, -60);
            });
            Upgrades.end();
            
            Upgrades.begin("Improved Cannon Research", "all");
            Upgrades.add('q062', thistype.isCannonTower, function(unit u) {
                AddUnitBonus(u, BONUS_ATTACK_SPEED, 15);
            }, function(unit u) {
                AddUnitBonus(u, BONUS_ATTACK_SPEED, -15);
            });
            Upgrades.end();
            
            Upgrades.begin("Ballistics Research", "all");
            up = Upgrades.addUnitConversion('q066', function(unit u) -> boolean {
                integer id = GetUnitTypeId(u);
                return id == 'o010' || id == 'o00W';
            }, 'S00Y', 'S00Z');
            
            up.learnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
                player p = pu.player();
                SetPlayerTechMaxAllowed(p, 'o010', -1); // Enable Enhanced
                SetPlayerTechMaxAllowed(p, 'o00W', 0);
            };
            up.unlearnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
                player p = pu.player();
                SetPlayerTechMaxAllowed(p, 'o00W', -1);
                SetPlayerTechMaxAllowed(p, 'o010', 0);
            };
            Upgrades.end();
            
            Upgrades.begin("Advanced Wall Research", "all");
            up = Upgrades.addUnitConversion('q067', function(unit u) -> boolean {
                integer id = GetUnitTypeId(u);
                return id == 'h005' || id == 'h015';
            }, 'S00W', 'S00X');
            
            up.learnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
                player p = pu.player();
                SetPlayerTechMaxAllowed(p, 'h005', -1); // Enable Advanced
                SetPlayerTechMaxAllowed(p, 'h015', 0);
            };
            up.unlearnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
                player p = pu.player();
                SetPlayerTechMaxAllowed(p, 'h015', -1);
                SetPlayerTechMaxAllowed(p, 'h005', 0);
            };
            
            Upgrades.end();
        }
    }
}

//! endzinc