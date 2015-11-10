//TESH.scrollpos=61
//TESH.alwaysfold=0
library LightningUtils requires TimerUtils, GetLocationZEx

//******************************************************************************
//* Author: Fledermaus
//* 
//* LightningUtils is a library that was designed to give users more control
//* over the handle type lightning.
//* There are two "flavours" which offer different levels of speed and safety.
//*   - "Blue" is the default and the safest. It allows you to use all the
//*     lightning natives by hooking them into the system. However due to the
//*     use of hooks, it is slower.
//*   - "Red" is faster because it doesn't use hooks but is less safe and more
//*     restricted. There are a number of natives you should not call if you are
//*     using the red flavour. I will tell you more about this later.
//*
//* There are several configuration constants that you can alter however you
//* like.
//*   SUPPORT_HOOKING determines which "flavour" the library is. Set it to true
//*                   to use the safer but slower "blue" flavour or to false
//*                   the faster, more restricting "red" flavour.
//*   TIMEOUT is the timer speed for updating the position of lightning and
//*           fading out when destroyed.
//*   HEIGHT_OFFSET is added to the height of ground units that lightning is
//*                 connected to.
//*   DEFAULT_FADE_TIME is how long lightning will take to fade out by default.
//* 
//******************************************************************************
//* List of functions:
//* 
//*     function CreateLightningBetweenPoints takes string codeName, ...
//*     ... boolean visibility, real x1, real y1, real z1, real x2, real y2, ...
//*     ... real z2 returns lightning
//*     function CreateLightningBetweenUnits takes string codeName, ...
//*     ... boolean visibility, unit u1, unit u2 returns lightning
//*     function CreateLightningBetweenPointAndUnit takes string codeName, ...
//*     ... boolean visibility, real x, real y, real z, unit u returns lightning
//*     function CreateLightningBetweenUnitAndPoint takes string codeName, 
//*     ... boolean visibility, unit u, real x, real y, real z returns lightning
//* 
//* Their names should be pretty self-explanatory, they create lightning from
//* the first target (StartPoint or StartUnit) to the second target(EndPoint or 
//* EndUnit).
//* Some things to note:
//*   - The first targeting type in the function's name is either the StartUnit
//*     or StartPoint and the last targeting type is the EndUnit or EndPoint,
//*     depending on which create function you call. e.g. for
//*     call CreateLightningBetweenPointAndUnit(..., 10, 50, 50, someUnit)
//*     the point 10, 50 would be the StartPoint and someUnit would be the
//*     EndUnit.
//*   - You can change a lightning's start or end point/unit after it has
//*     been created (more on this later).
//*   - If you create a lightning with a unit as one (or both) of the targets,
//*     it will automatically follow the unit(s).
//*   - Lightning will usually flow from the StartPoint/Unit to the
//*     EndPoint/Unit but there are a few exceptions:
//*       + Drain Life, Drain Life and Mana and Drain Mana all flow from the
//*         EndPoint/Unit to the StartPoint/Unit.
//*       + The net on Aerial Shackles appears at the EndPoint/Unit.
//* 
//* Once you've created some lightning, there are various things you can do to
//* it:
//* 
//*     function SetLightningStartPoint takes lightning l, real x,  real y, real z returns boolean
//*     function SetLightningStartUnit takes lightning l, unit u returns boolean
//*     function SetLightningEndPoint takes lightning l, real x, real y, real z returns boolean
//*     function SetLightningEndUnit takes lightning l, unit u returns boolean
//* 
//* These functions are used to change the start or end target of a lightning
//* If you created a lightning between a unit and a point, you can also use
//* these functions to change it so that it will target two units or two points.
//* Again, any lightning with one of its targets as a unit will automatically
//* follow the unit(s).
//* 
//*     function SetLightningColour takes lightning l, real r, real g, real b, real a returns boolean
//* 
//* Used to set the colour of a lightning. Should only use values between
//* 0.00 and 1.00.
//* 
//*     function SetLightningFadeTime takes lightning l, real fade returns boolean
//* 
//* A lightning's fade time is how long it takes to fade out when destroyed.
//* Lightning has it's fade time set to the default when it's created so this
//* is used if you want a different fade time.
//* A fade time of 0 will make lightning vanish instantly when released.
//* 
//*     function ReleaseLightning takes lightning l returns nothing
//*     function ReleaseLightningDelayed takes lightning l, real delay returns nothing
//* 
//* There are the replacement functions for DestroyLightning.
//*
//******************************************************************************
//* 
//* Flavour explanations:
//*
//* As already stated, the "flavours" allow you to alter how the library works
//* as well as it's speed, safety and restrictions. Here I will go into more
//* detail about the differences between to two flavours.
//*
//* Red is the faster and less safe/more restrictive of the two. The most
//* important thing to note about it is that you should not use a number of the
//* lightning functions. These include:
//*   - AddLightning
//*   - AddLightningEx
//*   - AddLightningLoc
//*   - DestroyLightning
//*   - DestroyLightningBJ
//*   - MoveLightning
//*   - MoveLightningEx
//*   - MoveLightningLoc
//*   - SetLightningColor
//*   - SetLightningColorBJ
//*
//* Using any of those functions with lightning created by this system is
//* strongly recommendedagainst as it can result in crashing the game.
//* You can use them on lightning created outside of this system but again, I
//* would advise against that as this system allows you much more control.
//*
//* The rest of the lightning natives are fine to use, these include:
//*   - GetLightningColorR
//*   - GetLightningColorG
//*   - GetLightningColorB
//*   - GetLightningColorA
//*   - SaveLightningHandle
//*   - LoadLightningHandle
//*
//* Blue is a bit different, it hooks all lightning created outside of the
//* system in so that you can use it with the systems functions as well as any
//* of lightning functions which are unsafe in the red flavour.
//* Some of the native lightning functions will work slightly differently than
//* normal because they need to be adapted to work with the system.
//*   - MoveLightning, MoveLightningEx and MoveLightningLoc will set the
//*     StartPoint and EndPoint of the lightning as well as changing it's
//*     position.
//*   - SetLightningColor and SetLightningColorBJ will allow you to set values
//*     outside of 0 to 1. While this works for colouring them, it can screw up
//*     the FadeTime of a lightning when it's fading out - especially if you
//*     change the alpha value to something outside the range of 0 to 1. I would
//*     also kindly ask you to avoid calling it on lightning that is fading out.
//*   - DestroyLightning and DestroyLightningBJ will ignore the lightnings
//*     FadeTime.
//*
//* There is the inherent limit that you can only have 8192 lightning at once.
//* However, if you ever get this high, your map will have worse problems than
//* this system working improperly.
//* Finally, you should be aware that if you call any lightning function
//* (native, BJ, or this systems) on a lightning that has been destroyed, your
//* map will most likely crash. This is not a result of this system, it's how
//* Blizzard made them.
//* 
//******************************************************************************
//* Credits: Thanks to Vexorian for TimerUtils and vJass and Kueken for the work
//*          he previously did which helped me create this library. Oh and Dusk
//*          for being sexy ;)
//* 
//* If you have any further questions regarding LightningUtils or how to use it,
//* feel free to visit [url]www.wc3c.net[/url] and ask questions there. This library should
//* only ever be released at WC3C and at no other site. Please give credits if
//* this library finds its way into your maps, and otherwise thanks for reading!
//* 

private keyword Lightning

globals
    private constant boolean  SUPPORT_HOOKING                     = true //This changes which flavour of the library is being used
    private constant real     TIMEOUT                             = 0.03125 //32 fps
    private constant real     HEIGHT_OFFSET                       = 75. //This seems to be the norm
    private constant real     DEFAULT_FADE_TIME                   = 1. //This tends to be the norm for most lightning
    
    //* Do not edit below here
    
            constant string   LIGHTNING_AERIAL_SHACKLES           = "LEAS"
            constant string   LIGHTNING_CHAIN_LIGHTNING_PRIMARY   = "CLPB"
            constant string   LIGHTNING_CHAIN_LIGHTNING_SECONDARY = "CLSB"
            constant string   LIGHTNING_DRAIN_LIFE                = "DRAL"
            constant string   LIGHTNING_DRAIN_LIFE_AND_MANA       = "DRAB"
            constant string   LIGHTNING_DRAIN_MANA                = "DRAM"
            constant string   LIGHTNING_FINGER_OF_DEATH           = "AFOD"
            constant string   LIGHTNING_FORKED_LIGHTNING          = "FORK"
            constant string   LIGHTNING_HEALING_WAVE_PRIMARY      = "HWPB"
            constant string   LIGHTNING_HEALING_WAVE_SECONDARY    = "HWSB"
            constant string   LIGHTNING_LIGHTNING_ATTACK          = "CHIM"
            constant string   LIGHTNING_MANA_BURN                 = "MBUR"
            constant string   LIGHTNING_MANA_FLARE                = "MFPB"
            constant string   LIGHTNING_SPIRIT_LINK               = "SPLK"
    
    private          Lightning array SystemLightning
