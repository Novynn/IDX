//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc
library PowerupSentinel{
    function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DROP_ITEM);
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_USE_ITEM);
        TriggerAddCondition(t, function() -> boolean {
            if (GetWidgetLife(GetManipulatedItem())==0) {
                RemoveItem(GetManipulatedItem());
            }
            return false;
        });
    }
}
//! endzinc