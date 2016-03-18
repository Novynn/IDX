//TESH.scrollpos=6
//TESH.alwaysfold=0
//! zinc

library Detected requires Table, GameTimer, Upgrades {
    private struct Detected extends array {
        private static method isUnitVisibleToEnemies(unit u) -> boolean {
            PlayerData p = PlayerData.get(GetOwningPlayer(u));
            PlayerData q = 0;
            integer i = 0;
            for (0 <= i < 12) {
                if (PlayerData.hasById(i)) {
                    q = PlayerData[i];
                    if (!PlayerData.classLikes(p.class(), q.class()) &&
                        IsUnitVisible(u, q.player())) {
                        return true;
                    }
                }
            }
            
            return false;
        }
        
        private static method hasUpgrade(player p) -> boolean {
            return Upgrades.playerHasUpgradeLevel(p, 'q259');
            //return GetPlayerTechResearched(p, 'R02W', true);
        }
        
        private static method tick() {
            group g = CreateGroup();
            unit u = null;
            xecast cast = xecast.createBasicA('A02T', OrderId("unholyfrenzy"), null);
            
            GroupEnumUnitsInRect(g, GetWorldBounds(), Filter(function() -> boolean {
                return GetUnitAbilityLevel(GetFilterUnit(), 'A02P') > 0 &&
                       UnitAlive(GetFilterUnit()) &&
                       hasUpgrade(GetOwningPlayer(GetFilterUnit()));
            }));
            
            u = FirstOfGroup(g);
            while (u != null) {
                if (thistype.isUnitVisibleToEnemies(u)){
                    if (GetUnitAbilityLevel(u, 'B014') == 0) {
                        // Doesn't have detected buff
                        cast.owningplayer = GetOwningPlayer(u);
                        cast.castOnTarget(u);
                    }
                }
                else {
                    if (GetUnitAbilityLevel(u, 'B014') > 0) {
                        UnitRemoveAbility(u, 'B014');
                    }
                }
                
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            DestroyGroup(g);
            g = null;
            u = null;
            
            cast.destroy();
        }
        
        public static method setup() {
            trigger t = CreateTrigger();
            TriggerRegisterTimerEvent(t, 0.5, true);
            TriggerAddAction(t, static method Detected.tick);
        }
    }
    
    private function onInit() {
        Detected.setup.execute();
    }
}

//! endzinc