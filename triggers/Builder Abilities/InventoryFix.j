//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library InventoryFix requires GT, UnitManager {
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetResearchingUnit();
            player p = GetOwningPlayer(u);
            integer id = GetResearched();
            PlayerData q = 0;
            integer level = GetPlayerTechCount(p, id, true);
            
            debug {BJDebugMsg("Research complete!");}

            if (id == 'R025'){ // Inventory Upgrade
                debug {BJDebugMsg("was inven!");}
                q = PlayerData.get(p);
                if (q != 0) {
                    debug {BJDebugMsg("have player: " + q.name());}
                    u = q.unit().unit();
                    if (u != null) {
                        debug {BJDebugMsg("have unit: " + GetUnitName(u));}
                        SetUnitAbilityLevel(u, 'A013', level + 1);
                        debug {BJDebugMsg("set level to:" + I2S(level + 1));}
                    }
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