//TESH.scrollpos=28
//TESH.alwaysfold=0
//! zinc
library IslandBloomAttack requires Table {
    constant integer ISLAND_BLOOM_ID = 'o03C';
    constant integer DISABLE_ATTACK = '&noa';

    function onDayStart(){
        group g;
        integer i = 0;
        //BJDebugMsg("DAY TIME START");
        g = GetUnitsOfTypeIdAll(ISLAND_BLOOM_ID);
        ForGroup(g, function(){
            UnitRemoveAbility(GetEnumUnit(), DISABLE_ATTACK);
        });
        DestroyGroup(g);
        g = null;
    }
    function onNightStart(){
        group g;
        integer i = 0;
        //BJDebugMsg("Night TIME START");
        
        g = GetUnitsOfTypeIdAll(ISLAND_BLOOM_ID);
        ForGroup(g, function(){
            UnitAddAbility(GetEnumUnit(), DISABLE_ATTACK);
        });
        DestroyGroup(g);
        g = null;
    }
    function onConstruction(){
        unit u = GetConstructedStructure();
        real timeOfDay = GetFloatGameState(GAME_STATE_TIME_OF_DAY);
        if (GetUnitTypeId(u) != ISLAND_BLOOM_ID){u = null; return;}
        if (timeOfDay >= 6. && timeOfDay < 18.) {
            //BJDebugMsg("CONSTRUCTED DURING DAYTIME");
            //Do Nothing
        }
        else {
            //BJDebugMsg("CONSTRUCTED DURING NIGHTTIME");
            UnitAddAbility(u, DISABLE_ATTACK);
        }
        SetUnitState(u, UNIT_STATE_MANA, 0);
        u = null;
    }
    
    function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterGameStateEvent(t, GAME_STATE_TIME_OF_DAY, EQUAL, 6.);
        TriggerAddAction(t, function onDayStart);
        t = CreateTrigger();
        TriggerRegisterGameStateEvent(t, GAME_STATE_TIME_OF_DAY, EQUAL, 18.);
        TriggerAddAction(t, function onNightStart);
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH);
        TriggerAddAction(t, function onConstruction);
    }
}
//! endzinc