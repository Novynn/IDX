//TESH.scrollpos=18
//TESH.alwaysfold=0
//! zinc

// TDAQ
library DemonicusNuke requires GT, xebasic, xemissile, xepreload, GenericTitanTargets {
    private struct DemonicusNukeMissile extends xehomingmissile {
        private static constant string MISSILE_EFFECT = "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl";
        private DemonicusNuke object = 0;
        public method setup(DemonicusNuke object){
            this.object = object;
            this.fxpath = thistype.MISSILE_EFFECT;
        }
        
        public method onHit(){
            // the missile object will destroy itself after this
            this.object.onUnitHit.execute(this.targetUnit);
        }
    }
    
    private struct DemonicusNuke {
        private static constant integer ABILITY_ID = 'TDAQ';
        private static constant string TARGET_EFFECT = "Abilities\\Spells\\NightElf\\shadowstrike\\shadowstrike.mdl";
        private static constant integer ARMOR_REDUCTION_ABILITY_ID = 'TDA4';
        
        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "overhead");
            this.damage.forceEffect = true;
            
            if (level == 1){
                this.damageAmount = 105.0;
                this.nukeRange = 600.0;
            }
            else if (level == 2){
                this.damageAmount = 135.0;
                this.nukeRange = 600.0;
            }
            else if (level == 3){
                this.damageAmount = 155.0;
                this.nukeRange = 600.0;
            }
        }
        private unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        
        private real damageAmount = 0.0;
        private real nukeRange = 0.0;
        private xedamage damage = 0;
        private xecast cast = 0;
        private integer missilesCount = 0;
        
        public method onUnitHit(unit u) {
            // Unit is actually hit, RIP unit
            if (u != null && this.checkTarget(u)){
                // Check if damage was dealt first...
                if (this.damage.damageTarget(this.caster, u, damageAmount)){
                    this.cast.castOnTarget(u);
                }
            }
            // TODO: Somehow destroy this struct after all units damaged (or timeout?)
            this.missilesCount = this.missilesCount - 1;
            if (this.missilesCount == 0) {
                this.destroy();
            }
        }
        
        public method checkTarget(unit u) -> boolean {
            return IsUnitNukable(u, this.caster) && IsUnitVisible(u, this.castingPlayer);
        }
        
        private method fireAtTarget(unit u) {
            real x = GetUnitX(this.caster);
            real y = GetUnitY(this.caster);
            real z = GetUnitFlyHeight(this.caster);
            // TODO setup missile and fire at the target
            DemonicusNukeMissile missile = DemonicusNukeMissile.create(x, y, z, u, 0.0);
            missile.setup(this);
            missile.owner = this.castingPlayer;
            missile.launch(/* speed */900.0, 0.0);
            this.missilesCount = this.missilesCount + 1;
        }
        
        private method damageArea(){
            group g = CreateGroup();
            unit u = null;
            
            GroupEnumUnitsInRange(g, GetUnitX(this.caster), GetUnitY(this.caster), this.nukeRange, null);
            
            u = FirstOfGroup(g);
            while (u != null){
                if (this.checkTarget(u)){
                    this.fireAtTarget(u);
                }
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            GroupClear(g);
            DestroyGroup(g);
            g = null;
            u = null;
        }
        
        private static method begin(unit caster, integer level) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.level = level;
            this.castingPlayer = GetOwningPlayer(this.caster);
            
            this.damage = xedamage.create();
            this.damage.damageEnemies = true;
            this.damage.damageNeutral = true;
            this.damage.damageSelf = false;
            this.damage.damageAllies = false;
            this.cast = xecast.createBasic(thistype.ARMOR_REDUCTION_ABILITY_ID, OrderId("acidbomb"), this.castingPlayer);
            this.cast.recycledelay = 3.0;
            this.cast.level = this.level;
            this.setup(this.level);
            
            this.missilesCount = 0;
            this.damageArea();
            if (this.missilesCount == 0) {
                this.destroy();
                return 0;
            }
            return this;
        }
        
        private method onDestroy(){
            this.cast.destroy();
            this.cast = 0;
            this.damage.destroy();
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
        DemonicusNuke.onSetup.execute();
    }
}


//! endzinc