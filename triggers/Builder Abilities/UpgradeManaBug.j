//TESH.scrollpos=3
//TESH.alwaysfold=0
//! zinc

// TODO(neco): Fix this in the case that researches effect maximum mana.

library UpgradeManaFix requires UnitMaxState, TableBC {
    private struct TempUnitData {
        unit u = null;
    }
    
    private struct UpgradeManaFix {
        private static Table unitTable = 0;
        
        public static method register(integer id) {
            unit u = null;
            real mana = 0.0;
            u = CreateUnit(Player(15), id, 0, 0, 0);
            mana = GetUnitState(u, UNIT_STATE_MAX_MANA);
            RemoveUnit(u);

            thistype.unitTable[id] = R2I(mana);
        }
        
        private static method fix(unit u){
            integer id = GetUnitTypeId(u);
            real mana = I2R(thistype.unitTable[id]);
            Upgrades.removeUpgrades(u);
            SetUnitMaxState(u, UNIT_STATE_MAX_MANA, mana);
            Upgrades.applyUpgrades(u);
        }
        
        public static method registerAll() {
            // Draenei Towers
            thistype.register('h03V');
            thistype.register('o02B');
            thistype.register('o02D');
            thistype.register('o02C');
            // Draenei Walls
            thistype.register('h03X');
            thistype.register('u014');
            // Dryad Towers
            thistype.register('o032');
            thistype.register('o033');
            thistype.register('o034');
            thistype.register('o035');
            thistype.register('o036');
            thistype.register('o037');
            thistype.register('o038');
            thistype.register('o039');
            thistype.register('o03A');
            thistype.register('o03B');
        }
        
        public static method setup(){
            trigger t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_CANCEL);
            TriggerAddAction(t, function(){
                unit u = GetTriggerUnit();
                integer id = GetUnitTypeId(u);
                if (thistype.unitTable.has(id)){
                    thistype.fix(u);
                }
            });
            
            t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_FINISH);
            TriggerAddAction(t, function(){
                unit u = GetTriggerUnit();
                integer id = GetUnitTypeId(u);
                TempUnitData d = TempUnitData.create();
                if (thistype.unitTable.has(id)){
                    d.u = u;
                    // This should run after the Upgrade System deals with it, right?
                    GameTimer.new(function(GameTimer t) {
                        TempUnitData d = TempUnitData(t.data());
                        if (d != 0) {
                            thistype.fix(d.u);
                            d.destroy();
                        }
                    }).start(0.0).setData(d);
                }
            });
            
            thistype.unitTable = Table.create();
            thistype.registerAll();

            t = null;
        }
    }
    private function onInit(){
        UpgradeManaFix.setup();
    }
}

//! endzinc