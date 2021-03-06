//TESH.scrollpos=33
//TESH.alwaysfold=0
//! zinc
library ItemDrops requires UnitManager, GameSettings {
    private struct ItemDrops {
        private static itempool itemDropPool = null;
        
        private static method setup(){
            thistype.itemDropPool = CreateItemPool();
            ItemPoolAddItemType(thistype.itemDropPool, 'I017', 1); // Healing Wards
            ItemPoolAddItemType(thistype.itemDropPool, 'I01G', 1); // Replenishment Potion
            ItemPoolAddItemType(thistype.itemDropPool, 'I018', 1); // Scroll of the Beast
            ItemPoolAddItemType(thistype.itemDropPool, 'I01F', 1); // Eye of the Ocean
            ItemPoolAddItemType(thistype.itemDropPool, 'I01H', 1); // Wand of the Wind
            ItemPoolAddItemType(thistype.itemDropPool, 'I003', 0.5); // Tome of Health
            ItemPoolAddItemType(thistype.itemDropPool, 'I008', 0.5); // Tome of Power
            ItemPoolAddItemType(thistype.itemDropPool, 'I01I', 1); // Staff of Teleportation
            ItemPoolAddItemType(thistype.itemDropPool, 'I03Q', 1); // Trident
            ItemPoolAddItemType(thistype.itemDropPool, 'I03R', 1); // Armored Scales
            ItemPoolAddItemType(thistype.itemDropPool, 'I000', 1); // Shadowstone
        }
        
        public static method dropRandomItem(real x, real y) {
            PlaceRandomItem(thistype.itemDropPool, x, y);
        }
        
        public static method dropRandomItemChance(real x, real y) {
            integer i = GetRandomInt(0,20);
            if (i == 15){
                // 1/20 chance for a drop
                thistype.dropRandomItem(x, y);
            }
            else if (GameSettings["TWEAK_GC"] == "on" && i > 18){
                // 19/20 * 1/10 chance for a GC
                CreateItem('I064', x, y);
            }
        }
        
        public static method checkDropConditions(player killer, player killed) -> boolean {
            PlayerData p = PlayerData.get(killed);
            PlayerData q = PlayerData.get(killer);
            if (killer == null || killed == null) return false;
            return ((q.class() == PlayerData.CLASS_TITAN ||
                     q.class() == PlayerData.CLASS_MINION) &&
                    (p.class() == PlayerData.CLASS_DEFENDER ||
                     killed == Player(PLAYER_NEUTRAL_PASSIVE)));
        }
        
        private static method onInit(){
            trigger t = CreateTrigger();
            
            thistype.setup();
            
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
            TriggerAddAction(t, function (){
                unit u = GetTriggerUnit();
                unit k = GetKillingUnit();
                if (u != null && k != null) {
                    if (thistype.checkDropConditions(GetOwningPlayer(k), GetOwningPlayer(u))){
                        thistype.dropRandomItemChance(GetUnitX(u), GetUnitY(u));
                    }
                    
                }
                k = null;
                u = null;
            });
        }
    }
}

//! endzinc