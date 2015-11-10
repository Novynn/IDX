//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library DefenderUnit requires Unit, RevealMapForPlayer, GT, Upgrades {
    private struct MinionGracefulSpawn {
        real x = 0.0;
        real y = 0.0;
        integer level = 0;
        effect grave = null;
        boolean spawned = false;
        integer gameId = 0;
        
        public static method begin(real x, real y, integer level) -> thistype {
            thistype this = thistype.allocate();
            this.x = x;
            this.y = y;
            this.level = level;
            this.grave = AddSpecialEffect("Doodads\\Cinematic\\GlowingRunes\\GlowingRunes0.mdl", x, y);
            this.spawned = false;
            this.gameId = Game.id();
            
            GameTimer.newPeriodic(function(GameTimer t) {
                thistype this = t.data();
                if (this.gameId != Game.id()) {
                    t.deleteLater();
                    return;
                }
                
                if (Game.currentGameElapsed() > GameSettings.getReal("MINION_SPAWN_GRACE_TIME") &&
                    !this.spawned){
                    this.spawn();
                    t.deleteLater();
                }
            }).start(1.0).setData(this);
            
            return this;
        }
        
        public method onDestroy() {
            if (this.grave != null) {
                DestroyEffect(this.grave);
                this.grave = null;
            }
        }
        
        private method spawn() {
            PlayerData p = DefenderDeath.findTitanPlayer();
            TitanCourier c = 0;
            real x = GetUnitX(UnitManager.TITAN_SPELL_WELL);
            real y = GetUnitY(UnitManager.TITAN_SPELL_WELL);
            
            if (p != 0) {
                c = TitanCourier.create(this.x, this.y, 120.0, x, y, 120.0);
                
                c.setOnHit(this, function(TitanCourier c) {
                    thistype this = c.data();
                    if (this != 0) {
                        this.spawnMinion(c.x, c.y);
                    }
                });
                
                c.launch(522.0, 0.0);
            
                p.say("|cff00bfffThe Minion Spawn grace time is now over. A courier will deliver your level|r |cffff0000" + I2S(level) + "|r |cff00bfffminion to you shortly.|r");
                Game.sayClass(PlayerData.CLASS_DEFENDER, "|cffff0000Warning!|r |cff00bfffThe Minion Spawn grace time is now over. The Titan will gain a minion at the mound shortly.|r");
                Game.sayClass(PlayerData.CLASS_OBSERVER, "|cffff0000Warning!|r |cff00bfffThe Minion Spawn grace time is now over. The Titan will gain a minion at the mound shortly.|r");
                
                if (this.grave != null) {
                    DestroyEffect(this.grave);
                    this.grave = null;
                }
                this.spawned = true;
            }
            else {
                Game.say("DefenderUnit.MinionGracefulSpawn.spawnMinion could not complete properly. No titan player could be found.\n" +
                         "Please report this bug with the replay and time of occurance to one of the websites listed in the top-right corner.");
                this.destroy();
            }
        }
        
        public method spawnMinion(real x, real y) {
            PlayerData p = DefenderDeath.findTitanPlayer();
            MinionUnit minion = 0;
            if (p != 0) {
                minion = UnitManager.spawnMinion(p, x, y, this.level);
                // Potion
                UnitAddItem(minion.unit(), CreateItem('I03M', x, y));
            }
            else {
                Game.say("DefenderUnit.MinionGracefulSpawn.spawnMinion could not complete properly. No titan player could be found.\n" +
                             "Please report this bug with the replay and time of occurance to one of the websites listed in the top-right corner.");
            }
            
            this.destroy();
        }
    }
    
    public struct DefenderUnit extends Unit {
        private unit mUnit = null;
        private integer mClass = 0;
        private Race mRace = 0;
        private PlayerData mOwner = 0;
        
        public method unit() -> unit {
            return this.mUnit;
        }
        public method class() -> integer {
            return this.mClass;
        }
        public method race() -> Race {
            return this.mRace;
        }
        public method owner() -> PlayerData {
            PlayerData data = 0;
            if (this.mUnit != null){
                data = PlayerData.get(GetOwningPlayer(this.mUnit));
                return data;
            }
            return this.mOwner;
        }
        
        public static method create(PlayerData p) -> thistype {
            thistype this = 0;
            if (p.class() != PlayerData.CLASS_DEFENDER){
                Game.say("ERROR - " + p.nameColored() + " tried to create DefenderUnit but isn't CLASS_DEFENDER");
                return this;
            }
            this = thistype.allocate();
            this.mClass = p.class();
            this.mRace = PlayerData.CLASS_DEFENDER;
            this.mOwner = p;
            
            return this;
        }
		
		public method spawn(real x, real y, real rotation) -> unit {
            this.mUnit = CreateUnit(this.mOwner.player(), this.mOwner.race().widgetId(), x, y, rotation);
			return this.mUnit;
		}
    }
    
    public struct DefenderDeath {
        private static group shops = null;
        public static method visionGlitchBegin(){
            unit u = null;
            group g = CreateGroup();
            boolexpr b = Filter(function() -> boolean {
                return GetUnitAbilityLevel(GetFilterUnit(), 'Aall') > 0;
            });
            GroupEnumUnitsInRect(g, GetWorldBounds(), b);
            shops = CreateGroup();
            u = FirstOfGroup(g);
            while (u != null){
                UnitRemoveAbility(u, 'Aall'); // Remove "Shop Sharing"
                
                GroupRemoveUnit(g, u);
                GroupAddUnit(shops, u);
                u = FirstOfGroup(g);
            }
            u = null;
            DestroyBoolExpr(b);
            DestroyGroup(g);
            g = null;
            b = null;
        }
        
        public static method visionGlitchEnd(){
            unit u = null;
            if (shops == null){
                return;
            }
            u = FirstOfGroup(shops);
            while (u != null){
                UnitAddAbility(u, 'Aall'); // Add "Shop Sharing"
                
                GroupRemoveUnit(shops, u);
                u = FirstOfGroup(shops);
            }
            DestroyGroup(shops);
            shops = null;
            u = null;
        }
        public static method findTitanPlayer() -> PlayerData {
            PlayerDataArray list = PlayerData.withClass(PlayerData.CLASS_TITAN);
            PlayerData p = 0;
            integer i = 0;
            for (0 <= i < list.size()){
                p = list[i];
                // Found one...
                break;
            }
            list.destroy();
            return p;
        }
        public static method findMinionPlayer() -> PlayerData {
            PlayerDataArray list = PlayerData.withClass(PlayerData.CLASS_MINION);
            PlayerData p = 0;
            integer i = 0;
            for (0 <= i < list.size()){
                p = list[i];
                // Found one...
                break;
            }
            list.destroy();
            return p;
        }
        
        public static method onDeath(DefenderUnit u, unit killer){
            PlayerData p = u.owner();
            PlayerData k = PlayerData.get(GetOwningPlayer(killer));
            real x=GetUnitX(u.unit());
            real y=GetUnitY(u.unit());
            real q=GetUnitX(killer);
            real r=GetUnitY(killer);
            Unit minion = 0;
            
            // First up, ping the minimap to show everyone where the defender died.
            if (PlayerData.get(GetLocalPlayer()).isClass(PlayerData.CLASS_DEFENDER) ||
                PlayerData.get(GetLocalPlayer()).isClass(PlayerData.CLASS_OBSERVER)){
                PingMinimapEx(x, y, 10.00, 254, 0, 0, true);
            }
            else {
                PingMinimapEx(x, y, 10.00, 0, 255, 0, true);
            }
            
            if (k == 0 || 
                (k.class() != PlayerData.CLASS_TITAN &&
                k.class() != PlayerData.CLASS_MINION)){
                // Something went wrong, they were killed by something other than a titan
                // We're going to have problems spawning the minion... this may end with hilarious results!
                // Let's assume the killer is the first titan we find.
                Game.say("UnitManager.DefenderUnit.onDeath could not complete properly. The killing player was not of the right class.\n" +
                             "Please report this bug with the replay and time of occurance to one of the websites listed in the top-right corner.");
                k = thistype.findTitanPlayer();
                q = GetUnitX(k.unit().unit());
                r = GetUnitY(k.unit().unit());
                if (k == 0){
                    // Unable to find a titan, what the fuck happened?!
                    Game.say("No Titan's found... something has gone terribly wrong.");
                    Game.say("Now attempting to resolve the situation by finding another minion to copy...");
                    k = thistype.findMinionPlayer();
                    q = GetUnitX(k.unit().unit());
                    r = GetUnitY(k.unit().unit());
                    if (k == 0){
                        Game.say("Nope, no Titans or Minions... ignoring the death.");
                        p.setClass(PlayerData.CLASS_OBSERVER);
                        Game.checkVictory();
                        return;
                    }
                }
            }

            // Announce it
            Game.say(p.nameColored() + "|cff00bfff was killed by |r" + k.nameColored());
            PlaySoundBJ(gg_snd_Titan_BuilderKill);
            
            // Remove all player units apart from the killed unit
            SetUnitOwner(u.unit(), Player(PLAYER_NEUTRAL_PASSIVE), false);
			
			// Remove learned upgrades
			Upgrades.resetAllUpgradesForPlayer(p.player(), false);
			
            UnitManager.removePlayerUnits(p);
            SetUnitOwner(u.unit(), p.player(), true);
			
            
            // Remove corpse after 3 seconds
            GameTimer.newNamed(function(GameTimer t){
                Unit u = t.data();
                RemoveUnit(u.unit());
            }, "DefenderDeathRemoveCorpse").start(3.00).setData(u);
                        
            // W3MMD
            p.setDeaths(p.deaths() + 1);
            k.setKills(k.kills() + 1);
            
            // Track amount of Defender deaths for use in the ExperienceSystem.
            GameSettings.setInt("KILLED_DEFENDERS_COUNT", GameSettings.getInt("KILLED_DEFENDERS_COUNT") + 1);
            
            // Shop vision glitch!
            // Switched to being in Players.forceAlliances
            
            if (GameSettings.getBool("MINION_SPAWN_ALLOW_GRACE") &&
                Game.currentGameElapsed() <= GameSettings.getReal("MINION_SPAWN_GRACE_TIME")) {
                // Grace time!
                p.setClass(PlayerData.CLASS_OBSERVER);
                p.setRace(NullRace.instance());
                Game.say(p.nameColored() + "|cff00bfff has become an observer for dying before |r" +
                         "|cffff0000" + R2S(GameSettings.getReal("MINION_SPAWN_GRACE_TIME")) + "|r|cff00bfff seconds.|r");
                
                Game.say("|cff00bfffThe minion will spawn once the game has been running for more than the above time.|r");
                // But Neco, where is the minion supposed to come from?!
                // I'm glad you asked Timmy!
                
                MinionGracefulSpawn.begin(x, y, UnitManager.minionLevel);
                
                // Map Reveal is in the form of a fancy item later!
            }
            else {
                // Swap them over
                if (GameSettings.getBool("MINION_FORCE_OBS")) {
                    p.setClass(PlayerData.CLASS_OBSERVER);
                    p.setRace(NullRace.instance());
					minion = UnitManager.spawnMinion(k, q, r, UnitManager.minionLevel);
                }
                else {
                    p.setClass(PlayerData.CLASS_MINION);
                    p.setRace(k.race());
					// Spawn the minion
					minion = UnitManager.spawnMinion(p, q, r, UnitManager.minionLevel);
                }
                
                if (p.isLeaving() || p.hasLeft() ||
                    GameSettings.getBool("TITAN_AUTOPUNISH") ||
                    GameSettings.getBool("MINION_FORCE_OBS")){
                    k = thistype.findTitanPlayer();
                    if (k != 0) {
                        SetUnitOwner(minion.unit(), k.player(), true);
                    }
                }
                else {
                    if (GetLocalPlayer() == p.player()) {
                        ClearSelection();
                        SelectUnit(minion.unit(), true);
                    }
                }
            
                // Unpunish
                PunishmentCentre.update();
                
                // Reveal the map after a very short delay, in order to allow currently running nukes
                // to choose new targets
                GameTimer.newNamed(function(GameTimer t){
                    PlayerData k = t.data();
                    RevealMapForPlayer(k.player());
                }, "DefenderDeathMapReveal").start(0.2).setData(k);
            }

            if (p.isLeaving()){
                // They're gone now
                p.left();
            }
            
            // Set resources to 0, after 0.5 seconds too to prevent bugs
            p.setGold(0);
            p.setWood(0);
            GameTimer.newNamed(function(GameTimer t){
                PlayerData p = t.data();
                p.setGold(0);
                p.setWood(0);
            }, "DefenderDeathResourcesReset").start(0.5).setData(p);
            
            // Check if that was the last defender alive
            Game.checkVictory();
        }
    }
}

//! endzinc