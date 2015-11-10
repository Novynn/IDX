//TESH.scrollpos=0
//TESH.alwaysfold=0
library Earthquake initializer init
    private function cond takes nothing returns boolean
        return(GetSpellAbilityId()=='A0MO')
    endfunction
    
    private function act takes nothing returns nothing
        local location l=GetSpellTargetLoc()
        local unit u=GetTriggerUnit()
        local player p=GetOwningPlayer(u)
        local unit d=CreateUnitAtLoc(p,'h047',l,0)
        call TerrainDeformationRippleBJ(12.,true,l,512.,512.,64,1,128.)
        call UnitAddAbility(d,'A0MQ')
        call UnitAddAbility(d,'A0MP')
        call UnitApplyTimedLife(d,'BTLF',12)
        call RemoveLocation(l)
        set l=null
        set u=null
        set p=null
        set d=null
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t,Condition(function cond))
        call TriggerAddAction(t,function act)
    endfunction
endlibrary