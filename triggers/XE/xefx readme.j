//TESH.scrollpos=39
//TESH.alwaysfold=0
xefx
----
  This module just allows you to have movable special effects, they are actually
 dummy units, you can do plenty of things like changing their position, their
 height, their rotation (in the xy and in the z axis as well), color, and things
 like that. It is all about assigning attributes, the only two important methods
 xefx objects have are create and destroy. There are other accessory methods.
 
implementation
--------------
  Just copy the xefx trigger to your map.
 
xefx object
-------------
__________________________________________________________________________________________________
  static method create    takes real x, real y, real facing returns xefx
--
  This is the create method, it will make a new xefx for you to use, there are 
 initial values you must specify, like the x,y coordinate and the facing angle.
 facing is in radians.

  Eg. set myfx = xefx.create()
__________________________________________________________________________________________________
  method destroy   takes nothing returns nothing
--
  This just destroys your xefx object. (call myfx.destroy() )

* List of attributes *

________________________________________________________________________________
    string fxpath
----
    Determines the model of the special effect, yes, you may  change it after
 assigning it if necessary to change the model path.
    
    Example: set myfx.path = "abilities\thisisamadeup\modelpath.mdl"

________________________________________________________________________________
    method hiddenReset takes string newfxpath, real newfacing returns nothing
----
    Resets the xefx with a new effect path and a new facing angle (radians).
    Avoids playing the dead animation of the previous model, notice that it is
    impossible to do this withouth playing the birth animation of the new model
    and without playing the sound of the dead animation of the previous model.
    
    Example: call myfx.hiddenReset("abilities\thisisamadeup\modelpath.mdl", 0.4)

________________________________________________________________________________
    method hiddenDestroy takes nothing returns nothing
----
    Destroys the xefx without playing the death animation of the model. Notice
    that it is impossible to do this without playing the sound of the
    dead animation.
    
    Example: call myfx.hiddenDestroy()


________________________________________________________________________________
    real x
    real y
    real z
----
    Determine the position of your special effect, you can keep moving the
  effect in a periodic loop, etc.
    
    Example: set myfx.x=myfx.x + 65.0
             set myfx.y=GetUnitY(u)
             set myfx.z=JumpParabola(t)
            
________________________________________________________________________________
    real xyangle
----
    The angle in the xy plane, also called 'facing' angle. (Note: uses radians)
    
    Example: set myfx.xyangle = AngleBetweenPoints(target, source)*bj_DEGTORAD
    
________________________________________________________________________________
    real zangle
----
    The angle in the z-axis (inclination?), (Note: uses radians)
    
    Example: set myfx.zangle = bj_PI/2 //Now the model will look towards the sky

   
________________________________________________________________________________
    integer red
    integer green
    integer blue
    integer alpha
----
    Well, the model's vertex coloring in RGB , a is the opacity value (use
 values from 0 to 255 here)
    
    Example: set myfx.red=255
             set myfx.green=0
             set myfx.blue=255
             set myfx.alpha=128
             
______________________________________________________________________________________
    method recolor takes integer r, integer g , integer b, integer a returns nothing
----
    This one assigns all the color values in one pass.

________________________________________________________________________________
    real scale (write-only)
----
    Allows you to resize the xefx object, the default scale is 1.
    
    Example:   set myfx.scale=2.0 //double size (in fact 8x)
               set myfx.scale=0.5 //half size   (in fact 1/8x)
________________________________________________________________________________
    player owner
----
    For some reason you might want to change ownership of the effect, for 
  example, if you use abilityid (see bellow) and the ability does damage.
  
    Example: set myfx.owner = GetOwningPlayer(GetTriggerUnit() )
________________________________________________________________________________
    integer abilityid
----
    Well, you may use a xefx object to grab a passive ability, perhaps you need
    it for ye candy reasons or you want to use it as a damage dealer.

        Example: set myfx.abilityid = 'Hphf'
________________________________________________________________________________
    integer abilityLevel
----
    And with this one, you change the level of that ability.

        Example: set myfx.abilityLevel = GetUnitAbilityLevel( u, s)

________________________________________________________________________________
    playercolor teamcolor
----
    The team color to use for the model.
    
        Example: set somevar.teamcolor=PLAYER_COLOR_RED
                 set somevar.teamcolor=GetPlayerColor(GetOwningPlayer(u))
   
________________________________________________________________________________
    method flash           takes string modelpath returns nothing
----
    It shows the dead animation of the model specified by modelpath. This is
    in case you need this sort of eye candy.
    
________________________________________________________________________________
    method ARGBrecolor     takes ARGB color returns nothing
----
    If you got the ARGB library in your map, xefx then acquires the ARGBrecolor
   method, that you can use to use an ARGB object to recolor the fx's model,
   in a way similar to how recolor() works.
   
    
    

