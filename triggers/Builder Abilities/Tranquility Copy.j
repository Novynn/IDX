//TESH.scrollpos=24
//TESH.alwaysfold=0
//! zinc

library Tranquility requires xecast, xepreload {
    private constant integer TRANQ_BUFF_ID = 'B04G';
    private constant integer TRANQ_ABIL_ID = 'A0LT';
    
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ATTACKED);
        TriggerAddCondition(t, Condition(function() -> boolean {
            return GetUnitAbilityLevel(GetTriggerUnit(), 'B04D') > 0 &&
                   IsUnitEnemy(GetAttacker(), GetOwningPlayer(GetTriggerUnit()));
        }));
        TriggerAddAction(t, function() {
            unit u = GetTriggerUnit(); // Attacked
            xecast xe = xecast.createBasic('A0LU', OrderId("invisibility"), GetOwningPlayer(u));
            xe.recycledelay = 2.0;
            xe.castOnTarget(u);
            
            u = null;
        });
        
        t = CreateTrigger();
        TriggerRegisterTimerEvent(t, 1.00, true);
        TriggerAddAction(t, function() {
            group g = CreateGroup();
            unit u = null;
            GroupEnumUnitsInRect(g, GetWorldBounds(), null);
            
            u = FirstOfGroup(g);
            while (u != null) {
                if (GetUnitAbilityLevel(u, TRANQ_BUFF_ID) > 0 &&
                    GetUnitAbilityLevel(u, TRANQ_ABIL_ID) == 0){
                    UnitAddAbility(u, TRANQ_ABIL_ID);
                }
                else if (GetUnitAbilityLevel(u, TRANQ_BUFF_ID) == 0 &&
                         GetUnitAbilityLevel(u, TRANQ_ABIL_ID) > 0){
                    UnitRemoveAbility(u, TRANQ_ABIL_ID);
                }
                
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
        
            DestroyGroup(g);
            u = null;
            g = null;
            
        });
        XE_PreloadAbility('A0LU');
        t = null;
    }
}

//! endzinc

