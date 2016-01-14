//! zinc

library TrollUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState {
        // Spiked Structures (Troll)
    public struct TrollUpgrades extends UpgradeDefinition {
        module UpgradeModule;
        
        public static method isHunter(unit u) -> boolean {
            return DefenderRace.fromName("Troll").isChildId(GetUnitTypeId(u));
        }
        public static method isTowerOrWall(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return isTower(u) || id == 'h00L' || id == 'h00G';
        }
        
        public static method isTower(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'n005' || id == 'n003' || id == 'n004' || id == 'n002';
        }
        
        public static method isWorker(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h00C' || id == 'h03R';
        }
        
        public method setup() {
            UpgradeLevel up = 0;
            Upgrades.begin("Spiked Structures", "all");
                Upgrades.add('q245', thistype.isTowerOrWall, function(unit u) {
                    UnitAddAbility(u, 'A065');
                    AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 50);
                }, function(unit u) {
                    UnitRemoveAbility(u, 'A065');
                    AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -50);
                });
                Upgrades.add('q246', thistype.isTowerOrWall, function(unit u) {
                    IncUnitAbilityLevel(u, 'A065');
                    AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 50);
                }, function(unit u) {
                    DecUnitAbilityLevel(u, 'A065');
                    AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -50);
                });
            Upgrades.end();
            
            Upgrades.begin("Adept Hunter Training", "all");
                Upgrades.add('q247', thistype.isHunter, function(unit u) {
                    AddUnitMaxState(u, UNIT_STATE_MAX_MANA, 200);
                    AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 400);
                    AddUnitBonus(u, BONUS_ATTACK_SPEED, 15); // 15%
                    AddUnitBonus(u, BONUS_DAMAGE, 20);
                }, function(unit u) {
                    AddUnitMaxState(u, UNIT_STATE_MAX_MANA, -200);
                    AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -400);
                    AddUnitBonus(u, BONUS_ATTACK_SPEED, -15); // 15%
                    AddUnitBonus(u, BONUS_DAMAGE, -20);
                });
            Upgrades.end();
            
            Upgrades.begin("Haste", "all");
                Upgrades.add('q248', thistype.isTower, function(unit u) {
                    AddUnitBonus(u, BONUS_ATTACK_SPEED, 20);
                }, function(unit u) {
                    AddUnitBonus(u, BONUS_ATTACK_SPEED, -20);
                });
            Upgrades.end();
            
            Upgrades.begin("Cannibalism Reform", "all");
                up = Upgrades.addUnitConversion('q229', thistype.isWorker, 'S008', 'S00V');
                up.learnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
                    player p = pu.player();
                    SetPlayerTechMaxAllowed(p, 'h03R', -1); // Enable 5 Food
                    SetPlayerTechMaxAllowed(p, 'h00C', 0);
                };
                up.unlearnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
                    player p = pu.player();
                    SetPlayerTechMaxAllowed(p, 'h00C', -1);
                    SetPlayerTechMaxAllowed(p, 'h03R', 0);
                    
                };
            Upgrades.end();
        }
    }
}

//! endzinc