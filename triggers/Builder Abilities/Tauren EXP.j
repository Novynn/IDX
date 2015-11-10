//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library TaurenEXP requires Damage {
    private function onInit(){
        trigger t = CreateTrigger();
        Damage_RegisterEvent(t);
        TriggerAddCondition(t, Condition(function() -> boolean {
            return Damage_IsAttack() &&
               (GetUnitTypeId(GetEventDamageSource()) == 'O01Q' ||
                GetUnitTypeId(GetEventDamageSource()) == 'O01R') &&
               (UnitManager.isTitan(GetTriggerUnit()) ||
                UnitManager.isMinion(GetTriggerUnit()));
        }));
        TriggerAddAction(t, function(){
            unit u = GetEventDamageSource();
			unit attacker = GetTriggerUnit();
            real damage = GetEventDamage();
			integer level = GetHeroLevel(attacker);
			integer exp = 2;
			
			if (level < 6) exp = 3;
			else if (level <= 11) exp = 4;
			else exp = 5;
			
            // Threshold of 45 so whirlpool, bombard, etc don't damage
            if (damage > 45.0) {
                ExperienceSystem.giveExperience(u, exp);
            }
			attacker = null;
            u = null;
        });
        t = null;
    }
}

//! endzinc