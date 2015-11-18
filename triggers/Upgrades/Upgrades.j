//! zinc

/*	
 *	ISSUES:
 *		- When a player is currently researching, and a cancel occurs:
 *			The research continues
 *			On completion, the system finds an unexpected level (expected 3; got 1)
 *			Resources are not refunded, system gives visual error message
 *			SOLUTION: Force all structures to cancel their build queues. Can maybe filter?
 *					  Also to note, changing the owner of a structure cancels it's queue.
 *	
 *	
 */

library Upgrades requires Table, Players, GetPlayerActualName, AIDS, Races, Ascii {
	private constant integer MAX_LEVEL = 100;
	private constant integer MAX_UPGRADES = 1000;
	
	type UpgradeFilter extends function(unit) -> boolean;
	type UpgradeIter extends function(unit);
	type UpgradeEvent extends function(PlayerUpgradeData, UpgradeLevel, unit);
	
	private struct CurrentPlayerUpgrade {
		Upgrade upgrade;
		integer level;
		
		unit units[MAX_LEVEL];
	}
	
	public struct PlayerUpgradeData {
        module PlayerDataWrappings;
		
		public method getUpgradeTable() -> Table {
			return this.upgradeTable;
		}
		
		public method printUpgrades() {
			integer i = 0;
			Upgrade u = 0;
			CurrentPlayerUpgrade cpu = 0;
			this.say("Current Upgrades:");
			for (0 <= i < Upgrades.count()) {
				u = Upgrades.at(i);
				if (this.upgradeTable.has(u)) {
					cpu = this.upgradeTable[u];
					this.say("\t(" + I2S(u) + ") " + u.id() + " at level " + I2S(cpu.level) + ": " + GetObjectName(u.level(cpu.level).unitId));
				}
			}
		}
		
		// NOTE(rory): This does not handle upgrade effects at all, it is assumed the players do not have units or that their units are swapped already.
		//             It only handles learn and unlearn events (as it should, to setup tech properly).
		public method setUpgradeTable(Table t) {
			integer i = 0;
			integer j = 0;
			Upgrade u = 0;
			CurrentPlayerUpgrade cpu = 0;
			UpgradeLevel levelData = 0;
			
			for (0 <= i < Upgrades.count()) {
				u = Upgrades.at(i);
				
				// Unlearn
				if (this.upgradeTable.has(u)) {
					cpu = this.upgradeTable[u];
					for (cpu.level >= j >= 1) {
						levelData = u.level(i);
						if (levelData.unlearnEvent != 0) {
							levelData.unlearnEvent.execute(this, levelData, null);
						}
					}
				}
				
				// Learn
				if (t.has(u)) {
					cpu = t[u];
					for (cpu.level >= j >= 1) {
						levelData = u.level(i);
						if (levelData.learnEvent != 0) {
							levelData.learnEvent.execute(this, levelData, null);
						}
					}
				}
			}
		
			this.upgradeTable = t;
		}
		
		private Table upgradeTable = 0;
        private method onSetup(){
			this.upgradeTable = Table.create();
        }
        
        private method onTerminate(){
			integer i = 0;
			Upgrade u = 0;
			CurrentPlayerUpgrade cpu = 0;
			for (0 <= i < Upgrades.count()) {
				u = Upgrades.at(i);
				if (this.upgradeTable.has(u)) {
					cpu = this.upgradeTable[u];
					cpu.destroy();
					this.upgradeTable.remove(u);
				}
			}
			this.upgradeTable.destroy();
			this.upgradeTable = 0;
        }
		
		// We want to be able to keep a table of Upgrade's for the player along with their ID and
		// their upgrade unit (of UpgradeLevel.unitId).
		
		public method levelFor(Upgrade upgrade) -> integer {
			CurrentPlayerUpgrade cpu = 0;
			if (this.upgradeTable.has(upgrade)) {
				cpu = this.upgradeTable[upgrade];
				return cpu.level;
			}
			return 0;
		}
		
		public static method researchCompleteSound(player p) {
			race r = GetPlayerRace(p);
			sound s = null;
			if (r == RACE_HUMAN) 			s = gg_snd_KnightResearchComplete1;
			else if (r == RACE_NIGHTELF) 	s = gg_snd_SentinelResearchComplete1;
			else if (r == RACE_ORC) 		s = gg_snd_GruntResearchComplete1;
			else if (r == RACE_UNDEAD) 		s = gg_snd_NecromancerResearchComplete1;
			else 							s = gg_snd_ResearchComplete;
			
			if (GetLocalPlayer() == p) {
				PlaySoundBJ(s);
			}
			s = null;
		}
		
		public method incrementLevel(Upgrade upgrade, unit u, unit researching) {
			integer currentLevel = this.levelFor(upgrade);
			integer level = currentLevel + 1;
			CurrentPlayerUpgrade playerUpgradeData = this.upgradeTable[upgrade];
			UpgradeLevel newLevelData = upgrade.level(level);
			UpgradeLevel nextLevelData = upgrade.level(currentLevel + 2);
			integer newId = 0;
			integer nextId = 0;
			
			if (level > MAX_LEVEL) {
				Upgrades.error(this.playerData, "|cffff0000PlayerUpgradeData.incrementLevel failed - max level reached (100)|r");
				return;
			}
			
			newId = newLevelData.unitId;
			if (nextLevelData != 0) {
				nextId = nextLevelData.unitId;
			}
			
			if (u == null) {
				u = CreateUnit(this.player(), newId, 0, 0, 0);
			}
			
			else if (GetUnitTypeId(u) != newId) {
				Upgrades.error(this.playerData, "|cffff0000PlayerUpgradeData.incrementLevel failed - leveling unit had an incorrect unit id|r");
				return;
			}
			
			// Add unit handle to table
			UnitAddAbility(u, 'Avul');
			UnitAddAbility(u, 'Aloc');
			// Increment internal level
			if (this.upgradeTable.has(upgrade)) {
				playerUpgradeData.level = level;
				playerUpgradeData.units[level] = u;
			}
			else {
				playerUpgradeData = CurrentPlayerUpgrade.create();
				playerUpgradeData.level = level;
				playerUpgradeData.units[level] = u;
				this.upgradeTable[upgrade] = playerUpgradeData;
			}
			
			debug {this.say("Successfully upgraded " + upgrade.id() + " to level " + I2S(level));}
			thistype.researchCompleteSound(this.player());
			
			// Set tech
			if (level == MAX_LEVEL) {
				// Final tech reached
				debug { BJDebugMsg("Final level reached (recursive)"); }
			}
			else if (nextLevelData == upgrade.finalLevel() &&
				nextId > 0) {
				// Allow further levels
				debug { BJDebugMsg("Another level is available (recursive): " + GetObjectName(nextId)); }
				SetPlayerTechMaxAllowed(this.player(), nextId, (MAX_LEVEL - nextLevelData.level) + 1);
			}
			else {
				if (newId > 0) {
					// Disallow current
					SetPlayerTechMaxAllowed(this.player(), newId, 0);
				}
				if (nextId > 0) {
					// Allow next
					SetPlayerTechMaxAllowed(this.player(), nextId, 1);
					debug { BJDebugMsg("Another level is available: " + GetObjectName(nextId));}
				}
				else {
					debug { BJDebugMsg("That was the final level");}
				}
			}
			
			// Activate new
			Upgrades.runUpgradeLevelIteration(this.player(), newLevelData, newLevelData.activate, true);
			
			// Execute Event
			if (newLevelData.learnEvent != 0) {
				newLevelData.learnEvent.execute(this, newLevelData, researching);
			}
		}
		
		public method decrementLevel(Upgrade upgrade) {
			// TODO(rory): make this available.
			debug { BJDebugMsg("PlayerUpgradeData.levelTo failed - attempted to decrement level");}
		}
		
		public method resetLevel(Upgrade upgrade, boolean downgrade) {
			CurrentPlayerUpgrade playerUpgradeData = this.upgradeTable[upgrade];
			UpgradeLevel levelData = 0;
			integer i = 0;
			unit u = null;
			
			if (!this.upgradeTable.has(upgrade)) return;
			
			// Reset units (dependencies)
			// If a unit has been converted using Chaos, and then has a stat upgrade applied, resetting the chaos will also reset the stat upgrade.
			// Deactivate all
			for (playerUpgradeData.level >= i >= 1) {
				if (playerUpgradeData.units[i] != null) {
					levelData = upgrade.level(i);
					
					if (downgrade) {
						Upgrades.runUpgradeLevelIteration(this.player(), levelData, levelData.deactivate, false);
					}
					
					// Execute Event
					if (levelData.unlearnEvent != 0) {
						levelData.unlearnEvent.execute(this, levelData, null);
					}
					
					u = playerUpgradeData.units[i];
					playerUpgradeData.units[i] = null;
					RemoveUnit(u);
					u = null;
				}
				else {
					debug { BJDebugMsg("Warning - check bounds"); }
				}
			}
			
			// Reset Tech (visibility)
			upgrade.setupTechForPlayer(this.player());
			
			// Reset internal level counter
			this.upgradeTable.remove(upgrade);
			playerUpgradeData.level = 0;
			playerUpgradeData.destroy();
		}
		
		public method levelTo(Upgrade upgrade, integer level, unit u, unit researching) {
			integer currentLevel = this.levelFor(upgrade);
			
			if (level > MAX_LEVEL) level = MAX_LEVEL;
			
			if (level > currentLevel) {
				if (level == currentLevel + 1) {
					this.incrementLevel(upgrade, u, researching);
				}
				else {
					if (u != null) {
						debug { BJDebugMsg("PlayerUpgradeData.levelTo warning - was passed a unit when jumping ahead"); }
					}
					
					while (currentLevel < level && currentLevel < MAX_LEVEL) {
						this.incrementLevel(upgrade, null, null);
						currentLevel = currentLevel + 1;
					}
				}
			}
			else if (level < currentLevel) {
				if (level == 0) {
					this.resetLevel(upgrade, true);
				}
				else if (level == currentLevel - 1){
					this.decrementLevel(upgrade);
				}
				else {
					// TODO(rory): make this available.
					debug { BJDebugMsg("PlayerUpgradeData.levelTo failed - attempted to level down"); }
				}
			}
			else {
				// Same so do nothing
				debug { BJDebugMsg("PlayerUpgradeData.levelTo failed - could not level to an upgrade as it was already at the specified level"); }
			}
		}
	}
	
	private struct UnitConversionUpgradeData {
		integer chaosToNew;
		integer chaosToOld;
	}
	private struct UnitConversionDelayData extends array {
		unit u;
		real mana;
		real maxMana;
		integer movespeed;
	}
	
	public struct Upgrades {
		private static Upgrade upgrades[MAX_UPGRADES];
		private static integer upgradesCount = 0;
		public static Table objectMap = 0;
		
		private static integer currentData = 0;
		public static method data() -> integer {
			return thistype.currentData;
		}
		
		public static method setData(integer data) {
			thistype.currentData = data;
		}
		
		public static method count() -> integer {
			return thistype.upgradesCount;
		}
		
		public static method at(integer i) -> Upgrade {
			return thistype.upgrades[i];
		}
		
		public static method resetAllUpgradesForPlayer(player p, boolean downgrade) {
			integer i = 0;
			Upgrade u;
			
			for (0 <= i < thistype.upgradesCount) {
				u = thistype.upgrades[i];
				thistype.resetUpgradeForPlayer(p, u, downgrade);
			}
		}
		
		public static method resetUpgradeForPlayer(player p, Upgrade u, boolean downgrade) {
			PlayerUpgradeData pUp = PlayerUpgradeData[PlayerData.get(p)];
			pUp.resetLevel(u, downgrade);
		}
	
		public static method swapPlayerUpgradeTables(player p1, player p2) {
			PlayerUpgradeData p1ud = PlayerUpgradeData[PlayerData.get(p1)];
			PlayerUpgradeData p2ud = PlayerUpgradeData[PlayerData.get(p2)];
			integer i = 0;
			Upgrade u;
			CurrentPlayerUpgrade cpu = 0;
			Table tmp = p1ud.getUpgradeTable();
			
			if (p1ud == 0 || p2ud == 0) {
				// fail?
			}
			
			
			p1ud.setUpgradeTable(p2ud.getUpgradeTable());
			p2ud.setUpgradeTable(tmp);
			
			// Now handle tech levels
			for (0 <= i < thistype.upgradesCount) {
				u = thistype.upgrades[i];
				
				// Reset upgrade tech levels
				u.setupTechForPlayer(p1);
				u.setupTechForPlayer(p2);
				
				tmp = p1ud.getUpgradeTable();
				if (tmp.has(u)) {
					cpu = tmp[u];
					u.setupTechLevelForPlayer(p1, cpu.level);
				}
				
				tmp = p2ud.getUpgradeTable();
				if (tmp.has(u)) {
					cpu = tmp[u];
					u.setupTechLevelForPlayer(p2, cpu.level);
				}
			}
			
			// Assume unit handling is done???
		}
		
		public static method applyUpgrades(unit u) {
			integer i = 0;
			integer j = 0;
			PlayerData q = PlayerData.get(GetOwningPlayer(u));
			PlayerUpgradeData p = 0;
			Upgrade upgrade = 0;
			UpgradeLevel upgradeLevel = 0;
			integer level = 0;
			
			if (q == 0) return;
			p = PlayerUpgradeData[q];
			if (p == 0) return;
			
			// Pre-checks
			if (GetUnitTypeId(u) == 'sync' || GetUnitAbilityLevel(u, 'UPGR') > 0) return;
			if (IsUnitIllusion(u)) return;
			
			for (0 <= i < thistype.count()) {
				upgrade = thistype.at(i);
				level = p.levelFor(upgrade);
				if (level > 0) {
					for (1 <= j <= level) {
						upgradeLevel = upgrade.level(j);
						thistype.applyUpgradeLevelIteration(u, upgradeLevel, upgradeLevel.activate, true);
					}
				}
			}
		}
		
		public static method removeUpgradesWithFakeUnit(unit u, integer unitId) {
			integer i = 0;
			integer j = 0;
			PlayerData q = PlayerData.get(GetOwningPlayer(u));
			PlayerUpgradeData p = 0;
			Upgrade upgrade = 0;
			UpgradeLevel upgradeLevel = 0;
			integer level = 0;
			unit fakeUnit = null;
			
			if (q == 0) return;
			p = PlayerUpgradeData[q];
			if (p == 0) return;
			
			// Pre-checks
			if (GetUnitTypeId(u) == 'sync' || GetUnitAbilityLevel(u, 'UPGR') > 0) return;
			if (IsUnitIllusion(u)) return;
			
			// Fake unit is used in order to run filter checks on the units previous state..
			// This will only work with Upgrades that filter based on unit ID rather than anything else
			// This should probably be changed in the future to just work off unit IDs
			fakeUnit = CreateUnit(q.player(), unitId, 0, 0, 0.0);
			
			for (0 <= i < thistype.count()) {
				upgrade = thistype.at(i);
				level = p.levelFor(upgrade);
				if (level > 0) {
					for (1 <= j <= level) {
						upgradeLevel = upgrade.level(j);
						// UPGRADES ARE NOT GUARANTEED TO BE APPLIED IN THEIR ORDER
						if (upgradeLevel.filter != 0 &&
							upgradeLevel.filter.evaluate(fakeUnit)) {
							thistype.executeUpgradeLevelIteration(u, upgradeLevel, upgradeLevel.deactivate, false);
						}
					}
				}
			}
			
			RemoveUnit(fakeUnit);
		}
		
		public static method removeUpgrades(unit u) {
			integer i = 0;
			integer j = 0;
			PlayerData q = PlayerData.get(GetOwningPlayer(u));
			PlayerUpgradeData p = 0;
			Upgrade upgrade = 0;
			UpgradeLevel upgradeLevel = 0;
			integer level = 0;
			
			if (q == 0) return;
			p = PlayerUpgradeData[q];
			if (p == 0) return;
			
			// Pre-checks
			if (GetUnitTypeId(u) == 'sync' || GetUnitAbilityLevel(u, 'UPGR') > 0) return;
			if (IsUnitIllusion(u)) return;
			
			for (0 <= i < thistype.count()) {
				upgrade = thistype.at(i);
				level = p.levelFor(upgrade);
				if (level > 0) {
					for (1 <= j <= level) {
						upgradeLevel = upgrade.level(j);
						// UPGRADES ARE NOT GUARANTEED TO BE APPLIED IN THEIR ORDER
						thistype.applyUpgradeLevelIteration(u, upgradeLevel, upgradeLevel.deactivate, false);
					}
				}
			}
		}
		
		// Matches the filter
		public static method executeUpgradeLevelIteration(unit u, UpgradeLevel level, UpgradeIter iterable, boolean activate) {
			integer i = 0;
			thistype.setData(level.data);
			debug {
				BJDebugMsg("Executing Upgrade Level Iteration. Effects: " + I2S(level.effectCount));
				if (activate) BJDebugMsg("Mode is: activate");
				else BJDebugMsg("Mode is: deactivate");
			}
			for (0 <= i < level.effectCount) {
				if (activate) {
					level[i].activate(u);
				}
				else {
					level[i].deactivate(u);
				}
			}
			
			// Execute old-style
			if (iterable != 0) iterable.execute(u);
			
			thistype.setData(0);
		}
		
		public static method applyUpgradeLevelIteration(unit u, UpgradeLevel level, UpgradeIter iterable, boolean activate) -> boolean {
			if (level.filter != 0 &&
				level.filter.evaluate(u)) {
				thistype.executeUpgradeLevelIteration(u, level, iterable, activate);
				return true;
			}
			return false;
		}
		
		public static method runUpgradeLevelIteration(player p, UpgradeLevel level, UpgradeIter iterable, boolean activate) {
			group g = null;
			unit u = null;
			
			if (level.filter != 0) {
				g = CreateGroup();
				GroupEnumUnitsOfPlayer(g, p, null);
				
				u = FirstOfGroup(g);
				while (u != null) {
					thistype.applyUpgradeLevelIteration(u, level, iterable, activate);
					GroupRemoveUnit(g, u);
					u = FirstOfGroup(g);
				}
				
				DestroyGroup(g);
				g = null;
				u = null;
			}
			// TODO(neco): why is this even a thing?
			else if (iterable != 0) {
				iterable.execute(null);
			}
		}
		
		private static UpgradeEffect prevEffect = 0;
		private static string currentName = "";
		private static string currentForRace = "";
		private static boolean lastIsRecursive = false;
		private static UpgradeLevel currentUpgrades[MAX_LEVEL];
		private static integer currentUpgradesCount = 0;
		public static method begin(string name, string forRace) {
			thistype.currentName = name;
			thistype.currentForRace = forRace;
		}
		
		public static method lastEffect() -> UpgradeEffect {
			return thistype.prevEffect;
		}
		
		public static method addRequirement(integer unitId) {
			thistype.add(unitId, 0, 0, 0);
		}
		
		public static method addEx(integer unitId, 
							     UpgradeFilter filter) -> UpgradeLevel {
			 return thistype.add(unitId, filter, 0, 0);
		} 
		
		public static method add(integer unitId,
							     UpgradeFilter filter,
								 UpgradeIter activate,
								 UpgradeIter deactivate) -> UpgradeLevel {
			UpgradeLevel level = UpgradeLevel.create();
			
			if (level == 0) {
				// BJDebugMsg("WARNING! Max upgrade levels reached (~8000). Check for recursion maybe? That's crazy!");
				// BJDebugMsg("\tWhile trying to add: " + A2S(unitId) + " to " + thistype.currentName);
			}
			
			level.parent = 0;
			level.level = thistype.currentUpgradesCount + 1;
			level.unitId = unitId;
			level.filter = filter;
			level.activate = activate;
			level.deactivate = deactivate;
			level.learnEvent = 0;
			level.unlearnEvent = 0;
			level.data = 0;
			thistype.currentUpgrades[thistype.currentUpgradesCount] = level;
			thistype.currentUpgradesCount = thistype.currentUpgradesCount + 1;
			return level;
		}
		
		public static method addWithData(integer unitId,
										 UpgradeFilter filter,
										 UpgradeIter activate,
										 UpgradeIter deactivate,
										 integer data) -> UpgradeLevel {
			UpgradeLevel level = thistype.add(unitId, filter, activate, deactivate);
			level.data = data;
			return level;
		} 
		
		public static method addWithEvents(integer unitId,
										  UpgradeEvent learnEvent,
										  UpgradeEvent unlearnEvent) -> UpgradeLevel {
			UpgradeLevel level = thistype.add(unitId, 0, 0, 0);
			level.learnEvent = learnEvent;
			level.unlearnEvent = unlearnEvent;
			return level;
		}
		
		private static method applyChaos(unit u, integer oldChaos, integer newChaos) {
			integer id = GetUnitIndex(u);
			// Save some values as they don't transfer with Chaos properly..
			UnitConversionDelayData[id].movespeed = GetUnitBonus(u, BONUS_MOVEMENT_SPEED);
			UnitConversionDelayData[id].mana = GetUnitState(u, UNIT_STATE_MAX_MANA);
			UnitConversionDelayData[id].maxMana = GetUnitState(u, UNIT_STATE_MAX_MANA);
			UnitConversionDelayData[id].u = u;
			RemoveUnitBonus(u, BONUS_MOVEMENT_SPEED);
			
			UnitRemoveAbility(u, oldChaos);
			UnitAddChaos(u, newChaos);
			
			// Apply after a delay (to let the game catch up)
			GameTimer.new(function(GameTimer t) {
				integer id = t.data();
				unit u = UnitConversionDelayData[id].u;
				AddUnitBonus(u, BONUS_MOVEMENT_SPEED, UnitConversionDelayData[id].movespeed);
				SetUnitMaxState(u, UNIT_STATE_MAX_MANA, UnitConversionDelayData[id].maxMana);
				SetUnitState(u, UNIT_STATE_MANA, UnitConversionDelayData[id].mana);
				UnitConversionDelayData[id].u = null;
			}).start(0.1).setData(id);
		}
		
		private static method activateChaos(unit u) {
			UnitConversionUpgradeData data = Upgrades.data();
			thistype.applyChaos(u, data.chaosToOld, data.chaosToNew);
		}
		
		private static method deactivateChaos(unit u) {
			UnitConversionUpgradeData data = Upgrades.data();
			thistype.applyChaos(u, data.chaosToNew, data.chaosToOld);
		}
		
		public static method addUnitConversion(integer unitId, 
											   UpgradeFilter filter, 
											   integer chaosToNew,  
											   integer chaosToOld) -> UpgradeLevel {
		    UnitConversionUpgradeData data = UnitConversionUpgradeData.create();
			data.chaosToNew = chaosToNew;
			data.chaosToOld = chaosToOld;
			return thistype.addWithData(unitId, filter, thistype.activateChaos, thistype.deactivateChaos, data);
		}
		
		public static method continueEffect() {
			thistype.addEffect(thistype.lastEffect());
		}
		
		// Slightly more expensive, but copies all effects
		public static method continueEffects() {
			integer lastIndex = thistype.currentUpgradesCount - 2;
			integer i = 0;
			UpgradeLevel level = 0;
			if (lastIndex < 0) return;
			level = thistype.currentUpgrades[lastIndex];
			for (0 <= i < level.effectCount) {
				thistype.addEffect(level[i]);
			}
		}
		
		public static method addEffect(UpgradeEffect e) {
			integer currIndex = thistype.currentUpgradesCount - 1;
			UpgradeLevel level = thistype.currentUpgrades[currIndex];
			level.addEffect(e);
			thistype.prevEffect = e;
		}
		
		public static method setLastAsRecursive() {
			thistype.lastIsRecursive = true;
		}
		
		public static method end() -> Upgrade {
			Upgrade u = 0;
			UpgradeLevel level = 0;
			if (thistype.lastIsRecursive) {
				thistype.currentUpgradesCount = thistype.currentUpgradesCount - 1;
				level = thistype.currentUpgrades[thistype.currentUpgradesCount];
			}
			
			u = thistype.save();
			
			if (thistype.lastIsRecursive) {
				thistype.objectMap[level.unitId] = level;
				u.addRecursiveLevel(level.level, level);
			}
			thistype.currentName = "";
			thistype.currentForRace = "";
			thistype.currentUpgradesCount = 0;
			thistype.lastIsRecursive = false;
			u.setupTech();
			return u;
		}
		
		private static method save() -> Upgrade {
			Upgrade upgrade = Upgrade.create();
			UpgradeLevel level = 0;
			integer i = 0;
			
			upgrade.name = thistype.currentName;
			upgrade.match = thistype.currentForRace;
			for (0 <= i < thistype.currentUpgradesCount) {
				level = thistype.currentUpgrades[i];
				thistype.objectMap[level.unitId] = level;
				upgrade.addLevel(level.level, level);
			}
			
			// Save in a table or something
			thistype.upgrades[thistype.upgradesCount] = upgrade;
			thistype.upgradesCount = thistype.upgradesCount + 1;
			
			return upgrade;
		}
		
		// the integer id is the ID of a UpgradeLevel unit id
		public static method getPlayerUpgradeLevel(player p, integer id) -> integer {
			UpgradeLevel upgradeLevel = thistype.objectMap[id];
			PlayerData pd = PlayerData.get(p);
			PlayerUpgradeData q = PlayerUpgradeData[pd];
			integer level = 0;
			
			if (pd == 0 || q == 0) return 0; // Couldn't get PlayerData
			
			if (upgradeLevel != 0 && upgradeLevel.parent != 0) {
				level = q.levelFor(upgradeLevel.parent);
				return level;
			}
			return 0;
		}
		
		public static method playerHasUpgradeLevel(player p, integer id) -> boolean {
			return thistype.getPlayerUpgradeLevel(p, id) > 0;
		}
		
		public static method error(PlayerData p, string message) {
			p.say(message);
			if (GetLocalPlayer() == p.player()) {
				PlaySoundBJ(gg_snd_Error);
			}
		}
		
		private static method onResearch(unit u, unit v) {
			player p = GetOwningPlayer(u);
			PlayerData q = PlayerData.get(p);
			integer id = GetUnitTypeId(u);
			UpgradeLevel upgradeLevel = thistype.objectMap[id];
			UpgradeLevel nextUpgradeLevel = 0;
			Upgrade upgrade = upgradeLevel.parent;
			integer currentLevel = 0;
			PlayerUpgradeData upP = PlayerUpgradeData[q];
			
			if (upP == 0) {
				thistype.error(q, "|cffff0000Research Failed - Could not find PlayerUpgradeData|r");
				RemoveUnit(u);
				return;
			}
			
			if (upgradeLevel == 0) {
				thistype.error(q, "|cffff0000Research Failed - Could not find level unit in object map|r");
				RemoveUnit(u);
				return;
			}
			
			if (upgrade == 0) {
				thistype.error(q, "|cffff0000Research Failed - Could not find upgrade from upgradeLevel data|r");
				RemoveUnit(u);
				return;
			}
			
			currentLevel = upP.levelFor(upgrade);
			
			nextUpgradeLevel = upgrade.level(currentLevel + 1);
			// This will pass even if the level is recursive
			if (nextUpgradeLevel != upgradeLevel) {
				thistype.error(q, "|cffff0000Research Failed - Player |r" + GetPlayerActualName(p) + "|cffff0000 was not at expected level|r");
				q.say("\t|cffff0000Expected level " + I2S(nextUpgradeLevel.level) + ", got level " + I2S(upgradeLevel.level) + "|r");
				q.say("\t|cffff0000Expected object #" + I2S(nextUpgradeLevel) + " (|r" + GetObjectName(nextUpgradeLevel.unitId) + "|cffff0000), got object #" + I2S(upgradeLevel) + " (|r" + GetObjectName(upgradeLevel.unitId) + "|cffff0000)|r");
				RemoveUnit(u);
				return;
			}
			
			// Handle recursive levels
			if (upgrade.finalLevel() == upgradeLevel) {
				upP.levelTo(upgrade, currentLevel + 1, u, v);
			}
			else {
				upP.levelTo(upgrade, upgradeLevel.level, u, v);
			}
		}
		
		private static UpgradeDefinition definitions[MAX_UPGRADES];
		private static integer definitionsCount = 0;
		
		private static method hideAllUpgrades() {
			integer i = 0;
			integer j = 0;
			integer id = 0;
			string s = "";
			
			// BJDebugMsg("Hiding all upgrades...");
			
			// q000 -> q999
			for (0 <= i < 1000) {
				s = I2S(i);
				while (StringLength(s) < 3) {
					s = "0" + s;
				}
				s = "q" + s;
				
				id = S2A(s);
				
				
				
				// Disabled
				for (0 <= j < 12) {
					SetPlayerTechMaxAllowed(Player(j), id, 0);
				}
			}
			
			// BJDebugMsg("Hiding complete");
		}
		
		public static method initialize() {
			UpgradeDefinition def = 0;
			Upgrade u = 0;
			integer i = 0;
			integer j = 0;
			integer k = 0;
			PlayerUpgradeData.initialize();
			
			if (thistype.upgradesCount > 0) {
				// Reset already registered upgrades!
				for (0 <= i < thistype.upgradesCount) {
					u = thistype.upgrades[i];
					u.setupTech(); 
				}
			}
			else if (thistype.definitionsCount > 0) {
				// If this is the first time, we need to load upgrades from their definitions
				for (0 <= i < thistype.definitionsCount) {
					def = thistype.definitions[i];
					j = UpgradeLevel.create();
					k = j;
					UpgradeLevel(k).destroy();
					
					def.setup();
					def.destroy(); // will this cause problems?
					thistype.definitions[i] = 0;
				}
				
				thistype.definitionsCount = 0;
			}
		}
		
		public static method registerDefinition(UpgradeDefinition def) {
			thistype.definitions[thistype.definitionsCount] = def;
			thistype.definitionsCount = thistype.definitionsCount + 1;
		}
		
		public static method terminate() {
			PlayerUpgradeData.terminate();
		}
		
		private static method onInit() {
			trigger t = CreateTrigger();
			TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_TRAIN_FINISH);
			TriggerAddCondition(t, Condition(function() -> boolean {
				unit u = GetTrainedUnit();
				unit v = GetTriggerUnit();
				if (GetUnitAbilityLevel(u, 'UPGR') > 0) {
					thistype.onResearch(u, v);
				}
				u = null;
				v = null;
				return false;
			}));
			
			t = null;
			thistype.objectMap = Table.create();
		}
	}
	
	public struct Upgrade {
		public string name;
		public string match;
		public integer max = 0;
		public UpgradeLevel final = 0;
		
		public static Table upgrades = 0;
		private static method hash(thistype this, integer level) -> integer {
			return StringHash(I2S(this) + "_" + I2S(level));
		}
		
		public method id() -> string {
			return name;
		}
		
		public method isForRace(string r) -> boolean {
			return (StringCase(r, false) == "all" ||
					StringCase(r, false) == StringCase(match, false));
		}
		
		public method addLevel(integer level, UpgradeLevel obj) {
			obj.parent = this;
			thistype.upgrades[thistype.hash(this, level)] = obj;
			
			if (level > this.maxLevel()) {
				this.max = level;
			}	
		}
		
		public method addRecursiveLevel(integer level, UpgradeLevel obj) {
			obj.parent = this;
			this.final = obj;
			this.max = level;
		}
		
		public method finalLevel() -> UpgradeLevel {
			return this.final;
		}
		
		public method maxLevel() -> integer {
			return this.max;
		}
		
		public method level(integer level) -> UpgradeLevel {
			integer k = thistype.hash(this, level);
			if (thistype.upgrades.has(k)) {
				return thistype.upgrades[k];
			}
			else if (final != 0 && level >= this.maxLevel()) {
				return final;
			}
			return 0;
		}
		
		public method setupTech() {
			UpgradeLevel levelData = 0;
			integer i = 0;
			integer j = 0;
			
			// Allow the first level
			levelData = this.level(1);
			for (0 <= i < 12) {
				SetPlayerTechMaxAllowed(Player(i), levelData.unitId, 1);
			}
			
			// Disallow subsequent levels
			for (1 < j <= this.maxLevel()) {
				levelData = this.level(j);
				for (0 <= i < 12) {
					SetPlayerTechMaxAllowed(Player(i), levelData.unitId, 0);
				}
			}
		}
		
		public method setupTechForPlayer(player p) {
			this.setupTechLevelForPlayer(p, 0);
		}
		
		public method setupTechLevelForPlayer(player p, integer level) {
			UpgradeLevel levelData = 0;
			integer i = 0;
			
			for (1 <= i <= this.maxLevel()) {
				levelData = this.level(i);
				if (i == (level + 1)) {
					SetPlayerTechMaxAllowed(p, levelData.unitId, 1);
				}
				else {
					SetPlayerTechMaxAllowed(p, levelData.unitId, 0);
				}
			}
		}
		
		private static method onInit() {
			thistype.upgrades = Table.create();
		}
	}
	
	public struct UpgradeLevel {
		public Upgrade parent;
		public integer unitId;
		public integer level;
		
		public integer data;
		
		public UpgradeFilter filter;
		public UpgradeIter activate;
		public UpgradeIter deactivate;
		public UpgradeEvent learnEvent;
		public UpgradeEvent unlearnEvent;
		
		// This stuff is so stupid. Apparently vJASS structs don't allow arrays inside themselves while maintaining a large instance count...
		private static Table effectTable = 0;
		private static integer effectNext = 0;
		private static constant integer MAX_EFFECTS_PER_UPGRADE_LEVEL = 10;
		public integer effectOffset = 0;
		public integer effectCount = 0;
		
		public static method create() -> thistype {
			thistype this = thistype.allocate();
			this.effectOffset = thistype.effectNext;
			thistype.effectNext = thistype.effectNext + MAX_EFFECTS_PER_UPGRADE_LEVEL;
			return this;
		}
		
		public method operator[] (integer i) -> UpgradeEffect {
			return UpgradeEffect(this.effectTable[this.effectOffset + i]);
		}
		
		public method addEffect(UpgradeEffect e) {
			if (this.effectCount >= (MAX_EFFECTS_PER_UPGRADE_LEVEL)) {
				BJDebugMsg("WARNING - Tried to assign too many events to an upgrade level.");
				return;
			}
			this.effectTable[this.effectOffset + this.effectCount] = e;
			this.effectCount = this.effectCount + 1;
		}
		
		private static method onInit() {
			thistype.effectTable = Table.create();
		}
	}
	
	public module UpgradeModule {
		private static method create() -> thistype {
            return thistype.allocate();
        }
        
        private static method onInit(){
            Upgrades.registerDefinition.evaluate(thistype.create());
        }
	}
	
	public interface UpgradeDefinition {
		method setup();
	}
	
	public interface UpgradeEffect {
		public method activate(unit u);
		public method deactivate(unit u);
	}
}

