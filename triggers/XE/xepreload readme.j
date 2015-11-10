//TESH.scrollpos=0
//TESH.alwaysfold=0
xepreload
---------
  xepreload attacks the ability preloading issue. It is a good idea to preload 
 abilities you are going to add to units during the game to avoid the typical
 "first-cast freeze". xepreload exploits jasshelper's inline and a timer to
 minimize the time spent preloading each ability.

Install
-------
 Copy the xepreload trigger to your map.
 
Usage
-----
_____________________________________________________________________________
    function XE_PreloadAbility takes integer abilid returns nothing
----
    Preloads the ability, pass it an ability id (rawcode). Notice that this
 function may only work during map init. In order to use it in a library's 
 initializer, make sure the library requires xepreload.
        

* Please notice that the ability removal might trigger certain order events, try
ignoring xe dummy units in those events if necessary.

