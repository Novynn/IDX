//TESH.scrollpos=0
//TESH.alwaysfold=0
xe
--
  Q. Why xe?
  A. As the caster system grew bigger vJass also appeared, there are also a lot 
   of things in the caster system that could have been done better but cannot
   be fixed without dropping the caster system's function interface.
   
  Q. No, really, WHY IS IT NAMED XE?
  A. I have no idea.
  
  Q. What's wrong with the caster system?
  A. Instead of answering that I will list what's right with xe:
  *  It is modular. You can make a whole spell with just xebasic which is just
  like a "constant package" that comes with the dummy model and unit. All the
  other parts are disposable or replaceable.
  
     Still, I made them and will probably keep making new modules as I advance,
  right now xe can only do some basic functions, still cannot 100% replace
  the caster system in functionality, certain parts like the parabolic
  projectiles most notably, don't have a xe module yet, maybe later...
  
     xebasic is so minimal I personally hope people could use it on their spells
  and systems as a way to make it common to use these constants as constants of
  that kind are often required to make things work.
  
  * It is quite OOP, this is more related to the modules themselves, I wanted it
  to exploit OOP for two reasons: 1) It prevents the 'ultra long function calls'
  disease that has plagued the caster system since the beginning of time. 2) I
  personally think it is easier this way instead of memorizing function names
  and their argument lists.
  
xebasic
-------
  xebasic is the nucleous of all xe, in order to use a xe module you would most
 likely need xebasic. It is also meant to be the only part of xe that most users
 would really need to tweak for their map.
 
  This section is supposed to be a rapid guide on copying xebasic. The rest of
 the xe modules should be rather easy to implement (just copy the 'trigger' that
 contains it to the map).
 
 1) Make a backup of your map.
 2) Get vJass support. The most usual way would be using the newgen pack. There
 are plenty of other ways. I for example do my vJass coding on Linux using just
 jasshelper.exe, WINE and some editor tricks using a tool called Warcity.
 
     Getting vJass to work is a wide area, if just installing and using the
 "Jass newgen pack" doesn't work to you, please request/search help somehow. As
 of now there really is no vJass support in OS/X, so you would need virtualization
 and things of that style.
 
 -- Note: You can have two maps open in the editor, and it is the only way to
 make copy and paste work.
 
 3) Copy the model, in this map's import manager you may find dummy.mdx, select
 it and export it to some temp folder, then go to your map and import it, use
 war3mapimported\dummy.mdx for path.
 
 Please save the map immediatelly after importing the model to prevent it from
 getting unimported due to a rare WE bug.
 
 4) Copy the dummy unit: In the object editor under neutral passive, you may
 find the dummy unit, select it, go to 'edit' then click copy. Now switch to
 your map's object editor and use 'paste'.
 
 5) Write down the rawcode: While you are in the object editor select your map's
 recently pasted dummy unit, then go to the 'view' menu and click the option to
 show values as raw data. Now take a look to the selected unit type. It will now
 come with a code like "ewsp:e001", the last four characters of the code are
 what matter, write them down.
 
 6) Copy this map's xebasic trigger to your map.
 
 7) Update your map's xebasic: change the value assigned to XE_DUMMY_UNITID to
 'XXXX' where XXXX is the four character code you wrote down in step 5.
 
 8) Save your map and pray, if it compiles correctly then it is done. Make sure
 to test (after implementing) whatever needed you to install xebasic. If it
 doesn't work correctly then it is likely you made a mistake when copying the
 unit or the model or updating the rawcode.

 9) Update the other values if you think it is necessary. 

Using xebasic
-------------
  Well, once you state your trigger/spell/system requires xebasic, just use
 its constants, on a map that has implemented xebasic XE_DUMMY_UNITID will be
 your key to creating dummy units, just remember to add it 'Aloc' ...
 