//! endzinc

library UpgradesExt requires Upgrades, Ascii
	struct UpgradeUnit extends array
		//! runtextmacro AIDS()
		
		private trigger t
		private integer originalId
		
		private static method onUpgradeFinish takes nothing returns boolean
			local thistype d = thistype[GetTriggerUnit()]
			local integer id = GetUnitTypeId(d.unit)
			call Upgrades.removeUpgradesWithFakeUnit(d.unit, d.originalId)
			call Upgrades.applyUpgrades(d.unit)
			set d.originalId = id
			return false
		endmethod
		
		private static method AIDS_filter takes unit u returns boolean 
			// Check for sync, xeunit, upgrades, and illusions (we ignore these things!)
			return GetUnitTypeId(u) != 'sync' and GetUnitTypeId(u) != 'e01B' and GetUnitAbilityLevel(u, 'UPGR') == 0 and not IsUnitIllusion(u)
		endmethod
		
		private method AIDS_onCreate takes nothing returns nothing
			set originalId = GetUnitTypeId(this.unit)
			call Upgrades.applyUpgrades(this.unit)
			
			set this.t = CreateTrigger()
			call TriggerRegisterUnitEvent(this.t, this.unit, EVENT_UNIT_UPGRADE_FINISH)
			call TriggerAddCondition(this.t, Condition(function thistype.onUpgradeFinish))
		endmethod
		
		private method AIDS_onDestroy takes nothing returns nothing
			call DestroyTrigger(this.t)
			set this.t = null
		endmethod
	endstruct
endlibrary





















