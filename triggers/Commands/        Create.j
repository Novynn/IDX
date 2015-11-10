//TESH.scrollpos=20
//TESH.alwaysfold=0
//! zinc

library CreateTweak requires TweakManager {
    public struct CreateTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Create";
        }
        public method shortName() -> string {
            return "C";
        }
        public method description() -> string {
            return "Create's the specified race's unit.";
        }
        public method command() -> string {
            return ":/create";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        // -cd [on/off]
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            string raceString = "";
            Race r = 0;
            if (args.size() == 0) return;
            raceString = args[0].getStr();
            
            if (!Game.isMode(Game.MODE_DEBUG) && p.name() != GameSettings.getStr("EDITOR")) return;
            
            if (p.class() == PlayerData.CLASS_DEFENDER) {
                r = DefenderRace.fromName(raceString);
            }
            if (p.class() == PlayerData.CLASS_TITAN) {
                r = TitanRace.fromName(raceString);
            }
            if (p.class() == PlayerData.CLASS_MINION) {
                r = TitanRace.fromName(raceString);
            }
            
            if (r.class() != Race.CLASS_NONE) {
                CreateUnit(p.player(), r.widgetId(), 0, 0, 0);
            }
        }
    }
}
//! endzinc