//TESH.scrollpos=14
//TESH.alwaysfold=0
xemissile
----------
  A specialization xefx, aids at creating targeted missiles with arc and
 speed and that sort of stuff, notice you'd usually have to make a new
 struct and extend xemissile from it so you can declare your own methods
 for handling the hit event.
 
implementation
--------------
  First of all, you need xefx, after you implement xefx, you may just copy
 the xemissile trigger to your map.
 
  I'd also recommend you to implement the BoundSentinel library to prevent
 crashes related to the xemissiles moving too down in the map, you can find the
 BoundSentinel in the "Extras" trigger category.
 
  Notice this needs at least jasshelper 0.9.E.0 to compile.
  
  This library has two objects you can extend, xemissile and xehomingmissile.
  xehomingmissile extends xemissile and is only there to provide an alternate
  constructor for your convenience. You could also create a normal xemissile
  and then give it a homing target and it would work the same as if you created
  a xehmoingmissile.
 
xemissile object
-----------------
__________________________________________________________________________________________________
 static method create          takes real x, real y, real z, real tx, real ty, real tz returns xemissile
-      -      -      ----------
  This is the create method, it will make a new xemissile object for you to
 launch, If you are extending xemissile and wish to have a custom create method
 on your struct, remember that you will need to call allocate(x,y,z, tx,ty,tz)

 set somevariable = myxemissile.create( GetUnitX(u),GetUnitY(u),GetUnitFlyHeight(u)+LAUNCH_OFFSET, targetx,targety,0.0 )


xehomingmissile object
-----------------
__________________________________________________________________________________________________
 static method create          takes real x, real y, real z, unit target, real zoffset returns xehomingmissile
-      -      -      ----------
  Same as the xemissile create method, except that the target now is not a
 point, but a unit, which will be hit at zoffset from its origin point. 

 set somevariable = myxehomingmissile.create( GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u)+LAUNCH_OFFSET, target, HIT_OFFSET )

 
both objects
-----------------
_________________________________________________________________________________________________
 method launch                 takes real speed, real arc returns nothing
-      -      -----------------
  This launches the missile, it is a seperate method from .create in order to
 keep method argument lists reasonably short, the xemissile create method
 already takes 6 arguments. You will probably never create an xemissile without
 launching it immediately afterwards.
  The speed value determines how fast the missile will move and can later be
 changed mid-flight, the arc value determines at what angle the missile will be
 launched and works the same way as object editor missile arc values.
 
 Example:   call somevariable.launch(1000.0, 0.25)

_________________________________________________________________________________________________
 method terminate              takes nothing returns nothing
-      -         --------------
  Call terminate() when you wish to 'kill' the missile, it will call .destroy()
 automatically, I recommend you not to call .destroy() manually. Use onDestroy
 to detect when it was called. You can use .x and .y on onDestroy...
 
 Example:   call somevariable.terminate()
                  
_________________________________________________________________________________________________
 method setTargetPoint         takes real tx, real ty, real tz returns nothing
-      -              ---------
  This method sets the point towards which the xemissile will fly. This point
 is already automatically set by the create method, if the xemissile has a
 targetUnit set then this point will be constantly updated to the position of
 that unit. You can also manually set the target point with this method to
 redirect the missile, if you do the missile will forget any homing target
 it may have had.
 
 Example:   call somevariable.setTargetPoint(GetSpellTargetX(),GetSpellTargetY(),0.0)
                  
_____________________________________________________________________________________________________
 delegate xefx
-
   A xemissile object is practically also a xefx object, you may call all of
 the members in xefx for your disposal, including x,y,z  (to change the position)
 and height of the missile) and fxpath (the model used by the missile) please,
 read the xefx documentation as it includes a lot of members used by xemissile.

________________________________________________________________________________
 real speed          = 0.0
-                         ------------------------------------------------------
  The automatic movement is just a vertical arc that homes in on the target,
 just like WC3 attack and spell missiles.
  Speed would be the distance a xemissile can move in a second and should be
 a positive value or the missile will not cooperate. Speed is automatically 
 set by the launch method but you can also set it manually after launch.
 
 unit targetUnit     = null
 real zoffset        = 0.0
-                         ------------------------------------------------------
  By setting these two values you can make an xemissile home in on a unit.
 These values are automatically set by the xehomingmissile's create method,
 but you can also set them manually. If you set the unit to null or if the
 unit is removed, the missile will break its homing and land at the unit's
 last known coordinates.
 
xemissile event methods
------------------------
  These are methods you may declare on your custom struct in order to listen to
 the xemissile events.

________________________________________________________________________________ 
 method onHit             takes nothing returns nothing defaults nothing
-      -     -------------                                              --------
  The onHit method is called when the missile hits its target. The missile will
 be destroyed afterwards unless you re-launch it.

________________________________________________________________________________
 method loopControl       takes nothing returns nothing defaults nothing
-                  -------                                              --------
  This is a method that, if declared will be called every XE_ANIMATION_PERIOD
 seconds, may allow you to save a timer loop.
 