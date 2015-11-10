/**********************************************************
*
*   Shadow Trail System v 1.1.1.7 by Maker
*
*   Creates a trail of units behind the caster
*
*   To use this system, copy this library,
*   and then Table and CTL from Resources folder into your map.
*
*   struct ShadowTrail
*       static method add takes unit target, integer trailType, real duration returns thistype
*           - target is the unit to attach the trail to
*           - trailType, 0 = units are created repeatedly, 1 = uses the same units. Test which suits your spell better      
*           - duration is how long the trail lasts in seconds. 0 = lasts until the unit dies
*
*       method setupMovingTrail takes integer count, real separation, real alphaFactor returns nothing
*           - use this only if the trail type is 1, TRAIL_TYPE_MOTION
*           - must be used if trail type is 1
*           - count is how many units are in the trail. More units -> longer trail
*           - separation is the distance between units.
*           - alphaFactor is the transparency multiplier between units. The further away the trail unit is from the main unit,
*             the more transparent it will be. Use values between 0 and 1.
*
*       method setInterval takes real timee returns nothing
*           - only affects trail type 0, TRAIL_TYPE_STATIC
*           - must be used with trail type 0
*           - timee is how often new units are created
*
*       method setFadeRate takes real rate, boolean flatMode returns nothing
*           - rate is how quickly the units fade out after the trail is terminated
*           - flatMode == true, units fade at a constant rate. Transparency = transparency - rate. Try values around 10. Higher value, faster fading.
*           - flatMode == false, units fade out at multiplicative rate. Transparency = transparency*(1-rate). Use values around 0.9. Lower value, faster fading-
*
*       method setAnimationSpeed takes real r returns nothing
*           - how quickly the animations of the trail units are played. Default value is 1.
*
*       method setAnimationIndex takes integer k returns nothing
*           - what animation index the trail units play      
*
*       method setColor takes integer red, integer grn, integer blu, integer alpha returns nothing
*           - sets the colouring of the trail units. Use values between 0 and 255.
*           - if alpha is 0, the unit is completely transparent, 255 means it is fully visible
*
*       method setEffect takes string model, string attachPoint, boolean attachToShadows returns nothing
*           - attaches a special effect to the trail units and the main unit          
*           - model = the path of a effect to attach
*           - attachPoint is the attachment point
*           - attachToShadows, if set to true will attach the effect to the trail units and the main unit, if
*             set to false then the effect is only attached to the main unit
*
*       method remove takes nothing returns nothing
*           - destroys/removes/ends the trail
*           - you can use this to remove the trail before the duration ends.
*           - trails are automatically detroyed when the duration ends so there is no need to use this
*
*       method setPlayerColor takes playercolor pColor returns nothing
*           - Sets the player color of the dummy units
*
*
*       Examples
*
*       / --------- Moving Shadow Trail ----------
*           local ShadowTrail ST = ShadowTrail.add(GetTriggerUnit(), TRAIL_TYPE_MOTION, 8)          // Lasts 8 seconds
*           call ST.setupMovingTrail(5, 20, 0.85)                                   // This method affects only trail type 1, must use
*           call ST.setAnimationIndex(2)                                            // Recommended to set
*           call ST.setFadeRate(10, true)                                           // Optional method call, recommended
*           call ST.setAnimationSpeed(1.0)                                          // Optional method call
*           call ST.setColor(200, 200, 200, 200)                                    // Optional method call
*           call ST.setEffect(EFF, "chest", false)                                  // Optional, EFF = variable holding the model path
*
*        ---------------------------------------- /
*            
*            
*       /--------- Static Shadow Trail ----------
*           local ShadowTrail ST = ShadowTrail.add(GetTriggerUnit(), TRAIL_TYPE_STAITC, 8)     // Lasts 8 seconds
*           call ST.setInterval(0.06250)                                            // This method affects only trail type 0, must use
*           call ST.setAnimationIndex(6)                                            // Recommended to set
*           call ST.setFadeRate(7, true)                                            // Optional method call, recommended
*           call ST.setAnimationSpeed(1.0)                                          // Optional method call
*           call ST.setColor(200, 200, 200, 200)                                    // Optional method call
*           call ST.setEffect(EFF, "chest", false)                                  // Optional, EFF = variable holding the model path
*       ----------------------------------------/
*          
*
*   Credits
*   Bribe       :   Table
*   Nestharus   :   CTL
*
***********************************************************/

