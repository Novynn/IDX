//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library RacePickModeUniquePick requires RacePickMode, UnitManager {
    private player PICK_PLAYER = Player(15); // Neutral Passive
    private struct UniquePickData {
        public static UniquePickData data[];
        public static integer dataCount = 0;
        
        public static method fromPicker(unit p) -> thistype {
            integer i = 0;
            thistype this = 0;
            for (0 <= i < thistype.dataCount) {
                this = thistype.data[i];
                if (this != 0 && this.picker == p) {
                    return this;
                }
            }
            return 0;
        }
        
        public static method fromRace(DefenderRace r) -> thistype {
            integer i = 0;
            thistype this = 0;
            for (0 <= i < thistype.dataCount) {
                this = thistype.data[i];
                if (this != 0 && this.race == r) {
                    return this;
                }
            }
            return 0;
        }
        
        unit model = null;
        unit picker = null;
        DefenderRace race = 0;
        private integer index = 0;
        
        method getRace() -> DefenderRace {
            return this.race;
        }
        
        public static method reset() {
            thistype.dataCount = 0;
        }
        
        public static method createRandom(real x, real y, real angle) -> thistype {
            thistype this = thistype.allocate();
            this.race = 0;
            this.model = CreateUnit(PICK_PLAYER, 'h02B', x, y, angle);
            UnitAddAbility(this.model, 'Avul');
            UnitAddAbility(this.model, 'Aloc');
            SetUnitPathing(this.model, false);
            
            this.picker = CreateUnit(PICK_PLAYER, 'n00G', x, y, 0.0);
            //UnitAddItem(this.picker, CreateItem('I006', x, y));
            SetUnitX(this.picker, x);
            SetUnitY(this.picker, y);
            SetUnitPathing(this.picker, false);
            
            
            if (thistype.dataCount >= 99) {
                BJDebugMsg("FATAL ERROR - Unique pick cannot assign more data points??");
                return this;
            }
            
            thistype.data[thistype.dataCount] = this;
            this.index = thistype.dataCount;
            thistype.dataCount = thistype.dataCount + 1;
            
            return this;
        }
        
        public static method create(real x, real y, real angle, DefenderRace r) -> thistype {
            thistype this = thistype.allocate();
            this.race = r;
            this.model = CreateUnit(PICK_PLAYER, r.widgetId(), x, y, angle);
            UnitAddAbility(this.model, 'Avul');
            UnitAddAbility(this.model, 'Aloc');
            SetUnitPathing(this.model, false);
            
            this.picker = null;
            if (r.isPickable()) {
                this.picker = CreateUnit(PICK_PLAYER, 'n00G', x, y, 0.0);
                //UnitAddItem(this.picker, CreateItem(r.itemId(), x, y));
                SetUnitX(this.picker, x);
                SetUnitY(this.picker, y);
                SetUnitPathing(this.picker, false);
                
            }
            
            if (thistype.dataCount >= 99) {
                BJDebugMsg("FATAL ERROR - Unique pick cannot assign more data points??");
                return this;
            }
            
            thistype.data[thistype.dataCount] = this;
            this.index = thistype.dataCount;
            thistype.dataCount = thistype.dataCount + 1;
            
            return this;
        }
        
        method onDestroy() {
            RemoveUnit(this.model);
            RemoveUnit(this.picker);
            this.race = 0;
            
            // Clear (but doesn't rearrange)
            thistype.data[this.index] = 0;
        }
    }
    
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
                p.pick(race);
            }
            else {
                //Game.say("Could not resolve: " + race.toString());
            }
            
            this.destroy();
            
            return p;
        }
    
        public static method setupPickUnits() {
            integer i = 0;
            Race r = 0;
            real x = 0.0;
            real y = 0.0;
            real angle = 0.0;
            real startX = GetUnitX(UnitManager.TITAN_SPELL_WELL);
            real startY = GetUnitY(UnitManager.TITAN_SPELL_WELL);
            
            for (0 <= i < (DefenderRace.count() + 1)) {
                // Location angle
                angle = (360.0 / (DefenderRace.count() + 1)) * i;
                x = startX + 300.0 * Cos(angle * bj_DEGTORAD);
                y = startY + 300.0 * Sin(angle * bj_DEGTORAD);
                
                // Facing angle
                angle = bj_RADTODEG * Atan2(startY - y, startX - x);
                
                if (i == DefenderRace.count()) {
                    UniquePickData.createRandom(x, y, angle);
                }
                else {
                    r = DefenderRace[i];
                    UniquePickData.create(x, y, angle, r);
                }
                
            }
        }
        
        public static method checkPickUnits() {
            PlayerDataArray list = 0;
            PlayerDataPick p = 0;
            integer i = 0;
            integer hasntPicked = 0;
            
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                if (!p.hasPicked()) {
                    hasntPicked = hasntPicked + 1;
                }
            }
            list.destroy();
            list = 0;
            
            if (hasntPicked == 0) {
                thistype.removePickUnits();
            }
        }
        
        public static method removePickUnits() {
            // Here we clean up still existing pick data
            integer i = 0;
            UniquePickData data = 0;
            for (0 <= i < UniquePickData.dataCount) {
                data = UniquePickData.data[i];
                if (data != 0) {
                    data.destroy();
                }
            }
            
            for (0 <= i < 12) {
                SetPlayerAlliance(PICK_PLAYER, Player(i), ALLIANCE_SHARED_VISION, false);
            }
            
            UniquePickData.dataCount = 0;
        }
        
        public static method finish(PlayerDataPick p) {
            unit defender = p.unit().unit();
            UniquePickData data = UniquePickData.fromRace(p.race());
            
            if (data == 0 || defender == null) {
                p.say("FATAL ERROR - Unique Pick failed due to invalid data state.");
                return;
            }
            SetPlayerAlliance(PICK_PLAYER, p.player(), ALLIANCE_SHARED_VISION, false);
            
            SetUnitX(defender, GetUnitX(data.model));
            SetUnitY(defender, GetUnitY(data.model));
            SetUnitFacing(defender, GetUnitFacing(data.model));
            
            // Reset initial position
            p.setInitialPosition(GetUnitX(defender), GetUnitY(defender));
            
            // Destroy this data point
            data.destroy();
            
            thistype.checkPickUnits();
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
            this.setupPlayers();
            this.setupPickShops();
            DefenderRaceUniquePick.setupPickUnits();
            this.spawnStarted = false;
        }
        
        public method onPlayerSetup(PlayerData p){
            PlayerDataPick q = PlayerDataPick[p];
            real x = GetUnitX(UnitManager.TITAN_SPELL_WELL);
            real y = GetUnitY(UnitManager.TITAN_SPELL_WELL);
            rect r = null;
            if (p.class() == PlayerData.CLASS_DEFENDER) {
                r = Rect(x, y, x, y);
                SetUnitX(q.picker(), x);
                SetUnitY(q.picker(), y);
                
                q.freeCamera();
                PanCameraToTimed(x, y, 0.0);
                q.restrictCamera(r);
                
                SetPlayerAlliance(PICK_PLAYER, p.player(), ALLIANCE_SHARED_VISION, true);
                
                RemoveRect(r);
                r = null;
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
            item it = null;
            
            // Now we want to let all the Defenders choose their race
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                if (!p.isLeaving() && !p.hasLeft() && !p.hasPicked()){
                    for (0 <= j < 6) {
                        it = UnitItemInSlot(p.picker(), j);
                        r = 0;
                        randomed = p.isRandoming() || (p.isFake() && GameSettings.getBool("FAKE_PLAYERS_AUTOPICK"));
                        if (randomed || it != null) {
                            if (randomed || GetItemTypeId(it) == 'I006') {
                                r = PlayerDataPick.getPlayerDataPickRandomRaceUniqueWithBans(p);
                                randomed = true;
                            }
                            else {
                                r = DefenderRace.fromItemId(GetItemTypeId(it));
                                RemoveItem(it);
                            }
                        }
                        
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
                    if (hasRandom) {
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
            this.pickedNormal(p);
            
            if (p.class() == PlayerData.CLASS_DEFENDER) {
                DefenderRaceUniquePick.finish(p);
            }
        }
        
        method onUnitCreation(PlayerDataPick p){
            this.onUnitCreationNormal(p);
        }
        method onPickerItemEvent(PlayerDataPick p, unit seller, item it){
            UniquePickData data = 0;
            DefenderRace r = 0;
            integer id = 0;
            integer i = 0;

            if (p.class() == PlayerData.CLASS_DEFENDER){
                data = UniquePickData.fromPicker(seller);
                r = data.getRace();
                
                if (this.spawnStarted) {
                    p.pick(r);
                }
                else {
                    if (r == 0) {
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
                    }
                }
                
                RemoveItem(it);
            }
            else if (p.class() == PlayerData.CLASS_TITAN){
                this.onPickerItemEventNormal(p, seller, it);
            }
        }
        method getStartDelay() -> real {
            return this.getStartDelayNormal() + 20.0; // Add 20 seconds
        }
        method end(){
            DefenderRaceUniquePick.removePickUnits();
            
            this.endNormally();
        }
        method terminate() {
            DefenderRaceUniquePick.removePickUnits();
        }
    }
}

//! endzinc