endglobals


static if SUPPORT_HOOKING then
globals
    private boolean HOOK_LIGHTNING = true
endglobals
endif

private function GetLocZ takes real x, real y returns real
    return XYGetZ(x, y)
endfunction

//******************************************************************************

private struct Lightning
    lightning lightning
    string    CodeName
    boolean   Visibility
    boolean   Fading
    unit      StartUnit
    unit      EndUnit
    real      StartX
    real      StartY
    real      StartZ
    real      EndX
    real      EndY
    real      EndZ
    real      Red
    real      Green
    real      Blue
    real      Alpha
    real      FadeTime
    real      FadingAlpha
    timer     timer
    
    static method Update takes nothing returns nothing
        local timer     t    = GetExpiredTimer()
        local Lightning this = Lightning(GetTimerData(t))
        
        if .StartUnit != null and IsUnitType(.StartUnit, UNIT_TYPE_DEAD) == false and GetUnitTypeId(.StartUnit) != 0 then
            set .StartX = GetUnitX(.StartUnit)
            set .StartY = GetUnitY(.StartUnit)
            if IsUnitType(.StartUnit, UNIT_TYPE_FLYING) == true then
                set .StartZ = GetLocZ(.StartX, .StartY) + GetUnitFlyHeight(.StartUnit)
            else
                set .StartZ = GetLocZ(.StartX, .StartY) + GetUnitFlyHeight(.StartUnit) + HEIGHT_OFFSET
            endif
        endif
        if .EndUnit != null and IsUnitType(.EndUnit, UNIT_TYPE_DEAD) == false and GetUnitTypeId(.EndUnit) != 0 then
            set .EndX = GetUnitX(.EndUnit)
            set .EndY = GetUnitY(.EndUnit)
            if IsUnitType(.EndUnit, UNIT_TYPE_FLYING) == true then
                set .EndZ = GetLocZ(.EndX, .EndY) + GetUnitFlyHeight(.EndUnit)
            else
                set .EndZ = GetLocZ(.EndX, .EndY) + GetUnitFlyHeight(.EndUnit) + HEIGHT_OFFSET
            endif
        endif
        
        if .StartUnit != null or .EndUnit != null then
            static if SUPPORT_HOOKING then
                set HOOK_LIGHTNING = false
            endif
            call MoveLightningEx(.lightning, .Visibility, .StartX, .StartY, .StartZ, .EndX, .EndY, .EndZ)
            static if SUPPORT_HOOKING then
                set HOOK_LIGHTNING = true
            endif
        endif
        
        if .Fading then
            if .Alpha - .FadingAlpha > 0. then
                set .Alpha = .Alpha - .FadingAlpha
                static if SUPPORT_HOOKING then
                    set HOOK_LIGHTNING = false
                endif
                call SetLightningColor(.lightning, .Red, .Green, .Blue, .Alpha)
                static if SUPPORT_HOOKING then
                    set HOOK_LIGHTNING = true
                endif
            else
                set SystemLightning[GetHandleId(.lightning)] = 0
                static if SUPPORT_HOOKING then
                    set HOOK_LIGHTNING = false
                endif
                call DestroyLightning(.lightning)
                static if SUPPORT_HOOKING then
                    set HOOK_LIGHTNING = true
                endif
                call ReleaseTimer(.timer)
                set .lightning = null
                set .StartUnit = null
                set .EndUnit   = null
                set .timer     = null
                call .destroy()
            endif
        endif
        
        set t = null
    endmethod
    
    static method create takes string codeName, boolean visibility, unit u1, unit u2, real x1, real y1, real z1, real x2, real y2, real z2 returns Lightning
        local Lightning this = Lightning.allocate()
        
        if u1 != null then
            set .StartUnit = u1
            set .StartX    = GetUnitX(u1)
            set .StartY    = GetUnitY(u1)
            if IsUnitType(u1, UNIT_TYPE_FLYING) == true then
                set .StartZ = GetLocZ(.StartX, .StartY) + GetUnitFlyHeight(u1)
            else
                set .StartZ = GetLocZ(.StartX, .StartY) + GetUnitFlyHeight(u1) + HEIGHT_OFFSET
            endif
        else
            set .StartUnit = null
            set .StartX    = x1
            set .StartY    = y1
            set .StartZ    = z1
        endif
        if u2 != null then
            set .EndUnit = u2
            set .EndX    = GetUnitX(u2)
            set .EndY    = GetUnitY(u2)
            if IsUnitType(u2, UNIT_TYPE_FLYING) == true then
                set .EndZ = GetLocZ(.EndX, .EndY) + GetUnitFlyHeight(u2)
            else
                set .EndZ = GetLocZ(.EndX, .EndY) + GetUnitFlyHeight(u2) + HEIGHT_OFFSET
            endif
        else
            set .EndUnit = null
            set .EndX    = x2
            set .EndY    = y2
            set .EndZ    = z2
        endif
        set .CodeName   = codeName
        set .Visibility = visibility
        set .Fading     = false
        set .FadeTime   = DEFAULT_FADE_TIME
        static if SUPPORT_HOOKING then
            set HOOK_LIGHTNING = false
        endif
        set .lightning     = AddLightningEx(codeName, visibility, .StartX, .StartY, .StartZ, .EndX, .EndY, .EndZ)
        static if SUPPORT_HOOKING then
            set HOOK_LIGHTNING = true
        endif
        set .Red        = GetLightningColorR(.lightning)
        set .Green      = GetLightningColorG(.lightning)
        set .Blue       = GetLightningColorB(.lightning)
        set .Alpha      = GetLightningColorA(.lightning)
        set SystemLightning[GetHandleId(.lightning)] = this
        
        if u1 != null or u2 != null then
            set .timer = NewTimer()
            call SetTimerData(.timer, this)
            call TimerStart(.timer, TIMEOUT, true, function Lightning.Update)
        else
            set .timer = null
        endif
        
        
        return this
    endmethod
    
    static if SUPPORT_HOOKING then
    static method createHook takes string codeName, boolean visibility, real x1, real y1, real z1, real x2, real y2, real z2 returns Lightning
        local Lightning this = Lightning.allocate()
        
        set .StartUnit     = null
        set .StartX        = x1
        set .StartY        = y1
        set .StartZ        = z1
        set .EndUnit       = null
        set .EndX          = x2
        set .EndY          = y2
        set .EndZ          = z2
        set .CodeName      = codeName
        set .Visibility    = visibility
        set .Fading        = false
        set .FadeTime      = DEFAULT_FADE_TIME
        set HOOK_LIGHTNING = false
        set .lightning     = AddLightningEx(codeName, visibility, x1, y1, z1, x2, y2, z2)
        set .Red           = GetLightningColorR(.lightning)
        set .Green         = GetLightningColorG(.lightning)
        set .Blue          = GetLightningColorB(.lightning)
        set .Alpha         = GetLightningColorA(.lightning)
        set .timer         = null
        set SystemLightning[GetHandleId(.lightning)] = this
        call DestroyLightning(.lightning)
        set HOOK_LIGHTNING = true
        set .lightning     = null
        
        return this
    endmethod
    endif
    
    method SetColour takes real r, real g, real b, real a returns boolean
        static if SUPPORT_HOOKING then
            local boolean B
        endif
        
        set .Red   = r
        set .Green = g
        set .Blue  = b
        set .Alpha = a
        
        static if SUPPORT_HOOKING then
            set HOOK_LIGHTNING = false
            set B              = SetLightningColor(.lightning, r, g, b, a)
            set HOOK_LIGHTNING = true
            return B
        else
            return SetLightningColor(.lightning, r, g, b, a)
        endif
    endmethod
    
    static if SUPPORT_HOOKING then
    method SetColorHook takes real r, real g, real b, real a returns nothing
        set .Red   = r
        set .Green = g
        set .Blue  = b
        set .Alpha = a
    endmethod
    endif
    
    method SetStartPoint takes real x, real y, real z returns boolean
        static if SUPPORT_HOOKING then
            local boolean B
        endif
        
        set .StartUnit = null
        set .StartX    = x
        set .StartY    = y
        set .StartZ    = z
        
        if .EndUnit == null and .timer != null then
            call ReleaseTimer(.timer)
            set .timer = null
        endif
        
        static if SUPPORT_HOOKING then
            set HOOK_LIGHTNING = false
            set B              = MoveLightningEx(.lightning, .Visibility, x, y, z, .EndX, .EndY, .EndZ)
            set HOOK_LIGHTNING = true
            return B
        else
            return MoveLightningEx(.lightning, .Visibility, x, y, z, .EndX, .EndY, .EndZ)
        endif
    endmethod
    
    method SetStartUnit takes unit u returns boolean
        static if SUPPORT_HOOKING then
            local boolean B
        endif
        
        set .StartUnit = u
        set .StartX    = GetUnitX(u)
        set .StartY    = GetUnitY(u)
        set .StartZ    = GetLocZ(.StartX, .StartY) + GetUnitFlyHeight(u) + HEIGHT_OFFSET
        
        if .timer == null then
            set .timer = NewTimer()
            call SetTimerData(.timer, this)
            call TimerStart(.timer, TIMEOUT, true, function Lightning.Update)
        endif
        
        static if SUPPORT_HOOKING then
            set HOOK_LIGHTNING = false
            set B              = MoveLightningEx(.lightning, .Visibility, .StartX, .StartY, .StartZ, .EndX, .EndY, .EndZ)
            set HOOK_LIGHTNING = true
            return B
        else
            return MoveLightningEx(.lightning, .Visibility, .StartX, .StartY, .StartZ, .EndX, .EndY, .EndZ)
        endif
    endmethod
    
    method SetEndPoint takes real x, real y, real z returns boolean
        static if SUPPORT_HOOKING then
            local boolean B
        endif
        
        set .EndUnit = null
        set .EndX    = x
        set .EndY    = y
        set .EndZ    = z
        
        if .StartUnit == null and .timer != null then
            call ReleaseTimer(.timer)
            set .timer = null
        endif
        
        static if SUPPORT_HOOKING then
            set HOOK_LIGHTNING = false
            set B              = MoveLightningEx(.lightning, .Visibility, .StartX, .StartY, .StartZ, x, y, z)
            set HOOK_LIGHTNING = true
            return B
        else
            return MoveLightningEx(.lightning, .Visibility, .StartX, .StartY, .StartZ, x, y, z)
        endif
    endmethod
    
    method SetEndUnit takes unit u returns boolean
        static if SUPPORT_HOOKING then
            local boolean B
        endif
        
        set .EndUnit = u
        set .EndX    = GetUnitX(u)
        set .EndY    = GetUnitY(u)
        set .EndZ    = GetLocZ(.EndX, .EndY) + GetUnitFlyHeight(u) + HEIGHT_OFFSET
        
        if .timer == null then
            set .timer = NewTimer()
            call SetTimerData(.timer, this)
            call TimerStart(.timer, TIMEOUT, true, function Lightning.Update)
        endif
        
        static if SUPPORT_HOOKING then
            set HOOK_LIGHTNING = false
            set B              = MoveLightningEx(.lightning, .Visibility, .StartX, .StartY, .StartZ, .EndX, .EndY, .EndZ)
            set HOOK_LIGHTNING = true
            return B
        else
            return MoveLightningEx(.lightning, .Visibility, .StartX, .StartY, .StartZ, .EndX, .EndY, .EndZ)
        endif
    endmethod
    
    static if SUPPORT_HOOKING then
    method ChangePositionsHook takes real x1, real y1, real z1, real x2, real y2, real z2 returns nothing
        set .StartUnit = null
        set .StartX    = x1
        set .StartY    = y1
        set .StartZ    = z1
        set .EndUnit   = null
        set .EndX      = x2
        set .EndY      = y2
        set .EndZ      = z2
        
        if .timer != null then
            call ReleaseTimer(.timer)
            set .timer = null
        endif
    endmethod
    endif
    
    method Release takes nothing returns nothing
        if .FadeTime > 0. then
            set .Fading      = true
            set .FadingAlpha = .Alpha * TIMEOUT / .FadeTime
            if .timer == null then
                set .timer = NewTimer()
                call SetTimerData(.timer, this)
                call TimerStart(.timer, TIMEOUT, true, function Lightning.Update)
            endif
        else
            set SystemLightning[GetHandleId(.lightning)] = 0
            static if SUPPORT_HOOKING then
                set HOOK_LIGHTNING = false
            endif
            call DestroyLightning(.lightning)
            static if SUPPORT_HOOKING then
                set HOOK_LIGHTNING = true
            endif
            set .lightning = null
            set .StartUnit = null
            set .EndUnit   = null
            if .timer != null then
                call ReleaseTimer(.timer)
                set .timer = null
            endif
            call .destroy()
        endif
    endmethod
    
    static method DelayedReleaseCallback takes nothing returns nothing
        local timer t = GetExpiredTimer()
        call Lightning(GetTimerData(t)).Release()
        call ReleaseTimer(t)
        set t = null
    endmethod
    
    method DelayedRelease takes real delay returns nothing
        local timer t = NewTimer()
        call SetTimerData(t, this)
        call TimerStart(t, delay, false, function Lightning.DelayedReleaseCallback)
        set t = null
    endmethod
    
    static if SUPPORT_HOOKING then
    method DestroyHook takes nothing returns nothing
        set SystemLightning[GetHandleId(.lightning)] = 0
        set .lightning = null
        set .StartUnit = null
        set .EndUnit   = null
        if .timer != null then
            call ReleaseTimer(.timer)
            set .timer = null
        endif
        call .destroy()
    endmethod
    endif
endstruct

//******************************************************************************

static if SUPPORT_HOOKING then

private function AddLightning_Hook takes string codeName, boolean checkVisibility, real x1, real y1, real x2, real y2 returns nothing
    if HOOK_LIGHTNING then
        call Lightning.createHook(codeName, checkVisibility, x1, y1, 0., x2, y2, 0.)
    endif
endfunction

private function AddLightningEx_Hook takes string codeName, boolean checkVisibility, real x1, real y1, real z1, real x2, real y2, real z2 returns nothing
    if HOOK_LIGHTNING then
        call Lightning.createHook(codeName, checkVisibility, x1, y1, z1, x2, y2, z2)
    endif
endfunction

private function AddLightningLoc_Hook takes string codeName, location where1, location where2 returns nothing
    call AddLightningEx_Hook(codeName, true, GetLocationX(where1), GetLocationY(where1), LocGetZ(where1), GetLocationX(where2), GetLocationY(where2), LocGetZ(where2))
endfunction

private function SetLightningColor_Hook takes lightning whichBolt, real r, real g, real b, real a returns nothing
    local Lightning L = SystemLightning[GetHandleId(whichBolt)]
    if HOOK_LIGHTNING then
        if L.lightning == null then
            set L.lightning = whichBolt
        endif
        call L.SetColorHook(r, g, b, a)
    endif
endfunction

private function MoveLightning_Hook takes lightning whichBolt, boolean checkVisibility, real x1, real y1, real x2, real y2 returns nothing
    local Lightning L = SystemLightning[GetHandleId(whichBolt)]
    if HOOK_LIGHTNING then
        if L.lightning == null then
            set L.lightning = whichBolt
        endif
        call L.ChangePositionsHook(x1, y1, 0., x2, y2, 0.)
    endif
endfunction

private function MoveLightningEx_Hook takes lightning whichBolt, boolean checkVisibility, real x1, real y1, real z1, real x2, real y2, real z2 returns nothing
    local Lightning L = SystemLightning[GetHandleId(whichBolt)]
    if HOOK_LIGHTNING then
        if L.lightning == null then
            set L.lightning = whichBolt
        endif
        call L.ChangePositionsHook(x1, y1, z1, x2, y2, z2)
    endif
endfunction

private function MoveLightningLoc_Hook takes lightning whichBolt, location where1, location where2 returns nothing
    call MoveLightningEx_Hook(whichBolt, true, GetLocationX(where1), GetLocationY(where1), LocGetZ(where1), GetLocationX(where2), GetLocationY(where2), LocGetZ(where2))
endfunction

private function DestroyLightning_Hook takes lightning whichBolt returns nothing
    local Lightning L = SystemLightning[GetHandleId(whichBolt)]
    if HOOK_LIGHTNING then
        if L.lightning == null then
            set L.lightning = whichBolt
        endif
        call L.DestroyHook()
    endif
