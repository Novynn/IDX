//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

// TSAQ
library VoltronMinionNuke requires GenericTitanTargets {
    private struct VoltronMinionNuke {
        private static constant integer ABILITY_ID = 'TVNQ';
        private static constant string TARGET_EFFECT = "war3mapImported\\LightningSphere_FX.mdx";

        private boolean useLightning = true;
        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "chest");
            this.damage.forceEffect = true;
            
            if (level == 1){
                this.damageAmount = 130.0;
                this.distance = 650.0;
            }
            else if (level == 2){
                this.damageAmount = 155.0;
                this.distance = 650.0;
            }
            else if (level == 3){
                this.damageAmount = 180.0;
                this.distance = 650.0;
            }
            
            this.delta = 35.0;
            
            if (!GameSettings.getBool("LIGHTNING_EFFECTS_ENABLED")) {
                this.useLightning = false;
            }
        }
        
        private unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        private real distance = 0.0;
        private real damageAmount = 0.0;
        private real delta = 0.0;
        private xedamage damage = 0;
        
        public method checkTarget(unit u) -> boolean {
            return !IsUnit(u, this.caster) && IsUnitNukable(u, this.caster) && IsUnitVisible(u, this.castingPlayer);
        }
        
        public method hitTarget(unit u){
            // TODO(rory): wut do?
            if (this.useLightning) {
                ReleaseLightningDelayed(CreateLightningBetweenUnits("CHIM", true, this.caster, u), 0.5);
            }
            this.damage.damageTarget(this.caster, u, this.damageAmount);
        }
        
        public static method pointInCone(real baseX, real baseY, real distance, real angle, real delta, real x, real y) -> boolean {
            real posAngle = Atan2(y - baseY, x - baseX) * bj_RADTODEG;
            posAngle = RAbsBJ(posAngle - angle);
            if (posAngle > 180) posAngle = 360 - posAngle;
            return posAngle <= delta;
        }
        
        private method acquireTargets(unit target, real x, real y) {
            real pointX = x;
            real pointY = y;
            real castX = GetUnitX(this.caster);
            real castY = GetUnitY(this.caster);
            real angle = Atan2(pointY - castY, pointX - castX) * bj_RADTODEG;
            real endX = castX + this.distance * Cos(angle * bj_DEGTORAD);
            real endY = castY + this.distance * Sin(angle * bj_DEGTORAD);
            unit u = null;
            group g = CreateGroup();
            
            GroupEnumUnitsInRange(g, castX, castY, this.distance, null);
            
            if (target != null && this.checkTarget(target)) {
                // Hit the main target (fo sho!)
                this.hitTarget(target);
            }
            
            u = FirstOfGroup(g);
            while (u != null) {
                if (u != target && this.checkTarget(u) &&
                    thistype.pointInCone(castX, castY, this.distance, angle, this.delta, GetUnitX(u), GetUnitY(u))) {
                    this.hitTarget(u);
                }
                
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            DestroyGroup(g);
            g = null;
            u = null;
        }
        
        private static method begin(unit caster, unit u, real x, real y, integer level) -> thistype {
            thistype this = thistype.allocate();
            this.level = level; // Sigh
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            this.damage = xedamage.create();
            
            this.setup(this.level);
            
            if (u != null) {
                x = GetUnitX(u);
                y = GetUnitY(u);
            }
            
            this.acquireTargets(u, x, y);
            this.destroy();
            return 0;
        }
        
        private method onDestroy(){
            this.damage.destroy();
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
            unit u = GetSpellTargetUnit();
            real x = GetSpellTargetX();
            real y = GetSpellTargetY();
            
            VoltronMinionNuke.begin(caster, u, x, y, level);
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
        VoltronMinionNuke.onSetup.execute();
    }
}


//! endzinc