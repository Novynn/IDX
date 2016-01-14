//! zinc

library MagnataurUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState, BonusMod {
    // Arctic Endurance
    public struct MagnataurUpgrades extends UpgradeDefinition {
        module UpgradeModule;
        
        public static method isMagnataur(unit u) -> boolean {
            return DefenderRace.fromName("Magnataur").isWidgetId(GetUnitTypeId(u));
        }
        
        public static method isWall(unit u) -> boolean {
            integer id = GetUnitTypeId(u);
            return id == 'h00K' || id == 'h01D' || id == 'h042';
        }
        
        public method setup() {
            Upgrades.begin("Arctic Endurance", "all");
                Upgrades.addWithData('q012', thistype.isMagnataur, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
            Upgrades.end();
            Upgrades.begin("Defense Boost", "all");
                Upgrades.addRequirement('q049');
            Upgrades.end();
            Upgrades.begin("Polar Wrath", "all");
                Upgrades.addRequirement('q063');
                Upgrades.add('q285', thistype.isMagnataur, function(unit u) {
                    IncUnitAbilityLevel(u, 'A04H');
                }, function(unit u) {
                    DecUnitAbilityLevel(u, 'A04H');
                });
            Upgrades.end();
            
            Upgrades.begin("Advanced War Training", "all");
                Upgrades.addRequirement('q068');
            Upgrades.end();
            Upgrades.begin("Armored Skin", "all");
                Upgrades.addWithData('q069', thistype.isMagnataur, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
                Upgrades.addWithData('q070', thistype.isMagnataur, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
                Upgrades.addWithData('q071', thistype.isMagnataur, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
                Upgrades.addWithData('q072', thistype.isMagnataur, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
            Upgrades.end();
            Upgrades.begin("Enhanced Defenses", "all");
                Upgrades.addWithData('q073', thistype.isWall, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
                Upgrades.addWithData('q074', thistype.isWall, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
                Upgrades.addWithData('q075', thistype.isWall, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
                Upgrades.addWithData('q076', thistype.isWall, DefaultUpgrades.incrMaxHealth, DefaultUpgrades.decrMaxHealth, 50);
            Upgrades.end();
            Upgrades.begin("Frigid Climate", "all");
                Upgrades.addRequirement('q077');
            Upgrades.end();
            Upgrades.begin("Arctic Waters", "all");
                Upgrades.addRequirement('q078');
            Upgrades.end();
            Upgrades.begin("Arctic Wilderness Staff", "all");
                Upgrades.addRequirement('q079');
            Upgrades.end();
            
            Upgrades.begin("Inner Cold", "all");
                Upgrades.add('q081', thistype.isMagnataur, function(unit u) {
                    AddUnitBonus(u, BONUS_MOVEMENT_SPEED, 15);
                    IncUnitAbilityLevel(u, 'A04Z');
                }, function(unit u) {
                    AddUnitBonus(u, BONUS_MOVEMENT_SPEED, -15);
                    DecUnitAbilityLevel(u, 'A04Z');
                });
            Upgrades.end();
            Upgrades.begin("Icy Weapons", "all");
                Upgrades.addRequirement('q082');
            Upgrades.end();
            
            Upgrades.begin("Arctic Armor", "all");
                Upgrades.addRequirement('q083');
            Upgrades.end();
            
            Upgrades.begin("Ice Water", "all");
                Upgrades.addWithData('q084', thistype.isMagnataur, DefaultUpgrades.incrMaxMana, DefaultUpgrades.decrMaxMana, 25);
                Upgrades.addWithData('q085', thistype.isMagnataur, DefaultUpgrades.incrMaxMana, DefaultUpgrades.decrMaxMana, 25);
                Upgrades.addWithData('q086', thistype.isMagnataur, DefaultUpgrades.incrMaxMana, DefaultUpgrades.decrMaxMana, 25);
            Upgrades.end();
            
            Upgrades.begin("Northern Storms", "all");
                Upgrades.addRequirement('q087');
            Upgrades.end();
        }
    }
}

//! endzinc