//! zinc

library GnollUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState {
        // Deadly Poisons (Gnoll)
    public struct GnollUpgrades extends UpgradeDefinition {
        module UpgradeModule;
        
        private static DefenderRace Gnoll = 0;
        
        public static method isHunter(unit u) -> boolean {
            return Gnoll.isChildId(GetUnitTypeId(u));
        }
        
        public method setup() {
            UpgradeLevel up = 0;
            thistype.Gnoll = DefenderRace.fromName("Gnoll");
            
            Upgrades.begin("Deadly Poisons", "all");
                up = Upgrades.addUnitConversion('q139', function(unit u) -> boolean {
                    integer id = GetUnitTypeId(u);
                    return id == 'o027' || id == 'o00B';
                }, 'S00E', 'S00U');
                
                up.learnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
                    player p = pu.player();
                    SetPlayerTechMaxAllowed(p, 'o027', -1); // Enable Deadly
                    SetPlayerTechMaxAllowed(p, 'o00B', 0);
                };
                up.unlearnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
                    player p = pu.player();
                    SetPlayerTechMaxAllowed(p, 'o00B', -1);
                    SetPlayerTechMaxAllowed(p, 'o027', 0);
                };
            Upgrades.end();
            
            Upgrades.begin("Sentry Ward", "all");
                Upgrades.addEx('q284', function(unit u) -> boolean {
                    return thistype.Gnoll.isWidgetId(GetUnitTypeId(u));
                });
                    Upgrades.addEffect(UpgradeAbilityEffect.create('A01G'));
            Upgrades.end();
            
            Upgrades.begin("Advanced Masonry", "all");
            Upgrades.addRequirement('q237');
            Upgrades.end();
            
            Upgrades.begin("Adept Hunter Training", "all");
            Upgrades.add('q251', thistype.isHunter, function(unit u) {
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
        }
    }
}

//! endzinc