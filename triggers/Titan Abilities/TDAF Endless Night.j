//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

// TDAF
library DemonicusUltimate requires GT, xebasic, xepreload {
    private struct DemonicusUltimate {
        private static constant integer ABILITY_ID = 'TDAF';
        
        public static method checkEndlessNight() {
            group g = CreateGroup();
            filterfunc b = Filter(function() -> boolean {
                unit u = GetFilterUnit();
                boolean b = UnitAlive(u) &&
                            GetUnitAbilityLevel(u, thistype.ABILITY_ID) > 0;
                u = null;
                return b;
            });
            GroupEnumUnitsInRect(g, GetWorldBounds(), b);
            if (CountUnitsInGroup(g) == 0) {
                Game.say("|cff00bfffThe Endless Night has ended. Hell has frozen over. Pigs now fly through the skies.|r");
                SuspendTimeOfDay(false);
            }
            DestroyGroup(g);
            DestroyFilter(b);
            g = null;
            b = null;
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterLearnsAbilityEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit u = GetLearningUnit();
                // Set it to be night time 5ever
                SetFloatGameState(GAME_STATE_TIME_OF_DAY, 0.0);
                SuspendTimeOfDay(true);
                Game.say("|cff00bfffThe Endless Night has begun. There will be no mercy.|r");
                PlaySoundBJ(gg_snd_Titan_EndlessNight);
                UnitAddAbility(u, 'TDA6');
                UnitMakeAbilityPermanent(u, true, 'TDA6');
                
                PlayerData.get(GetOwningPlayer(u)).say("|cff00bfffIf the Endless Night... ends for some reason other than you dying, re-enable Shadow Walk to fix it.|r");
                u = null;
                return false;
            }));
            
            // Tome of Retraining check
            t = CreateTrigger();
            GT_RegisterItemAcquiredEvent(t, 'I05S');
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit u = GetTriggerUnit();
                if (GetUnitAbilityLevel(u, 'TDA6') > 0) {
                    UnitRemoveAbility(u, 'TDA6');
                    thistype.checkEndlessNight();
                }
                u = null;
                return false;
            }));
            t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit u = GetDyingUnit();
                if (GetUnitAbilityLevel(u, thistype.ABILITY_ID) > 0) {
                    thistype.checkEndlessNight();
                }
                u = null;
                return false;
            }));
            t = null;
            XE_PreloadAbility(thistype.ABILITY_ID);
        }
    }
    
    private function onInit(){
        DemonicusUltimate.onSetup.execute();
    }
}


//! endzinc