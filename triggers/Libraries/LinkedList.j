//TESH.scrollpos=68
//TESH.alwaysfold=0

//===============================================================================
// LINKED LIST 
//===========by Trollvottel======================================================
// DESCRIPTION:
//  * Creates a dynamic data structure.
//  * It consists of a front and an end dummy node, data are attached to nodes between them
//    which are linked together (each node has a previous and a next node
//    like nodes in a chain). 
//  * Nodes can be replaced or removed,  you can add nodes between existing
//    nodes.
//  * At the moment you can store 3 different data types: integers, reals, strings
//  * The amount of code created by importing this library is about the same as 360 lines vJass 
//    code.
//  * You can only store 8190 "objects" of one type at one time.
//================================================================================
// PURPOSE:
//  * Making easy data handling possible
//  * Making code more structured
//  * Making code more overlookable
//================================================================================
// USAGE:
//    1. Linked_IntList
//    2. Linked_RealList
//    3. Linked_StringList
//  * All of these have the same methods.
//  * You will work with a position pointer which points to a node in the list to call methods on it
//
//=================================================================================================
//  * METHOD SUMMARY:
//          RETURN VALUES:            
//          1. $ create () : thistype
//              -> creates a new List and returns it
//-------------------------------------------------------------------------------------------------
//          2.   isEmpty () : boolean
//              -> if there are no things stored in the list, this will return true
//-------------------------------------------------------------------------------------------------
//          3.   isInFrontOf () : boolean
//              -> if the position pointer points to the front node (is in front of the list)
//                 this will return true
//-------------------------------------------------------------------------------------------------
//          4.   isBehind () : boolean
//              -> if the position pointer points to the end node (is behind the list)
//                 this will return true
//-------------------------------------------------------------------------------------------------
//          5.   getItem () : $TYPE$
//              -> returns the object stored in the node the position pointer is pointing to
//=================================================================================================
//          ACTIONS (Conditions are what the user should care for):
//          1.  next () : nothing
//              Condition: the pointer is not at the end node
//              -> moves the position pointer to the next node
//-------------------------------------------------------------------------------------------------
//          2. previous () : nothing
//              Condition: the pointer is not at the front node
//              -> moves the position pointer to the previous node
//-------------------------------------------------------------------------------------------------
//          3. toFirst () : nothing
//              -> moves the position pointer to the next of the front node
//-------------------------------------------------------------------------------------------------
//          4. toLast () : nothing
//              -> moves the position pointer to the previous of the end node
//-------------------------------------------------------------------------------------------------
//          5. replace ($TYPE$ cont) : nothing
//              Condition: the position pointer is not pointing to the end node or front node.
//              -> replaces the object stored at the node the position pointer is pointing to
//-------------------------------------------------------------------------------------------------
//          6. insertInFrontOf ($TYPE$ cont) : nothing
//              Conditon: the position pointer is not pointing to the front node
//              -> inserts the object in front of the node the position pointer is pointing to
//-------------------------------------------------------------------------------------------------
//          7. insertBehind ($TYPE$ cont) : nothing
//              Conditon: the position pointer is not pointing to the end node
//              -> inserts the object behind the node the position pointer is pointing to
//-------------------------------------------------------------------------------------------------
//          8. remove () : nothing
//              Condition: the position pointer is not pointing to the end node or front node
//              -> removes the node the position pointer is pointing to and points to the next node
//-------------------------------------------------------------------------------------------------
//          9. addList ($NAME$List which) : nothing
//              -> adds another list to the end of the current list. the list you add will be cleared
//-------------------------------------------------------------------------------------------------
//          10. destroy () : nothing
//              -> destroys the list and all it's nodes
//-------------------------------------------------------------------------------------------------
//          11. flush () : nothing
//              -> empties the list and destroys all nodes in it
//==================================================================================================
//          ATTRIBUTES:
//          1.  size : integer
//              -> Number of elements/nodes in your list
//==================================================================================================
// Library Code - You better dont touch... You better dont look... Who cares about the implementation?
library Linked
        
    //! textmacro_once Linked_List_create takes TYPE, NAME, NULL
    private struct $NAME$Node
      
        thistype next
        thistype prev
        
        $TYPE$ cont
        
        static method create takes $TYPE$ content, thistype p, thistype n returns thistype
            local thistype this = .allocate()
            
            debug if integer(this) == 0 then
            debug   call BJDebugMsg("Could not create $NAME$Node, too many instances!")            
            debug   return 0
            debug endif
            
            set .next = n
            set .prev = p
            set .cont = content
            return this
        endmethod
        
        method onDestroy takes nothing returns nothing
            set .cont = $NULL$
        endmethod
    endstruct
    
    public struct $NAME$List
    
        readonly integer size = 0
        
        private $NAME$Node front
        private $NAME$Node end
        private $NAME$Node position
    
        static method create takes nothing returns thistype
            local thistype this = .allocate()
            
            debug if integer(this) == 0 then
            debug   call BJDebugMsg("Could not create $NAME$List, too many instances!")            
            debug   return 0
            debug endif
            
            set .front = $NAME$Node.create($NULL$, 0, 0)
            set .end = $NAME$Node.create($NULL$, .front, 0)
            set .front.next = .end
            set .position = .front
            return this
        endmethod
    
        method isEmpty takes nothing returns boolean
            return .size == 0
        endmethod
        
        method isInFrontOf takes nothing returns boolean
            return .position == .front
        endmethod
        
        method isBehind takes nothing returns boolean
            return .position == .end
        endmethod
        
        method next takes nothing returns nothing
            debug if .position == .end then
            debug   call BJDebugMsg("$NAME$List: Tried to get next of end node!")
            debug   return 
            debug endif
            set .position = .position.next
        endmethod
                
        method previous takes nothing returns nothing
            debug if .position == .front then
            debug   call BJDebugMsg("$NAME$List: Tried to get previous of front node!")
            debug   return 
            debug endif
            set .position = .position.prev
        endmethod

        
        method toFirst takes nothing returns nothing
            set .position = .front.next
        endmethod
        
        method toLast takes nothing returns nothing
            set .position = .end.prev
        endmethod
        
        method getItem takes nothing returns $TYPE$
            debug if .position == .front or .position == .end then
            debug   call BJDebugMsg("$NAME$List: Tried to get content of front or end node!")
            debug   return $NULL$
            debug endif
            return .position.cont
        endmethod
        
        method replace takes $TYPE$ cont returns nothing
            debug if .position == .front or .position == .end then
            debug   call BJDebugMsg("$NAME$List: Tried to replace content of front or end node!")
            debug   return 
            debug endif
            set .position.cont = cont
        endmethod
        
        method insertInFrontOf takes $TYPE$ cont returns nothing
            local $NAME$Node tmp = $NAME$Node.create(cont, .position.prev, .position)
            
            debug if .position == .front then
            debug   call BJDebugMsg("$NAME$List: Tried to insert in front of front node!")
            debug   return 
            debug endif
            
            set .size = .size + 1
            set .position.prev.next = tmp
            set .position.prev = tmp
        endmethod
        
        method insertBehind takes $TYPE$ cont returns nothing
            local $NAME$Node tmp = $NAME$Node.create(cont, .position, .position.next)
            
            debug if  .position == .end then
            debug   call BJDebugMsg("$NAME$List: Tried to insert behind end node!")
            debug   return 
            debug endif            
            
            set .size = .size + 1
            set .position.next.prev = tmp
            set .position.next = tmp
        endmethod
        
        method remove takes nothing returns nothing
            
            debug if .position == .front or .position == .end then
            debug   call BJDebugMsg("$NAME$List: Tried to remove front or end node!")
            debug   return 
            debug endif
            
            set .size = .size - 1
            set .position.next.prev = .position.prev
            set .position.prev.next = .position.next
            call .position.destroy()
            set .position = .position.next
        endmethod
        
        method flush takes nothing returns nothing
            call .toFirst()
            loop
                exitwhen .isEmpty()
                call .remove()            
            endloop
        endmethod
        
        stub method addList takes $NAME$List which returns nothing
            local $NAME$Node tmp = .end
            local $NAME$Node tmp2 = which.front
            
            if which.isEmpty() == false then
                set .end.prev.next = which.front.next
                set .end.prev.next.prev = .end.prev
                
                set .end = which.end
                
                set which.end = tmp
                
                set tmp.prev = tmp2
                set tmp2.next = tmp
                
                set .size = .size + which.size
                set which.size = 0
                
            debug else
            debug   call BJDebugMsg("$NAME$List: Added empty list!")
            endif
            
        endmethod
        
        method onDestroy takes nothing returns nothing
            call .flush()
            call .front.destroy()
            call .end.destroy()
        endmethod
        
    endstruct

//! endtextmacro

//! runtextmacro Linked_List_create("integer", "Integer", "0")
//! runtextmacro Linked_List_create("real", "Real", "0.0")
//! runtextmacro Linked_List_create("string", "String", "null")


endlibrary