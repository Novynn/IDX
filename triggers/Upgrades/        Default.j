//TESH.scrollpos=0
//TESH.alwaysfold=0

//! zinc

library DefaultUpgrades requires Upgrades, UnitMaxState, UnitManager, BonusMod {
	public struct DefaultUpgrades {
		public static method incrMaxHealth(unit u) {
			integer data = Upgrades.data();
			AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, data);
		}
		
		public static method decrMaxHealth(unit u) {
			integer data = Upgrades.data();
			AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -data);
		}
		
		public static method incrMaxMana(unit u) {
			integer data = Upgrades.data();
			AddUnitMaxState(u, UNIT_STATE_MAX_MANA, data);
		}
		
		public static method decrMaxMana(unit u) {
			integer data = Upgrades.data();
			AddUnitMaxState(u, UNIT_STATE_MAX_MANA, -data);
		}
	}
}

//! endzinc