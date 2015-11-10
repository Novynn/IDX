//TESH.scrollpos=6
//TESH.alwaysfold=0
//! zinc

library BuildingSizeFix {
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_CANCEL);
        TriggerAddCondition(t, Condition(function() -> boolean {
            return IsUnitType(GetDyingUnit(), UNIT_TYPE_STRUCTURE);
        }));
        TriggerAddAction(t, function(){
            unit u = GetTriggerUnit();

			// Use chaos to set unit back to normal size??
			
            SetUnitScale(u, 1.0, 1.0, 1.0);
            u = null;
        });
        t = null;
    }
}

//! endzinc