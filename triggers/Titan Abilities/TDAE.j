//TESH.scrollpos=176
//TESH.alwaysfold=0
//! zinc

// TDAE
library DemonicusHeal requires GameTimer, GT, xebasic, xepreload, UnitStatus, Table, AIDS {
    private struct DemonicusHealMissile extends xemissile {
        private static constant string MISSILE_EFFECT = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl";
        private DemonicusHeal object = 0;
        public method setup(DemonicusHeal obj){
            this.object = obj;
            this.fxpath = thistype.MISSILE_EFFECT;
            this.scale = 1.0;
        }
        
        public method onHit(){
            this.object.onHit(this.x, this.y, this.z);
            this.terminate();
        }
    }
    private struct DemonicusHeal {
        private static constant integer ABILITY_ID = 'TDAE';
        private static constant string TARGET_EFFECT = "Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl";
        private static constant integer MISSILE_COUNT = 24;
        private static constant real DAMAGE_FACTOR = 1.33;
        
        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_UNIVERSAL;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            
            if (level == 1){
                this.healAmount = 300.0;
                this.effectArea = 300.0;
            }
            else if (level == 2){
                this.healAmount = 500.0;
                this.effectArea = 300.0;
            }
            else if (level == 3){
                this.healAmount = 700.0;
                this.effectArea = 300.0;
            }
            else if (level == 4){
                this.healAmount = 900.0;
                this.effectArea = 300.0;
            }
        }
        private unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        
        private real healAmount = 0.0;
        private real effectArea = 0.0;
        private xedamage damage = 0;
        private DemonicusHealMissile missiles[thistype.MISSILE_COUNT];
        private Table healedAmountUnits = 0;
        private integer launchCount = 0;
        private integer hitCount = 0;
        private GameTimer launchTimer = 0;
        private real castX = 0.0;
        private real castY = 0.0;
        private real targetX = 0.0;
        private real targetY = 0.0;
        
        public method checkTarget(unit u) -> boolean {
            return IsUnitHealable(u, this.caster);
        }
        
        public method onHit(real x, real y, real z){
            group g = CreateGroup();
            unit u = null;
            integer id = 0;
            real splashArea = this.effectArea / 2;
            real healedAmount = 0.0;
            real damage = 0.0;
            GroupEnumUnitsInRange(g, x, y, splashArea, null);
            u = FirstOfGroup(g);
            while (u != null){
                if (this.checkTarget(u)){
                    id = GetUnitIndex(u);
                    healedAmount = this.healedAmountUnits.real[id];
                    if (healedAmount < this.healAmount){
                        damage = this.healAmount * 0.25;
                        
                        if (damage + healedAmount > this.healAmount){
                            damage = (this.healAmount - healedAmount);
                        }
                        
                        this.damage.damageTarget(this.caster, u, damage * thistype.DAMAGE_FACTOR);
                        if (healedAmount == 0) {
                            DestroyEffectTimed(AddSpecialEffect(this.TARGET_EFFECT, GetUnitX(u), GetUnitY(u)), 2.0);
                        }
                        
                        this.healedAmountUnits.real[id] = healedAmount + damage;
                    }
                }
            
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }

            GroupClear(g);
            DestroyGroup(g);
            g = null;
            u = null;
            
            this.hitCount = this.hitCount + 1;
            if (this.hitCount >= thistype.MISSILE_COUNT){
                this.destroy();
            }
        }
        
        public method launchNext(){
            DemonicusHealMissile missile = 0;
            real x = this.targetX;
            real y = this.targetY;
            real angle = 0.0;
            real dist = 0.0;
    
            if (this.launchCount >= thistype.MISSILE_COUNT){
                this.launchTimer.deleteLater();
                return;
            }
            
            angle = GetRandomReal(0.0, 360.0);
            dist = GetRandomReal(0.0, this.effectArea);
            x = x + dist * Cos(angle * bj_DEGTORAD);
            y = y + dist * Sin(angle * bj_DEGTORAD);
            
            this.castX = GetUnitX(this.caster);
            this.castY = GetUnitY(this.caster);
            
            missile = DemonicusHealMissile.create(this.castX, this.castY, 120.0, x, y, 0.0);
            this.missiles[this.launchCount] = missile;
            this.launchCount = this.launchCount + 1;
            
            missile.setup(this);
            missile.owner = this.castingPlayer;
            missile.launch(800, 0.4);
        }
        
        private static method begin(unit caster, real x, real y, integer level) -> thistype {
            thistype this = thistype.allocate();
            integer i = 0;
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            this.level = level;
            this.castX = GetUnitX(this.caster);
            this.castY = GetUnitY(this.caster);
            this.targetX = x;
            this.targetY = y;

            this.damage = xedamage.create();
            this.damage.damageSelf = true;
            this.damage.damageAllies = true;
            this.damage.damageEnemies = false;
            this.damage.damageNeutral = false;
            this.damage.allyfactor = -1.0;
            this.healedAmountUnits = Table.create();
            this.setup(this.level);
            
            this.launchCount = 0;
            
            this.launchTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                this.launchNext();
                this.launchNext();
            });
            this.launchTimer.setData(this);
            this.launchTimer.start(0.08);
            
            return this;
        }
        
        private method onDestroy(){
            this.healedAmountUnits.destroy();
            this.damage.destroy();
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            real x = GetSpellTargetX();
            real y = GetSpellTargetY();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
            thistype.begin(caster, x, y, level);
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
        DemonicusHeal.onSetup.execute();
    }
}


//! endzinc