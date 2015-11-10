//TESH.scrollpos=193
//TESH.alwaysfold=0
//! zinc

library UnitManager requires UnitSpawner, RegisterPlayerUnitEvent {   
    
    public struct UnitManager {
        private static UnitList titans = 0;
        private static UnitList minions = 0;
        private static UnitList defenders = 0;
        private static UnitList hunters = 0;
            
        module UnitSpawner;
        
        public static method onDeath(){
            unit u = GetTriggerUnit();
            unit v = GetKillingUnit();
            Unit un = 0;

            if (thistype.isTitan(u)){
                un = thistype.titans.get(u);
                thistype.titans.remove(un);
                TitanDeath.onDeath(un, v);
            }
            if (thistype.isDefender(u)){
                un = thistype.defenders.get(u);
                thistype.defenders.remove(un);
                DefenderDeath.onDeath(un, v);
            }
            if (thistype.isMinion(u)){
                un = thistype.minions.get(u);
                thistype.minions.remove(un);
                MinionDeath.onDeath(un, v);
            }
            if (thistype.isHunter(u)){
                un = thistype.hunters.get(u);
                thistype.hunters.remove(un);
                HunterDeath.onDeath(un, v);
            }
            // We're not interested... bye!
            u = null;
            un = 0;
        }
        
        public static method isDefender(unit u) -> boolean {
            return thistype.defenders.indexOfUnit(u) != -1;
        }
        
        public static method isTitan(unit u) -> boolean {
            return thistype.titans.indexOfUnit(u) != -1;
        }
        
        public static method isMinion(unit u) -> boolean {
            return thistype.minions.indexOfUnit(u) != -1;
        }
        
        public static method isHunter(unit u) -> boolean {
            return thistype.hunters.indexOfUnit(u) != -1;
        }
        
        public static method getDefender(unit u) -> DefenderUnit {
            DefenderUnit d = 0;
            integer i = thistype.defenders.indexOfUnit(u);
            if (i != -1)
                d = thistype.defenders.at(i);
            return d;
        }
        
        public static method countTitans() -> integer {
            UnitList l = thistype.getTitans();
            integer i = l.size();
            l.destroy();
            return i;
        }
        
        public static method countMinions() -> integer {
            UnitList l = thistype.getMinions();
            integer i = l.size();
            l.destroy();
            return i;
        }
        
        public static method getTitans() -> UnitList {
            UnitList list = 0;
            //Game.say("getTitans() start " + I2S(thistype.titans.size()) + " | " + I2S(0));
            list = UnitList.copy(thistype.titans);
            //Game.say("getTitans() end " + I2S(thistype.titans.size()) + " | " + I2S(list.size()));
            return list;
        }
        
        public static method getMinions() -> UnitList {
            return UnitList.copy(thistype.minions);
        }
        
        public static method getDefenders() -> UnitList {
            return UnitList.copy(thistype.defenders);
        }
        
        public static method getHunters() -> UnitList {
            return UnitList.copy(thistype.hunters);
        }
        
        public static method initialize(){
            titans = UnitList.create();
            minions = UnitList.create();
            defenders = UnitList.create();
            hunters = UnitList.create();
        }
        
        public static method givePlayerUnitsTo(PlayerData from, PlayerData new){
            group g = CreateGroup();
            unit u = null;
            
            GroupEnumUnitsOfPlayer(g, from.player(), null);
            u = FirstOfGroup(g);
            while (u != null){
                SetUnitOwner(u, new.player(), true);
            
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            DestroyGroup(g);
            g = null;
            u = null;
        }
        
        public static method swapPlayerUnits(PlayerData firstPlayer, PlayerData secondPlayer){
            group firstPlayerUnits = CreateGroup();
            group secondPlayerUnits = CreateGroup();
            unit u = null;

            GroupEnumUnitsOfPlayer(firstPlayerUnits, firstPlayer.player(), null);
            GroupEnumUnitsOfPlayer(secondPlayerUnits, secondPlayer.player(), null);
            
            u = FirstOfGroup(firstPlayerUnits);
            while (u != null){
                SetUnitOwner(u, secondPlayer.player(), true);
            
                GroupRemoveUnit(firstPlayerUnits, u);
                u = FirstOfGroup(firstPlayerUnits);
            }
            DestroyGroup(firstPlayerUnits);
            
            u = FirstOfGroup(secondPlayerUnits);
            while (u != null){
                SetUnitOwner(u, firstPlayer.player(), true);
            
                GroupRemoveUnit(secondPlayerUnits, u);
                u = FirstOfGroup(secondPlayerUnits);
            }
            DestroyGroup(secondPlayerUnits);
            
            firstPlayerUnits = null;
            secondPlayerUnits = null;
            u = null;
        }
        
        
        
        public static method removeUnit(unit u){
            if (thistype.isDefender(u)){
                thistype.defenders.remove(thistype.defenders.get(u));
            }
        }
        
        public static method removePlayerUnits(PlayerData p){
            group g = CreateGroup();
            unit u = null;
            
            GroupEnumUnitsOfPlayer(g, p.player(), null);
            u = FirstOfGroup(g);
            while (u != null){
                thistype.removeUnit(u);
                RemoveUnit(u);
            
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            DestroyGroup(g);
            g = null;
            u = null;
        }

        
        public static method terminate(){
            Unit u = 0;
            while(titans.size() > 0){
                u = titans.takeAt(0); if (u != 0) u.destroy();
            }
            titans.destroy();
            
            while(minions.size() > 0){
                u = minions.takeAt(0); if (u != 0) u.destroy();
            }
            minions.destroy();
            
            while(defenders.size() > 0){
                u = defenders.takeAt(0); if (u != 0) u.destroy();
            }
            defenders.destroy();
            
            while(hunters.size() > 0){
                u = hunters.takeAt(0); if (u != 0) u.destroy();
            }
            hunters.destroy();
            
            ShopSystem.terminate();
        }
        
        public static method onInit(){
            PunishmentCentre.initialize();
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function(){
                thistype.onDeath();
            });
        }
    }
   
}

//! endzinc