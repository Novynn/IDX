//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library ShopSystem requires UnitManager, AIDS, Table {
    private struct Shop {
        private static constant integer MAX_PAGES = 2;
        private static Table shopPages = 0;
        private unit units[thistype.MAX_PAGES];
        private integer index = 0;
        
        public static method reset(){
            thistype.shopPages.reset();
        }
        
        public static method create() -> thistype {
            thistype this = thistype.allocate();
            integer i = 0;
            for (0 <= i < thistype.MAX_PAGES){
                this.units[i] = null;
            }
            return this;
        }
        
        public static method get(unit u) -> thistype {
            integer id = GetUnitIndex(u);
            thistype shop = thistype.shopPages[id];
            
            if (shop != 0)
                shop.setIndex(shop.indexOf(u));
            
            return shop;
        }
        
        public method addPage(unit u) -> boolean {
            integer i = 0;
            integer id = GetUnitIndex(u);
            for (0 <= i < thistype.MAX_PAGES){
                if (this.units[i] == null){
                    this.units[i] = u;
                    thistype.shopPages[id] = this;
                    return true;
                }
            }
            return false;
        }
        
        public method nextPage() -> unit {
            this.setIndex(this.index + 1);
            return this.units[this.index];
        }
        
        public method previousPage() -> unit {
            this.setIndex(this.index - 1);
            return this.units[this.index];
        }
        
        public method setIndex(integer i){
            if (i < 0 || i > thistype.MAX_PAGES) return;
            this.index = i;
        }
        
        public method indexOf(unit u) -> integer {
            integer i = 0;
            for (0 <= i < thistype.MAX_PAGES){
                if (IsUnit(this.units[i], u)){
                    return i;
                }
            }
            return -1;
        }
        
        private static method onInit(){
            thistype.shopPages = Table.create();
        }
    }
    
    public struct ShopSystem {
        private static constant integer PAGE_FORWARD_ID = 'I051';
        private static constant integer PAGE_BACKWARD_ID = 'I050';
        private static Shop artifactsShop = 0;
        private static Shop consumablesShop = 0;
        private static Shop recipesShop = 0;
        
        public static method initialize(){
            thistype.artifactsShop = Shop.create();
            thistype.artifactsShop.addPage(UnitManager.ARTIFACTS_PAGE_ONE);
            thistype.artifactsShop.addPage(UnitManager.ARTIFACTS_PAGE_TWO);
            
            thistype.consumablesShop = Shop.create();
            thistype.consumablesShop.addPage(UnitManager.CONSUMABLES_PAGE_ONE);
            thistype.consumablesShop.addPage(UnitManager.CONSUMABLES_PAGE_TWO);
            
            thistype.recipesShop = Shop.create();
            thistype.recipesShop.addPage(UnitManager.RECIPES_PAGE_ONE);
            thistype.recipesShop.addPage(UnitManager.RECIPES_PAGE_TWO);
        }
        
        public static method terminate(){
            Shop.reset();
            
            thistype.artifactsShop.destroy();
            thistype.consumablesShop.destroy();
            thistype.recipesShop.destroy();
            thistype.artifactsShop = 0;
            thistype.consumablesShop = 0;
            thistype.recipesShop = 0;
        }
        
        public static method onAct(){
            item i = GetSoldItem();
            integer id = GetItemTypeId(i);
            unit u = GetSellingUnit();
            unit v = GetBuyingUnit();
            player p = GetOwningPlayer(v);
            Shop s = Shop.get(u);
            
            if (s != 0){                
                if (id == PAGE_FORWARD_ID){
                    u = s.nextPage();
                    
                    if (p == GetLocalPlayer()){
                        ClearSelection();
                        SelectUnit(u, true);
                    }
                    RemoveItem(i);
                }
                else if (id == PAGE_BACKWARD_ID){
                    u = s.previousPage();
                    
                    if (p == GetLocalPlayer()){
                        ClearSelection();
                        SelectUnit(u, true);
                    }
                    RemoveItem(i);
                }
            }
            i = null;
            p = null;
            u = null;
            v = null;
        }
        
        private static method onInit() {          
            trigger t = CreateTrigger();           
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SELL_ITEM);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onAct();
                return false;
            }));
            t = null;
        }
    }
}
//! endzinc