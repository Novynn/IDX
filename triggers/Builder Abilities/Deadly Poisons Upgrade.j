//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library DeadlyPoisonsUpgrade {
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            integer i = GetResearched();
            player p = GetOwningPlayer(u);
            
            if (i == 'R02C'){
                SetPlayerTechMaxAllowed(p, 'o00B', 0);
                SetPlayerTechMaxAllowed(p, 'o027', -1);
            }

            u = null;
            p = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc