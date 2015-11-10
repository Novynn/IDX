//TESH.scrollpos=154
//TESH.alwaysfold=0
//! zinc

library RadonTowerModules requires GT {
    private struct RadonTowerModules {
        private static constant integer RADON_INVENTORY = 'A00U';

        private static constant integer RADON_MAGIC_MODULE = 'I03E';
        private static constant integer RADON_FROST_MODULE = 'I03G';
        private static constant integer RADON_RAPID_MODULE = 'I03H';
        private static constant integer RADON_OVERLOAD_MODULE = 'I03F';
        private static constant integer RADON_TURTLE_MODULE = 'I00Q';
        
        private static constant integer RADON_TOWER_ENHANCEMENT_ID = 'A07W';
        
        private static method getRadonLevel(unit u) -> integer {
            integer id = GetUnitTypeId(u);
            if (id == 'h01H') return 0;
            if (id == 'h01I') return 1;
            if (id == 'h01J') return 2;
            if (id == 'h01K') return 3;
            return -1;
        }
        
        private static method addOverload(unit u, integer overloadId) {
            UnitAddAbility(u, overloadId);
            SetUnitAbilityLevel(u, overloadId, 2);
            IssueImmediateOrder(u, "roar");
            SetUnitAbilityLevel(u, overloadId, 1);
        }
        
        private static method addModule(unit u, integer mod) -> boolean {
            integer id = GetUnitTypeId(u);
            integer level = thistype.getRadonLevel(u);
            if (mod == thistype.RADON_MAGIC_MODULE){
                if (level == 1) UnitAddAbility(u, 'A05J');
                if (level == 2) UnitAddAbility(u, 'A07U');
                if (level == 3) UnitAddAbility(u, 'A07V');
                UnitAddAbility(u, thistype.RADON_TOWER_ENHANCEMENT_ID);
                
                SetUnitVertexColor(u, 255, 255, 255, 255);
                return true;
            }
            if (mod == thistype.RADON_FROST_MODULE){
                if (level == 1) UnitAddAbility(u, 'A05E');
                if (level == 2) UnitAddAbility(u, 'A05F');
                if (level == 3) UnitAddAbility(u, 'A05G');
                UnitAddAbility(u, thistype.RADON_TOWER_ENHANCEMENT_ID);
                
                UnitAddAbility(u, 'A010'); // Attack Damage +10
                SetUnitVertexColor(u, 0, 50, 255, 255);
                return true;
            }
            if (mod == thistype.RADON_RAPID_MODULE){
                UnitAddAbility(u, 'A011');
                UnitAddAbility(u, 'A03U');// Rapid Missile
                UnitAddAbility(u, thistype.RADON_TOWER_ENHANCEMENT_ID);
                SetUnitVertexColor(u, 255, 255, 0, 255);
                return true;
            }
            if (mod == thistype.RADON_OVERLOAD_MODULE){
                if (level == 1) thistype.addOverload(u, 'A05A');
                if (level == 2) thistype.addOverload(u, 'A05B');
                if (level == 3) thistype.addOverload(u, 'A05C');
                UnitAddAbility(u, thistype.RADON_TOWER_ENHANCEMENT_ID);
                UnitAddAbility(u, 'A00Y'); // Attack Damage +10 + Overload Missile
                
                SetUnitVertexColor(u, 255, 0, 0, 255);
                return true;
            }
            if (mod == thistype.RADON_TURTLE_MODULE){
                UnitAddAbility(u, 'A03V');
                return true;
            }
            return false;
        }
        
        private static method removeModule(unit u, integer mod){
            integer id = GetUnitTypeId(u);
            integer level = thistype.getRadonLevel(u);
            if (mod == thistype.RADON_MAGIC_MODULE){
                if (level == 1) UnitRemoveAbility(u, 'A05J');
                if (level == 2) UnitRemoveAbility(u, 'A07U');
                if (level == 3) UnitRemoveAbility(u, 'A07V');
                UnitRemoveAbility(u, thistype.RADON_TOWER_ENHANCEMENT_ID);
            }
            if (mod == thistype.RADON_FROST_MODULE){
                if (level == 1) UnitRemoveAbility(u, 'A05E');
                if (level == 2) UnitRemoveAbility(u, 'A05F');
                if (level == 3) UnitRemoveAbility(u, 'A05G');
                UnitRemoveAbility(u, 'A010'); // Attack Damage +10
                UnitRemoveAbility(u, thistype.RADON_TOWER_ENHANCEMENT_ID);
            }
            if (mod == thistype.RADON_RAPID_MODULE){
                UnitRemoveAbility(u, 'A011');
                UnitRemoveAbility(u, 'A03U');// Rapid Missile
                UnitRemoveAbility(u, thistype.RADON_TOWER_ENHANCEMENT_ID);
            }
            if (mod == thistype.RADON_OVERLOAD_MODULE){
                if (level == 1) UnitRemoveAbility(u, 'A05A');
                if (level == 2) UnitRemoveAbility(u, 'A05B');
                if (level == 3) UnitRemoveAbility(u, 'A05C');
                UnitRemoveAbility(u, 'A00Y'); // Attack Damage +10 + Overload Missile
                UnitRemoveAbility(u, thistype.RADON_TOWER_ENHANCEMENT_ID);
            }
            if (mod == thistype.RADON_TURTLE_MODULE){
                UnitRemoveAbility(u, 'A03V');
            }

            SetUnitVertexColor(u, 0, 255, 0, 255);
        }
    
        private static method onAcquire(){
            item i = GetManipulatedItem();
            unit u = GetManipulatingUnit();
            integer id = GetItemTypeId(i);
            
            if (!thistype.addModule(u, id)){
                SetItemPosition(i, GetUnitX(u), GetUnitY(u));
            }

            i = null;
            u = null;
        }
        
        private static method onDrop(){
            item it = GetManipulatedItem();
            unit u = GetManipulatingUnit();
            integer id = GetItemTypeId(it);

            thistype.removeModule(u, id);

            u = null;
            it = null;
        }
        
        private static method onUpgrade(){
            unit u = GetTriggerUnit();
            item it = UnitItemInSlot(u, 0);
            
            if (it != null && !thistype.addModule(u, GetItemTypeId(it))){
                SetItemPosition(it, GetUnitX(u), GetUnitY(u));
            }
            
            u = null;
            it = null;
        }
        
        private static method onDeploy() {
            unit u = GetTriggerUnit();
            unit v = GetSpellTargetUnit();
            integer id = GetSpellAbilityId();
            item it = null;
            integer i = 0;
            
            if (id == 'A03R') { // Frost
                id = 'I03G';
            }
            else if (id == 'A03S') { // Magic
                id = 'I03E';
            }
            else if (id == 'A03W') { // Overload
                id = 'I03F';
            }
            else if (id == 'A03X') { // Rapid
                id = 'I03H';
            }
            else {
                id = 0;
            }
            
            if (id != 0) {
                for (6 > i >= 0) {
                    it = UnitItemInSlot(u, i);
                    if (GetItemTypeId(it) == id) {
                        UnitAddItem(v, it);
                        break;
                    }
                }
            }
            
            it = null;
            u = null;
            v = null;
        }
    
        private static method onInit(){
            trigger t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM);
            TriggerAddCondition(t, function() -> boolean {
                if (GetUnitAbilityLevel(GetManipulatingUnit(),
                                        thistype.RADON_INVENTORY) == 0) return false;
                thistype.onAcquire();
                return false;
            });
            t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DROP_ITEM);
            TriggerAddCondition(t, function() -> boolean {
                if (GetUnitAbilityLevel(GetManipulatingUnit(),
                                        thistype.RADON_INVENTORY) == 0) return false;
                thistype.onDrop();
                return false;
            });
            t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH);
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_FINISH);
            TriggerAddCondition(t, function() -> boolean {
                if (GetUnitAbilityLevel(GetTriggerUnit(),
                                        thistype.RADON_INVENTORY) == 0) return false;
                thistype.onUpgrade();
                return false;
            });
            t = CreateTrigger();
            //GT_RegisterItemUsedEvent(t, 'I03G');
            //GT_RegisterItemUsedEvent(t, 'I03E');
            //GT_RegisterItemUsedEvent(t, 'I03F');
            //GT_RegisterItemUsedEvent(t, 'I03H');
            GT_RegisterStartsEffectEvent(t, 'A03R');
            GT_RegisterStartsEffectEvent(t, 'A03S');
            GT_RegisterStartsEffectEvent(t, 'A03W');
            GT_RegisterStartsEffectEvent(t, 'A03X');
            TriggerAddCondition(t, function() -> boolean {
                thistype.onDeploy();
                return false;
            });
            t = null;
        }
    }
}

//! endzinc