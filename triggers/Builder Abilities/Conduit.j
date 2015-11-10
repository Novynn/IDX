//TESH.scrollpos=139
//TESH.alwaysfold=0
//! zinc

library MorphlingEnergyTransfer requires GT, Table, AIDS {
    private struct PulseTower {
        private static constant integer ATTACK_BONUS_ID = 'A01D';
        private static Table pulseLookupTable;
        private unit tower = null;
        private group conduits = null;
        private static Table lightningTable;
        private integer lightningCount = 0;
        
        method connect(unit u) {
            thistype currTower = thistype.getTowerFromConduit(u);
            if (currTower != 0) {
                currTower.disconnect(u);
            }
            
            thistype.pulseLookupTable[GetUnitIndex(u)] = this;
            
            GroupAddUnit(this.conduits, u);
            thistype.lightningTable.lightning[GetUnitIndex(u)] = AddLightning("LEAS", true,
                                                                GetUnitX(u), GetUnitY(u),
                                                                GetUnitX(this.tower), GetUnitY(this.tower));
            this.update();
        }
        
        method getConnectedConduits() -> integer {
            return CountUnitsInGroup(this.conduits);
        }
        
        method disconnect(unit u) {
            integer id = 0;
            if (!IsUnitInGroup(u, this.conduits)) {
                return;
            }
            id = GetUnitIndex(u);
            DestroyLightning(thistype.lightningTable.lightning[id]);
            thistype.lightningTable.remove(id);
            thistype.pulseLookupTable.remove(id);
            GroupRemoveUnit(this.conduits, u);
            this.update();
        }
        
        public method update() {
            integer count = this.getConnectedConduits();
            BJDebugMsg("Current # of connected conduits: " + I2S(count));
            if (count > 0) {
                SetUnitAnimation(this.tower, "work");
                UnitAddAbility(this.tower, thistype.ATTACK_BONUS_ID);
                SetUnitAbilityLevel(this.tower, thistype.ATTACK_BONUS_ID, count);
            }
            else {
                SetUnitAnimation(this.tower, "stand");
                UnitRemoveAbility(this.tower, thistype.ATTACK_BONUS_ID);
            }
        }
        
        // Cleanup!
        private method onDestroy() {
            unit u = FirstOfGroup(this.conduits);
            while (u != null) {
                this.disconnect(u);
                GroupRemoveUnit(this.conduits, u);
                u = FirstOfGroup(this.conduits);
            }
            thistype.pulseLookupTable.remove(GetUnitIndex(this.tower));
            DestroyGroup(this.conduits);
            this.conduits = null;
            this.tower = null;
        }
        
        public static method create(unit u) -> thistype {
            thistype this = thistype.allocate();
            this.conduits = CreateGroup();
            this.tower = u;
            thistype.pulseLookupTable[GetUnitIndex(u)] = this;
            return this;
        }
        
        public static method getTowerFromConduit(unit u) -> PulseTower {
            integer id = GetUnitIndex(u);
            thistype tower = 0;
            if (thistype.pulseLookupTable.has(id)) {
                tower = thistype.pulseLookupTable[id];
            }
            return tower;
        }
        
        public static method getTower(unit u) -> PulseTower {
            return thistype.getTowerFromConduit(u);
        }
        
        private static method onConduitDeath() {
            unit u = GetDyingUnit();
            thistype tower = thistype.getTowerFromConduit(u);
            if (tower != 0) {
                tower.disconnect(u);
            }
            u = null;
        }
        
        private static method onTowerDeath() {
            unit u = GetDyingUnit();
            thistype tower = thistype.getTower(u);
            if (tower != 0) {
                tower.destroy();
            }
            u = null;
        }
        
        private static method onInit() {
            trigger t = CreateTrigger();
            GT_RegisterUnitDiesEvent(t, 'o00Z');
            GT_RegisterUnitDiesEvent(t, 'o01A');
            GT_RegisterUnitDiesEvent(t, 'o01B');
            GT_RegisterUnitDiesEvent(t, 'o01C');
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onConduitDeath();
                return false;
            }));
            t = CreateTrigger();
            GT_RegisterUnitDiesEvent(t, 'o018');
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onTowerDeath();
                return false;
            }));
            t = null;
            
            thistype.pulseLookupTable = Table.create();
            thistype.lightningTable = Table.create();
        }
    }
    
    private struct MorphlingEnergyTransfer {
    
    
        private static method onInit() {
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, 'A018');
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit u = GetTriggerUnit();
                unit t = GetSpellTargetUnit();
                PulseTower tower = PulseTower.getTower(t);
                
                if (tower != 0) {
                    tower.connect(u);
                }
                
                u = null;
                t = null;
                return false;
            }));
            t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH);
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit u = GetConstructedStructure();
                PulseTower.create(u);
                u = null;
                return false;
            }));
            t = null;
        }
    }


}

//! endzinc