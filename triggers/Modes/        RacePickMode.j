//TESH.scrollpos=183
//TESH.alwaysfold=0
//! zinc

// Simply a module that gets implemented by Pick Modes containing the default setup

library RacePickMode requires RacePicker, optional PerksSystem {
    public module RacePickModeModule {
        public GameTimer graceDelayTimer = 0;
        
        public method setupCamera(PlayerData p){
            rect r = null;
            if (p.class() == PlayerData.CLASS_DEFENDER){
                r = Rect(-2900, 9800, -2900, 9800);
            }
            else if (p.class() == PlayerData.CLASS_TITAN){
                r = Rect(-9952, 10304, -9952, 10304);
            }
            else {
                return;
            }
            PlayerDataPick[p].restrictCamera(r);
            RemoveRect(r);
            r = null;
        }
        public method setupPicker(PlayerData q){
            PlayerDataPick p = PlayerDataPick[q];
            p.removePicker();
            p.createPicker();
        }
        
        public method setupPlayer(PlayerData p){
            this.setupCamera(p);
            this.setupPicker(p);
            
            // Safe to assume that they haven't picked yet?
            PlayerDataPick[p].setPicked(false);
            PlayerDataPick[p].clearRaceRandomBans();
            
            this.onPlayerSetup(p);
        }
        
        public method setupPlayers(){
            PlayerDataArray list = 0;
            integer i = 0;
            list = PlayerData.all();
            for (0 <= i < list.size()){
                this.setupPlayer(list.at(i));
            }
            list.destroy();
        }
        
        public method setupPickShops(){
            player p = Player(PLAYER_NEUTRAL_PASSIVE);
            // Clean up in case of something going wrong!
            UnitManager.despawnPickShops();
            // Spawn Pick shops
            UnitManager.spawnPickShops();
        }

        public method setupNormally(){
            this.setupPlayers();
            this.setupPickShops();
        }
        
        private method endNormallyCheck() {
            PlayerDataArray list = 0;
            PlayerDataPick p = 0;
            integer i = 0;
            
            // Check if Defender's haven't moved, and make them observers.
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                p.setAfk(false);
                if (!p.hasMoved() && GameSettings.getBool("PICKMODE_REMOVE_AFK")){
                    // They haven't moved or picked! Now let's make them an observer.
                    Game.say(p.nameColored() + "|cff00bfff has been changed to an observer for not moving in the allocated time.|r");
                    UnitManager.removePlayerUnits(p.playerData);
                    p.setClass(PlayerData.CLASS_OBSERVER);
                    p.setAfk(true);
                }
                else if (!p.hasPicked()){
                    Game.say(p.nameColored() + "|cff00bfff has been changed to an observer for not choosing in the allocated time.|r");
                    UnitManager.removePlayerUnits(p.playerData);
                    p.setClass(PlayerData.CLASS_OBSERVER);
                    p.setAfk(true);
                }
            }
            list.destroy();
            
            list = PlayerData.withClass(PlayerData.CLASS_OBSERVER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                p.freeCamera();
                if (GetLocalPlayer() == p.player()){
                    PanCameraToTimed(GetUnitX(UnitManager.TITAN_SPELL_WELL),
                                     GetUnitY(UnitManager.TITAN_SPELL_WELL), 0);
                }
            }
            list.destroy();
        }
        
        public method endNormally(){
            PlayerDataArray list = 0;
            PlayerDataPick p = 0;
            integer i = 0;
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                p.removePicker();
            }
            list.destroy();
            list = 0;
            UnitManager.despawnPickShops();
            
            if (graceDelayTimer != 0) {
                graceDelayTimer.deleteNow();
            }
            
            this.endNormallyCheck();
            
            RacePicker.finish();
        }
        
        public method meetsVoteRequirementsNormal(RacePickModeVotes mode) -> boolean {
            // Check all titan's agreed
            if (mode.titanVotes == PlayerData.countClass(PlayerData.CLASS_TITAN) ||
                !GameSettings.getBool("PICKMODE_VOTE_REQUIRES_TITAN")){
                // Titans and majority of defenders voted, enough for me!
                // Or it's default but titan wanted something else? Suck it!
                return true;
            }
            
            Game.say("|cff00bfffThe Titan did not agree to the most voted game mode.|r");
            return false;
        }
        
        // The default pick method
        public method pickedNormal(PlayerDataPick p){
            PlayerDataArray list = 0;
            integer i = 0;
            integer titansPicked = 0;
            
            p.removePicker();
            
            if (p.class() == PlayerData.CLASS_DEFENDER){
                UnitManager.spawnDefender(p.playerData);
            }
            else if (p.class() == PlayerData.CLASS_TITAN){
                list = PlayerData.withClass(PlayerData.CLASS_TITAN);
                for (0 <= i < list.size()){
                    if (PlayerDataPick[list[i]].hasPicked()){
                        titansPicked = titansPicked + 1;
                    }
                }
                list.destroy();
                list = 0;
                
                // If all Titans have picked, create them!
                if (titansPicked >= PlayerData.countClass(PlayerData.CLASS_TITAN)){
                    UnitManager.spawnTitans();
                    // We're done picking! Time to clean up...
                    this.end();
                    return;
                }
                else {
                    Game.say("|cffff0000Waiting for all of the Titans to pick...|r");
                }
            }
        }
        
        public method onUnitCreationNormal(PlayerDataPick p) {
            integer delta = GetRandomInt(1, 40);
            player q = p.player();
            unit u = p.unit().unit();
            
            SetPlayerAbilityAvailable(q, 'Aro1', false); // Disable Root
            SetPlayerState(q, PLAYER_STATE_GIVES_BOUNTY, 1); // Gives Bounty
            SetPlayerTechMaxAllowed(q, 'HERO', 1); // Max one Hero
			
			// All of this Upgrade System shit should be moved somewhere else......................................................
            SetPlayerTechMaxAllowed(q, 'h03R', 0); // Disable Troll's Workers
            SetPlayerTechMaxAllowed(q, 'h005', 0); // Disable Goblin's Advanced Walls
            SetPlayerTechMaxAllowed(q, 'o027', 0); // Disable Gnolls's Deadly Mega Axe Towers
			SetPlayerTechMaxAllowed(q, 'o010', 0); // Disable Goblin's Enhanced Factories
			SetPlayerTechMaxAllowed(q, 'o011', 0); // Disable Faerie's Enhanced Pools
            SetPlayerTechMaxAllowed(q, 'R03B', 0); // Disable Additional HP
			
			SetPlayerTechMaxAllowed(q, 'o012', 0); // Disable Ogre's Enhanced Catapult
			SetPlayerTechMaxAllowed(q, 'o019', 0); // Disable Ogre's Super Catapult
			SetPlayerTechMaxAllowed(q, 'o01E', 0); // Disable Ogre's Mega Catapult
			
			SetPlayerTechMaxAllowed(q, 'o01Z', 0); // Disable Murloc's Mega Long Dart Tower
			
			// Disable True Strike spellbook
			SetPlayerAbilityAvailable(q, '&tru', false);
            
            // Disable Ultimate Towers
            SetPlayerTechMaxAllowed(q, 'e00Y', 0);
            SetPlayerTechMaxAllowed(q, 'h00P', 0);
            SetPlayerTechMaxAllowed(q, 'n01J', 0);
            SetPlayerTechMaxAllowed(q, 'n01K', 0);
            SetPlayerTechMaxAllowed(q, 'n01L', 0);
            SetPlayerTechMaxAllowed(q, 'o003', 0);
            SetPlayerTechMaxAllowed(q, 'o005', 0);
            SetPlayerTechMaxAllowed(q, 'o006', 0);
            SetPlayerTechMaxAllowed(q, 'o007', 0);
            SetPlayerTechMaxAllowed(q, 'o00J', 0);
            SetPlayerTechMaxAllowed(q, 'o00K', 0);
            SetPlayerTechMaxAllowed(q, 'o00L', 0);
            SetPlayerTechMaxAllowed(q, 'o00M', 0);
            SetPlayerTechMaxAllowed(q, 'o00N', 0);
            SetPlayerTechMaxAllowed(q, 'o00O', 0);
            SetPlayerTechMaxAllowed(q, 'o00P', 0);
            SetPlayerTechMaxAllowed(q, 'o00Q', 0);
            SetPlayerTechMaxAllowed(q, 'o00R', 0);
            SetPlayerTechMaxAllowed(q, 'o00S', 0);
            SetPlayerTechMaxAllowed(q, 'o00T', 0);
            SetPlayerTechMaxAllowed(q, 'o015', 0);
            SetPlayerTechMaxAllowed(q, 'o016', 0);
            SetPlayerTechMaxAllowed(q, 'o017', 0);
            SetPlayerTechMaxAllowed(q, 'o01P', 0);
            SetPlayerTechMaxAllowed(q, 'o01U', 0);
            SetPlayerTechMaxAllowed(q, 'o01V', 0);
            SetPlayerTechMaxAllowed(q, 'o01Y', 0);
            SetPlayerTechMaxAllowed(q, 'o02A', 0);
            SetPlayerTechMaxAllowed(q, 'o02E', 0);
            SetPlayerTechMaxAllowed(q, 'o02P', 0);
            SetPlayerTechMaxAllowed(q, 'o02Q', 0);
            SetPlayerTechMaxAllowed(q, 'o02R', 0);
            SetPlayerTechMaxAllowed(q, 'o03C', 0);
            
            if (GetUnitAbilityLevel(u, 'A013') > 0) {
                // Set inventory level to 2, to fix a random bug where it wouldn't update
                SetUnitAbilityLevel(u, 'A013', 1);
            }

            // Abilities and Tech Availability
            p.race().onSpawn(u);
            
            // Race Specific
            if (p.class() == PlayerData.CLASS_DEFENDER) {
                // Random Effects
                if (p.isRandoming()) {
                    Game.sayClass(PlayerData.CLASS_DEFENDER, 
                                  p.nameColored() + "|cff00bfff has randomed " + p.race().toString() + ".|r");
                    
                    if (delta <= 6){ // 15%  // HP Tome
                        UnitAddItem(u,CreateItem('I04V', 0, 0));
                    }
                    else if (delta <= 8){ // 5%  // Island's Blessing
                        UnitAddAbility(u, 'A0P2'); UnitMakeAbilityPermanent(u, true, 'A0P2');
                        p.say("|cff00bfffYou have been blessed by the Island.|r");
                    }
                }
                else {
                    Game.sayClass(PlayerData.CLASS_DEFENDER, 
                                  p.nameColored() + "|cff00bfff has chosen " + p.race().toString() + ".|r");
                }
				p.setWood(p.wood() + 70);

                // Set initial position
                p.setInitialPosition(GetUnitX(u), GetUnitY(u));
            }
            else {
                // Preload Minion (prevents lag later on?)
                RemoveUnit(CreateUnit(p.player(), p.race().childId(), 0, 0, 270));
                
                // Set resources
                p.setGold(GameSettings.getInt("TITAN_START_GOLD"));
                p.setWood(GameSettings.getInt("TITAN_START_WOOD"));
                
                // Defaults
                UnitAddItem(u, CreateItem('I00P',0,0));                                 // 100% // Ankh of Reincarnation
                
                // Random Chances
                if (delta <= 8)                 UnitAddItem(u, CreateItem('I00E',0,0)); // 20%  // Webbed Feet
                else if (delta <= 16)           UnitAddItem(u, CreateItem('I00C',0,0)); // 20%  // Spines
                else if (delta <= 24)           UnitAddItem(u, CreateItem('I03Q',0,0)); // 20%  // Trident
                
                if (p.isRandoming()){
                    if (delta > 24) {
                        if (delta <= 28)        UnitAddItem(u, CreateItem('I01O',0,0)); // 10%  // Moon Crystal
                        else if (delta <= 32)   UnitAddItem(u, CreateItem('I00M',0,0)); // 10%  // Magic Coral
                        else if (delta <= 34)   UnitAddItem(u, CreateItem('I00B',0,0)); // 5%   // Gem of Haste
                        else if (delta <= 36)   UnitAddItem(u, CreateItem('I016',0,0)); // 5%   // Pearl of Vision
                        else if (delta <= 37)   UnitAddItem(u, CreateItem('I042',0,0)); // 2.5% // Shield of Fate
                        else if (delta <= 38)   UnitAddItem(u, CreateItem('I01N',0,0)); // 2.5% // Windcatcher
                        else if (delta <= 39)   UnitAddItem(u, CreateItem('I01Z',0,0)); // 2.5% // Eternal Wards
                        else if (delta <= 40)   UnitAddItem(u, CreateItem('I068',0,0)); // 2.5% // Ethereal Mirror
                    }
                    
                    if (GetRandomInt(0, 20) == 13){
                        UnitAddAbility(u, 'A0P2'); 
                        UnitMakeAbilityPermanent(u, true, 'A0P2');                      // 5%  // Island's Blessing
                        p.say("|cff00bfffYou have been blessed by Island.|r");
                    } 
                    
                    p.setGold(p.gold() + GameSettings.getInt("TITAN_RANDOM_GOLD_BONUS"));
                    p.setWood(p.wood() + GameSettings.getInt("TITAN_RANDOM_WOOD_BONUS"));
                }
            }

            p.freeCamera();
            if (p.player() == GetLocalPlayer()) {
                PanCameraToTimed(GetUnitX(UnitManager.TITAN_SPELL_WELL),
                                 GetUnitY(UnitManager.TITAN_SPELL_WELL), 0);
                            
                ClearSelection();
                SelectUnit(u, true);
            }
            
            static if (LIBRARY_PerksSystem){
                PerksSystem.onSpawn(p.playerData);
            }
            
            Game.onPlayerRaceChosen.execute(p.playerData);
            
            u = null;
        }
        
        private static method create() -> thistype {
            // Will this prevent anyone creating one of these objects without onInit?
            return thistype.allocate();
        }
    
        private static method onInit() {
            // Here we have to register the type with RacePicker so it knows
            // Hmm.. we have another problem. Because of how interfaces work, we 
            // can't use static structs
            RacePicker.register.execute(thistype.create());
        }
        
        private integer mIndex = 0;
        public method setIndex(integer i){
            this.mIndex = i;
        }
        
        public method index() -> integer {
            return this.mIndex;
        }
    }
    
    public interface RacePickMode {
        method name() -> string;
        method shortName() -> string;
        method description() -> string;
        
        method gameMode() -> string = "ID";
        
        method onPlayerSetup(PlayerData p) = null;
        method setup();
        method start();
        method picked(PlayerDataPick p);
        method onUnitCreation(PlayerDataPick p);
        method end();
        
        method meetsVoteRequirements(RacePickModeVotes mode) -> boolean = true;
        
        method setupCamera(PlayerData p) = null;
        method setupPicker(PlayerData p) = null;
        method setupPlayer(PlayerData p) = null;
        method setupPlayers() = null;
        method setupPickShops() = null;
        
        method setIndex(integer i);
        method index() -> integer;
    }
}

//! endzinc