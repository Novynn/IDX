//TESH.scrollpos=37
//TESH.alwaysfold=0
//! zinc

library Plunder requires Damage, ShowTagFromUnit {
    function plunder(unit attacker, unit attacked){
        integer level = GetHeroLevel(attacked);
        integer gold = 0;
        integer wood = 0;
        string s = "";
        PlayerData p = PlayerData.get(GetOwningPlayer(attacker));
        
        if (level < 6) gold = 3;
        else if (level <= 11) gold = 4;
        else gold = 5;
        
        if (UnitManager.isMinion(attacked)) {
            gold = R2I(I2R(gold) / 2.0);
        }
        wood = gold * 100;
        
        p.setGold(p.gold() + gold);
        p.setWood(p.wood() + wood);
        
        s = "|cffffd700+" + I2S(gold) + "|r\n\n|ccf01bf4d+" + I2S(wood) + "|r";
        if (GetLocalPlayer() == p.player()) {
            ShowTagFromUnit(s, attacker);
        }
        s = "";
    }
    
    private function setup() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_ATTACKED );
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit a = GetAttacker();
            unit u = GetTriggerUnit();
            if (GetUnitAbilityLevel(a, 'A0BS') > 1 && IsUnitType(u, UNIT_TYPE_HERO) &&
                (UnitManager.isTitan(u) || UnitManager.isMinion(u))) {
                plunder(a, u);
            }
            a = null;
            u = null;
            return false;
        }));
        t = CreateTrigger();
        Damage_RegisterEvent(t);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit a = GetEventDamageSource();
            unit u = GetTriggerUnit();
            real damage = GetEventDamage();
            // Threshold of 20 so whirlpool etc don't damage
            if (GetUnitAbilityLevel(a, 'A0BS') == 1 &&
                (UnitManager.isTitan(u) || UnitManager.isMinion(u)) &&
                Damage_IsAttack() && damage > 20.0) {
                plunder(a, u);
            }
            a = null;
            u = null;
            return false;
        }));
        t = null;
    }

    private function onInit() {
        setup.execute();
    }
}

//! endzinc