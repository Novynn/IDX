//TESH.scrollpos=19
//TESH.alwaysfold=0
//! zinc

library ChickenTweak requires TweakManager, PerksSystem, SpeechSystem {
    public struct ChickenTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Chicken Dance";
        }
        public method shortName() -> string {
            return "CD";
        }
        public method description() -> string {
            return "Dance! Dance! Dance!";
        }
        public method command() -> string {
            return "-dance";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        private method startMusic() {
            PlayerDataSpeech p = 0;
            PlayerDataArray list = 0;
            integer i = 0;
            if (!PlayerDataSpeech.initialized()) return;
            list = PlayerData.all();
            for (0 <= i < list.size()){
                p = PlayerDataSpeech[list[i]];
                if (!p.wantsSilence()){
                    if (p.playerData.player() == GetLocalPlayer()){
                        PlaySoundBJ(gg_snd_Chicken);
                    }
                }
            }
            list.destroy();
        }
        
        // -cd [on/off]
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            if (!PlayerDataPerks.initialized()) return;
            if (!PlayerDataPerks[p].hasPerkByName("SongPerk") && !GameSettings.getBool("DEBUG")) return;
            
            this.startMusic();
        }
    }
}
//! endzinc