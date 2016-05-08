//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library Sacrifice requires GT, UnitManager {
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A05P');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetSpellTargetUnit();
            real x = GetUnitX(u);
            real y = GetUnitY(u);
            
            if (!UnitManager.isDefender(u)){
                UnitAddAbility(u, 'S00F');
                
                UnitRemoveBuffsEx(u, false, false, false, false, true, false, false);
                UnitApplyTimedLife(u, 'BTLF', 15.0);
                SetUnitOwner(u, GetOwningPlayer(GetTriggerUnit()), true);
                
                DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", x, y));
            }
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc