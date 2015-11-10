//TESH.scrollpos=12
//TESH.alwaysfold=0
//! zinc

library UpgradesCommand requires TweakManager, Upgrades {
    public struct UpgradesCommand extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Upgrades";
        }
        public method shortName() -> string {
            return "UPG";
        }
        public method description() -> string {
            return "Gives you information about upgrades.";
        }
        public method command() -> string {
            return "-upgrades,-upgrade,-u";
        }
		public method hidden() -> boolean {
            return true;
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            Upgrade u = 0;
			
			if (args.size() > 0 && args[0].isInt()) {
				u = Upgrade(args[0].getInt());
				
				if (args.size() > 1) {
					if (StringCase(args[1].getStr(), false) == "reset") {
						p.say("|cff00bfffResetting Upgrade #" + u.id() + "...|r");
						Upgrades.resetUpgradeForPlayer(p.player(), u, true);
					}
				}
				else {
					p.say("|cff00bfffUpgrade #" + I2S(u) + " is " + u.id() + "|r");
				}
			}
			else if (args.size() > 0 && StringCase(args[0].getStr(), false) == "reset") {
				Upgrades.resetAllUpgradesForPlayer(p.player(), true);
				p.say("|cff00bfffAll of your upgrades have been reset.|r");
			}
			else {
				PlayerUpgradeData[p].printUpgrades();
			}
        }
    }
}
//! endzinc