//TESH.scrollpos=28
//TESH.alwaysfold=0
scope Tranquility initializer init
    globals
        private constant integer TRANQ_BUFF_ID = 'B04G'
        private constant integer TRANQ_TOWR_ID = 'o031'
        private constant integer TRANQ_ABIL_ID = 'A0LT'
    endglobals

    private function invis_act takes nothing returns nothing
        local group g=CreateGroup()
        local unit u
        call GroupEnumUnitsInRect(g,bj_mapInitialPlayableArea,null)
        set u=FirstOfGroup(g)
        loop
            exitwhen u==null
            
            if (GetUnitAbilityLevel(u,TRANQ_BUFF_ID)>0) and (GetUnitAbilityLevel(u,TRANQ_ABIL_ID)<1) then
                call UnitAddAbility(u,TRANQ_ABIL_ID)
            elseif (GetUnitAbilityLevel(u,TRANQ_BUFF_ID)<1) and (GetUnitAbilityLevel(u,TRANQ_ABIL_ID)>0) then
                call UnitRemoveAbility(u,TRANQ_ABIL_ID)
            endif
            call GroupRemoveUnit(g,u)
            set u=FirstOfGroup(g)
        endloop
        call DestroyGroup(g)
        set u=null
        set g=null
    endfunction
    
    private function item_cond takes nothing returns boolean  
        return(GetUnitAbilityLevel(GetTriggerUnit(), 'B04D') > 0) and (IsUnitEnemy(GetAttacker(), GetOwningPlayer(GetTriggerUnit())))
    endfunction
    
    private function item_act takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local player p = GetOwningPlayer(u)
        local unit d = CreateUnit(p, 'h047', GetUnitX(u), GetUnitY(u), 0.00)
        call UnitApplyTimedLife( d, 'BTLF', 2.00 )
        call UnitAddAbility(d, 'A0LU')
        call IssueTargetOrder(d, "invisibility", u)
        set d = null
        set u = null
        set p = null
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local trigger r = CreateTrigger()
        call TriggerRegisterTimerEvent(t ,1.00,true)
        call TriggerAddAction(t ,function invis_act)
        
        call TriggerRegisterAnyUnitEventBJ(r, EVENT_PLAYER_UNIT_ATTACKED)
        call TriggerAddCondition(r, Condition(function item_cond))
        call TriggerAddAction(r, function item_act)
    endfunction
endscope

