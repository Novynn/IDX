//TESH.scrollpos=8
//TESH.alwaysfold=0
//! zinc

// TSAF
library SypheriousUltimate requires GT, xebasic, xepreload, UnitStatus {
    private struct SypheriousUltimate {
        private static constant integer ABILITY_ID = 'TSAF';
        private static constant string TARGET_EFFECT = "Abilities\\Spells\\Other\\Drain\\ManaDrainCaster.mdl";
        
        private unit caster = null;
        private player castingPlayer = null;
        private static constant real disableRange = 800.0;
        private static constant real disableTime = 10.0;
		
		// Workaround for filters
		private static thistype curr = 0;
        
        public method checkTarget(unit u) -> boolean {
            return (!IsUnitAlly(u, this.castingPlayer) ||
                    GetOwningPlayer(u) == Player(PLAYER_NEUTRAL_PASSIVE)) &&
                   (IsUnitType(u, UNIT_TYPE_STRUCTURE) ||
                    IsUnitType(u, UNIT_TYPE_MECHANICAL)) &&
                    UnitAlive(u);
        }
        
        private method disableArea(real x, real y){
            group g = CreateGroup();
			boolexpr b = null;
			
			thistype.curr = this;
			b = Filter(function() -> boolean {
				// How to pass "this" in?
				return thistype.curr.checkTarget(GetFilterUnit());
			});
            GroupEnumUnitsInRange(g, x, y, thistype.disableRange, b);
			thistype.curr = 0;
			
			ForGroup(g, function() {
				unit u = GetEnumUnit();
				xecollider xe = 0;
				xe = xecollider.create(GetUnitX(u), GetUnitY(u), 0.0);
				xe.expirationTime = thistype.disableTime;
				xe.fxpath = thistype.TARGET_EFFECT;
				xe.scale = 1.0;
				xe.z = 80;
				DisableUnitTimed(u, thistype.disableTime);
				u = null;
			});
			
            DestroyBoolExpr(b);
            DestroyGroup(g);
            g = null;
			b = null;
        }
        
        private static method begin(unit caster, real x, real y) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);

            this.disableArea(x, y);
            
            return this;
        }
        
        private method onDestroy(){
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            real x = GetSpellTargetX();
            real y = GetSpellTargetY();
            thistype.begin(caster, x, y);
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            XE_PreloadAbility(thistype.ABILITY_ID);
        }
    }
    
    private function onInit(){
        SypheriousUltimate.onSetup.execute();
    }
}


//! endzinc