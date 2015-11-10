//TESH.scrollpos=234
//TESH.alwaysfold=0
xedamage
--------
 When blizzard released UnitDamageTarget and UnitDamagePoint there were some
issue, both had a lot of parameters that were undocumented, but more importantly
DamagePoint was not a good enough solution, UnitDamagePoint causes issues with
apple players and it also misses ways to specify what sort of unit to target.
What many people missed was a way to specify these things in a similar way
to targets allowed in the object editor.

 Determining and configuring valid targets and things like damage factors is
always a hassle, xedamage can automatize that process in a nice way.

 xedamage is the successor of damageoptions it is also a little less messy. 
bitflags are not used anymore, instead xedamage uses struct members to specify
most of it. So, when using xedamage, you may end up feeling like feeling a
table of fields. An example is worth a thousand of words:

 local xedamage d=xedamage.create()

   set d.damageAllies=true                       // also harm allies
   set d.exception = UNIT_TYPE_FLYING            // don't harm fliers
   call d.factor ( UNIT_TYPE_STRUCTURE, 0.5)     // half damage to buildings
   set d.dtype = DAMAGE_TYPE_UNIVERSAL           // Do universal damage.
   
   //Execute AOE damage using those options:
   call d.damageAOE(GetTriggerUnit(), point_x, point_y, 250.0, 450)
 
 But there is more, xedamage also has a couple of members like isInUse() that
would add some event responses for the damaged unit event. That will allow you
to recognize when xedamage was in use to inflict the damage, the damagetype and
attacktype used, and even a custom tag that you could specify as a xedamage
field, this would allow you to have a bridge between xedamage and certain damage
detection systems that rely on such things.

About damage factors and dummy damages
----------------------------------------
  Typically xedamage does some dummy damage to test the damage factor of a unit
 because blizzard has not provided us with such a native... This damage is
 invisible to the player, but not invisible to spells and damage detect systems
 which could be a problem.
 
  By default, the dummy damage is 0.01 and it is a common practice in these
 spells and systems to ignore such low damage values. However, a bug from
 blizzard makes it so we require a HUGE damage of 20.0 to be actually able to
 detect all armor resistances. Something as low as 0.01 will not even detect
 hero resistance. This blows. So if you want xedamage to consider resistance
 correctly, you should use a test damage of 1/(armor reduction you wish to detect)
 (change the FACTOR_TEST_DAMAGE constant in the xedamage trigger).
 
  Of course, if you do this change, then you'll confuse spells/systems that
 detect damage, that's the reason I have added a variable isDummyDamage to
 xedamage (call it xedamage.isDummyDamage ) that you may read during a damage
 event to ignore this dummy damage.
 
implementation
--------------
  Just copy the xedamage trigger to your map.
 
