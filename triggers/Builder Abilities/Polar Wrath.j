//TESH.scrollpos=6
//TESH.alwaysfold=0
//! zinc

// Removes the Magnataur's ability to gold for 3 minutes (Polar Wrath)

library PolarWrath requires GT, GameTimer, AIDS {
     private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A04H');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            integer id = GetUnitIndex(u);
            UnitRemoveAbility(u, 'A041');
            GameTimer.newPeriodic(function(GameTimer t){
                unit u = GetIndexUnit(t.data());
                // NOTE(Neco): Using "BHav" here instead of Polar Wrath's buff
                //             as it is hardcoded into WC3 to use BHav.
                if (GetUnitAbilityLevel(u, 'BHav') == 0) {
                    UnitAddAbility(u, 'A041');
                    IssueImmediateOrder(u, "restorationon");
                    t.deleteLater();
                }
                u = null;
            }).start(1.0).setData(id);
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc