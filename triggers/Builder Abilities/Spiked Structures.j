//TESH.scrollpos=45
//TESH.alwaysfold=0
//! zinc

library SpikedStructures requires Damage, xedamage {
    private constant integer ABILITY_ID = 'A065';
    
    private function onInit(){
        trigger t = CreateTrigger();
        Damage_RegisterEvent(t);
        TriggerAddCondition(t , Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            unit a = GetEventDamageSource();
            player p = GetOwningPlayer(u);
            xedamage damage = 0;
            integer level = GetUnitAbilityLevel(u, ABILITY_ID);
            if (level > 0 && p != Player(PLAYER_NEUTRAL_AGGRESSIVE)) {
                // Has Spiked
                if (IsUnitEnemy(a, p)) {
                    damage = xedamage.create();
                    damage.dtype = DAMAGE_TYPE_NORMAL;
                    damage.damageTarget(u, a, level * 20);
                    damage.destroy();
                }
            }
            a = null;
            u = null;
            return false;
        }));
        XE_PreloadAbility(ABILITY_ID);
        t = null;
    }
}

//! endzinc