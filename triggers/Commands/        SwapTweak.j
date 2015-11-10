//TESH.scrollpos=0
//TESH.alwaysfold=0

// TODO(neco): Fix this so it actually works! Currently broken (can't find swap data for some players etc)

//! zinc

library SwapTweak requires TweakManager, GameTimer, Table {
    private struct PlayerDataSwap extends PlayerDataExtension {
        module PlayerDataWrappings;
        
        public PlayerData toSwapWith = 0;
        private boolean mSwappingEnabled = true;
        private GameTimer swapTimer = 0;
        
        public method swappingEnabled() -> boolean {
            return this.mSwappingEnabled;
        }
        
        public method setSwappingEnabled(boolean b){
            this.mSwappingEnabled = b;
        }
        
        public method onSetup(){
            this.setSwappingEnabled(true);
        }
        
        public method onTerminate(){
            if (this.swapTimer != 0){
                this.swapTimer.destroy();
            }
            this.swapTimer = 0;
        }
        
        public method willSwapWith(PlayerData p) -> boolean {
            if (!this.mSwappingEnabled) return false;
            return this.toSwapWith == p;
        }
        
        public method doSwap(){
            PlayerData p = this.toSwapWith;
            integer pClass = 0;
            Race pRace = 0;
            integer pGold = 0;
            integer pWood = 0;
            Unit pUnit = 0;
			integer fed = 0;
            
            if (p == 0) return; // Can't swap with null
            
            pClass = p.class();
            pRace = p.race();
            pUnit = p.unit();
			fed = PlayerDataFed[p].fed();
            
            p.setClass(this.class());
            p.setRace(this.race());
            p.setUnit(this.unit());
			
			PlayerDataFed[p].setFed(PlayerDataFed[this.playerData].fed());
            
            this.setClass(pClass);
            this.setRace(pRace);
            this.setUnit(pUnit);
			PlayerDataFed[this.playerData].setFed(fed);

            
            UnitManager.swapPlayerUnits(p, this.playerData);
			Upgrades.swapPlayerUpgradeTables(p.player(), this.player());
			
			pGold = p.gold();
            pWood = p.wood();
			p.setGold(this.gold());
            p.setWood(this.wood());
            this.setGold(pGold);
            this.setWood(pWood);

            this.toSwapWith = 0;
            if (this.swapTimer != 0){
                this.swapTimer.destroy();
            }
            this.swapTimer = 0;
        }
        
        public method removeRequest(){
            this.say(this.toSwapWith.nameColored() + "|cff00bfff did not respond to your request. Please try again later.|r");
            this.toSwapWith.say("|cff00bfffYou did not respond to |r" + this.nameColored() + "|cff00bfff's request in time.|r");
            this.toSwapWith = 0;
            if (this.swapTimer != 0){
                this.swapTimer.destroy();
            }
            this.swapTimer = 0;
        }
        
        public method requestSwapWith(PlayerData p) -> boolean {
            if (this.toSwapWith != 0){
                this.say("|cffff0000Please wait for the current swap request to complete.|r");
                return false;
            }
            if (!thistype[p].swappingEnabled()){
                this.say(p.nameColored() + "|cffff0000 has disabled swap requests.|r");
                return false;
            }
            p.say(this.nameColored() + "|cff00bfff is requesting to swap places with you. " +
                  "Type|r -swap " + this.nameColored() + "|cff00bfff to accept their offer within 30 seconds.\n" +
                  "If these offers become an annoyance, use |r-swap off|cff00bfff to disable them.");
            this.toSwapWith = p;
            
            // Timeout 30s
            this.swapTimer = GameTimer.new(function(GameTimer t){
                thistype this = t.data();
                if (this == 0 || this.toSwapWith == 0 ||
					(this.toSwapWith.class() != PlayerData.CLASS_DEFENDER &&
					 this.toSwapWith.class() != PlayerData.CLASS_OBSERVER) ||
                    this.swapTimer == 0) return;
                this.removeRequest();
                this.swapTimer = 0;
            });
            this.swapTimer.setData(this);
            this.swapTimer.start(30.0);
			return true;
        }
    }
    
    public struct SwapTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Swap";
        }
        public method shortName() -> string {
            return "SWAP";
        }
        public method description() -> string {
            return "Allows two players from the same faction to swap control of their units and resources.";
        }
        public method command() -> string {
            return "-swap";
        }
        
        // [Player 1] -swap Neco
        // [Neco] -swap
        // *Swaps*
        
        // [Player 1] -swap Neco
        // [Neco] -swap off
        
        public method initialize(){
            PlayerDataSwap.initialize();
        }
        
        public method terminate(){
            PlayerDataSwap.terminate();
        }
    
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            PlayerData q = 0;
            string arg = "";
			PlayerDataSwap ps = PlayerDataSwap[p];
			PlayerDataSwap qs = 0;
            
            if (Game.state() != Game.STATE_STARTED){
                p.say("|cffff0000Please wait until the game has started before using the |r-swap|cffff0000 command.|r");
                return;
            }
            
            if (args.size() > 0){
                // New -swap
                if (args[0].isPlayer()){
                    q = PlayerData.get(args[0].getPlayer());
                    if (q == p) return; // Can't swap with yourself derp.
					qs = PlayerDataSwap[q];
					
					if (ps == 0 || qs == 0) {
						p.say("Could not get swap data for you or the target.");
						return;
					}
					
                    if ((p.class() == PlayerData.CLASS_DEFENDER ||
                         p.class() == PlayerData.CLASS_OBSERVER) &&
                        (q.class() == PlayerData.CLASS_TITAN ||
                         q.class() == PlayerData.CLASS_MINION)){
                        p.say("|cffff0000You cannot swap with a player of the other team!|r");
                        return;
                    }
                    if ((p.class() == PlayerData.CLASS_TITAN ||
                         p.class() == PlayerData.CLASS_MINION) &&
                        (q.class() == PlayerData.CLASS_DEFENDER ||
                         q.class() == PlayerData.CLASS_OBSERVER)){
                        p.say("|cffff0000You cannot swap with a player of the other team!|r");
                        return;
                    }
                    
                    if (p.class() == PlayerData.CLASS_OBSERVER &&
                        q.class() == PlayerData.CLASS_OBSERVER){
                        p.say("|cffff0000Swapping with another observer won't achieve much...|r");
                        return;
                    }
                    
                    if (qs.willSwapWith(p)){
                        // Swap!
                        p.say("|cff00bfffBoth players agree, now swapping.|r");
                        q.say("|cff00bfffBoth players agree, now swapping.|r");
                        ps.doSwap();
                    }
                    else {
                        if (ps.requestSwapWith(q)) {
							p.say("|cff00bfffSwap request sent to |r" + q.nameColored());
						}
						
						// Fakeplayers will autoaccept
						if (q.isFake() && ps.willSwapWith(q)) {
							ps.doSwap();
						}
                    }
					
                }
                else {
                    arg = StringCase(args[0].getStr(), false);
                    if (arg == "off"){
                        ps.setSwappingEnabled(false);
                        p.say("|cff00bfffSwapping |r|cffff0000disabled|r|cff00bfff.|r");
                    }
                    else if (arg == "on"){
                        ps.setSwappingEnabled(true);
                        p.say("|cff00bfffSwapping |r|cffff0000enabled|r|cff00bfff.|r");
                    }
                }
            }
            else {
                p.say("|cffff0000You must provide a player to swap with!|r");
            }
        }
    }
}
//! endzinc