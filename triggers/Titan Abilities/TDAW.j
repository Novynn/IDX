//TESH.scrollpos=67
//TESH.alwaysfold=0
//! zinc

// TDAW
library ShadowWalk requires GT, xebasic, xepreload, Table, AIDS {
    private struct ShadowWalk {
        private static constant integer ABILITY_ID = 'TDAW';
        private static constant integer ABILITY_BUFF_ID = 'B018';
        private static constant integer ABILITY_INVIS_ID = 'TDA2'; // AA off
        private static constant integer ABILITY_INVIS_AA_ID = 'TDA3'; // AA on
        private static constant integer ULTIMATE_ID = 'TDAF';
        private static constant real DISTANCE_TO_MANA_FACTOR = 0.15;
        
        private unit caster = null;
        private player castingPlayer = null;
        private GameTimer tickTimer = 0;
        private real lastX = 0.0;
        private real lastY = 0.0;
        
        private static method isNight() -> boolean {
            real timeOfDay = GetFloatGameState(GAME_STATE_TIME_OF_DAY);
            return timeOfDay < 6.0 || timeOfDay >= 18.0;
        }
        
        public method drainTick() {
            real x = GetUnitX(this.caster);
            real y = GetUnitY(this.caster);
            real dx = x - this.lastX;
            real dy = y - this.lastY;
            real distance = SquareRoot(dx * dx + dy * dy);
            real mana = thistype.DISTANCE_TO_MANA_FACTOR * distance;
            
            // If we're out of mana, turn off
            if (GetUnitState(this.caster, UNIT_STATE_MANA) < mana) {
                this.destroy();
                return;
            }
            
            // Take mana
            SetUnitState(this.caster, UNIT_STATE_MANA, GetUnitState(this.caster, UNIT_STATE_MANA) - mana);
            this.lastX = GetUnitX(this.caster);
            this.lastY = GetUnitY(this.caster);
        }
        
        private method tick(){
            if (GetUnitAbilityLevel(this.caster, thistype.ULTIMATE_ID) == 0){
                this.drainTick();
            }
        }
        
        private static method begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            this.tickTimer = 0;
            
            if (!thistype.isNight()) {
                // Fix for Endless Night ending via Moon Crystal
                if (GetUnitAbilityLevel(this.caster, thistype.ULTIMATE_ID) > 0) {
                    SetFloatGameState(GAME_STATE_TIME_OF_DAY, 0.0);
                    SuspendTimeOfDay(true);
                } 
                else {
                    PlayerData.get(this.castingPlayer).say("|cff00bfffShadow Walk may only be used at night.|r");
                    GameTimer.new(function(GameTimer t) {
                        thistype this = t.data();
                        this.destroy();
                    }).start(0.0).setData(this);
                    return 0;
                }
            }
            
            this.lastX = GetUnitX(this.caster);
            this.lastY = GetUnitY(this.caster);
            this.tickTimer = GameTimer.newNamedPeriodic(function(GameTimer t){
                thistype this = t.data();
                if (this.caster == null ||
                    !UnitAlive(this.caster) || 
                    GetUnitAbilityLevel(this.caster, thistype.ABILITY_BUFF_ID) == 0) {
                    this.destroy();
                    return;
                }
                
                if (!thistype.isNight()){
                    // Fix for Endless Night ending via Moon Crystal
                    if (GetUnitAbilityLevel(this.caster, thistype.ULTIMATE_ID) > 0) {
                        SetFloatGameState(GAME_STATE_TIME_OF_DAY, 0.0);
                        SuspendTimeOfDay(true);
                    }
                    else {
                        this.destroy();
                        return;
                    }
                }
                
                this.tick();
            }, "ShadowWalkTick");
            
            this.tickTimer.setData(this);
            this.tickTimer.start(0.25);
            
            // If we made it this far, perma invis!
            if (GameSettings.getBool("TITAN_AUTOATTACK_ON")) {
                UnitAddAbility(this.caster, thistype.ABILITY_INVIS_AA_ID);
            }
            else {
                UnitAddAbility(this.caster, thistype.ABILITY_INVIS_ID);
            }
            
            return this;
        }
        
        private method onDestroy(){
            if (this.caster != null) {
                UnitRemoveAbility(this.caster, thistype.ABILITY_BUFF_ID);
                UnitRemoveAbility(this.caster, thistype.ABILITY_INVIS_ID);
                UnitRemoveAbility(this.caster, thistype.ABILITY_INVIS_AA_ID);
            }
            this.caster = null;
            this.castingPlayer = null;
            if (this.tickTimer != 0) {
                this.tickTimer.deleteNow();
                this.tickTimer = 0;
            }
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster);
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            
            t = CreateTrigger();
            TriggerRegisterTimerEvent(t, 0.50, true);
            TriggerAddCondition(t, Condition(function() -> boolean {
                return false;
            }));
            t = null;
            XE_PreloadAbility(thistype.ABILITY_ID);
        }
    }
    
    private function onInit(){
        ShadowWalk.onSetup.execute();
    }
}


//! endzinc