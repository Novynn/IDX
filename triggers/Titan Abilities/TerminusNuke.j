//TESH.scrollpos=124
//TESH.alwaysfold=0
//! zinc

// TVAQ
library TerminusNuke requires GameTimer, GT, xebasic, xepreload, xecollider, GenericTitanTargets {
    private struct TerminusNukeBall extends xecollider {
        private TerminusNuke object = 0;
        public method setNukeObject(TerminusNuke object){
            this.object = object;
        }
        
        public method onUnitHit(unit hitTarget){
            this.object.onUnitHit(hitTarget);
        }
        
        private real startX = 0.0;
        private real startY = 0.0;
        public method setStartPoint(real x, real y){
            this.startX = x;
            this.startY = y;
        }
        
        public method loopControl(){
            real dx = (this.homingTargetX - this.startX);
            real dy = (this.homingTargetY - this.startY);
            real range = SquareRoot(dx * dx + dy * dy);
            real currRange = 0.0;
            real factor = 0.0;
            
            dx = (this.x - this.startX);
            dy = (this.y - this.startY);
            currRange = SquareRoot(dx * dx + dy * dy);
            factor = (currRange / range);
            
            if (factor >= 1.0){
                this.object.ballEnd(this);
                this.terminate();
            }
        }
    }
    private struct TerminusNuke {
        private static constant integer ABILITY_ID = 'TTAQ';
        private static constant string BALL_EFFECT = "war3mapImported\\OrbOfLightning.mdx";
        private static constant string TARGET_EFFECT = "war3mapImported\\LightningSphere_FX.mdx";

        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "origin");
            this.damage.forceEffect = true;
            
            if (level == 1){
                this.damageAmount = 130.0;
				this.collisionSize = 100;
                this.distance = 600.0;
            }
            else if (level == 2){
                this.damageAmount = 155.0;
				this.collisionSize = 125;
                this.distance = 600.0;
            }
            else if (level == 3){
                this.damageAmount = 180.0;
				this.collisionSize = 150;
                this.distance = 600.0;
            }
        }
        
        private unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        private real distance = 0.0;
        private real collisionSize = 0.0;
        private real damageAmount = 0.0;
        private xedamage damage = 0;
        private TerminusNukeBall ball[3];
        private group hitUnits = null;
        
        public method checkTarget(unit u) -> boolean {
            return !IsUnit(u, this.caster) && !IsUnitInGroup(u, this.hitUnits) && IsUnitNukable(u, this.caster);
        }
        
        public method onUnitHit(unit u) -> boolean {
            if (!this.checkTarget(u)) return false;
            
            this.damage.damageTarget(this.caster, u, this.damageAmount);
            GroupAddUnit(this.hitUnits, u);
            return true;
        }
        
        private method generateBalls(real centerAngle, real delta, real collision) {
            integer i = -1;
            real castX = GetUnitX(this.caster);
            real castY = GetUnitY(this.caster);
            
            for (-1 <= i <= 1) {
                this.ball[i+1] = TerminusNukeBall.create(castX, castY, (centerAngle + (delta * i)) * bj_DEGTORAD);
                this.ball[i+1].setNukeObject(this);
                this.ball[i+1].owner = this.castingPlayer;
                this.ball[i+1].fxpath = thistype.BALL_EFFECT;
                this.ball[i+1].z = 60.0;
                this.ball[i+1].collisionSize = collision;
            }
        }
        
        method ballEnd(TerminusNukeBall b) {
            integer i = 0;
            integer count = 0;
            for (0 <= i < 3) {
                if (b == this.ball[i]) {
                    // Terminate will be called on b
                    this.ball[i] = 0;
                }
                else if (this.ball[i] != 0) {
                    count = count + 1;
                }
            }
            
            if (count == 0) {
                this.destroy();
            }
        }
        
        private method sendBalls() {
            integer i = -1;
            real angle = 0.0;
            real endX = 0.0;
            real endY = 0.0;
            real castX = GetUnitX(this.caster);
            real castY = GetUnitY(this.caster);
            
            for (-1 <= i <= 1) {
                angle = this.ball[i+1].direction;
                endX = castX + this.distance * Cos(angle * bj_DEGTORAD);
                endY = castY + this.distance * Sin(angle * bj_DEGTORAD);
                
                this.ball[i+1].setTargetPoint(endX, endY);
                this.ball[i+1].setStartPoint(castX, castY);
                this.ball[i+1].scale = 1.0;
                this.ball[i+1].speed = (this.distance / 0.8); // How far it travels in 1 second.
            }
        }
        
        private static method begin(unit caster, real x, real y, integer level) -> thistype {
            thistype this = thistype.allocate();
            real castX = GetUnitX(caster);
            real castY = GetUnitY(caster);
            real angle = Atan2(y - castY, x - castX) * bj_RADTODEG;
            real endX = 0.0;
            real endY = 0.0;
            
            this.level = level; // Sigh
            
            this.hitUnits = CreateGroup();
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            this.damage = xedamage.create();
            
            this.setup(this.level);
            this.generateBalls(angle, 25.0, this.collisionSize);
            this.sendBalls();
            
            return this;
        }
        
        private method onDestroy(){
            if (this.hitUnits != null) {
                GroupClear(this.hitUnits);
                DestroyGroup(this.hitUnits);
                this.hitUnits = null;
            }
            this.damage.destroy();
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
            real x = GetSpellTargetX();
            real y = GetSpellTargetY();
            TerminusNuke.begin(caster, x, y, level);
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
        TerminusNuke.onSetup.execute();
    }
}


//! endzinc