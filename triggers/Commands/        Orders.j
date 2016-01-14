//TESH.scrollpos=20
//TESH.alwaysfold=0
//! zinc

library OrdersDebugCommand requires TweakManager {
    public struct OrdersDebugCommand extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Orders";
        }
        public method shortName() -> string {
            return "O";
        }
        public method description() -> string {
            return "Debug command for inspecting unit orders.";
        }
        public method command() -> string {
            return ":/o";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        public static trigger orderTrigger = CreateTrigger();
        
        public static method onOrder() {
            unit u = GetOrderedUnit();
            integer id = GetIssuedOrderId();
            string s = OrderId2String(id);
            BJDebugMsg(GetUnitName(u) + " was ordered to \"" + "\" / " + I2S(id));
            u = null;
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            group g = CreateGroup();
            GroupEnumUnitsSelected(g, p.player(), null);
            ForGroup(g, function() {
                unit u = GetEnumUnit();
                TriggerRegisterUnitEvent(thistype.orderTrigger, u, EVENT_UNIT_ISSUED_ORDER);
                TriggerRegisterUnitEvent(thistype.orderTrigger, u, EVENT_UNIT_ISSUED_POINT_ORDER);
                TriggerRegisterUnitEvent(thistype.orderTrigger, u, EVENT_UNIT_ISSUED_TARGET_ORDER);
                BJDebugMsg(GetUnitName(u) + " registered!");
                u = null;
            });
            DestroyGroup(g);
            
            TriggerAddCondition(thistype.orderTrigger, Condition(static method thistype.onOrder));
            g = null;
        }
    }
}
//! endzinc