//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library SongPerk requires PerksSystem {
    public struct SongPerk extends Perk {
        module PerkModule;
        
        public method name() -> string {
            return "SongPerk";
        }
        
        public method forPlayer(PlayerData p) -> boolean {
            string name = StringCase(p.name(), false);
            if (name == "neco" ||
                name == "fossurious" ||
                name == "shadowzz") {
				return true;
			}
            return false;
        }
        
        private static method initialize() {
        }
    }
}
//! endzinc