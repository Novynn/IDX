//TESH.scrollpos=76
//TESH.alwaysfold=0
//! zinc

library CurrentTap requires GameTimer, RegisterPlayerUnitEvent, xecast, DestroyEffectTimed {
    public struct CurrentTap {
        public static real DELAY_TIME = 45.0;
        public static string EFFECT = "Abilities\\Spells\\Human\\Blizzard\\BlizzardTarget.mdl";
        public static real EFFECT_TICK = 0.2;
        private static Table instances = 0;
        private integer index = 0;
        private GameTimer tickTimer = 0;
        private GameTimer effectTimer = 0;
        private unit caster = null;
        private xecast cast = 0;
        private integer effectTicks = 0;
        private real lastCastX = 0.0;
        private real lastCastY = 0.0;
        
        public method tick() {
            rect r = bj_mapInitialPlayableArea; // No need for a selection buffer here?
            real x = GetRandomReal(GetRectMinX(r), GetRectMaxX(r));
            real y = GetRandomReal(GetRectMinY(r), GetRectMaxY(r));
			PlayerData p = PlayerData.get(GetOwningPlayer(this.caster));
            // Create "Current Tap"
			this.cast.owningplayer = GetOwningPlayer(this.caster);
			this.cast.castOnPoint(x, y);

            if (GameSettings.getBool("TITAN_GLACIOUS_SHOW_CURRENT_TAP_PINGS")) {
                if (GetLocalPlayer() == GetOwningPlayer(this.caster)) {
                    PingMinimapEx(x, y, 2.0, 80, 80, 255, true);
                }
            }
            
            this.lastCastX = x;
            this.lastCastY = y;
            if (this.effectTimer != 0) {
                this.effectTimer.deleteNow();
            }
            this.effectTimer = GameTimer.newNamedPeriodic(function(GameTimer t) {
                thistype this = t.data();
                real x = 0.0;
                real y = 0.0;
                real angle = 0.0;
                real dist = 0.0;
                if (this != 0) {
                    this.effectTicks = this.effectTicks + 1;
                    if (this.effectTicks > R2I(15.0 / thistype.EFFECT_TICK)) {
                        this.effectTimer.deleteLater();
                        this.lastCastX = 0.0;
                        this.lastCastY = 0.0;
                        this.effectTicks = 0;
                        this.effectTimer = 0;
                        return;
                    }
                    
                    dist = GetRandomReal(0.0, 2000.0);
                    angle = GetRandomReal(0.0, 360.0);
                    x = this.lastCastX + dist * Cos(angle * bj_DEGTORAD);
                    y = this.lastCastY + dist * Sin(angle * bj_DEGTORAD);
                    
                    DestroyEffectTimed(AddSpecialEffect(thistype.EFFECT, x, y), 2.0);
                }
            }, "GlaciousCurrentTapEffect");
            this.effectTimer.setData(this);
            this.effectTimer.start(thistype.EFFECT_TICK);
        }
        
        
        public static method begin(unit u) -> thistype {
			integer id = GetUnitIndex(u);
            thistype this = thistype.instances[id];
			if (this != 0) this.destroy();
			this = thistype.allocate();
            this.caster = u;
            this.index = id;
            
            this.cast = xecast.createBasic('A052', OrderId("farsight"), GetOwningPlayer(this.caster));
            this.cast.recycledelay = 2.0;
            
            this.tickTimer = GameTimer.newNamedPeriodic(function(GameTimer t) {
                thistype this = t.data();
                if (this != 0) {
                    this.tick();
                }
            }, "GlaciousCurrentTap");
            this.tickTimer.setData(this);
            this.tickTimer.start(thistype.DELAY_TIME);
            
            thistype.instances[this.index] = this;
            return this;
        }
        
        public method onDestroy() {
            thistype.instances.remove(this.index);
            this.index = 0;
            
            if (this.cast != 0) {
                this.cast.destroy();
                this.cast = 0;
            }
            if (this.tickTimer != 0) {
                this.tickTimer.deleteNow();
                this.tickTimer = 0;
            }
            if (this.effectTimer != 0) {
                this.effectTimer.deleteNow();
                this.effectTimer = 0;
            }
        }
        
        public static method onDeath(unit u) {
            thistype this = 0;
            integer id = GetUnitId(u);
            if (!thistype.instances.has(id)) return;
            
            this = thistype.instances[id];
            if (this != 0) {
                this.destroy();
            }
        }
        
        public static method onSetup() {
            trigger t = CreateTrigger();
            rect rec = GetWorldBounds();
            region r = CreateRegion();
            RegionAddRect(r, rec);
            RemoveRect(rec);
            rec = null;
            
            TriggerRegisterEnterRegion(t, r, Filter(function() -> boolean {
                unit u = GetFilterUnit();
                if (GetUnitAbilityLevel(u, 'TGAD') > 0) {
                    thistype.begin(u);
                }
                u = null;
                return false;
            }));
            
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function() -> boolean {
                unit u = GetDyingUnit();
                thistype.onDeath(u);
                u = null;
                return false;
            });
            thistype.instances = Table.create();
            t = null;
            r = null;
        }
    }
    
        
    private function onInit(){
        CurrentTap.onSetup.execute();
    }
}

//! endzinc