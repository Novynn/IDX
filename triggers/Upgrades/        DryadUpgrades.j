//! zinc

library DryadUpgrades requires Upgrades, DefaultUpgrades, FeralTowerRegeneration {
    public struct DryadUpgrades extends UpgradeDefinition {
        module UpgradeModule;
        
        public static method isHunter(unit u) -> boolean {
            return DefenderRace.fromName("Dryad").isChildId(GetUnitTypeId(u));
        }
        
        public static method isTower(unit u) -> boolean {
            return getFeralTowerLevel(u) != -1;
        }
        
        public method setup() {
            Upgrades.begin("Thorns Aura", "all");
            Upgrades.addRequirement('q224');
            Upgrades.end();
            
            Upgrades.begin("Paralyzing Thorns", "all");
            Upgrades.addRequirement('q220'); // No effects
            Upgrades.end();
            
            Upgrades.begin("Adept Hunter Training", "all");
            // Level 1 - Increases the damage of your Titan Hunter by 20, hit points by 200, attack speed by 15%, and mana by 400. Also allows the hunter to have a chance to perform critical strikes on his targets.
            Upgrades.add('q222', thistype.isHunter, function(unit u) {
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 200);
                AddUnitMaxState(u, UNIT_STATE_MAX_MANA, 400);
                AddUnitBonus(u, BONUS_ATTACK_SPEED, 15); // 15%
                AddUnitBonus(u, BONUS_DAMAGE, 20);
            }, function(unit u) {
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -200);
                AddUnitMaxState(u, UNIT_STATE_MAX_MANA, -400);
                AddUnitBonus(u, BONUS_ATTACK_SPEED, -15); // 15%
                AddUnitBonus(u, BONUS_DAMAGE, -20);
            });
            Upgrades.end();
            
            Upgrades.begin("Fertilizer", "all");
                Upgrades.add('q221', thistype.isTower, function(unit u) {
                    AddUnitBonus(u, BONUS_MANA_REGEN, 1);
                }, function(unit u) {
                    AddUnitBonus(u, BONUS_MANA_REGEN, -1);
                });
            Upgrades.end();
            
            Upgrades.begin("Nature's Grace", "all");
            Upgrades.addRequirement('q217');
            Upgrades.add('q218', thistype.isHunter, function(unit u) {
                IncUnitAbilityLevel(u, 'A0O6');
            }, function(unit u) {
                DecUnitAbilityLevel(u, 'A0O6');
            });
            Upgrades.end();
        }
    }
}

//! endzinc