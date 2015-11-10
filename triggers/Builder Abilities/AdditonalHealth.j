//TESH.scrollpos=17
//TESH.alwaysfold=0
//! zinc

library AdditonalHealth requires GT, UnitManager {
    private function upgradeDefender(PlayerData p) {
        group g = CreateGroup();
        
        GroupEnumUnitsOfPlayer(g, p.player(), Filter(function() -> boolean {
            PlayerData p = PlayerData.get(GetOwningPlayer(GetFilterUnit()));
            return p.unit().unit() == GetFilterUnit();
        }));
        
        ForGroup(g, function() {
            unit u = GetEnumUnit();
            UnitAddItem(u, CreateItem('I04V', 0.0, 0.0));
            u = null;
        });
        
        DestroyGroup(g);
        g = null;
    }
    
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetResearchingUnit();
            player p = GetOwningPlayer(u);
            integer id = GetResearched();
            integer level = GetPlayerTechCount(p, id, true);
            PlayerData q = 0;

            if (id == 'R04K' || id == 'R03B') {
                q = PlayerData.get(p);
                upgradeDefender(q);
                if (id == 'R04K' && level > 3){ // Next Upgrade
                    SetPlayerTechMaxAllowed(p, 'R03B', -1);
                }
            }
            
            u = null;
            p = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc