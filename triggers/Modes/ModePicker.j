//TESH.scrollpos=346
//TESH.alwaysfold=0
//! zinc

library RacePicker requires IslandDefenseSystem, PlayerDataPick, UnitManager {
    public struct RacePickModeVotes[] {
        public integer index;
        public integer votes;
        public integer titanVotes;
    }
    
    public struct RacePicker {
        private static integer currentIndex = 0;
        private static RacePickMode modes[];
        private static integer index = 0;
        
        private static GameTimer randomCycle = 0;
        
        public static method register(RacePickMode mode){
            thistype.modes[thistype.index] = mode;
            mode.setIndex(thistype.index);
            thistype.index = thistype.index + 1;
            
            Command["-" + mode.shortName()].register(function(Args a){
                PlayerData p = PlayerData.get(GetTriggerPlayer());
                if (thistype.state() != thistype.STATE_VOTING) return;
                
                VoteBoardGeneric.instance().vote(p, SubString(a.command(), 1, StringLength(a.command())));
            });
        }
        
        public static method cycleRaces(){
            PlayerDataArray list = PlayerData.all();
            PlayerDataPick p = 0;
            integer i = 0;
            for (0 <= i < list.size()){
                p = PlayerDataPick[list.at(i)];
                if (p.isRandoming() &&
                    !p.hasPicked() &&
                    GetRandomInt(0, 5) < 4){
                    PlayerDataPick.setPlayerDataPickRandomRaceUniqueWithBans(p);
                }
            }
            list.destroy();
        }
        
        public static method pickMode() -> RacePickMode {
            return thistype.modes[thistype.currentIndex];
        }
        
        public static constant integer STATE_IDLE = 0;
        public static constant integer STATE_VOTING = 1;
        public static constant integer STATE_RUNNING = 2;
        public static constant integer STATE_FINISHED = 3;
        private static integer mState = STATE_IDLE;
        public static method state() -> integer {
            return mState;
        }
        public static method setState(integer state){
            thistype.mState = state;
        }
        
        public static method picked(PlayerDataPick p){
            thistype.pickMode().picked(p);
        }
        
        public static method onUnitCreation(PlayerData p){
            thistype.pickMode().onUnitCreation(PlayerDataPick[p]);
        }
        
        public static method onPickerItemEvent(PlayerDataPick p, unit seller, item it) {
            thistype.pickMode().onPickerItemEvent(p, seller, it);
        }
        
        public static method finish(){
            if (thistype.state() != thistype.STATE_RUNNING){
                // Uh oh, we were interrupted 
                return;
            }
            // Start the game!
            Game.start();
            Game.say("|cff00bfffRace picking complete.|r");
            thistype.setState(thistype.STATE_FINISHED);
        }
        
        public static method finalizePickMode(){
            if (thistype.state() != thistype.STATE_VOTING){
                return;
            }
            
            thistype.setState(thistype.STATE_RUNNING);
            
            if (Game.isState(Game.STATE_IDLE)) {
                Game.setMode(Game[thistype.pickMode().gameMode()]);
                Game.mode().setup();
            }
            else {
                thistype.activatePickMode();
            }
        }
        
        public static method activatePickMode() {
            Game.say("|cff00bfffActivating |r|cffff0000" + 
                        thistype.pickMode().shortName() +
                        "|r|cff00bfff (|cffff0000" +
                        thistype.pickMode().name() +
                        "|r|cff00bfff) mode.\n" +
                        thistype.pickMode().description() + "|r");
                        
            thistype.pickMode().setup();
            
            MetaData.onPickMode(thistype.pickMode().shortName());
            
            GameTimer.newNamed(function(GameTimer t){
                thistype.pickMode().start();
            }, "PickModeStartDelay").start(thistype.pickMode().getStartDelay()).showDialog(thistype.pickMode().shortName() + " Mode");
        }

        public static method printModes(){
            string message = "";
            integer i = 0;
            RacePickMode mode = 0;
            message = "|cff00bfffAvailable Modes: |r\n";
            for (0 <= i < index){
                mode = thistype.modes[i];
                message = message + "|cff00bfff(|r|cffff4000-" + StringCase(mode.shortName(), false) + "|r|cff00bfff)|r |cffff0000" + mode.name() + "|r";
                
                if (mode == thistype.getDefaultMode()){
                    message = message + "|cff00bfff (|r|cffff0000Default|r|cff00bfff)|r";
                }
                message = message + "\n";
            }
            Game.say(message);
        }
        
        public static method getDefaultMode() -> RacePickMode {
            integer i = 0;
            RacePickMode mode = 0;
            string default = GameSettings.getStr("PICKMODE_DEFAULT");
            for (0 <= i < index){
                mode = thistype.modes[i];
                if (mode.shortName() == default){
                    return mode;
                }
            }
            return 0;
        }
        
        private static method calculateVotes(VoteResult r){
            integer i = 0;
            integer j = 0;
            PlayerDataArray list = 0;
            PlayerData p = 0;
            RacePickModeVotes mode = 0;
            for(0 <= i < thistype.index){
                RacePickModeVotes[i].index = i;
                RacePickModeVotes[i].votes = 0;
                RacePickModeVotes[i].titanVotes = 0;
            }
            // Calculate
            list = PlayerData.all();
            for(0 <= i < list.size()){
                p = list[i];
                if (!p.isFake()){
                    mode = 0;
                    for(0 <= j < thistype.index){
                        if (StringCase(r[p], false) == StringCase(thistype.modes[j].shortName(), false)){
                            mode = RacePickModeVotes[j];
                            break;
                        }
                    }
                    if (mode == 0) mode = RacePickModeVotes[thistype.getDefaultMode().index()];

                    mode.votes = mode.votes + 1;
                    if (p.class() == PlayerData.CLASS_TITAN){
                        mode.titanVotes = mode.titanVotes + 1;
                    }
                }
            }
            list.destroy();
            
            // Check most voted for
            mode = RacePickModeVotes[0];
            for (1 <= i < thistype.index){
                if (mode.votes < RacePickModeVotes[i].votes){
                    mode = RacePickModeVotes[i];
                }
            }
            
            // Set default index
            thistype.currentIndex = thistype.getDefaultMode().index(); // AP
            
            // Check
            if (mode.votes > 0){
                if (thistype.modes[mode.index].meetsVoteRequirements(mode)) {
                    thistype.currentIndex = mode.index;
                    Game.say("|cff00bfffMode vote succeeded.|r");
                }
                else {
                    Game.say("|cff00bfffMode vote failed.|r");
                }
            }
            else {
                Game.say("|cff00bfffNo vote recorded, the default mode has been enabled.|r");
            }
            
            thistype.finalizePickMode();
        }
        
        private static method vote(PlayerData p, VoteResult r){
            integer i = 0;
            for (0 <= i < thistype.index){
                if (StringCase(r[p], false) == 
                    StringCase(thistype.modes[i].shortName(), false)){
                    Game.say(p.nameColored() + "|cff00bfff has voted for " + 
                             thistype.modes[i].shortName() +
                             "|r|cff00bfff (|cffff0000" + thistype.modes[i].name() + "|r|cff00bfff) mode.");
                    break;
                }
            }
        }
        
        private static method findPickMode(){
            VoteBoardGeneric vb = VoteBoardGeneric.instance();
            real time = GameSettings.getReal("PICKMODE_VOTE_TIME");
            vb.begin("Pick Mode", function(PlayerData p) -> boolean {
                return true;
            }, function(VoteResult r, integer data){
                PlayerData p = 0;
                if (r.expired()){
                    thistype.calculateVotes(r);
                }
                else {
                    p = r.lastVoter();
                    thistype.vote(p, r);
                }
            }, time, 0);
            
            thistype.printModes();
            
            Game.say("|cff00bfffYou now have |r|cffff0000" + R2SW(time, 1, 1) + "|r|cff00bfff seconds to choose a pick mode.|r");
        }
        
        public static method pickModeInitialize() -> boolean {
            //if (!Game.isState(Game.STATE_STARTING)) return false;
            if (thistype.state() != thistype.STATE_VOTING) return false;
            
            if (GameSettings.getBool("PICKMODE_VOTE_ENABLED")){
                thistype.findPickMode();
            }
            else {
                // Set default index
                thistype.currentIndex = thistype.getDefaultMode().index(); // Defined in GameSettings
                thistype.finalizePickMode();
            }
            
            thistype.randomCycle = 0;
            if (thistype.pickMode().cycleRaces()) {
                thistype.randomCycle = GameTimer.newNamedPeriodic(function(GameTimer t){
                    if (thistype.state() != thistype.STATE_FINISHED){
                        thistype.cycleRaces();
                    }
                    else {
                        t.deleteLater();
                        thistype.randomCycle = 0;
                    }
                }, "RacePickerRandomCycle");
                thistype.randomCycle.start(0.4);
            }
            
            return true;
        }

        public static method initialize() -> boolean {
            if (thistype.state() != thistype.STATE_IDLE) {
                Game.say("|cffff0000RacePicker is not in an idle state: " + I2S(thistype.state()) + "|r");
                return false;
            }
            PlayerDataPick.initialize();
            thistype.setState(thistype.STATE_VOTING);
            
            PanCameraToTimed(-384, -512, 0.0);
            SetCameraQuickPosition(-384, -512);
            
            if (GameSettings.getBool("STARTGAME_MESSAGE_ENABLED")) {
                CinematicModeBJ(true, bj_FORCE_ALL_PLAYERS);
                TransmissionFromUnitTypeWithNameBJ(bj_FORCE_ALL_PLAYERS, Player(PLAYER_NEUTRAL_PASSIVE),
                                                   GameSettings.getInt("STARTGAME_MESSAGE_FROM_ID"),
                                                   GameSettings.getStr("STARTGAME_MESSAGE_FROM"), Location(-384, -512),
                                                   gg_snd_Builder_ToHellWithYourApologies, 
                                                   GameSettings.getStr("STARTGAME_MESSAGE_TEXT"),
                                                   bj_TIMETYPE_ADD, GameSettings.getReal("STARTGAME_MESSAGE_TIME"), false);
                
                GameTimer.new(function(GameTimer t) {
                    CinematicModeBJ(false, bj_FORCE_ALL_PLAYERS);
                    thistype.pickModeInitialize();
                }).start(3.0 + GameSettings.getInt("STARTGAME_MESSAGE_TIME"));
            }
            else {
                if (!thistype.pickModeInitialize()) {
                    Game.say("|cffff0000Failed to call pickModeInitialize|r");
                }
            }

            return true;
        }
        
        public static method terminate(){
            if (thistype.state() == thistype.STATE_IDLE) return;
            Game.say("|cff00bfffRacePicker: Cleaning up (terminate called).|r");
            thistype.mState = thistype.STATE_IDLE;
            PlayerDataPick.terminate();
        }
    }
    
    function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SELL_ITEM);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit c = GetBuyingUnit();
            unit s = GetSellingUnit();
            PlayerDataPick p = 0;
            Race r = NullRace.instance();
            item im = GetSoldItem();
            integer id = GetItemTypeId(im);
            
            if (RacePicker.state() != RacePicker.STATE_RUNNING){
                return false;
            }
            
            p = PlayerDataPick[PlayerData.get(GetOwningPlayer(c))];
            
            if (p != 0 && c == p.picker()) {
                RacePicker.onPickerItemEvent(p, s, im);
            }

            c = null;
            im = null;
            p = 0;
            return false;
        }));
        t = null;
    }
}

//! endzinc