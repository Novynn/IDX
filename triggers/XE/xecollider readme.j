//TESH.scrollpos=48
//TESH.alwaysfold=0
xecollider
----------
  A specialization xefx, aids at creating 2D missiles with collision and speed
 and that sort of stuff, notice you'd usually have to make a new struct and
 extend xecollider from it so you can declare your own methods for handling
 the hit event.
 
implementation
--------------
  First of all, you need xefx, after you implement xefx, you may just copy
 the xecollider trigger to your map.
 
  I'd also recommend you to implement the BoundSentinel library to prevent
 crashes related to the xecolliders moving too down in the map, you can find the
 BoundSentinel in the "Extras" trigger category.
 
  Notice this needs at least jasshelper 0.9.E.0 to compile.
 
xecollider object
-----------------

__________________________________________________________________________________________________
 static method create          takes real x, real y, real dir returns xecollider
-      -      -      ----------

  This is the create method, it will make a new xecollider object for you to
 use, If you are extending xecollider and wish to have a custom create method
 on your struct, remember that you will need to call allocate(x,y,dir)

 set somevariable = myxecollider.create( GetUnitX(u), GetUnitY(u), angl )

_________________________________________________________________________________________________
 method terminate              takes nothing returns nothing
-      -         --------------
  Call terminate() when you wish to 'kill' the missile, it will call .destroy()
 automatically, I recommend you not to call .destroy() manually. Use onDestroy
 to detect when it was called. You can use .x and .y on onDestroy...
 
 Example:   call somevariable.terminate()
                  
_____________________________________________________________________________________________________
 delegate xefx
-
   A xecollider object is practically also a xefx object, you may call all of
 the members in xefx for your disposal, including x,y,z  (to change the position)
 and height of the missile) and fxpath (the model used by the missile) please,
 read the xefx documentation as it includes a lot of members used by xecollider.

________________________________________________________________________________
 real expirationTime
-                   ------------------------------------------------------------
   The missile will die after expirationTime seconds, notice this is just a  
 variable so you can modify and read it as you will, when the expirationTime
 ends, the missile is 'killed' so onDestroy will be called. If you do not assign
 this manually, the expirationTime will be 100.0 by default
 
 Example:   set somevar.expirationTime = 3.0 // Die after three seconds.

________________________________________________________________________________
 real direction
-              -----------------------------------------------------------------
   Direction determines two things, the facing angle of the missile and the
 direction at which the missile will move (if you enable speed, etc) Since
 just about everything else uses radians this does as well.
 
 Example:   set somevar.direction = 0.5 * bj_PI  // face north...
 
________________________________________________________________________________
 real collisionSize
-                  -------------------------------------------------------------
   xecollider wouldn't have that name if it wasn't for collision, if a unit's
 collision circle collides with the xecollider's collisionSize, then your 
 onUnitHit method will be called.  Notice that you can change collisionSize
 dynamically. 
 
 Example:   set somevar.collisionSize = 50.0
 
________________________________________________________________________________
 real speed          = 0.0

 real acceleration   = 0.0

 real maxSpeed       = DEFAULT_MAX_SPEED
 real minSpeed       = 0.0
-                         ------------------------------------------------------
 The automatic movement is just 2D over the xy axis, so is the collision, simple
 spells don't usually mess a lot with 3D... Speed would be the distance a
 xecollider can move in a second, the acceleration is an increment of speed
 per second, notice acceleration can be negative.
 
 maxSpeed and minSpeed are caps for the speed in case acceleration was used.
 
 Initially a missile has zero speed and zero acceleration , the minimum speed
 is 0, which means a negative acceleration can never make speed go negative
 (which would probably make the missile look as it is going backwards) The
 default max speed is 1500, but you can tweak that by changing the constant
 at the top of the xecollider library.
 
________________________________________________________________________________
 real angleSpeed          = 0.0
-                               ------------------------------------------------
  Although it lacks a more formal name, this is the increment to the direction
 angle during a second, this like the other variables, is in radians. It will
 allow you to have missiles with curved movement, angleSpeed is also used by
 homing (see bellow)

________________________________________________________________________________
 unit targetUnit = null
-                      ---------------------------------------------------------
   By assigning this member to a living unit, the xecollider will home towards
 the unit's position. Notice that for this to work it will require an angleSpeed
 higher than 0.0.
 
________________________________________________________________________________
 method setTargetPoint     takes real x, real y returns nothing
 method setTargetPointLoc  takes real x, real y returns nothing
-                                                              -----------------
   This one makes the missile home towards a point. Same as targetUnit , it will
 need an angleSpeed higher than 0.
________________________________________________________________________________
 method forgetTargetPoint  takes nothing returns nothing
-                                                       ------------------------
  This method makes the xecollider forget it was homing towards a unit or point
 then it becomes a normal missile, you may like to change angleSpeed as well
 though.
 

 
xecollider event methods
------------------------
  These are methods you may declare on your custom struct in order to listen to
 the xecollider events.

________________________________________________________________________________ 
 method onUnitHit         takes unit hitTarget returns nothing defaults nothing
-      -         ---------                                                     -
  The onUnitHit method is called whenever the missile hits a unit (the collision
 circles intersect) it is similar to the UnitInRange event. hitTarget is the
 unit that just collided with the missile.

________________________________________________________________________________
 method loopControl       takes nothing returns nothing defaults nothing
-                  -------                                              --------
  This is a method that, if declared will be called every XE_ANIMATION_PERIOD
 seconds, may allow you to save a timer loop.
 
 
  The FireNovaStrike sample attempts to be a well explained example on how to
 use xecollider, get used to this whole 'extends' stuff, as you'd see in the
 example it makes things easier since you will not need to attach things anymore.
    











 


 
 
 
 



