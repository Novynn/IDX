//TESH.scrollpos=187
//TESH.alwaysfold=0
//! zinc

library IslandDefenseSystem requires HCL, Players, GameTimer, CheatPack, ElapsedGameTime, Upgrades {
    public constant integer TITAN_LOWERBOUND = 0;
    public constant integer TITAN_UPPERBOUND = 10;

    public constant integer DEFENDER_LOWERBOUND = 0;
    public constant integer DEFENDER_UPPERBOUND = 9;
    
    public struct Game {
        public static constant integer STATE_IDLE = 0;         // When the map is initialized
        public static constant integer STATE_STARTING = 1;     // When game modes / player races are being chosen
        public static constant integer STATE_STARTED = 2;      // Once defenders (and titan?) has spawned
        public static constant integer STATE_PAUSED = 3;
        public static constant integer STATE_FINISHED = 4;     // On gameover
        private static integer mState = STATE_IDLE;
        
        // Results to use in playerResult();
        public static constant integer RESULT_UNKNOWN = 0;
        public static constant integer RESULT_WINNER = 1;
        public static constant integer RESULT_LOSER = 2;
        public static constant integer RESULT_LEAVER = 3;
        public static constant integer RESULT_DEBUG = 4;
        
        // Debug
        public static boolean ignorePlayers[];
        
        private static GameMode modes[];
        private static integer index = 0;
        public static method register(GameMode mode){
            thistype.modes[thistype.index] = mode;
            thistype.index = thistype.index + 1;
        }
        
        public static method operator[] (string mode) -> GameMode {
            integer i = 0;
            for (0 <= i < thistype.index) {
                if (StringCase(thistype.modes[i].shortName(), false) == StringCase(mode, false)) {
                    return thistype.modes[i];
                }
            }
            return 0;
        }
        
        private static integer mMode = 0;
        public static method mode() -> GameMode {
            return mMode;
        }
        
        public static method isMode(string mode) -> boolean {
            if (mode() == 0) return false;
            return (StringCase(mode().shortName(), false) == StringCase(mode, false));
        }
        public static method setMode(GameMode mode){
            mMode = mode;
        }
        
        private static integer mGameId = 0;
        public static method id() -> integer {
            return mGameId;
        }
        
        private static integer oldState = 0;
        
        public static method pausedState() -> integer {
            return thistype.oldState;
        }
        
        public static method state() -> integer {
            return mState;
        }
        
        public static method isState(integer state) -> boolean {
            return (state() == state);
        }
        
        public static method setState(integer state){
            static if (LIBRARY_EnvironmentManager){
                MusicManager.stateChanged(state, thistype.mState);
            }
            thistype.mState = state;
        }
        
        public static method stateString(integer state) -> string {
            if (thistype.isState(STATE_IDLE)) return "STATE_IDLE";
            if (thistype.isState(STATE_STARTING)) return "STATE_STARTING";
            if (thistype.isState(STATE_STARTED)) return "STATE_STARTED";
            if (thistype.isState(STATE_PAUSED)) return "STATE_PAUSED";
            if (thistype.isState(STATE_FINISHED)) return "STATE_FINISHED";
            return "STATE_UNKNOWN";
        }
        
        public static method printState(){
            thistype.say("Game is currently in State: " + thistype.stateString(thistype.state()));
        }
        
        public static method initialize() -> boolean {
            if (!Game.isState(Game.STATE_IDLE)) return false;
            thistype.mGameId = thistype.mGameId + 1;
            
            thistype.loadPlayers();
            thistype.clearPlayerClasses();
            TweakManager.initialize();
            
            GameTimer.new(function(GameTimer t) {
                Game.say("|cffffcc00[|r|cffff0000GAME INITIALIZING...|r|cffffcc00]|r");
                thistype.setMode(thistype["ID"]);
                // Load HCL settings!
                HCLSystem.setup();
				
				// Initialize upgrades!
				Upgrades.initialize();
				
				// Ensure ability hidden ness!
				CustomTitanRace.setupAbilities();
				
				// Now gooooo!
                thistype.mode().setup();
            }).start(0.0);
            
            return true;
        }
        public static method start() -> boolean {
            if (!Game.isState(Game.STATE_STARTING)) return false;
            Game.setState(Game.STATE_STARTED);
            Game.say("|cffffcc00[|r|cffff0000GAME STARTED|r|cffffcc00]|r");
            ElapsedGameTime.start();
            return thistype.mode().start();
        }
        
        public static method pause(){
            thistype.say("|cffffcc00[|r|cffff0000GAME PAUSED|r|cffffcc00]|r");
            thistype.oldState = thistype.state();
            thistype.setState(thistype.STATE_PAUSED);
            if (ElapsedGameTime.started) {
                ElapsedGameTime.pause();
            }
            thistype.mode().pause();
        }
        
        public static method resume(){
            if (!thistype.isState(thistype.STATE_PAUSED)) return;
            thistype.say("|cffffcc00[|r|cffff0000GAME RESUMED|r|cffffcc00]|r");
            
            thistype.setState(Game.oldState);
            if (ElapsedGameTime.started) {
                ElapsedGameTime.resume();
            }
            thistype.mode().resume();
        }
        
        public static method stop(){
            thistype.say("|cffffcc00[|r|cffff0000GAME STOPPING...|r|cffffcc00]|r");
            ElapsedGameTime.stop();
            thistype.mode().stop();
            thistype.say("|cffffcc00[|r|cffff0000GAME STOPPED!|r|cffffcc00]|r");
            thistype.setState(thistype.STATE_IDLE);
        }
        
        public static method restart(){
            thistype.mode().restart();
        }
        
        public static method finish(){
            thistype.setState(thistype.STATE_FINISHED);
        }
        
        public static method clearPlayerClasses(){
            integer i = 0;
            PlayerDataArray list = PlayerData.all();
            PlayerData p;
            for (0 <= i < list.size()){
                p = list[i];
                p.resetClass();
                p.setRace(NullRace.instance());
            }
            list.destroy();
        }
        
        public static method loadPlayers() -> boolean {
            integer i = 0;
            player p;
            PlayerData q = 0;
            
            if (thistype.id() > 1) {
                for (0 <= i < 12){
                    p = Player(i);
                    if (PlayerData.has(p)){
                        q = PlayerData[i];
                        if (q.isLeaving() || q.hasLeft()){
                            thistype.ignorePlayers[i] = true;
                        }
                        else {
                            // If they were a titan that didn't leave, we want them to titan this game too!
                            if (q.class() == PlayerData.CLASS_TITAN){
                                TitanFinder.forceAsTitan[i] = true;
                            }
                        }
                    }
                }
                PlayerData.clear();
            }

            for (0 <= i < 11){
                p = Player(i);
                // Should we register players even if they aren't playing (ie. Computers)?
                if (!thistype.ignorePlayers[i]){
                    if ((GetPlayerController(p) == MAP_CONTROL_USER) 
                        && (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING)){
                        PlayerData.register(p);
                    }
                }
            }
            p = null;
            return true;
        }
        
        public static method checkVictory(){
            thistype.mode().checkVictory();
        }
        
        public static method endGame(){
            thistype.mode().endGame();
        }
        
        public static method setupPlayers() -> boolean {
            return thistype.mode().setupPlayers();
        }
        
        public static method activateCheats(){
            PlayerDataArray list = PlayerData.all();
            integer i = 0;
            for (0 <= i < list.size()){
                CheatActivate(list.at(i).player());
            }
            list.destroy();
        }
        
        public static method sayClass(integer class, string s){
            if (PlayerData.get(GetLocalPlayer()).class() == class){
                thistype.say(s);
            }
        }
        
        public static method error(string s){
            thistype.say(s);
        }
        
        public static method say(string s){
            DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 15.0, s);
        }
        
        public static method onPlayerJoin(PlayerData p) {
            MetaData.onPlayerJoin(p);
        }
        
        public static method onPlayerLeft(PlayerData p) {
            // Sync the event
            MetaData.onPlayerLeft(p);
        }
        
        public static method onPlayerClassChange(PlayerData p) {
            MetaData.onPlayerClassChange(p);
        }
        
        public static method onPlayerRaceChosen(PlayerData p) {
            MetaData.onPlayerRaceChosen(p);
        }
        
        public static method onInit(){
            integer i = 0;
            for (0 <= i < 11){
                thistype.ignorePlayers[i] = false;
            } // Debug
        }
        
        public static method currentGameElapsed() -> real {
            return ElapsedGameTime.getTime();
        }
        public static method currentGameElapsedTime() -> string {
            return ElapsedGameTime.getTimeString();
        }
    }
    
    public interface GameMode {
        method name() -> string;
        method shortName() -> string;
        method description() -> string;
        
        method isAvailable() -> boolean;
        method setup() -> boolean;
        method start() -> boolean;
        method pause();
        method resume();
        method stop();
        method restart();
        
        method onPlayerSetup(PlayerData p) = null;
        method clearPlayers() = null;
        method setupPlayers() -> boolean = true;
        method onStateChanged(integer oldState) = null;
        
        method checkVictory() -> boolean;
        method playerResult(PlayerData p) -> integer;
        method endGame();
    }
    
    private function onInit(){
        // Initial state
        SpeechSystem.setup();
        
        Game.setState(Game.STATE_IDLE);
        Game.initialize();
    }
}

//! endzinc