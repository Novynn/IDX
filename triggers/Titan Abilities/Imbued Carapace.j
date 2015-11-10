//TESH.scrollpos=0
//TESH.alwaysfold=0
library ImbuedCarapace initializer init uses PolledWaitEx
    globals
        private integer array REGEN_ID
        private integer array ARMOR_ID
        
        private constant integer SPELL_ID   = 'A0E6'
        private constant integer BURROW_ID  = 'A0F7'
        
        private constant integer MANA_CHECK = 100
    endglobals
    
    private function LoadIds takes nothing returns nothing
        set REGEN_ID[1] = 'A0FK'
        set REGEN_ID[2] = 'A0GQ'
        set REGEN_ID[3] = 'A0GR'
        set ARMOR_ID[1] = 'A0FM'
        set ARMOR_ID[2] = 'A0GO'
        set ARMOR_ID[3] = 'A0GP'
    endfunction

    private function cond takes nothing returns boolean
        return(GetSpellAbilityId()==SPELL_ID)
    endfunction

    private function act takes nothing returns nothing
        local unit u=GetTriggerUnit()
        local integer i = GetUnitAbilityLevel(u, SPELL_ID)
        local integer index = 0
        
        call UnitAddAbility(u, ARMOR_ID[i])
        call UnitAddAbility(u, REGEN_ID[i])
        
        loop
            call PolledWaitEx(1)
            if (GetUnitAbilityLevel(u, ARMOR_ID[i]) < 1) or (GetUnitAbilityLevel(u, REGEN_ID[i]) < 1)  then
                set index = 1
            elseif (GetUnitState(u, UNIT_STATE_MANA) < MANA_CHECK) then
                set index = 1
            endif
            exitwhen index == 1
        endloop
        call UnitRemoveAbility(u, ARMOR_ID[i])
        call UnitRemoveAbility(u, REGEN_ID[i])
        
        call IssueImmediateOrder(u, "unimmolation")
        set u=null
    endfunction
    
    private function offcond takes nothing returns boolean
        return GetIssuedOrderId() == OrderId("unimmolation")
    endfunction

    private function offact takes nothing returns nothing
        local unit u=GetTriggerUnit()
        local integer i = GetUnitAbilityLevel(u, SPELL_ID)
        call UnitRemoveAbility(u, ARMOR_ID[i])
        call UnitRemoveAbility(u, REGEN_ID[i])
    endfunction
    
    private function autooffcond takes nothing returns boolean
        return ( GetSpellAbilityId() == BURROW_ID ) 
    endfunction

    private function autooffact takes nothing returns nothing
        local unit u=GetTriggerUnit()
        local integer i = GetUnitAbilityLevel(u, SPELL_ID)
        call UnitRemoveAbility(u, ARMOR_ID[i])
        call UnitRemoveAbility(u, REGEN_ID[i])
        call IssueImmediateOrder(GetTriggerUnit(), "unimmolation")
    endfunction

    private function init takes nothing returns nothing
        local integer i = 0
        local trigger t = CreateTrigger()
        local trigger t2 = CreateTrigger()
        local trigger t3 = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_CAST )
        call TriggerAddCondition( t, Condition( function cond ) )
        call TriggerAddAction( t, function act )
        
        call TriggerRegisterAnyUnitEventBJ( t2, EVENT_PLAYER_UNIT_ISSUED_ORDER )
        call TriggerAddCondition( t2, Condition( function offcond ) )
        call TriggerAddAction( t2, function offact )
        
        call TriggerRegisterAnyUnitEventBJ( t3, EVENT_PLAYER_UNIT_SPELL_FINISH )
        call TriggerAddCondition( t3, Condition( function autooffcond ) )
        call TriggerAddAction( t3, function autooffact )

        call LoadIds()
    endfunction
endlibrary