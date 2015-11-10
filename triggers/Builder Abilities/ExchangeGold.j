//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library ExchangeGold requires GT {
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_TRAIN_FINISH);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            unit v = GetTrainedUnit();
            player p = GetOwningPlayer(u);

            if (GetUnitTypeId(v) == 'n007'){ // Dummy Unit
                DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Items\\ResourceItems\\ResourceEffectTarget.mdl", GetUnitX(u), GetUnitY(u)));
                SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER) + 600);
                RemoveUnit(v);
            }

            u = null;
            p = null;
            v = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc