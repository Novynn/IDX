//! zinc

// The library that handles all of Island Defense's stat tracking.
library MetaData requires GameTimer {
    public struct MetaData {
        private static boolean isSetup = false;
        private static gamecache cache = null;
        private static gamecache mmd = null;
        
        private static constant string FileName = "ID.D";
        private static constant string MMDFileName = "MMD.Dat";

        public static method getSyncPlayer() -> PlayerData {
            PlayerDataArray list = PlayerData.allReal();
            PlayerData p = PlayerData(list.first());
            list.destroy();
            return p;
        }
        
        public static method lock() -> boolean {
            PlayerData p = thistype.getSyncPlayer();
            return (GetLocalPlayer() == p.player());
        }
        
        public static method mmdStoreThenSync(string m, string k, integer v) {
            StoreInteger(thistype.mmd, m, k, v);
            if (thistype.lock())
                SyncStoredInteger(thistype.mmd, m, k);
        }
        
        public static method storeThenSync(string m, string k, integer v) {
            thistype.store(m, k, v);
            thistype.syncRemote(m, k);
        }
        
        public static method store(string m, string k, integer v) {
            StoreInteger(thistype.cache, m, k, v);
        }
        
        public static method syncRemote(string m, string k) {
            if (thistype.lock())
                thistype.syncLocal(m, k);
        }
        
        public static method syncLocal(string m, string k) {
            SyncStoredInteger(thistype.cache, m, k);
        }
        
        public static method onPickMode(string mode) {
            thistype.storeThenSync.execute("pick_mode", mode, 1); 
        }
        
        public static method onGameStart() {
            thistype.storeThenSync.execute("game_start", "global", 1); 
        }
        
        public static method onSpawn(string t, unit u) {
            PlayerData p = PlayerData.get(GetOwningPlayer(u));
            integer level = GetHeroLevel(u);
            thistype.storeThenSync.execute(t + "_spawn", p.sId(), GetHandleId(u));
        }
        
        public static method onLevel(string t, unit u) {
            PlayerData p = PlayerData.get(GetOwningPlayer(u));
            integer level = GetHeroLevel(u);
            thistype.storeThenSync.execute(t + "_level:" + I2S(level), p.sId(), GetHandleId(u)); 
        }
        
        public static method onDeath(string t, unit u) {
            PlayerData p = PlayerData.get(GetOwningPlayer(u));
            thistype.storeThenSync.execute(t + "_death", p.sId(), GetHandleId(u));
        }
        
        public static method onPlayerJoin(PlayerData p) {
            thistype.syncPlayerClass.execute(p);
        }
        
        public static method onPlayerLeft(PlayerData p) {
            if (Game.state() == Game.STATE_FINISHED) return;
            thistype.syncPlayerClass.execute(p);
            thistype.syncPlayerFed.execute(p);
            thistype.syncPlayerFlag.execute(p);
        }
        
        public static method onPlayerClassChange(PlayerData p) {
            thistype.syncPlayerClass.execute(p);
        }
        
        public static method onPlayerRaceChosen(PlayerData p) {
            thistype.syncPlayerRace.execute(p);
        }
        
        public static method initialize() {
            // No initialization code needed anymore?
        }
        
        public static method setup() {
            integer thread = 0; 
            if (thistype.isSetup) return;
            thistype.isSetup = true;
            // No setup needed anymore?
        }
        
        public static method reset() {
            thistype.storeThenSync("map_reset", I2S(Game.id()), 1);
        }
        
        public static method syncPlayerClass(PlayerData p) {
            string id = p.sId();
            thistype.store("start_class", id, p.initialClass());
            
            if (p.hasLeft()) {
                thistype.store("end_class", id, p.leftClass());
                thistype.store("end_state", id, p.leftGameState());
            }
            else {
                thistype.store("class", id, p.class());
            }
            
            if (thistype.lock()) {
                thistype.syncLocal("start_class", id);
                if (p.hasLeft()) {
                    thistype.syncLocal("end_class", id);
                    thistype.syncLocal("end_state", id);
                }
                else {
                    thistype.syncLocal("class", id);
                }
            }
        }
        
        public static method syncPlayerFed(PlayerData p) {
            string id = p.sId();
            if (!PlayerDataFed.initialized() || PlayerDataFed[p] == 0) return;
            thistype.storeThenSync("experience_fed", id, PlayerDataFed[p].fed());
        }
        
        public static method syncPlayerRace(PlayerData p) {
            string id = p.sId();
            integer flag = 0;
            if (p.chosenRace() == 0) return;
            thistype.storeThenSync("race:" + p.chosenRace().toString(), id, p.chosenRace().widgetId());
            if (p.wasRaceRandom()) flag = 1;
            thistype.storeThenSync("race_randomed", id, flag);
        }
        
        public static method syncPlayerFlag(PlayerData p) {
            string id = p.sId();
            string result = "";
            integer r;
            if (thistype.isFinalized()) return;
            thistype.storeThenSync("flag", id, Game.mode().playerResult(p));
            
            // Keep MMD stats for random parsers like ENT's?
            r = Game.mode().playerResult(p);
            if (r == 0) result = "loser";
            else if (r == 1) result = "winner";
            else result = "practicing";
            
            thistype.mmdStoreThenSync("val:0", "FlagP " + id + " " + result, 1);
        }
        
        private static boolean finalized = false;
        public static method isFinalized() -> boolean {
            return thistype.finalized;
        }
        
        public static method finalize() {
            PlayerDataArray list = 0;
            integer i = 0;
            if (thistype.isFinalized()) return;
            
            // Now for players that are still here...
            list = PlayerData.all();
            for (0 <= i < list.size()){
                thistype.syncPlayerFlag(list[i]);
            }
            list.destroy();
            list = PlayerData.leavers();
            for (0 <= i < list.size()){
                thistype.syncPlayerFlag(list[i]);
            }
            list.destroy();
            thistype.finalized = true;
        }
        
        public static method onInit() {
            trigger t = CreateTrigger();
            FlushGameCache(InitGameCache(thistype.FileName));
            thistype.cache = InitGameCache(thistype.FileName);
            
            FlushGameCache(InitGameCache(thistype.MMDFileName));
            thistype.mmd = InitGameCache(thistype.MMDFileName);
            
            TriggerRegisterTimerEvent(t, 0, false);
            TriggerAddAction(t, function() {
                thistype.initialize.execute();
                thistype.setup.execute();
            });
            t = null;
        }
    }
}

//! endzinc