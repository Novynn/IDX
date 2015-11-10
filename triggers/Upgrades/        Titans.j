//! zinc

library TitanUpgrades requires Upgrades, UnitManager {
	    public struct TitanMoundUpgrades extends UpgradeDefinition {
        module UpgradeModule;
		
        public static method appliesTo(unit u) -> boolean {
            return u == UnitManager.TITAN_SPELL_WELL;
        }
		public static method incrMysticsBonus(unit u) {
			IncUnitAbilityLevel(u, '&TEL');
			IncUnitAbilityLevel(u, 'ATMH');
			IncUnitAbilityLevel(u, 'ATMM');
		}
		public static method decrMysticsBonus(unit u) {
			DecUnitAbilityLevel(u, '&TEL');
			DecUnitAbilityLevel(u, 'ATMH');
			DecUnitAbilityLevel(u, 'ATMM');
		}
        public method setup() {
            Upgrades.begin("Apprentice Mystics", "all");
            Upgrades.add('q000', thistype.appliesTo, thistype.incrMysticsBonus, thistype.decrMysticsBonus);
            Upgrades.add('q001', thistype.appliesTo, thistype.incrMysticsBonus, thistype.decrMysticsBonus);
            Upgrades.add('q002', thistype.appliesTo, thistype.incrMysticsBonus, thistype.decrMysticsBonus);
            Upgrades.add('q003', thistype.appliesTo, thistype.incrMysticsBonus, thistype.decrMysticsBonus);
            Upgrades.end();
			
			Upgrades.begin("Courier", "all");
            Upgrades.addRequirement('q258');
            Upgrades.end();
			
			Upgrades.begin("Defensive Measures", "all");
            Upgrades.addRequirement('q080');
            Upgrades.end();
        }
    }
}

//! endzinc