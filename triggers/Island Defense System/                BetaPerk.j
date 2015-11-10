//TESH.scrollpos=12
//TESH.alwaysfold=0
//! zinc

library BetaPerk requires PerksSystem {
    private struct BetaPerk extends Perk {
        module PerkModule;
        private static constant integer BETA_BOOK_ITEM_ID = 'I02N';
        private static constant integer BETA_BOOK_EFFECT_ID = 'A000'; // <==== TO CHANGE
        
        public method onSpawn(PlayerData p){
            Unit u = p.unit();
            unit v = null;
            if (u == 0) return;
            v = u.unit();
            UnitAddItem(v, CreateItem(thistype.BETA_BOOK_ITEM_ID, 0.0, 0.0));
        }
        
        public method forPlayer(PlayerData p) -> boolean {
            return true; // All the players!
        }
        
        private static method initialize() {
            trigger t = CreateTrigger();
            GT_RegisterItemDroppedEvent(t, thistype.BETA_BOOK_ITEM_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit u = GetManipulatingUnit();
                item it = GetManipulatedItem();
                RemoveItem(it);
                
                if (false) { // If special condition, then give effect!
                    UnitAddAbility(u, thistype.BETA_BOOK_EFFECT_ID);
                    UnitMakeAbilityPermanent(u, true, thistype.BETA_BOOK_EFFECT_ID);
                }
                u = null;
                it = null;
                return false;
            }));
            t = null;
        }
    }
}
//! endzinc