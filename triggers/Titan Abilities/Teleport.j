//TESH.scrollpos=29
//TESH.alwaysfold=0
//! zinc

library PunishmentCentreTeleport requires UnitManager, AIDS, DestroyEffectTimed {
    public struct PunishmentCentreTeleport {
        public static method onInit(){
            // Teleport
            trigger t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
            TriggerAddCondition(t, Condition(function() -> boolean {
                return GetSpellAbilityId() == '&TEL';
            }));
            TriggerAddAction(t, function(){
                real x = GetUnitX(UnitManager.TITAN_SPELL_WELL);
                real y = GetUnitY(UnitManager.TITAN_SPELL_WELL);
                effect e = AddSpecialEffect("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTo.mdl", x, y);
                unit u = GetSpellTargetUnit();
                integer level = GetUnitAbilityLevel(GetTriggerUnit(), '&TEL');
                real time = 3.5;
                
                if (level == 1) {
                    time = 3.5;
                } 
                else if (level == 2) {
                    time = 3.25;
                } 
                else if (level == 3) {
                    time = 3.0;
                } 
                else if (level == 4) {
                    time = 2.75;
                } 
                else if (level == 5) {
                    time = 2.5;
                }
                
                UnitAddAbility(UnitManager.TITAN_SPELL_WELL, 'A06R');
            
                GameTimer.new(function(GameTimer t){
                    unit u = GetIndexUnit(t.data());
                    location l = GetUnitLoc(u);
                    location m = GetUnitLoc(UnitManager.TITAN_SPELL_WELL);
                    location n = PolarProjectionBJ(m, 200, AngleBetweenPoints(m, l));
                    SetUnitPositionLoc(u, n);
                    UnitRemoveAbility(UnitManager.TITAN_SPELL_WELL, 'A06R');
                    UnitRemoveAbility(UnitManager.TITAN_SPELL_WELL, 'B02U');
                    RemoveLocation(n);
                    RemoveLocation(m);
                    RemoveLocation(l);
                    n = null;
                    m = null;
                    l = null;
                    u = null;
                }).start(time).setData(GetUnitIndex(u));
                
                debug {BJDebugMsg("Teleport delay time: " + R2S(time) + "s");}

                DestroyEffectTimed(e, time + 0.5);
                
                e = null;
                u = null;
            });
            t = null;
        }
    }
}

//! endzinc