endfunction

private function DestroyLightningBJ_Hook takes lightning whichBolt returns nothing
    call DestroyLightning_Hook(whichBolt)
endfunction

hook AddLightning AddLightning_Hook
hook AddLightningEx AddLightningEx_Hook
hook AddLightningLoc AddLightningLoc_Hook
hook SetLightningColor SetLightningColor_Hook
hook SetLightningColorBJ SetLightningColor_Hook
hook MoveLightning MoveLightning_Hook
hook MoveLightningEx MoveLightningEx_Hook
hook MoveLightningLoc MoveLightningLoc_Hook
hook DestroyLightning DestroyLightning_Hook
hook DestroyLightningBJ DestroyLightningBJ_Hook

endif

//******************************************************************************

function CreateLightningBetweenPoints takes string codeName, boolean visibility, real x1, real y1, real z1, real x2, real y2, real z2 returns lightning
    return Lightning.create(codeName, visibility, null, null, x1, y1, z1, x2, y2, z2).lightning
endfunction

function CreateLightningBetweenUnits takes string codeName, boolean visibility, unit u1, unit u2 returns lightning
    if u1 == null or u2 == null then
        debug call BJDebugMsg(SCOPE_PREFIX + " Error: Trying to create a lightning connected to an invalid unit (or units)")
        return null
    endif
    return Lightning.create(codeName, visibility, u1, u2, 0., 0., 0., 0., 0., 0.).lightning
endfunction

function CreateLightningBetweenPointAndUnit takes string codeName, boolean visibility, real x, real y, real z, unit u returns lightning
    if u == null then
        debug call BJDebugMsg(SCOPE_PREFIX + " Error: Trying to create a lightning connected to an invalid unit")
        return null
    endif
    return Lightning.create(codeName, visibility, null, u, x, y, z, 0., 0., 0.).lightning
endfunction

function CreateLightningBetweenUnitAndPoint takes string codeName, boolean visibility, unit u, real x, real y, real z returns lightning
    if u == null then
        debug call BJDebugMsg(SCOPE_PREFIX + " Error: Trying to create a lightning connected to an invalid unit")
        return null
    endif
    return Lightning.create(codeName, visibility, u, null, 0., 0., 0., x, y, z).lightning
endfunction

//! textmacro LightningDebugTextmacro takes TYPE, RETURN
    static if not SUPPORT_HOOKING then
        if L == 0 then
            debug call BJDebugMsg(SCOPE_PREFIX + " Error: Trying to $TYPE$ a lightning not created by this system")
            return $RETURN$
        endif
    else
        if L.lightning == null then
            set L.lightning = l
        endif
    endif
    if L.Fading then
        debug call BJDebugMsg(SCOPE_PREFIX + " Error: Trying to $TYPE$ a lightning that is fading out of existance")
        return $RETURN$
    endif
//! endtextmacro

function ReleaseLightning takes lightning l returns nothing
    local Lightning L = SystemLightning[GetHandleId(l)]
    //! runtextmacro LightningDebugTextmacro("release", "")
    call L.Release()
endfunction

function ReleaseLightningDelayed takes lightning l, real delay returns nothing
    local Lightning L = SystemLightning[GetHandleId(l)]
    //! runtextmacro LightningDebugTextmacro("delayed release", "")
    call L.DelayedRelease(delay)
endfunction

function SetLightningStartPoint takes lightning l, real x, real y, real z returns boolean
    local Lightning L = SystemLightning[GetHandleId(l)]
    //! runtextmacro LightningDebugTextmacro("change the StartPoint of", "false")
    return L.SetStartPoint(x, y, z)
endfunction

function SetLightningStartUnit takes lightning l, unit u returns boolean
    local Lightning L = SystemLightning[GetHandleId(l)]
    //! runtextmacro LightningDebugTextmacro("change the StartUnit of", "false")
    return L.SetStartUnit(u)
endfunction

function SetLightningEndPoint takes lightning l, real x, real y, real z returns boolean
    local Lightning L = SystemLightning[GetHandleId(l)]
    //! runtextmacro LightningDebugTextmacro("change the EndPoint of", "false")
    return L.SetEndPoint(x, y, z)
endfunction

function SetLightningEndUnit takes lightning l, unit u returns boolean
    local Lightning L = SystemLightning[GetHandleId(l)]
    //! runtextmacro LightningDebugTextmacro("change the EndUnit of", "false")
    return L.SetEndUnit(u)
endfunction

//! textmacro SetLightningColourDebug takes VARIABLE, COLOUR
    if $VARIABLE$ < 0. then
        debug call BJDebugMsg(SCOPE_PREFIX + " Error: $COLOUR$ value passed to SetLightningColour is too low")
        set $VARIABLE$ = 0.
    elseif $VARIABLE$ > 1. then
        debug call BJDebugMsg(SCOPE_PREFIX + " Error: $COLOUR$ value passed to SetLightningColour is too high")
        set $VARIABLE$ = 1.
    endif
//! endtextmacro

function SetLightningColour takes lightning l, real r, real g, real b, real a returns boolean
    local Lightning L = SystemLightning[GetHandleId(l)]
    //! runtextmacro LightningDebugTextmacro("recolour", "false")
    //! runtextmacro SetLightningColourDebug("r", "Red")
    //! runtextmacro SetLightningColourDebug("g", "Green")
    //! runtextmacro SetLightningColourDebug("b", "Blue")
    //! runtextmacro SetLightningColourDebug("a", "Alpha")
    return L.SetColour(r, g, b, a)
endfunction

function SetLightningFadeTime takes lightning l, real fade returns boolean
    local Lightning L = SystemLightning[GetHandleId(l)]
    //! runtextmacro LightningDebugTextmacro("change the fade time of", "false")
    if fade < 0. then
        debug call BJDebugMsg(SCOPE_PREFIX + " Error: Trying to change a lightning's fade time to a value < 0")
        return false
    endif
    set L.FadeTime = fade
    return true
endfunction

endlibrary