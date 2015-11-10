//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library DemonicResistance {
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            integer i = GetResearched();
            player p = GetOwningPlayer(u);
            
            if (i == 'R02F'){
                SetPlayerAbilityAvailable(p, 'A04U', true); // Fix resistance bug
            }

            u = null;
            p = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc