//TESH.scrollpos=0
//TESH.alwaysfold=0
library Tremor initializer init
    private function cond takes nothing returns boolean
        return(GetSpellAbilityId()=='A0MC')
    endfunction
    
    private function act takes nothing returns nothing
        local unit u=GetTriggerUnit()
        local location l=GetUnitLoc(u)
        local integer i=0
        local unit d
        PlaySoundBJ(gg_snd_TitanEarthquake);
        loop
            exitwhen i>8
            set d=CreateUnitAtLoc(GetOwningPlayer(u),'u018',PolarProjectionBJ(l,GetRandomReal(0,5000),GetRandomReal(0,360)),0)
            call UnitApplyTimedLife(d,'BTLF',15)
            set i=i+1
        endloop
        call RemoveLocation(l)
        set l=null
        set u=null
        set d=null
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t,Condition(function cond))
        call TriggerAddAction(t,function act)
    endfunction
endlibrary