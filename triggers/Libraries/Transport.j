//TESH.scrollpos=186
//TESH.alwaysfold=0
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  ~~    Transport     ~~    By Jesus4Lyf    ~~    Version 1.02    ~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//  What is Transport?
//         - Transport provides Events for transport in Warcraft III.
//         - It also tracks what transportation unit a unit is in, and
//           can iterate over all units a transport unit is carrying.
//
//  Functions:
//         - Transport_RegisterLoadEvent(trigger)
//           Registers when a unit enters a transport. Within this:
//            - Use GetTriggerUnit() to refer to the passenger.
//            - Use GetTransportUnit() to refer to the transport.
//
//         - Transport_RegisterUnloadEvent(trigger)
//           Registers when a unit leaves a transport. Within this:
//            - Use GetUnloadedUnit() to refer to the passenger.
//            - Use GetUnloadingTransport() to refer to the transport.
//
//         - Transport_GetCarrier(passenger unit)
//           Returns the transport the unit has currently boarded.
//
//         - Transport_ForPassengers(transport unit, callback function)
//           Calls a ForGroup using the units on board as the group. Within this:
//            - Use GetEnumUnit() to refer to each unit on board.
//
//         - Transport_CountPassengers(transport unit)
//           Returns the number of units on board a transport unit.
//
//  Details:
//         - Unloading is detected by setting a unit's position to outside
//           the map when it is loaded into transport, and then registering when
//           it enters the map again, meaning it was unloaded.
//
//         - The purpose of the Load event is that it fires when the unit's x/y
//           coordinates are correct, but the state of Transport has been updated
//           (so Transport_GetCarrier and Transport_ForPassengers will work correctly).
//
//  How to import:
//         - Create a trigger named Transport.
//         - Convert it to custom text and replace the whole trigger text with this.
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library Transport uses AIDS, Event, optional Recycle, optional GroupUtils
    globals
        private Event LoadEvent
        private Event UnloadEvent
        private real MAX_X
        private real MAX_Y
    endglobals
    public function RegisterLoadEvent takes trigger t returns EventReg
        return LoadEvent.register(t)
    endfunction
    public function RegisterUnloadEvent takes trigger t returns EventReg
        return UnloadEvent.register(t)
    endfunction
    
    // Group recycling stuff, if available.
    //! textmacro Transport__GetGroup takes VAR
        static if LIBRARY_Recycle then
            call Group.release($VAR$)
        elseif LIBRARY_GroupUtils then
            call ReleaseGroup($VAR$)
        else
            call DestroyGroup($VAR$) // never had enums called.
            set $VAR$=null
        endif
    //! endtextmacro
    //! textmacro Transport__ReleaseGroup takes VAR
        static if LIBRARY_Recycle then
            set $VAR$=Group.get()
        elseif LIBRARY_GroupUtils then
            set $VAR$=NewGroup()
        else
            set $VAR$=CreateGroup()
        endif
    //! endtextmacro
    
    // Data for system
    private struct Data extends array
        // Transport
        group carrying
        integer passengerCount
        // Passenger
        thistype carriedBy
        private static method unloadEnum takes nothing returns nothing
            set thistype[GetEnumUnit()].carriedBy=thistype(0)
        endmethod
        private method AIDS_onDestroy takes nothing returns nothing
            // Transport
            if this.carrying!=null then
                call ForGroup(this.carrying,function thistype.unloadEnum)
                //! runtextmacro Transport__ReleaseGroup("this.carrying")
            endif
            set this.passengerCount=0
            
            // Passenger
            set this.carriedBy=thistype(0)
        endmethod
        //! runtextmacro AIDS()
    endstruct
    public function GetCarrier takes unit passenger returns unit
        return Data[passenger].carriedBy.unit
    endfunction
    public function ForPassengers takes unit transport, code callback returns nothing
        call ForGroup(Data[transport].carrying,callback)
    endfunction
    public function CountPassengers takes unit transport returns integer
        return Data[transport].passengerCount
    endfunction
    
    // Stack for event responses, with recursion safety.
    private module Stack
        static thistype top=0 // thistype(0) throws a syntax error, does not compile
        static method increment takes nothing returns nothing
            set thistype.top=thistype(thistype.top+1)
        endmethod
        static method decrement takes nothing returns nothing
            set thistype.top=thistype(thistype.top-1)
        endmethod
    endmodule
    
    // Event responses for UnloadEvent.
    private struct UnloadStack extends array
        implement Stack
        unit transport
        unit passenger
    endstruct
    function GetUnloadingTransport takes nothing returns unit
        return UnloadStack.top.transport
    endfunction
    function GetUnloadedUnit takes nothing returns unit
        return UnloadStack.top.passenger
    endfunction
    
    // When a unit enters world boundaries...
    globals//locals
        private unit EnteringUnit
        private Data EnteringData
        private Data EnteringTransportData
    endglobals
    private function OnEnterWorld takes nothing returns boolean
        set EnteringUnit=GetFilterUnit()
        set EnteringData=Data[EnteringUnit]
        
        if EnteringData.carriedBy!=null then // Unit was unloaded.
            
            call UnloadStack.increment()
            set EnteringTransportData=EnteringData.carriedBy
            set UnloadStack.top.transport=EnteringTransportData.unit
            set UnloadStack.top.passenger=EnteringUnit
            
            call GroupRemoveUnit(EnteringTransportData.carrying,EnteringUnit)
            set EnteringTransportData.passengerCount=EnteringTransportData.passengerCount-1
            set EnteringData.carriedBy=Data(0)
            
            // Global locals unsafe from this point on
            call UnloadEvent.fire()
            call UnloadStack.decrement()
            
        endif
        return false
    endfunction
    
    // When a unit enters a transport...
    globals//locals
        private unit LoadedUnit
        private Data LoadingData
    endglobals
    private function OnLoad takes nothing returns boolean
        set LoadedUnit=GetTriggerUnit()
        set LoadingData=Data[GetTransportUnit()]
        if LoadingData.carrying==null then
            //! runtextmacro Transport__GetGroup("LoadingData.carrying")
        endif
        call GroupAddUnit(LoadingData.carrying,LoadedUnit)
        set LoadingData.passengerCount=LoadingData.passengerCount+1
        set Data[LoadedUnit].carriedBy=LoadingData
        call LoadEvent.fire()
        //call SetUnitPosition(LoadedUnit,MAX_X,MAX_Y)
        call SetUnitX(LoadedUnit,MAX_X)
        call SetUnitY(LoadedUnit,MAX_Y)
        return false
    endfunction
    
    // Init.
    private struct Initializer extends array
        private static method onInit takes nothing returns nothing
            local trigger t
            local rect r=GetWorldBounds()
            local region g=CreateRegion()
            call RegionAddRect(g,r)
            set MAX_X=GetRectMaxX(r)
            set MAX_Y=GetRectMaxY(r)
            call RemoveRect(r)
            set r=null
            
            set LoadEvent=Event.create()
            set UnloadEvent=Event.create()
            
            // On transport load.
            set t=CreateTrigger()
            call TriggerAddCondition(t,Filter(function OnLoad))
            call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_LOADED)
            
            // On enter world.
            // Reuse previous trigger:
            call TriggerRegisterEnterRegion(t,g,Filter(function OnEnterWorld))
            
            set t=null
            set g=null
        endmethod
    endstruct
endlibrary