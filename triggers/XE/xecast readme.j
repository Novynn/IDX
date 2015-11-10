//TESH.scrollpos=33
//TESH.alwaysfold=0
xecast
------
  This one solves typical problems that require dummy casters. Things like the
 AOE sleep, targetted warstomp, etc. It is object oriented, this just means that
 you'll actually not just call functions but deal with xecast objects, change
 their attributes and then order them to cast. It deals with the dirty things
 like recycling and dealing with timing, etc.
 
implementation
--------------
  Just copy the xecast trigger to your map.

xecast object
-------------
__________________________________________________________________________________________________
 static method create      takes nothing returns nothing 
-                    ------
 This is the create method, it will make a new xecast object for you to use:

 set somevariable = xecast.create()
_________________________________________________________________________________________________
 static method createBasic takes integer abilityID, integer orderid, player owner returns xecast
-      -      -           -     -       -          -       -        -      -     -       -
 An abbreviated constructor, allows you to quickly set the basic attributes
  abilityID: the rawcode of the ability to cast.
                  Example: 'AHbz'
  orderid  : the orderid (integer) of the ability to cast.
                  Example: OrderId("blizzard")
  owner    : the owning player for this cast object (The one that gets credit for damage)
                  Example: ( GetOwningPlayer(GetTriggerUnit() ))
                  
_________________________________________________________________________________________________
 method destroy             takes nothing returns nothing
-
 Call destroy() on instances you are not going to use anymore, to prevent struct leaks that would
 break your map. A simple use for xecast is to just keep one instance per dummy spell to prevent
 having to care about destroying them. Another possibility is to use the A constructors.
 
 Example:   call somevariable.destroy()
                  
__________________________________________________________________________________________________
 static method createA      takes nothing returns nothing 
 static method createBasicA takes integer abilityID, integer orderid, player owner returns xecast 
-
 These do the same as create and createBasic , the only difference is that the
 object is destroyed automatically after every call to a cast method (See bellow).
 
_____________________________________________________________________________________________________
 method castOnTarget         takes unit target returns nothing 
-
 Tells the xecast object to cast its spell on the target unit. Can cast on units that are invisible
 to the owner of the xecast if FORCE_INVISIBLE_CAST is set to true.
_____________________________________________________________________________________________________
 method castOnWidgetTarget   takes widget target returns nothing 
-
 Tells the xecast object to cast its spell on the target. target may be unit, item or destructable.
_____________________________________________________________________________________________________
 method castOnPoint  takes real x, real y returns nothing
 method castOnLoc    takes location loc returns nothing
 method castInPoint  takes real x, real y returns nothing
 method castInLoc    takes location loc returns nothing
-                                                      -----------------------------------------------
 Instead of casting on a target unit/item/destructable these ones cast on a target point. OnPoint is
 used for point-targeteable spells, while InPoint is used for spells that have no target. The Loc
 versions allow you to use locations. Locations are useless most of the times, but if you want to use
 them you can use the Loc versions.
 
 Example:   call somevar.castOnPoint( spellx, spelly )

_____________________________________________________________________________________________________ 
 method castOnAOE    takes real x, real y, real radius returns nothing
 method castOnAOELoc takes location loc,real radius returns nothing
 method castOnGroup  takes group g returns nothing 
-                                                 ---------------------------------------------------
 Methods to cast the spell on multiple units, AOE takes a circle's center and radius, while Group
 takes a unit group, notice that the unit group will get cleaned after calling this function, which
 means it will be an empty unit group, no, it does not destroy the group automatically, just empties it
 
* List of attributes *
________________________________________________________________________________
    integer abilityid
----
    This one holds the ability to cast's ability Id.
        Example: set somevar.abilityid='AHbz'
________________________________________________________________________________
    integer level
----
    The level of the ability to cast.
        Example: set somevar.level = GetUnitAbilityLevel(u, spellid)
________________________________________________________________________________
    real    recycledelay
----
    The recycle delay is the time to wait before recycling the dummy caster, if
    it is 0.0 the ability will be considered instant.
    
    A proper recycle delay is important since when a dummy caster is recycled
    its owner becomes player passive. Every damage done by the casted spell will
    not credit the correct player.
    
    Some other spells need some time in order to cast correctly. Not to mention
    the channeling ones that require the caster to last during that situation.

        Example: set somevar.recycledelay=10.0
________________________________________________________________________________
    player  owningplayer
----
    The player that owns the spell (Who gets credited for it)
        Example: set somevar.owningplayer = Player(2)
        
________________________________________________________________________________
    integer orderid (write-only)
----
    The ability to cast's order id. eg 858029 or OrderId("blizzard")
________________________________________________________________________________
    string orderstring (write-only)
----
    The ability to cast's order string (eg "blizzard")
________________________________________________________________________________
    boolean customsource
----
    false by default, determines if you want the dummy caster to be placed at
    a specific point when casting, this allows you to exploit blizz spell's eye
    candy. Once customsource is true, you need to set sourcex,sourcey and 
    sourcez.
________________________________________________________________________________
    real sourcex, sourcey, sourcez
----
    The coordinates where you want to place the dummy caster, z is height and
    is 0.0 by default. These are ignored if customsource is set to false.
________________________________________________________________________________
    method setSourcePoint  takes real x, real y, real z returns nothing
    method setSourceLoc    takes  location loc, real z returns nothing        
----
    In case setting all that stuff manually takes too much lines for your taste
    you can use these methods to set those values, they will automatically set
    customsource to true.
    


    












 


 
 
 
 



