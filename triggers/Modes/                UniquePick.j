//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library RacePickModeUniquePick requires RacePickMode, UnitManager {
    private struct DefenderRaceUniquePick {
        DefenderRace race = 0;
        integer playerCount = 0;
        PlayerDataPick players[100];
        integer positions[100];
        boolean randomed[100];
    
        public static method create(DefenderRace r) -> thistype {
            thistype this = thistype.allocate();
            this.race = r;
            this.playerCount = 0;
            return this;
        }
        
        method addPlayer(PlayerDataPick p, integer position, boolean random) {
            this.players[this.playerCount] = p;
            this.positions[this.playerCount] = position;
            this.randomed[this.playerCount] = random;
            this.playerCount = this.playerCount + 1;
        }
        
        method resolve() -> PlayerDataPick {
            PlayerDataPick p = 0;
            boolean r = false;
            integer i = 0;
            integer j = 0;
            integer indicies[];
            integer indiciesCount = 0;
            for (0 <= i < 6) {
                indiciesCount = 0;
                for (0 <= j < this.playerCount) {
                    if (this.positions[j] == i && !this.players[j].hasPicked()) {
                        indicies[indiciesCount] = j;
                        indiciesCount = indiciesCount + 1;
                    }
                }
                
                if (indiciesCount > 0) {
                    i = indicies[GetRandomInt(0, indiciesCount - 1)];
                    p = this.players[i];
                    r = this.randomed[i];
                    break;
                }
            }
            
            if (p != 0) {
                //Game.say("Resolved " + race.toString() + " to: " + p.name() + " (out of " + I2S(indiciesCount) + " players)");
                p.setRandoming(r);
                p.pick(this.race);
            }
            else {
                //Game.say("Could not resolve: " + race.toString());
            }
            
            this.destroy();
            
            return p;
        }
    }
    
    public struct RacePickModeUniquePick extends RacePickMode {
        module RacePickModeModule;
        
        method name() -> string {
            return "Unique Pick";
        }
        method shortName() -> string {
            return "UP";
        }
        method description() -> string {
            return "All players will be able to choose a unique race.";
        }
        
        private boolean spawnStarted = false;
        
        method setup(){
            this.setupNormally();
            this.spawnStarted = false;
        }
        
        public method onPlayerSetup(PlayerData p){
            if (p.class() == PlayerData.CLASS_DEFENDER) {
                p.setGold(p.gold() + 1);
            }
        }
        
        method start(){
            PlayerDataArray list = 0;
            PlayerDataPick p = 0;
            integer i = 0;
            integer j = 0;
            Table raceUniquePickData = Table.create();
            DefenderRace pickedRaces[];
            integer pickedRacesCount = 0;
            DefenderRace r = 0;
            boolean randomed = false;
            boolean hasRandom = false;
            boolean preRandom = false;
            item it = null;
            
            // Now we want to let all the Defenders choose their race
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                if (!p.isLeaving() && !p.hasLeft() && !p.hasPicked()){
                    preRandom = p.isRandoming();
                    p.setRandoming(false);
                    for (0 <= j < 6) {
                        it = UnitItemInSlot(p.picker(), j);
                        r = 0;
                        randomed = p.isRandoming() || (p.isFake() && GameSettings.getBool("FAKE_PLAYERS_AUTOPICK"));
                        if (randomed || it != null) {
                            if (randomed || GetItemTypeId(it) == 'I006') {
                                r = PlayerDataPick.getPlayerDataPickRandomRaceUniqueWithBans(p);
                                randomed = true;
                                if (it != null) {
                                    RemoveItem(it);
                                }
                            }
                            else {
                                r = DefenderRace.fromItemId(GetItemTypeId(it));
                                RemoveItem(it);
                            }
                        }
                        it = null;
                        
                        hasRandom = hasRandom || randomed;
                        
                        if (r != 0) {
                            if (!raceUniquePickData.has(r)) {
                                raceUniquePickData[r] = DefenderRaceUniquePick.create(r);
                                pickedRaces[pickedRacesCount] = r;
                                pickedRacesCount = pickedRacesCount + 1;
                            }
                            DefenderRaceUniquePick(raceUniquePickData[r]).addPlayer(p, j, randomed);
                        }
                    }
                    
                    // If the player has chosen one random, we can always random on that.
                    // This will be overridden if a actual race is chosen, see resolve()
                    // preRandom is used for things such as lazy random. This will ensure that a 
                    // race is randomed if no matches are found
                    if (hasRandom || preRandom) {
                        p.setRandoming(true);
                    }
                }
            }
            list.destroy();
            list = 0;
            
            // Allow ALL players to spawn
            this.spawnStarted = true;
            
            for (0 <= i < pickedRacesCount) {
                r = pickedRaces[i];
                // Resolve destroys the data
                DefenderRaceUniquePick(raceUniquePickData[r]).resolve();
                raceUniquePickData.remove(r);
            }
            raceUniquePickData.destroy();
            
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            // For everyone that we couldn't spawn, give them a chance to pick properly
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                if (!p.isLeaving() && !p.hasLeft() && !p.hasPicked()){
                    if (p.isRandoming()) {
                        p.say("|cff00bfff(Backup) Force-randoming your Defender.|r");
                        p.pick(p.race());
                    }
                    else {
                        p.say("|cff00bfffFailed to assign you to your desired class, please pick from the remaining Defenders.|r");
                        p.setCanPick(true);
                    }
                }
            }
            list.destroy();
            list = 0;
            
            // Next, we want to start the timer for the Titan to spawn
            graceDelayTimer = GameTimer.newNamed(function(GameTimer t){
                PlayerDataArray list = 0;
                integer i = 0;
                PlayerDataPick p = 0;
                
                list = PlayerData.withClass(PlayerData.CLASS_TITAN);
                for (0 <= i < list.size()){
                    p = PlayerDataPick[list[i]];
                    if (!p.isLeaving() && !p.hasLeft() && !p.hasPicked()){
                        if (p.isRandoming() || (p.isFake() && GameSettings.getBool("FAKE_PLAYERS_AUTOPICK"))){
                            p.pick(p.race());
                        }
                        else {
                            p.setCanPick(true);
                        }
                    }
                }
                list.destroy();
                list = 0;
            }, "TitanDelayTime");
            graceDelayTimer.showDialog("Grace Period");
            graceDelayTimer.start(GameSettings.getReal("TITAN_SPAWN_GRACE_TIME"));
            
            it = null;
        }
        
        method picked(PlayerDataPick p){
            if (!this.spawnStarted) {
                p.setPicked(false);
                return;
            }
            // Since p.race() will count in the following, we need to check if there are more than 1
            if (PlayerData.countRace(p.race()) > 1) {
                p.setPicked(false);
                p.setGold(p.gold() + 1);
                p.say("|cff00bfffSomeone else has chosen this Defender, please choose another one.|r");
                return;
            }
            this.pickedNormal(p);
        }
        
        method onUnitCreation(PlayerDataPick p){
            this.onUnitCreationNormal(p);
        }
        method onPickerItemEvent(PlayerDataPick p, unit seller, item it){
            Race r = 0;
            integer id = GetItemTypeId(it);
            integer i = 0;

            if (p.class() == PlayerData.CLASS_DEFENDER){
                if (this.spawnStarted) {
                    r = this.onPickerItemEventNormal(p, seller, it);
                }
                else {
                    r = DefenderRace.fromItemId(id);
                    RemoveItem(it);
                    
                    if (r == 0 || r == NullRace.instance()) {
                        p.say("|cff00bfffYour remaining choices will be: |r|cffff0000Random|r");
                        id = 'I006'; // Random Item
                        for (0 <= i < 6) {
                            if (UnitItemInSlot(p.picker(), i) == null) {
                                UnitAddItemToSlotById(p.picker(), id, i);
                            }
                        }
                    }
                    else {
                        for (0 <= i < 6) {
                            if (UnitItemInSlot(p.picker(), i) == null) break;
                        }
                        p.say("|cff00bfffYour #" + I2S(i+1) + " choice is: |r|cffff0000" + r.toString() + "|r");
                        id = r.itemId();
                        UnitAddItemById(p.picker(), id);
                        p.playerData.setGold(p.playerData.gold() + 1);
                    }
                }
            }
            else if (p.class() == PlayerData.CLASS_TITAN){
                this.onPickerItemEventNormal(p, seller, it);
            }
        }
        method getStartDelay() -> real {
            return this.getStartDelayNormal() + 5.0; // Add 5 seconds
        }
        method end(){
            this.endNormally();
        }
    }
}

//! endzinc