library ShadowTrail requires Table, CTL
    globals
        // Does it use the team color of the owner of the main unit
        private constant boolean COLOUR_OWNER       = true
        // Default player colour for shadows, used if COLOUR_OWNER is false
        private constant playercolor PCOL           = GetPlayerColor(Player(15))
       
        // Dummies are created here and then isntantly placed at the hero's position
        private constant real CREATE_X              = 0
        private constant real CREATE_Y              = 0
       
        constant integer TRAIL_TYPE_STATIC          = 0
        constant integer TRAIL_TYPE_MOTION          = 1
       
        // The image to use as shadows for the dummies. No need to change this as the image will be hidden
        private constant string SHADOWPATH          = "Textures\\white.blp"
       
        private Table tab
        private integer dc = 0    // Dummy count
        private unit u
    endglobals
   
    // Credit to Deaod, edited by Maker
    private function CreateUnitWithoutShadow takes player owner, integer uid, real facing, string shadowfile returns unit
        local image i = CreateImage(shadowfile, 1, 1, 0, 0, 0, 0, 1, 1, 0, 3) // creates a dummy image
        if GetHandleId(i) == -1 then // if the new shadow is invalid, abort, it can screw up the game
            debug call BJDebugMsg("CreateUnitWithShadow: Invalid path for new shadow!") // it could also be caused by an imageType of 0, but thats a less common cause
            return null // since the image is invalid, we dont need to destroy it
        endif
        call DestroyImage(i) // destroy the dummy.
        set u = CreateUnit(owner, uid, CREATE_X, CREATE_Y, facing) // create the unit. this also creates a new image which functions as the shadow of the unit. The shadow will use the ID of the dummy image.
        call DestroyImage(i) // destroy the shadow of the unit
        call CreateImage(shadowfile, 1, 1, 0, 0, 0, 0, 1, 1, 0, 3) // this creates the new shadow for the unit, note that i dont need to overwrite "i" as the id this image will get is predictable
        call SetImageRenderAlways(i, false) // Hides the shadow
        call SetImageColor(i, 0, 0, 0, 0)   // Makes the shadow invisible
        // no need to null "i", as images dont use ref-counting
        return u
    endfunction

    // Fades out units over time
    private struct Alpha extends array
        private static unit array u         // The unit
        private static unit array hero      // The hero
        private static integer array aMax   // Maximum alpha value
        private static integer array a      // Current alpha value
        private static integer array r      // Red
        private static integer array g      // Green
        private static integer array b      // Blue
        private static integer array rf     // Flat alpha rate
        private static real array rs        // Multiplicative alpha rate
        private static boolean array bl     // Is fading flat
        private static boolean array rem    // Is the unit removed in the end
        private static boolean array sync   // Prevents overlapping fade in and fade out
        private static effect array e       // Effect

        implement CTLExpire
            if tab.boolean[GetHandleId(u[this])] == sync[this] then
                if bl[this] then
                    set a[this] = a[this] + rf[this]
                else
                    set a[this] = R2I(a[this] +rs[this]*50 + (aMax[this] - a[this]) * rs[this])
                endif
                if a[this] > 0 and a[this] < aMax[this] then
                    if IsUnitInvisible(hero[this], GetLocalPlayer()) then
                        call SetUnitVertexColor(u[this], r[this], g[this], b[this], 0)
                    else
                        call SetUnitVertexColor(u[this], r[this], g[this], b[this], a[this])
                    endif
                else
                    if rem[this] then
                        if e[this] != null then
                            call DestroyEffect(e[this])
                            set e[this] = null
                        endif
                        call RemoveUnit(u[this])
                        set dc = dc - 1
                        if dc == 0 then
                            call tab.flush()
                        endif
                    elseif a[this] <= 0 then
                        call SetUnitVertexColor(u[this], r[this], g[this], b[this], 0)
                        call ShowUnit(u[this], false)
                    else
                        if IsUnitInvisible(hero[this], GetLocalPlayer()) then
                            call SetUnitVertexColor(u[this], r[this], g[this], b[this], 0)
                        else
                            call SetUnitVertexColor(u[this], r[this], g[this], b[this], aMax[this])
                        endif
                    endif
                    set e[this] = null
                    set u[this] = null
                    set hero[this] = null
                    call destroy()
                endif
            else
                set e[this] = null
                set u[this] = null
                set hero[this] = null
                call destroy()
            endif
        implement CTLEnd
       
        static method start takes unit un, unit caster, integer rate1, real rate2, integer maxAlpha, integer red, integer grn, integer blu, integer alpha, boolean flatFade, boolean remove, boolean synch, effect eff returns nothing
            local thistype this = create()
            set u[this] = un
            set hero[this] = caster
            set a[this] = alpha
            set aMax[this] = maxAlpha
            set r[this] = red
            set g[this] = grn
            set b[this] = blu
            set rf[this] = rate1
            set rs[this] = rate2
            set bl[this] = flatFade
            set rem[this] = remove
            set sync[this] = synch
            set e[this] = eff
        endmethod
    endstruct

    struct ShadowTrail extends array
        private static unit array main      // The unit with the trail
        private static real array dur       // How long the trail lasts
        private static real array xm        // X of main during the previous loop
        private static real array ym        // Y of main during the previous loop
        private static real array ts        // Animation speed, time scale
        private static real array fd        // follow distance
        private static real array fp        // How quickly the shadow fades, multiplicative
        private static real array time      // Calculates the interval time
        private static real array interval  // How often a new shadow is created
        private static real array af        // Alpha factor between moving shadows
        private static real array d         // Distance between moving shadows
        private static integer array tc     // Number of moving shadows
        private static integer array fr     // How quickly the shadow fades, flat
        private static integer array r      // Red of shadows
        private static integer array g      // Green of shadows
        private static integer array b      // Blue of shadows
        private static integer array a      // Transparency of shadows
        private static integer array uid    // Unit type if of shadows
        private static integer array anim   // Animation index to play for the shadows
        private static integer array id     // Shadow Trail type
        private static string array eff     // Special effect on copies
        private static string array att     // Special effect attach point
        private static boolean array bo1    // True = flat fading time, false = multiplicative fading time
        private static boolean array bo2    // Is the specified effect created on dummies also
        private static boolean array h      // Are moving trail units hidden
        private static boolean array perm   // Is the trail permanent
        private static Table array ta       // For shadow copy units
        private static Table array tb       // For shadow copy effects
        private static playercolor array pc // Player colour of the shadows
       
        implement CTL
            local real x
            local real y
            local real an
            local real f
            local unit u
            local unit s
            local effect e = null // Passing unitialized variable to Alpha.start causes problems, null is good.
            local integer i
            local integer j
        implement CTLExpire
            if not IsUnitType(main[this], UNIT_TYPE_DEAD) and (dur[this] >= 0 or perm[this]) and GetUnitTypeId(main[this]) != 0 then
                if not perm[this] then
                    set dur[this] = dur[this] - 0.031250
                endif
                set x = GetUnitX(main[this])
                set y = GetUnitY(main[this])
                if x != xm[this] or y != ym[this] then
                    if id[this] == TRAIL_TYPE_STATIC then // Is moving, static trail
                        set time[this] = time[this] + 0.031250
                        if time[this] >= interval[this] then
                            set u = CreateUnitWithoutShadow(Player(15), uid[this], GetUnitFacing(main[this]), SHADOWPATH)
                            set dc = dc + 1
                            call SetUnitTurnSpeed(u, 1000)
                            call UnitAddAbility(u, 'Arav')
                            call UnitAddAbility(u, 'Aloc')
                            call PauseUnit(u, true)
                            call SetUnitUseFood(u, false)
                            call SetUnitX(u, x)
                            call SetUnitY(u, y)
                            call SetUnitTimeScale(u, ts[this])
                            call SetUnitColor(u, pc[this])
                            call SetUnitVertexColor(u, r[this], g[this], b[this], 0)
                            call SetUnitAnimationByIndex(u, anim[this])
                            call SetUnitFlyHeight(u, GetUnitFlyHeight(main[this]), 0)
                            if bo2[this] then
                                set e = AddSpecialEffectTarget(eff[this], u, att[this])
                            endif
                            set tab.boolean[GetHandleId(u)] = false
                            call Alpha.start(u, main[this], -fr[this], -fp[this], 255, r[this], g[this], b[this], a[this], bo1[this], true, false, e)
                            set time[this] = 0
                            set u = null
                            set e = null
                        endif
                    else // Is moving, moving trail (type 1)
                        set i = tc[this]
                        loop
                            exitwhen i == 0
                            set s = ta[this].unit[i]
                            set u = ta[this].unit[i-1]
                            set f = GetUnitFacing(u)
                            set an = (f+180)*bj_DEGTORAD
                            if IsUnitHidden(s) then // If units are hidden, they should be set to visible
                                set tab.boolean[GetHandleId(s)] = true
                                call Alpha.start(s, main[this], fr[this], fp[this], R2I(a[this]*Pow(af[this], i-1)), r[this], g[this], b[this], 0, bo1[this], false, true, e)
                                call ShowUnit(s, true)
                                call UnitRemoveAbility(s, 'Aloc')   // Showing unit makes units with Locust selectable
                                call UnitAddAbility(s, 'Aloc')      // Must apply Locust again
                                call SetUnitAnimationByIndex(s, anim[this])
                            endif
                            call SetUnitX(s, GetUnitX(u) + d[this] * Cos(an))
                            call SetUnitY(s, GetUnitY(u) + d[this] * Sin(an))
                            call SetUnitFacing(s, f)
                            call SetUnitFlyHeight(s, GetUnitFlyHeight(u), 0)
                            set i = i - 1
                        endloop
                        if h[this] then
                            set h[this] = false
                        endif
                        set s = null
                        set u = null
                    endif
                elseif not h[this] and id[this] == TRAIL_TYPE_MOTION then // Is not moving, trail is visible, trail type 1
                    set i = tc[this]
                    loop
                        exitwhen i == 0
                        set j = R2I(a[this]*Pow(af[this], i-1))
                        set tab.boolean[GetHandleId(ta[this].unit[i])] = false
                        call Alpha.start(ta[this].unit[i], main[this], -fr[this], -fp[this], j, r[this], g[this], b[this], j, bo1[this], false, false, null)
                        set i = i - 1
                    endloop
                    set h[this] = true
                endif
                set xm[this] = x
                set ym[this] = y
            else
                set i = tc[this]
                loop
                    exitwhen i == 0
                    if tb[this].effect[i] != null then
                        call DestroyEffect(tb[this].effect[i])
                    endif
                    set j = R2I(a[this]*Pow(af[this], i-1)) - 1
                    set tab.boolean[GetHandleId(ta[this].unit[i])] = false
                    call Alpha.start(ta[this].unit[i], main[this], -fr[this], -fp[this], j, r[this], g[this], b[this], j, bo1[this], true, false, null)
                    set i = i - 1
                endloop
                if tb[this].effect[0] != null then
                    call DestroyEffect(tb[this].effect[0])
                endif
                set main[this] = null
                call ta[this].flush()
                call tb[this].flush()
                call destroy()
            endif
        implement CTLEnd
       
        method remove takes nothing returns nothing
            set dur[this] = 0
            set perm[this] = false
        endmethod
       
        method setEffect takes string model, string attachPoint, boolean attachToShadows returns nothing
            local integer i = 1
            set eff[this] = model
            set att[this] = attachPoint
            set bo2[this] = attachToShadows
            if attachToShadows then
                loop
                    exitwhen ta[this].unit[i] == null
                    if tb[this].effect[i] != null then
                        call DestroyEffect(tb[this].effect[i])
                    endif
                    set tb[this].effect[i] = AddSpecialEffectTarget(model, ta[this].unit[i], attachPoint)
                    set i = i + 1
                endloop
            endif
            if tb[this].effect[i] != null then
                call DestroyEffect(tb[this].effect[i])
            endif
            set tb[this].effect[0] = AddSpecialEffectTarget(model, main[this], attachPoint)
        endmethod
       
        method setPlayerColor takes playercolor pColor returns nothing
            local integer i = 1
            set pc[this] = pColor
            loop
                exitwhen ta[this].unit[i] == null
                call SetUnitColor(ta[this].unit[i], pc[this])
                set i = i + 1
            endloop
        endmethod
       
        method setColor takes integer red, integer grn, integer blu, integer alpha returns nothing
            local integer i = 1
            set r[this] = red
            set g[this] = grn
            set b[this] = blu
            set a[this] = alpha
            loop
                exitwhen ta[this].unit[i] == null
                if id[this] == TRAIL_TYPE_STATIC or not h[this] then
                    call SetUnitVertexColor(ta[this].unit[i], red, grn, blu, R2I(a[this]*Pow(af[this], i-1)))
                else
                    call SetUnitVertexColor(ta[this].unit[i], red, grn, blu, 0)
                endif
                set i = i + 1
            endloop
        endmethod
       
        method setAnimationIndex takes integer k returns nothing
            local integer i = 1
            set anim[this] = k
            loop
                exitwhen ta[this].unit[i] == null
                call SetUnitAnimationByIndex(ta[this].unit[i], k)
                set i = i + 1
            endloop
        endmethod
       
        method setAnimationSpeed takes real r returns nothing
            local integer i = 1
            set ts[this] = r
            loop
                exitwhen ta[this].unit[i] == null
                call SetUnitTimeScale(ta[this].unit[i], r)
                set i = i + 1
            endloop
        endmethod
       
        method setFadeRate takes real rate, boolean flatMode returns nothing
            if flatMode then
                set fr[this] = R2I(rate)
            else
                set fp[this] = 1-rate
            endif
            set bo1[this] = flatMode
        endmethod
       
        method setInterval takes real timee returns nothing
            set time[this] = 0
            set interval[this] = timee
        endmethod
       
        method setupMovingTrail takes integer count, real separation, real alphaFactor returns nothing
            local integer i
            local unit u
            local real x = GetUnitX(main[this])
            local real y = GetUnitY(main[this])
            local real f = GetUnitFacing(main[this])
            if id[this] == TRAIL_TYPE_MOTION then
                if count > 0 then
                    set d[this] = separation
                    set tc[this] = count
                    set h[this] = false
                    set af[this] = alphaFactor
                    set xm[this] = GetUnitX(main[this])
                    set ym[this] = GetUnitY(main[this])
                    set ta[this] = Table.create()
                    set i = 1
                    loop
                        set u = CreateUnitWithoutShadow(Player(15), uid[this], f, SHADOWPATH)
                        call ShowUnit(u, false)
                        call SetUnitVertexColor(u, r[this], g[this], b[this], 0)
                        set dc = dc + 1
                        call SetUnitColor(u, pc[this])
                        call UnitAddAbility(u, 'Arav')
                        call UnitAddAbility(u, 'Aloc')
                        call SetUnitUseFood(u, false)
                        call SetUnitX(u, x)
                        call SetUnitY(u, y)
                        call PauseUnit(u, true)
                        set ta[this].unit[i] = u
                        exitwhen i == count
                        set i = i + 1
                    endloop
                    set h[this] = true
                    set ta[this].unit[0] = main[this]
                    set u = null
                else
                    debug call BJDebugMsg("Tried to use setupMovingTrail method with invalid dummy unit count. (Less than 1)")
                endif
            debug else
                debug call BJDebugMsg("Tried to use setupMovingTrail method with instance that has a wrong shadow trail type.")
            endif
        endmethod
       
        static method add takes unit target, integer trailType, real duration returns thistype
            local thistype this = 0
           
            if trailType == TRAIL_TYPE_MOTION or trailType == TRAIL_TYPE_STATIC then
                set this = create()
                set main[this] = target
                set uid[this] = GetUnitTypeId(target)
                set id[this] = trailType
                set dur[this] = duration
               
                set tc[this] = 0
                set perm[this] = duration == 0
               
                call this.setColor(255, 255, 255, 255)
                call this.setAnimationIndex(0)
                call this.setAnimationSpeed(1)
                call this.setFadeRate(0, true)
                call this.setFadeRate(0, false)
                call this.setInterval(0.2)
                call this.setEffect(null, null, false)
                static if COLOUR_OWNER then
                    set pc[this] = GetPlayerColor(GetOwningPlayer(target))
                else
                    set pc[this] = PCOL
                endif
            debug else
                debug call BJDebugMsg("Invalid shadow trail type.")
            endif
            return this
        endmethod
       
        private static method onInit takes nothing returns nothing
            set tab = Table.create()
        endmethod
    endstruct
endlibrary