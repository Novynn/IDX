//! zinc

library FaerieUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState {
        // Enhanced Energy Focusing
    public struct FaerieUpgrades extends UpgradeDefinition {
        module UpgradeModule;
        
        public static DefenderRace Faerie = 0;
        
        public static method isFaerie(unit u) -> boolean {
            return Faerie.isWidgetId(GetUnitTypeId(u));
        }
        
        public method setup() {
            UpgradeLevel up = 0;
            
            thistype.Faerie = DefenderRace.fromName("Faerie");
            
            Upgrades.begin("Enhanced Energy Focusing", "all");
                Upgrades.addRequirement('q277');
            Upgrades.end();
            
            Upgrades.begin("Adept Battle Training", "all");
                Upgrades.addUnitConversion('q150', thistype.isFaerie, 'S005', 'S007');
            Upgrades.end();
            
            Upgrades.begin("Improved Masonry ", "all");
                Upgrades.addRequirement('q151');
                Upgrades.addRequirement('q152');
                Upgrades.addRequirement('q153');
            Upgrades.end();
            
            Upgrades.begin("Adept Caster Training", "all");
                Upgrades.addRequirement('q154');
                Upgrades.addRequirement('q155');
            Upgrades.end();
            
            Upgrades.begin("Mystic Training", "all");
                Upgrades.addRequirement('q156');
                Upgrades.addRequirement('q157');
            Upgrades.end();
            
            Upgrades.begin("Ultimate Mystic Training", "all");
                Upgrades.addRequirement('q158');
            Upgrades.end();
            
            Upgrades.begin("Imbued Scroll", "all");
                Upgrades.addRequirement('q159');
            Upgrades.end();
            
            Upgrades.begin("Faerie Scroll", "all");
                Upgrades.addRequirement('q160');
            Upgrades.end();
            
            Upgrades.begin("Holy Water", "all");
            up = Upgrades.addUnitConversion('q131', function(unit u) -> boolean {
                integer id = GetUnitTypeId(u);
                return id == 'o011' || id == 'o01N';
            }, 'S010', 'S011');
            
            up.learnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
                player p = pu.player();
                SetPlayerTechMaxAllowed(p, 'o011', -1); // Enable Enhanced
                SetPlayerTechMaxAllowed(p, 'o01N', 0);
            };
            up.unlearnEvent = function(PlayerUpgradeData pu, UpgradeLevel up, unit u) {
                player p = pu.player();
                SetPlayerTechMaxAllowed(p, 'o01N', -1);
                SetPlayerTechMaxAllowed(p, 'o011', 0);
            };
            Upgrades.end();
        }
    }
}

//! endzinc