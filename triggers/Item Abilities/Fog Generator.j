//TESH.scrollpos=8
//TESH.alwaysfold=0
//! zinc

library FogGenerator {
    private function CanHaveFog() -> boolean {
        return IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO) == true;
    }

    private function tick() {
        group g = CreateGroup();
        boolexpr b = Condition(function CanHaveFog);
        unit u = null;
        
        GroupEnumUnitsInRect(g, GetWorldBounds(), b);
        DestroyBoolExpr(b);
        
        u = FirstOfGroup(g);
        while (u != null) {
            if (GetUnitAbilityLevel(u, 'B00L') > 0 &&   // Has Fog Generator Buff
                GetUnitAbilityLevel(u, 'Apiv') == 0 &&  // Has No Invis at the moment
                GetUnitAbilityLevel(u, 'A0BN') == 0 && // Doesn't have ShadowCatcher
                GetUnitAbilityLevel(u, 'B018') == 0) { // Doesn't have Demonicus Shadow Walk
                UnitAddAbility(u, 'Apiv');
            }
            else if ((GetUnitAbilityLevel(u,'B00L') == 0 || // If it lost the Fog Generator Buff
                      GetUnitAbilityLevel(u, 'B018') > 0) &&     // Or has Demonicus' Shadow Walk
                     GetUnitAbilityLevel(u,'Apiv') > 0) {   // And has perma invis
                UnitRemoveAbility(u,'Apiv');
            }
            GroupRemoveUnit(g, u);
            u = FirstOfGroup(g);
        }
        DestroyGroup(g);
        u = null;
        g = null;
        b = null;
    }

    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterTimerEvent(t, 0.50, true);
        TriggerAddAction(t, function tick);
        t = null;
    }
}

//! endzinc