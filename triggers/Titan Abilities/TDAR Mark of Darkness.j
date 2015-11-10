//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library MarkOfDarkness requires UnitManager {
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CAST);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetSpellTargetUnit();
            if (GetSpellAbilityId() == 'TDAR' &&
                UnitManager.isDefender(u) ||
                UnitManager.isHunter(u)) {
                IssueImmediateOrder(GetSpellAbilityUnit(), "stop" );
            }
            u = null;
            return false;
        }));
    }
}

//! endzinc