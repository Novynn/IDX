//TESH.scrollpos=19
//TESH.alwaysfold=0
//! zinc

library IntroTweak requires TweakManager, PerksSystem, SpeechSystem {
    public struct IntroTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Intro";
        }
        public method shortName() -> string {
            return "INTRO";
        }
        public method description() -> string {
            return "Warcraft II!";
        }
        public method command() -> string {
            return "-intro";
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
                        PlaySoundBJ(gg_snd_War2IntroMusic);
                    }
                }
            }
            list.destroy();
        }
        
        // -intro
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            if (!PlayerDataPerks.initialized()) return;
            if (!PlayerDataPerks[p].hasPerkByName("SongPerk") && !GameSettings.getBool("DEBUG")) return;
            
            this.startMusic();
        }
    }
}
//! endzinc