xedamage object
----------------
   xedamage fields include a bunch of boolean fields that you can set to
 true/false, they hopefully got  self-explaining names, I just list them and
 their default values, remember I got a whole forum in wc3c, if you got doubts
 don't forget to ask questions there:
 
  boolean damageSelf    = false

  boolean damageAllies  = false
  boolean damageEnemies = true 
  boolean damageNeutral = true 

  boolean visibleOnly   = false
 
  boolean deadOnly      = false
  boolean alsoDead      = false

  boolean damageTrees   = false

  Something to notice is that damageTrees is probably only considered by AOE
 damage and perhaps by some spells using xedamage to specify targets. 
 _______________________
  boolean ranged = true
 -----------------------
  This is a special boolean field, it doesn't really determine valid targets
 like the ones above, it merely determines if the damage should be considered
 ranged, this merely determines how the AI reacts to the damage, a lot of people
 don't care that much and just use true, that's the default.

 ___________________________________________________
  damagetype dtype  = DAMAGE_TYPE_UNIVERSAL
  attacktype atype  = ATTACK_TYPE_NORMAL
  weapontype wtype  = WEAPON_TYPE_WHOKNOWS
 ---------------------------------------------------
 
  These fields determine the types to use in the damage native, the damage type
 usually determines if the damage would be magical, universal (ultimate) or
 physical, attacktype determines armor stuff, and weapon type determines sound.
 
  There's some work on knowing what each combination does, for example:
  http://www.wc3campaigns.net/showthread.php?t=100752
  
  Some basic knowledge: For spells it is fine to use ATTACK_TYPE_NORMAL, and 
 that is default in xedamage, wtype usually doesn't need to be updated . dtype
 is the important one, _UNIVERSAL makes the damage behave as a ultimate, there
 is also _UNKNOWN which seems to ignore a lot of things, _FIRE, _LIGHTNING and
 similar damagetypes are all magical, while DAMAGE_TYPE_NORMAL is physical.
 Ultimate damage can harm both ethereal and spell immune units, magical damage
 harms ethereal (with bonus) but cannot harm spell immune, physical damage can't
 hurt ethereal units.
 
 ___________________________
  integer tag = 0
 ---------------------------
  This little field allows you to have a custom damage response CurrentDamageTag
 (see bellow for event responses) basically, you can use whatever you want here
 it all depends on what the thing that uses the event responses will do about it.

 ____________________________
  unittype exception
  unittype required
 ----------------------------
  Learn a little about unittype, it is what blizzard calls unit classifications,
 basically a unit can be a building, a flier, etc. exception specifies a
 unittype that is required for a unit to receive damage. required, does the
 opposite, for example:
 
   set d.exception = UNIT_TYPE_FLYING
   set d.required  = UNIT_TYPE_SUMMONED
   
 This xedamage instance can only hit ground summoned units.

 * factor stuff:
  Factor options in xedamage, specify some rules, if those rules are matched,
 the damage will be multiplied by the specified factor, you can use negative
 factor, half factor, etc. Notice that when using negative factors, these 
 things stack, so if you make a xedamage instance that does negative damage to
 undead and negative damage to allies, it might do possitive damage to undead
 allies.
 
  If the total damage factor is 0.0 it is the same as adding an exception.
  
  _____________________________
     real allyfactor = 1.0
  -----------------------------
    If the xedamage can affect allies (damageAllies is true), then the damage
  will be multiplied by allyfactor, for example, you can make a spell that does
  half damage to allies. Or one that heals allies while hurting enemies.
  
  _____________________________________________________________
     method factor takes unittype ut, real fc returns nothing
  -------------------------------------------------------------
    This method allows you to add a specific factor for a unit type, by default
  a xedamage instance allows up to three of these rules, you can increase this
  cap by increasing MAX_SUB_OPTIONS in the top of the library.
  
    For example:
    call d.factor(UNIT_TYPE_STRUCTURE, 0.5) 
    call d.factor(UNIT_TYPE_SUMMONED, 2.0)
    
    This instance of xedamage would do half damage to structures and double
  damage to summoned units. Notice these things stack, so if for some reason
  there was a "summoned building" in your map, it would do 100% damage.
  
  _________________________________________________________________________
     method abilityFactor takes integer abilityId, real fc returns nothing
  -------------------------------------------------------------------------
     Let's say you want a passive ability that makes you receive half damage
   from fire spells, a way to do this is to make a whole damage detection system
   and use xedamage's event responses to find out fire was used in the spell.
   Then block the damage somehow... another way is to just change the spell so
   when a unit has such passive ability, the damage is multiplied by 0.5 .
   
     The 3 rules cap also works with abilityFactor and can as well be increased
   by changing MAX_SUB_OPTIONS.
   
      call d.abilityFactor( 'A000', 0.5)

  ____________________________________________________________________________
     method useSpecialEffect takes string path, string attach returns nothing
  ----------------------------------------------------------------------------
     This will make a special effect show up whenever succesful damage is done
    using the xedamage object.
    
      call d.useSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl","origin")
  