Contact 
-------
 I got a forum that's supposed to hold questions related to my systems at:
    http://wc3campaigns.net/vexorian
    
 I'd really appreciate that you used that forum for your questions, for starters
 it is a lot more likely I would actually find the questions in that case.
 
 Changelog
 ---------
 0.9:
 - Added xemissile.
 - Added xedummy.
 - xefx can now use xedummy to recycle dummy units.
 - xepreload can now be used from struct initializers.
 - Fixed a bug in xecast that would occur if recycledelay was shorter than
   the duration of the spell cast by the dummy caster.
 - Fixed a bug in xefx where hiddenReset did not properly assign the new fxpath.
 - Optimized the xecollider collision detection.
 - Fixed some errors in xefx and xecast documentation.
 - new sample: Firestrike.
 - Removed an xecast leak in the IllusionRune sample.
 - Removed a handle id leak in SheepStaff sample.

 0.8:
 - No longer let xecollider hit corpses...
 - When xecollider misses targetUnit (the unit dies, it will stop homing and
   keep going on its current direction).
 - angleSpeed no longer implicitly makes rotation automatic unless there is homing,
   If you want rotation, set the boolean member rotation to true.
 - xedamage: Added MAX_DAMAGE_FACTOR to prevent some deads, a debug message will
   appear if the unit dies when being tested for a damage factor.
 - xepreload: debug message when preloading an ability at a wrong time.

 0.7:
 - Requires jasshelper 0.A.2.4 or greater.
 - xepreload will now show an useful error when the ability does not exist
   (in debug mode).
 - xepreload may now use TimerUtils to recycle its timer if you happen to have
   TimerUtils in the map.
 - xecast automatically resets mana and cooldown for the dummy before making it
   cast stuff. If this behaviour concerns you, you may disable it through a
   constant.
 - Added targetUnit, setTargetPoint and forgetTarget to xecollider's
   documentation.
 - Added abilityLevel to xefx.
 - Fixed a mistake in xefx's documentation that said "copy the xecast trigger"
 - xedamage: Added a constant FACTOR_TEST_DAMAGE, which allows you to set the
   amount of damage to do when testing for damage...
 - xedamage: Added an isDummyDamage event response boolean to detect test damages.
 - xedamage: Added a lot of things to documentation about the issues with armor.
 - xedamage: fx is for sure not shown when there is no damage.
 - xefx: added hiddenDestroy and hiddenReset
 - new sample: Chains of fire.

 0.6:
 - The demo map is playable in patch 1.24.
 - Only the samples and demomap system needed to be updated, xe's libraries
   themselves have not changed.

 0.5:
 - xecollider.terminate now prevents events from firing.
 - fixed a unit handle index kidnap in inRangeEnum (xecollider).
 - fixed a small documentation bug about xecollider.terminate
 - xecast's anti-AI protection now pauses the unit instead of removing the
   ability (since that seemed to have bad side effects)
 - xecast is now able to deal with units not visible to the player by setting
   a constant to true.
 - Due to technical split, xecast.castOnTarget now only takes unit and not
   widget, old castOnTarget that takes widget has been renamed castOnWidgetTarget.
 - xecollider now will not miss the detection of certain units that get inside
  the range too fast anymore, however now creates a group per collider (damn) I
  hope to find a better solution.
 - Added a notice in xepreload's documentation about order events firing during
   the preload.
 - Added gem of double green fire

 0.4:
 - More documentation fixes.
 - xecast no longer has double frees when using create/Basic/A  and the
   AOE/group methods.
 - damageDestructablesInAOE now actually works and does not leak a xedamage
   reference.
 - damageTarget now returns true if it was succesful and false if it wasn't.
 - xefx's recycle bin now extends array.
 - added rune of illusions sample.
 
 0.3:
 - More documentation fixes.
 - xefx requires xebasic in the library declaration (as it was supposed to)
 - xefx now creates the effects at the correct place (used to consider pathing
 during creation for some reason).
 - xebasic sample uses 197.0 for max collision size since that's the default in
 warcraft 3 (The default + 1)
 - xebasic now includes an explanation for max collision size and its effects.
 - added useSpecialEffect to xedamage
 - included BoundSentinel 
 - added xecollider
 - xedamage's required unittype field is not ignored anymore.
 - Added the fireNovaStrike example.
 
 0.2:
 - Fixed a bug with xecast.castInPoint basically ignoring the arguments.
 - Fixed a bug with xecast.createBasic ignoring the order id.
 - Fixed documentation bugs.
 - Added xedamage.
 - Added sheep staff sample.

 0.1 : Initial release

 
  
  

