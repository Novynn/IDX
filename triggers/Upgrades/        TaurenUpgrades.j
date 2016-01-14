//! zinc

library TaurenUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState {
          // Survival Skills
    public struct Upgrade105Upgrade extends UpgradeDefinition {
        module UpgradeModule;
        public static method isTauren(unit u) -> boolean {
            return DefenderRace.fromName("Tauren").isWidgetId(GetUnitTypeId(u));
        }
        
        public method setup() {
            Upgrades.begin("Survival Skills", "all");
                Upgrades.addRequirement('q193');
            Upgrades.end();
            
            Upgrades.begin("Ancestral Rage", "all");
                Upgrades.addRequirement('q187');
            Upgrades.end();
            
            Upgrades.begin("Basic Earth Mastery", "all");
                Upgrades.addRequirement('q180');
                Upgrades.addRequirement('q181');
            Upgrades.end();
            
            Upgrades.begin("Tauren Caster Training", "all");
                Upgrades.addWithData('q164', thistype.isTauren, DefaultUpgrades.incrMaxMana, DefaultUpgrades.decrMaxMana, 50);
                Upgrades.addWithData('q165', thistype.isTauren, DefaultUpgrades.incrMaxMana, DefaultUpgrades.decrMaxMana, 50);
            Upgrades.end();

            Upgrades.begin("Tauren Master Training", "all");
            Upgrades.add('q044', thistype.isTauren, function(unit u) {
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 100);
                AddUnitMaxState(u, UNIT_STATE_MAX_MANA, 100);
                AddUnitBonus(u, BONUS_DAMAGE, 20);
                AddUnitBonus(u, BONUS_LIFE_REGEN, 2);
            }, function(unit u) {
                AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -100);
                AddUnitMaxState(u, UNIT_STATE_MAX_MANA, -100);
                AddUnitBonus(u, BONUS_DAMAGE, -20);
                AddUnitBonus(u, BONUS_LIFE_REGEN, -2);
            });
            Upgrades.end();
            
            Upgrades.begin("Battle Training", "all");
                Upgrades.addRequirement('q174');
            Upgrades.end();
            
            //'A0IH';
            
            Upgrades.begin("Totemic Defenses", "all");
                Upgrades.addRequirement('q057');
            Upgrades.end();
        }
    }
}

//! endzinc