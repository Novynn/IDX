//TESH.scrollpos=24
//TESH.alwaysfold=0
//! zinc

library InventoryTweak requires TweakManager, GameTimer {
    public struct InventoryTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Inv";
        }
        public method shortName() -> string {
            return "INV";
        }
        public method description() -> string {
            return "Prints out the inventory of the selected unit.";
        }
        public method command() -> string {
            return ":/inv";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            group g = null;
            unit u = null;
            item it = null;
            integer i = 0;
            if (!GameSettings.getBool("DEBUG") && p.name() != GameSettings.getStr("EDITOR")) return;
            g = CreateGroup();
            
            GroupEnumUnitsSelected(g, p.player(), null);
            
            u = FirstOfGroup(g);
            while (u != null) {
                BJDebugMsg("unit: " + GetUnitName(u));
                for (0 <= i < 6) {
                    it = UnitItemInSlot(u, i);
                    if (it != null) {
                        BJDebugMsg("slot(" + I2S(i) + "): " + GetItemName(it));
                        BJDebugMsg("\tilvl: " + I2S(GetItemLevel(it)));
                    }
                }
                it = null;
                
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            GroupClear(g);
            DestroyGroup(g);
            g = null;
            u = null;
        }
    }
}
//! endzinc