//TESH.scrollpos=25
//TESH.alwaysfold=0
//! zinc

library DefenderTweak requires TweakManager, Upgrades {
    public struct DefenderTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Defender";
        }
        public method shortName() -> string {
            return "DEFENDER";
        }
        public method description() -> string {
            return "Takes over for a defender that has left the game.";
        }
        public method command() -> string {
            return "-defender,-builder";
        }
        
        public method takeOverLeaver(PlayerData p, PlayerData q){
            UnitManager.givePlayerUnitsTo(q, p);
			Upgrades.swapPlayerUpgradeTables(p.player(), q.player());
            
			p.setClass(PlayerData.CLASS_DEFENDER);
			p.setGold(q.gold());
			p.setWood(q.wood());
			p.setRace(q.race());
			p.setUnit(q.unit());
			
			if (PlayerDataFed.initialized()) {
				PlayerDataFed[p].setFed(PlayerDataFed[q].fed());
			}
			
			q.setClass(PlayerData.CLASS_OBSERVER);
			q.left();
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            PlayerData q = 0;
            PlayerDataArray list = 0;
            integer i = 0;
            if (p.class() != PlayerData.CLASS_OBSERVER) return;
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                q = list.at(i);
                if (q.isLeaving() && !q.hasLeft()){
                    // We found a -defenderable player!
                    Game.say(p.nameColored() + "|cff00bfff is taking over |r" + q.nameColored() + "|cff00bfff's units!|r");
                    this.takeOverLeaver(p, q);
                    break;
                }
            }
            list.destroy();
        }
    }
}
//! endzinc