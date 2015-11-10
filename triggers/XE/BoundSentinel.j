//TESH.scrollpos=21
//TESH.alwaysfold=0
library BoundSentinel initializer init
//*************************************************
//* BoundSentinel
//* -------------
//*  Don't leave your units unsupervised, naughty
//* them may try to get out of the map bounds and
//* crash your game.
//*
//*  To implement, just get a vJass compiler and
//* copy this library/trigger to your map.
//*
//*************************************************

//==================================================

   //=========================================================================================
   globals
       private constant boolean ALLOW_OUTSIDE_PLAYABLE_MAP_AREA = true
       private real maxx
       private real maxy
       private real minx
       private real miny
   endglobals

   //=======================================================================
   private function dis takes nothing returns boolean
    local unit u=GetTriggerUnit()
    local real x=GetUnitX(u)
    local real y=GetUnitY(u)

       if(x>maxx) then
           set x=maxx
       elseif(x<minx) then
           set x=minx
       endif
       if(y>maxy) then
           set y=maxy
       elseif(y<miny) then
           set y=miny
       endif
       call SetUnitX(u,x)
       call SetUnitY(u,y)
    set u=null
    return false
   endfunction

   private function init takes nothing returns nothing
    local trigger t = CreateTrigger()
    local region  r = CreateRegion()
    local rect map
    local rect rc

       if ALLOW_OUTSIDE_PLAYABLE_MAP_AREA then
          set map = GetWorldBounds()
       else
          set map = bj_mapInitialPlayableArea
       endif

       set minx = GetRectMinX(map)
       set miny = GetRectMinY(map)
       set maxx = GetRectMaxX(map)
       set maxy = GetRectMaxY(map)
       set rc=Rect(minx,miny,maxx,maxy)
       call RegionAddRect(r, rc)
       call RemoveRect(rc)
       if ALLOW_OUTSIDE_PLAYABLE_MAP_AREA then
          call RemoveRect(map)
       endif

       call TriggerRegisterLeaveRegion(t,r, null)
       call TriggerAddCondition(t, Condition(function dis))

    set rc=null
    set map = null
   endfunction
endlibrary