xedamage methods
----------------
  There would be little point in using all those fields without the methods that
 make use of them. 

 ____________________________________________________________________________________
   method damageTarget takes unit source, unit target, real damage returns boolean
 ------------------------------------------------------------------------------------
   A single unit targetting method, it will consider all the rules we just
 reviewed when doing the damage, if the damage would get a factor of 0.0 it will
 not perform any damage.
 
 local unit u = GetTriggerUnit()
 local unit t = GetSpellTargetUnit()
 local xedamage d= xedamage.create()
 
     set d.dtype = DAMAGE_TYPE_FIRE
     set d.damageAllies = true
     set d.allyfactor = -1.0
     call d.damageTarget(u,t, 100)
     call d.destroy()
     
 This would be a simple spell that does 100.0 fire damage on enemy units or
 heals for 100 hitpoints to allies.
 
 This method returns true if non zero damage was done, and false otherwise.
 
 ____________________________________________________________________________________________
   method damageTargetForceValue takes unit source, unit target, real damage returns nothing
 ---------------------------------------------------------------------------------------------
   This is an analogue for damageTarget, but it will IGNORE every specified
 field, and try to do the specified damage, no matter the circumstances, however
 it will use the xedamage instances' dtype, atype and tag for the xedamage event
 responses (see bellow).
 
   This could be useful when you already know the factor
    (you have previously used getTargetFactor)

 __________________________________________________________________________    
  method allowedTarget takes unit source, unit target returns boolean
 --------------------------------------------------------------------------
   Returns true if xedamage would do a damage different than 0.0 in this case.
 It is useful if you intend to use xedamage to configure a spell's allowed
 targets.
 
   if ( d.allowedTarget(u,t) ) then
       //...
       
 ____________________________________________________________________________
   method getTargetFactor takes unit source, unit target returns real
 ----------------------------------------------------------------------------
   For applications similar to allowedTarget, this returns the whole damage
 factor, so you can decide what to do based on it.
 
    set fc = d.getTargetFactor(u, t)
 
 ________________________________________________________________________________________
  method damageGroup takes unit source, group targetGroup, real damage returns integer
 ----------------------------------------------------------------------------------------
   This method does what damageTarget does, but it executes it on a whole unit
 group, probably faster than calling damageTarget on every unit in the group.
 
   Notice this method will empty the provided group.

 _________________________________________________________________________________________________
  method damageAOE    takes unit source, real x, real y, real radius, real damage returns integer
  method damageAOELoc takes unit source, location loc, real radius, real damage returns integer  
 -------------------------------------------------------------------------------------------------
   It will perform damage on units and destructables (if damageTrees is true) 
 that are inside the circle, notice collision sizes are considered. The returned
 value is the number of targets that were affected by the function, the loc
 version allows you to use a location instead of the more sane x,y coordinates.
 
 ______________________________________________________________________________________________________________
  method damageDestructablesAOE    takes unit source, real x, real y, real radius, real damage returns integer
  method damageDestructablesAOELoc takes unit source, location loc, real radius, real damage returns integer
 -----------------------------------------------------------------------------------------------------------
  This one damages all the destructables in a circle, regardless of damageTrees
 being true or not.
 
xedamage static method
-----------------------
 ________________________________________________________________________________________________
  static method getDamageTypeFactor takes unit u, attacktype a, damagetype d returns real
 ------------------------------------------------------------------------------------------------
  This method is used by one of the factor methods up there, thought it would be
 useful to make it available as a public method, it just returns the factor that
 a specific attacktype/damagetype couple would do on a certain unit u:
 
  set fc = xedamage.getDamageTypeFactor( GetTriggerUnit(), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_FIRE)
  
  Would return 1.0 if the unit is a normal unit, 1.66 if it is ethereal and 0 if it is spell immune.
  


xedamage event responses
------------------------
 ______________________________________________________________________
  boolean isDummyDamage
 ----------------------------------------------------------------------
  This variable is true when xedamage has performed "dummy damage" see
 above for more details.

 ______________________________________________________________________
  static method isInUse takes nothing returns boolean 
 ----------------------------------------------------------------------
  This method will return true if xedamage was in use during a damaged event,
 this would help you determine if the damage was inflicted by a xedamage call.
 
 _______________________________________________________________________
  readonly static damagetype CurrentDamageType=null
  readonly static attacktype CurrentAttackType=null
  readonly static integer    CurrentDamageTag =0
 -----------------------------------------------------------------------
   When isInUse() returns true, you can use these event responses to determine
 how was the damage inflicted, you can get the damage type, the attack type and
 the tag (specified by the field tag in the xedamage object) of the call.


   if (xedamage.isInUse() ) then
       if(xedamage.CurrentDamageType == DAMAGE_TYPE_FIRE ) then
           call BJDebugMsg(R2S(GetEventDamage())+" fire damage was inflicted to "+GetUnitName(GetTriggerUnit() ) )
       endif
       call BJDebugMsg("tag used: "+I2S(xedamage.CurrentDamageTag) )
   endif


--
  The FireNovaStrike sample attempts to be a quick example on
 how to use xedamage.
    

