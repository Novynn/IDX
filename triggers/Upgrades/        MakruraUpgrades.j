//! zinc

library MakruraUpgrades requires Upgrades, DefaultUpgrades, UnitManager, UnitMaxState {
    public struct MakruraUpgrades extends UpgradeDefinition {
        module UpgradeModule;
        public static method isHunter(unit u) -> boolean {
            return DefenderRace.fromName("Makrura").isChildId(GetUnitTypeId(u));
        }
        
        public method setup() {
            Upgrades.begin("Adept Hunter Training", "all");
            // Level 1 - Increases the speed of your Titan Hunter by 80, hit points by 200, attack speed by 15%, and hit point regeneration by 30%. Also grants the hunter an aura that increases the armor of all nearby friendly units by 10.
                Upgrades.add('q249', thistype.isHunter, function(unit u) {
                    AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, 200);
                    AddUnitBonus(u, BONUS_ATTACK_SPEED, 15); // 15%
                    AddUnitBonus(u, BONUS_MOVEMENT_SPEED, 80);
                    AddUnitBonus(u, BONUS_LIFE_REGEN, 2);
                }, function(unit u) {
                    AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -200);
                    AddUnitBonus(u, BONUS_ATTACK_SPEED, -15); // 15%
                    AddUnitBonus(u, BONUS_MOVEMENT_SPEED, -80);
                    AddUnitBonus(u, BONUS_LIFE_REGEN, -2);
                });
            Upgrades.end();
            
            Upgrades.begin("Electric Current", "all");
                Upgrades.add('q250', function(unit u) -> boolean { return GetUnitTypeId(u) == 'o00I'; }, function(unit u) {
                    UnitAddAbility(u, 'A069');
                    UnitMakeAbilityPermanent(u, true, 'A069');
                }, function(unit u) {
                    UnitMakeAbilityPermanent(u, false, 'A069');
                    UnitRemoveAbility(u, 'A069');
                });
            Upgrades.end();
            
            Upgrades.begin("Ultravision", "all");
                Upgrades.addRequirement('q257');
            Upgrades.end();
        }
    }
}

//! endzinc