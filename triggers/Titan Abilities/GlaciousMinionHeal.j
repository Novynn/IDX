//TESH.scrollpos=78
//TESH.alwaysfold=0
//! zinc

// TGNE
library GlaciousMinionHeal requires GenericTitanTargets {
    private struct GlaciousMinionHeal {
        private static constant integer ABILITY_ID = 'TGNE';
        private static constant string TARGET_EFFECT = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorTarget.mdl";
        private static constant real DAMAGE_FACTOR = 1.33;
        
        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_UNIVERSAL;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "chest");
            this.damage.forceEffect = true;
            
            this.duration = 5.0;
            this.timeoutDelay = 0.5;
            
            if (level == 1){
                this.damageAmount = 300.0;
            }
            else if (level == 2){
                this.damageAmount = 400.0;
            }
            else if (level == 3){
                this.damageAmount = 500.0;
            }
            else if (level == 4){
                this.damageAmount = 600.0;
            }
        }
        private unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        private real duration = 0.0;
        private real timeoutDelay = 0.0;
        
        private real damageAmount = 0.0;
        private xedamage damage = 0;
        private GameTimer healTimer = 0;
        private real tickTime = 0.0;
        
        private static method begin(unit caster, integer level) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.level = level;
            this.castingPlayer = GetOwningPlayer(this.caster);
            
            this.damage = xedamage.create();
            this.damage.damageSelf = true;
            this.damage.damageAllies = true;
            this.damage.damageEnemies = false;
            this.damage.damageNeutral = false;
            this.damage.allyfactor = -1.0;
            this.setup(this.level);
            
            this.tickTime = 0.0;
            this.healTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                real amount = this.damageAmount * (this.timeoutDelay / this.duration);
                if (this != 0) {
                    this.tickTime = this.tickTime + this.timeoutDelay;
                    if (this.tickTime > this.duration) {
                        this.destroy();
                        return;
                    }
                    
                    this.damage.damageTarget(this.caster, this.caster, amount * DAMAGE_FACTOR);
                }
            });
            this.healTimer.setData(this);
            this.healTimer.start(this.timeoutDelay);
            
            return this;
        }
        
        private method onDestroy(){
            this.damage.destroy();
            this.healTimer.deleteLater();
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
            thistype.begin(caster, level);
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
        GlaciousMinionHeal.onSetup.execute();
    }
}


//! endzinc