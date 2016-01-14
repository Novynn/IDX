//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library HalloweenPerk requires PerksSystem {
    private struct HalloweenPerk extends Perk {
        module PerkModule;
        
        public method name() -> string {
            return "HalloweenPerk";
        }
        
        public method onSpawn(PlayerData p){
            Unit u = p.unit();
            unit v = null;
            if (u == 0) return;
            v = u.unit();
            AddSpecialEffectTarget("war3mapImported\\Pumpkin.mdx", v, "head");
        }
        
        public method forPlayer(PlayerData p) -> boolean {
            return true; // All the players!
        }
        
        private static method initialize() {
        }
    }
}
//! endzinc