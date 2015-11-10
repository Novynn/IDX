//! zinc
library UpgradeEffects requires Upgrades, UnitMaxState {

	public struct UpgradeHPEffect extends UpgradeEffect {
		private real hp;
		
		public static method create(real hp) -> thistype {
			thistype this = thistype.allocate();
			this.hp = hp;
			return this;
		}
		
		public method activate(unit u) {
			AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, this.hp);
		}
		
		public method deactivate(unit u) {
			AddUnitMaxState(u, UNIT_STATE_MAX_LIFE, -this.hp);
		}
	}
	
	public struct UpgradeMPEffect extends UpgradeEffect {
		private real mp;
		
		public static method create(real mp) -> thistype {
			thistype this = thistype.allocate();
			this.mp = mp;
			return this;
		}
		
		public method activate(unit u) {
			AddUnitMaxState(u, UNIT_STATE_MAX_MANA, this.mp);
		}
		
		public method deactivate(unit u) {
			AddUnitMaxState(u, UNIT_STATE_MAX_MANA, -this.mp);
		}
	}
	
	public struct UpgradeAbilityEffect extends UpgradeEffect {
		private integer id;
		
		public static method create(integer id) -> thistype {
			thistype this = thistype.allocate();
			this.id = id;
			return this;
		}
		
		public method activate(unit u) {
			if (GetUnitAbilityLevel(u, this.id) == 0) UnitAddAbility(u, this.id);
			else IncUnitAbilityLevel(u, this.id);
		}
		
		public method deactivate(unit u) {
			if (GetUnitAbilityLevel(u, this.id) <= 0) return; // Can't go below 0
			if (GetUnitAbilityLevel(u, this.id) == 1) UnitRemoveAbility(u, this.id);
			else DecUnitAbilityLevel(u, this.id);
		}
	}
	
	// This is currently bugged when Upgrading
	/*
	public struct UpgradeUnitEffect extends UpgradeEffect {
		private static Table knownConverters = 0;
		public static method operator[] (integer uId) -> integer {
			return thistype.knownConverters[uId];
		
		}
		public static method operator[]= (integer uId, integer aId) {
			thistype.knownConverters[uId] = aId;
		}
		
		private integer newTypeId = 0;
		private integer oldTypeId = 0;
		
		public static method create(integer nId, integer oId) -> thistype {
			thistype this = thistype.allocate();
			this.newTypeId = nId;
			this.oldTypeId = oId;
			return this;
		}
		
		public method activate(unit u) {
			if (GetUnitTypeId(u) != this.oldTypeId) return;
			UnitRemoveAbility(u, thistype[this.oldTypeId]);
			UnitAddChaos(u, thistype[this.newTypeId]);
		}
		
		public method deactivate(unit u) {
			if (GetUnitTypeId(u) != this.newTypeId) return;
			UnitRemoveAbility(u, thistype[this.newTypeId]);
			UnitAddChaos(u, thistype[this.oldTypeId]);
		}
	}
	*/
}

//! endzinc