//TESH.scrollpos=6
//TESH.alwaysfold=0
//! zinc

library SatyrDash requires xecast, GT {
    private struct SatyrDash {
        private GameTimer timer = 0;
        private unit caster = null;
        private real startX = 0.0;
        private real startY = 0.0;
        private real increment = 20.0;
        private real distance = 0.0;
        private real facing = 0.0;
        
        public method tick() {
            real x = 0.0;
            real y = 0.0;
            this.facing = GetUnitFacing(this.caster);
            x = GetUnitX(this.caster) + this.increment * Cos(this.facing * bj_DEGTORAD);
            y = GetUnitY(this.caster) + this.increment * Sin(this.facing * bj_DEGTORAD);
            if (IsTerrainWalkable(x, y)){
                SetUnitPosition(this.caster, x, y);
            }
            
            this.distance = this.distance + this.increment;
            if (distance > 350.0) {
                this.destroy();
            }
        }
        
        public method onDestroy(){
            UnitRemoveAbility(this.caster, 'BOwk');
            SetUnitPathing(this.caster, true);
            this.timer.destroy();
            this.caster = null;
        }
        
        public static method begin(unit u) -> thistype {
            thistype this = thistype.allocate();
            this.caster = u;
            this.startX = GetUnitX(u);
            this.startY = GetUnitY(u);
            this.facing = GetUnitFacing(u);
            this.distance = 0.0;
            
            SetUnitAnimation(this.caster, "attack");
            this.timer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                if (IsUnitAliveBJ(this.caster)){
                    this.tick();
                }
                else {
                    this.destroy();
                }
            });
            this.timer.setData(this);
            this.timer.start(0.02);
            
            SetUnitPathing(this.caster, false);
            
            return this;
        }
    }
    
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A0C8');

        TriggerAddCondition(t, Condition(function() -> boolean {
            SatyrDash.begin(GetSpellAbilityUnit());
            return false;
        }));
        t = null;
        
        XE_PreloadAbility('A0C8');
    }
}

//! endzinc
