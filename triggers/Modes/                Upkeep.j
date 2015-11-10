//TESH.scrollpos=93
//TESH.alwaysfold=0
//! zinc

library RacePickModeAllPick requires RacePickMode {
    public struct RacePickModeAllPick extends RacePickMode {
        module RacePickModeModule;
        
        method name() -> string {
            return "Upkeep";
        }
        method shortName() -> string {
            return "UPKEEP";
        }
        method description() -> string {
            return "All players will be able to choose their desired races. Upkeep mode will also be enabled.";
        }
        
        method setup(){
            GameSettings.setBool("UPKEEP_MODE", true);
            this.setupNormally();
        }
        
         method meetsVoteRequirements(RacePickModeVotes mode) -> boolean {
            return this.meetsVoteRequirementsNormal(mode);
        }
        
        method start(){
            PlayerDataArray list = 0;
            PlayerDataPick p = 0;
            integer i = 0;
            
            // Now we want to let all the Defenders choose their race
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                p = PlayerDataPick[list[i]];
                if (!p.isLeaving() && !p.hasLeft()){
                    if (p.isRandoming()){
                        p.pick(p.race());
                    }
                    else if (p.isFake() && GameSettings.getBool("FAKE_PLAYERS_AUTOPICK")){
                        p.say("You're fake, so I'm picking for you!");
                        p.pick(p.race());
                    }
                    else {
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
                    if (!p.isLeaving() && !p.hasLeft()){
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
        }
        method picked(PlayerDataPick p){
            this.pickedNormal(p);
        }
        method onUnitCreation(PlayerDataPick p){
            this.onUnitCreationNormal(p);
        }
        method end(){
            this.endNormally();
            
            // Enable super fruits
        }
        
        // LONGEST METHOD NAME EVER
        public static method GetAllStarvingUnitsFoodCostForPlayer(player p) -> integer {
            
        }
        
        method tick() {
            // This runs during the game! Check to see if any players are over their food limit.
            PlayerData p = 0;
            PlayerDataArray list = 0;
            integer i = 0;
            integer used = 0;
            integer cap = 0;
            integer cost = 0;
            
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()) {
                p = list.at(i);
                used = GetPlayerState(p, PLAYER_STATE_RESOURCE_FOOD_USED);
                cap = GetPlayerState(p, PLAYER_STATE_RESOURCE_FOOD_CAP);
                cost = GetAllStarvingUnitsFoodCostForPlayer(p.player());
                
                if (used > cap) {
                    if (used - cost > cap) {
                        // Need to add more starving units
                    }
                    else {
                        // They're over cap but cost is doing too much, need to remove some starving units
                    }
                }
                else {
                    // Check if they had starving units
                    if (cost > 0) {
                        // "Heal" them!
                    }
                }
            }
            list.destroy();
        }
    }
}

//! endzinc