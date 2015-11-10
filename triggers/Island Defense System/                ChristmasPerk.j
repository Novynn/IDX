//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library ChristmasPerk requires PerksSystem {
    private struct ChristmasPerk extends Perk {
        module PerkModule;
        private static constant integer HAT_ABILITY_ID = 'A01X';
        
        public method onSpawn(PlayerData p){
            Unit u = p.unit();
            unit v = null;
            if (u == 0) return;
            v = u.unit();
            AddSpecialEffectTarget("war3mapImported\\SantaHat.mdx", v, "head");
        }
        
        public method forPlayer(PlayerData p) -> boolean {
            return true; // All the players!
        }
        
        private static method initialize() {
        }
    }
}
//! endzinc