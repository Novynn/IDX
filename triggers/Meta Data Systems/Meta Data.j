//TESH.scrollpos=36
//TESH.alwaysfold=0
//! zinc

// The library that handles all of Island Defense's W3MMD tracking.
library MetaData requires MMD, GameTimer {
    public struct MetaData {
        private static boolean isSetup = false;
        private static trigger triggerInitialize = null;
        private static trigger triggerSetup = null;
        private static trigger triggerReset = null;
        private static trigger triggerClass[12];
        private static trigger triggerFed[12];
        private static trigger triggerRace[12];
        private static trigger triggerFlag[12];
        private static integer syncCount = 0;
        
        public static method syncBegin() -> integer {
            //Thread thread = Thread.create();
            TriggerSyncStart();
            return 0; //thread;
        }
        
        public static method syncEnd(integer thread) {
            TriggerSyncReady();
            
            //thread.sync();
            
            //while (true) {
            //    TriggerSyncStart();
            //    if (thread.synced) break;
            //    TriggerSyncReady();
            //}
            //if (thread != 0) thread.destroy();
        }
        
        private static method getTriggerPlayerData(trigger t) -> PlayerData {
            integer i = 0;
            for (0 <= i < 12) {
                if (t == thistype.triggerClass[i] ||
                    t == thistype.triggerFed[i] ||
                    t == thistype.triggerRace[i] ||
                    t == thistype.triggerFlag[i]){
                    return PlayerData[i];
                }
            }
            return 0;
        }
        
        public static method extras() -> boolean {
            boolean enabled = false;
            static if (LIBRARY_MMD){
                return GameSettings.getBool("MMD_ENABLED") &&
                       GameSettings.getBool("EXTRAS_ENABLED");
            }
            return false;
        }
        
        public static method onPlayerJoin(PlayerData p) {
            //if (thistype.extras()) {
            //    thistype.syncPlayerClass(p);
            //}
        }
        
        public static method onPlayerLeft(PlayerData p) {
            //if (Game.state() == Game.STATE_FINISHED) return;
            //if (thistype.extras()) {
            //    thistype.syncPlayerClass(p);
            //    thistype.syncPlayerFed(p);
            //}
            
            //thistype.syncPlayerFlag(p);
        }
        
        public static method onPlayerClassChange(PlayerData p) {
            if (!thistype.extras()) return;
            thistype.syncPlayerClass(p);
        }
        
        public static method onPlayerRaceChosen(PlayerData p) {
            if (!thistype.extras()) return;
            thistype.syncPlayerRace(p);
        }

        
        public static method initialize() {
            TriggerExecute(thistype.triggerInitialize);
        }
        
        public static method setup() {
            TriggerExecute(thistype.triggerSetup);
        }
        
        public static method reset() {
            TriggerExecute(thistype.triggerReset);
        }
        
        public static method syncPlayerClass(PlayerData p) {
            if (!thistype.extras()) return;
            TriggerExecute(thistype.triggerClass[p.id()]);
        }
        
        public static method syncPlayerFed(PlayerData p) {
            TriggerExecute(thistype.triggerFed[p.id()]);
        }
        
        public static method syncPlayerRace(PlayerData p) {
            TriggerExecute(thistype.triggerRace[p.id()]);
        }
        
        public static method syncPlayerFlag(PlayerData p) {
            TriggerExecute(thistype.triggerFlag[p.id()]);
        }
        
        public static method initializeAct() { static if (LIBRARY_MMD){
            integer i = 0;
            integer thread = thistype.syncBegin();
            MMD_emit("init version " + I2S(MMD_MINIMUM_PARSER_VERSION) + " " + I2S(MMD_CURRENT_VERSION));

            for (0 <= i < 12) {
                if (GetPlayerController(Player(i)) == MAP_CONTROL_USER &&
                    GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING){
                    MMD_emit("init pid " + I2S(i) + " " + MMD_pack(GetPlayerActualName(Player(i))));
                }
            }
            thistype.syncEnd(thread);
            thread = 0;
        } }
        
        public static method setupAct() { static if (LIBRARY_MMD){
            integer thread = 0; 
            if (thistype.isSetup) return;
            thistype.isSetup = true;
            if (thistype.extras()){
                thread = thistype.syncBegin();
                MMD_DefineValue("kills",            MMD_TYPE_INT,   MMD_GOAL_HIGH, MMD_SUGGEST_LEADERBOARD);
                MMD_DefineValue("afk",              MMD_TYPE_INT,   MMD_GOAL_HIGH, MMD_SUGGEST_TRACK);
                MMD_DefineValue("deaths",           MMD_TYPE_INT,   MMD_GOAL_LOW,  MMD_SUGGEST_LEADERBOARD);
                MMD_DefineValue("start_class",      MMD_TYPE_INT,   MMD_GOAL_NONE, MMD_SUGGEST_TRACK);
                MMD_DefineValue("class",            MMD_TYPE_INT,   MMD_GOAL_NONE, MMD_SUGGEST_TRACK);
                MMD_DefineValue("end_class",        MMD_TYPE_INT,   MMD_GOAL_NONE, MMD_SUGGEST_TRACK);
                MMD_DefineValue("end_state",        MMD_TYPE_INT,   MMD_GOAL_NONE, MMD_SUGGEST_TRACK);
                MMD_DefineValue("race",             MMD_TYPE_STRING,MMD_GOAL_NONE, MMD_SUGGEST_TRACK);
                MMD_DefineValue("race_randomed",    MMD_TYPE_INT,   MMD_GOAL_NONE, MMD_SUGGEST_TRACK);
                MMD_DefineValue("experience_fed",   MMD_TYPE_INT,   MMD_GOAL_NONE, MMD_SUGGEST_TRACK);
                thistype.syncEnd(thread);
                thread = 0;
            }
        } }
        
        public static method resetAct(){ static if (LIBRARY_MMD){
            integer thread = 0;
            if (thistype.extras()){
                thread = thistype.syncBegin();
                MMD_LogCustom("map_reset", I2S(Game.id()));
                thistype.syncEnd(thread);
                thread = 0;
            }
        } }
        
        public static method syncPlayerClassAct() {
            PlayerData p = thistype.getTriggerPlayerData(GetTriggeringTrigger());
            integer thread = 0; 
            if (!thistype.extras()) return;
            thread = thistype.syncBegin();
            MMD_UpdateValueInt("start_class", p.player(), MMD_OP_SET, p.initialClass());
            
            if (p.hasLeft()) {
                MMD_UpdateValueInt("end_class", p.player(), MMD_OP_SET, p.leftClass());
                MMD_UpdateValueInt("end_state", p.player(), MMD_OP_SET, p.leftGameState());
            }
            else {
                MMD_UpdateValueInt("class", p.player(), MMD_OP_SET, p.class());
            }
            thistype.syncEnd(thread);
            thread = 0;
        }
        
        public static method syncPlayerFedAct() {
            PlayerData p = thistype.getTriggerPlayerData(GetTriggeringTrigger());
            integer thread = 0; 
            if (!thistype.extras()) return;
            if (!PlayerDataFed.initialized() || PlayerDataFed[p] == 0) return;
            thread = thistype.syncBegin();
            thistype.syncCount = thistype.syncCount + 1;
            MMD_UpdateValueInt("experience_fed", p.player(), MMD_OP_SET, PlayerDataFed[p].fed());
            thistype.syncEnd(thread);
            thread = 0;
        }
        
        public static method syncPlayerRaceAct() {
            PlayerData p = thistype.getTriggerPlayerData(GetTriggeringTrigger());
            integer thread = 0; 
            integer flag = 0;
            if (!thistype.extras()) return;
            if (p.chosenRace() == 0) return;
            thread = thistype.syncBegin();
            MMD_UpdateValueString("race", p.player(), p.chosenRace().toString());
            flag = 0;
            if (p.wasRaceRandom()) flag = 1;
            MMD_UpdateValueInt("race_randomed", p.player(), MMD_OP_SET, flag);

            thistype.syncEnd(thread);
            thread = 0;
        }
        
        public static method syncPlayerFlagAct() { static if (LIBRARY_MMD){
            PlayerData p = thistype.getTriggerPlayerData(GetTriggeringTrigger());
            integer thread = 0; 
            integer flag = 0;
            if (thistype.isFinalized()) return;
            if (!GameSettings.getBool("MMD_ENABLED")) return;
            
            thread = thistype.syncBegin();
            MMD_FlagPlayer(p.player(), Game.mode().playerResult(p));
            thistype.syncEnd(thread);
        } }
        
        private static boolean finalized = false;
        public static method isFinalized() -> boolean {
            return thistype.finalized;
        }
        
        public static method finalize() {
            static if (LIBRARY_MMD){
                PlayerDataArray list = 0;
                integer i = 0;
                if (thistype.isFinalized()) return;
                if (!GameSettings.getBool("MMD_ENABLED")) return;
                
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
        }
        
        public static method onInit() {
            trigger t = CreateTrigger();
            integer i = 0;
            thistype.triggerInitialize = CreateTrigger();
            thistype.triggerSetup = CreateTrigger();
            thistype.triggerReset = CreateTrigger();
            TriggerAddAction(thistype.triggerInitialize, static method thistype.initializeAct);
            TriggerAddAction(thistype.triggerSetup, static method thistype.setupAct);
            TriggerAddAction(thistype.triggerReset, static method thistype.resetAct);
            for (0 <= i < 12) {
                thistype.triggerClass[i] = CreateTrigger();
                thistype.triggerFed[i] = CreateTrigger();
                thistype.triggerRace[i] = CreateTrigger();
                thistype.triggerFlag[i] = CreateTrigger();
                
                TriggerAddAction(thistype.triggerClass[i], static method thistype.syncPlayerClassAct);
                TriggerAddAction(thistype.triggerFed[i], static method thistype.syncPlayerFedAct);
                TriggerAddAction(thistype.triggerRace[i], static method thistype.syncPlayerRaceAct);
                TriggerAddAction(thistype.triggerFlag[i], static method thistype.syncPlayerFlagAct);
            }
            
            
            TriggerRegisterTimerEvent(t, 0, false);
            TriggerAddAction(t, function() {
                thistype.initialize.evaluate();
                thistype.setup.evaluate();
            });
            
            //t = CreateTrigger();
            //TriggerRegisterTimerEvent(t, 2.0, true);
            //TriggerAddAction(t, function() {
            //    integer i = 0;
            //    PlayerDataArray list = PlayerData.all();
            //    for (0 <= i < list.size()){
            //        thistype.syncPlayerFed(list[i]);
            //    }
            //    list.destroy();
            //});
            t = null;
        }
    }
}

//! endzinc