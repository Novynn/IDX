//TESH.scrollpos=5
//TESH.alwaysfold=0
//! zinc

library SettingsTweak requires TweakManager {
    public struct SettingsTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Settings";
        }
        public method shortName() -> string {
            return "SETTINGS";
        }
        public method description() -> string {
            return "Allows you to access the values of various game settings.";
        }
        public method command() -> string {
            return "-s";
        }
        
        public method hidden() -> boolean {
            return true;
        }
        
        // -s get int GAME_STATE
        // -s set int GAME_STATE 2
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            if (GetLocalPlayer() == p.player()){
                ClearTextMessages();
            }
        }
    }
}
//! endzinc