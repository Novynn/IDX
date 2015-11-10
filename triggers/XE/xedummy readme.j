//TESH.scrollpos=17
//TESH.alwaysfold=0
xedummy
-------
  xedummy attacks the dummy unit recycling issue. Creating units is a costly
 operation and due to their versatility, xe dummy units can end up being
 created and destroyed very frequently. In such situations, recycling them
 makes sense.

Install
-------
 Copy the xedummy trigger to your map.
 
Usage
-----
_____________________________________________________________________________
    function XE_NewDummyUnit takes player p, real x, real y, real face returns unit
----
    Gives you a new xe dummy unit. If a previously preloaded or released unit
 is available for the given facing angle, it will be reused, else a new xe
 dummy unit will be created. The unit is automatically given the 'aloc'
 ability to make it unselectable and the XE_HEIGHT_ENABLER ability so you can
 modify its fly height.
 
    There is no way to change the facing angle of a unit instantly, this is
 why xedummy stores recycled units at various facing angles so that when a
 new unit is requested, the system may already have a unit with a similar
 facing angle available. This way, the non-instant change of facing when
 reusing a recycled unit is made less noticeable.
    The number of angles at which dummy units are stored is configurable,
 however keep in mind that more angles mean higher overhead. With the current
 implementation, the maximum theoretical overhead is N*N/4 units, so with the
 default 12 directions the map will use at most 36 more units than it would
 without this library.
_____________________________________________________________________________
    function XE_ReleaseDummyUnit takes unit u returns nothing
----
    Makes an xe dummy unit available for recycling. Please only call this on
 xe dummy units that were obtained with the NewXEDummy function and make sure
 to destroy any special effects attached to them and remove any abilities
 they may have.
 
    You can limit how many units the system will keep available for reuse.
 If this limit is reached then released dummy units will be removed. This
 way, if at some point your map needs a number of dummy units that greatly
 exceeds your average use, you won't be stuck with that many dummy units for
 the rest of the game. However, this limit should not be set too low or the
 map will end up creating and removing dummy units more often than recycling
 them.
_____________________________________________________________________________