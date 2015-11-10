//TESH.scrollpos=418
//TESH.alwaysfold=0
// --------------------------------------------------------------------------------------------------------------------
//  
//  Stack
//  =====
// 
//  Version:    1.7.0
//  Author:     Anachron
// 
//  Requirements:
//      (New) Table [by Bribe] (v. 3.1) [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/[/url]
// 
//  Description:
//      Stack is a list that includes basic features.
//      It can be easily extended so it will provide advanced functionality.
//  
//  History:
//      1.0.0: Initial Release
//      1.1.0: Add of split, switch and merge
//      1.2.0: A lot of bug fixes, added iterator, printing of debug msg
//      1.3.0: Added sorting and rand to get random element
//      1.4.0: Added first, last and onDestroy cleanup, replaced while with loop
//      1.5.0: Rearranged delete to not need a fix func
//      1.6.0: Swappred create with createEx, renamed functions to give a better clue what they do, 
//             fixed random method (thanks to Magtheridon96), used destroy instead of onDestroy
//      1.7.0: Replaced FunctionInterface with TriggerEvaluate, added full and empty methods
//
//  API:
//      ------------------------------------------------------------------------------------------------
//          Basics
//      ------------------------------------------------------------------------------------------------
//      has(int x)              --> Check if value is in stack
//      index(int value)        --> Get the index of value
//      add(int x)              --> Add a new value to the stack
//      clear()                 --> Remove all values from the stack
//      count                   --> Return how many elements are in stack
//      delete(int x)           --> Delete a value from the stack
//      full                    --> Boolean whether Stack is full or not
//      empty                   --> Boolean whether Stack is empty or not
//
//      ------------------------------------------------------------------------------------------------
//          Utilities
//      ------------------------------------------------------------------------------------------------
//      each(code x)            --> Execute this function for each value in stack
//      max[= x]                --> Get/Set maximum amount of elements in stack
//      merge(Stack x)          --> Merge other stack into current stack
//      split(Stack x, int y)   --> Split this stack with elements after y into the new stack
//      switch(int x, int y)    --> Switch indexes for value x and y
//      sort(bool asc)          --> Sort Stack ascend or descending
//
//      ------------------------------------------------------------------------------------------------
//          Iteration
//      ------------------------------------------------------------------------------------------------
//      cursor                  --> Get current cursor index location
//      direction               --> Get boolean, whether iterating is forward (true) or backward (false)
//      hasNext()               --> Boolean, whether cur is at end or not
//      hasPrev()               --> Boolean, whether cur is at start or not
//      getNext()               --> Increases cur by 1 and returns the current element
//      getPrev()               --> Decreases cur by 1 and returns the current element
//      reset()                 --> Sets cur to -1 (start)
//      end()                   --> Sets cur to count
//
//      ------------------------------------------------------------------------------------------------
//          Getters
//      ------------------------------------------------------------------------------------------------
//      get(int x)              --> Get value on index x
//      getFirst()              --> Returns first element of stack
//      getLast()               --> Returns the last element of stack
//      random()                --> Return any random value of the stack
//
//      ------------------------------------------------------------------------------------------------
//          Each Static Members
//      ------------------------------------------------------------------------------------------------
//      thistype.eachStack      --> Current instance of stack
//      thistype.eachValue      --> Current value
//      thistype.eachIndex      --> Current index
// 
// --------------------------------------------------------------------------------------------------------------------------
library Stack requires Table

    globals
        constant integer STACK_INFINITIVE = -1
        constant integer STACK_INVALID = -1
        constant boolean STACK_FIXED_MAX = true
        debug constant string STACK_COLOR = "|cffffcc00"
        debug string STACK_MSG = ""
        constant trigger STACK_EXECUTOR = CreateTrigger()
    endglobals

    module IsStack
        private Table   IndexData   = 0
        private Table   ValueData   = 0
        private integer Count       = 0
        private integer Max         = STACK_INFINITIVE
        private integer Cur         = -1
        private boolean Dir         = true
        
        public static thistype eachStack = 0
        public static integer eachValue = 0
        public static integer eachIndex = 0
        
        debug public boolean print  = false
        
        public static method createEx takes integer max returns thistype
            local thistype this = thistype.allocate()
            set .max = max
            set .IndexData = Table.create()
            set .ValueData = Table.create()
            return this
        endmethod
        
        public static method create takes nothing returns thistype
            return thistype.createEx(STACK_INFINITIVE)
        endmethod
        
        public method operator empty takes nothing returns boolean
            return .Count == 0
        endmethod
        
        public method operator full takes nothing returns boolean
            return .Max != STACK_INFINITIVE and .Count > .Max
        endmethod
        
        public method get takes integer index returns integer
            if not .IndexData.has(index) then
                return STACK_INVALID
            endif
            
            return .IndexData[index]
        endmethod
        
        public method has takes integer value returns boolean
            return .ValueData.has(value)
        endmethod
        
        public method random takes nothing returns integer
            if .Count == 0 then
                return STACK_INVALID
            endif
            
            return .IndexData[GetRandomInt(0, .Count -1)]
        endmethod
        
        public method index takes integer value returns integer
            if not .ValueData.has(value) then
                return STACK_INVALID
            endif
            
            return .ValueData[value]
        endmethod
        
        public method add takes integer value returns boolean
            if .has(value) then
                return false
            endif
            
            if .Max != STACK_INFINITIVE and .Count >= .Max then
                return false
            endif

            set .IndexData[.Count] = value
            set .ValueData[value] = .Count
            set .Count = .Count +1
            
            debug if .print then
                debug set STACK_MSG = STACK_COLOR + "Stack|r[" + STACK_COLOR+ I2S(this) + "|r]: "
                debug set STACK_MSG = STACK_MSG + "Added " + STACK_COLOR + I2S(value) + "|r" + " at [" + STACK_COLOR + I2S(.Count -1) + "|r]"
                debug call BJDebugMsg(STACK_MSG)
            debug endif
            
            return true
        endmethod
        
        method operator count takes nothing returns integer
            return .Count
        endmethod
        
        public method delete takes integer value returns boolean
            local integer index = .index(value)
            local integer lastIndex = .Count -1
            local integer lastValue = .get(lastIndex)
            
            if not .has(value) then
                return false
            endif
            
            call .ValueData.remove(value)
            
            if index < lastIndex then
                set .IndexData[index] = lastValue
                set .ValueData[lastValue] = index
                debug if .print then
                    debug set STACK_MSG = STACK_COLOR + "Stack|r[" + STACK_COLOR+ I2S(this) + "|r]: "
                    debug set STACK_MSG = STACK_MSG + "Pushed " + STACK_COLOR + I2S(value) + "|r" + " from [" + STACK_COLOR + I2S(lastIndex) + "|r] " 
                    debug set STACK_MSG = STACK_MSG + "to [" + STACK_COLOR + I2S(index) + "|r]"
                    debug call BJDebugMsg(STACK_MSG)
                debug endif
            else
                call .IndexData.remove(index)
                debug if .print then
                    debug set STACK_MSG = STACK_COLOR + "Stack|r[" + STACK_COLOR+ I2S(this) + "|r]: "
                    debug set STACK_MSG = STACK_MSG + "Deleted [" + STACK_COLOR + I2S(index) + "|r] = " + STACK_COLOR + I2S(value) + "|r"
                    debug call BJDebugMsg(STACK_MSG)
                debug endif
            endif

            set .Count = .Count -1
            if .Cur == index then
                if .Dir and .hasPrev() then
                    set .Cur = .Cur -1
                    debug if .print then
                        debug set STACK_MSG = STACK_COLOR + "Stack|r[" + STACK_COLOR+ I2S(this) + "|r]: "
                        debug set STACK_MSG = STACK_MSG + "Decreased cursor to [" + STACK_COLOR + I2S(.Cur) + "|r]"
                        debug call BJDebugMsg(STACK_MSG)
                    debug endif
                elseif not .Dir and .hasNext() then
                    set .Cur = .Cur +1
                    debug if .print then
                        debug set STACK_MSG = STACK_COLOR + "Stack|r[" + STACK_COLOR+ I2S(this) + "|r]: "
                        debug set STACK_MSG = STACK_MSG + "Increased cursor to [" + STACK_COLOR + I2S(.Cur) + "|r]"
                        debug call BJDebugMsg(STACK_MSG)
                    debug endif
                endif
            endif

            return true
        endmethod
        
        public method clear takes nothing returns integer
            local integer amount = .Count
            local boolean error = false
            loop
                exitwhen .Count == 0
                set error = .delete(.IndexData[.Count])
                if (error) then
                    debug call BJDebugMsg("Clear failed, couldn't delete: " + I2S(.IndexData[.Count]) + " at " + I2S(.Count))
                    exitwhen true
                endif 
            endloop
            
            return amount
        endmethod
        
        public method each takes code forEach returns integer
            local integer index = 1
            local integer iterated = 0
            local integer value = 0
            local boolean success = true
            local boolexpr forEachWrapper = Filter(forEach)
            local triggercondition forEachCondition = TriggerAddCondition(STACK_EXECUTOR, forEachWrapper)
            
            set thistype.eachStack = this
            loop
                exitwhen index > .Count
                set thistype.eachIndex = index
                
                set value = .IndexData[index]
                set thistype.eachValue = value
                
                set success = TriggerEvaluate(STACK_EXECUTOR)
                
                if .has(value) then
                    set index = index +1
                endif
                
                if success then
                    set iterated = iterated +1
                endif
            endloop
            
            set thistype.eachStack = 0
            set thistype.eachValue = 0
            set thistype.eachIndex = 0
            
            call TriggerRemoveCondition(STACK_EXECUTOR, forEachCondition)
            call DestroyBoolExpr(forEachWrapper)
            set forEachWrapper = null
            set forEachCondition = null
            
            return iterated
        endmethod
        
        method operator max takes nothing returns integer
            return .Max
        endmethod
        
        method operator max= takes integer max returns boolean
            if not STACK_FIXED_MAX then
                set .Max = max
                return true
            endif
            return false
        endmethod
        
        public method merge takes thistype mergeStack returns nothing
            local integer tmpValue = 0
            loop
                exitwhen mergeStack.count <= 0
                
                set tmpValue = mergeStack.get(mergeStack.count -1)
                call .add(tmpValue)
                call mergeStack.delete(tmpValue)
            endloop
        endmethod
        
        public method split takes thistype new, integer pos returns nothing
            local integer index = .Count -1
            
            loop
                exitwhen index < pos
                
                call new.add(.ValueData[index])
                call .delete(.ValueData[index])
                
                set index = index -1
            endloop
        endmethod
        
        public method switch takes integer left, integer right returns boolean
            local integer leftIndex = .ValueData[left]
            local integer rightIndex = .ValueData[right]
            
            if not .ValueData.has(left) or not .ValueData.has(right) then
                return false
            endif
            
            set .IndexData[leftIndex] = right
            set .ValueData[right] = leftIndex
            set .IndexData[rightIndex] = left
            set .ValueData[left] = rightIndex
            
            debug if .print then
                debug set STACK_MSG = STACK_COLOR + "Stack|r[" + STACK_COLOR+ I2S(this) + "|r]: "
                debug set STACK_MSG = STACK_MSG + "Switched [" + STACK_COLOR + I2S(leftIndex) + "|r] = " + STACK_COLOR + I2S(left)
                debug set STACK_MSG = STACK_MSG + "|r with [" + STACK_COLOR + I2S(rightIndex) + "|r] = " + STACK_COLOR + I2S(right) + "|r"
                debug call BJDebugMsg(STACK_MSG)
            debug endif
            
            return true
        endmethod
        
        public method sort takes boolean asc returns nothing
            local integer out = -1
            local integer ins = -1
            local integer outVal = -1
            local integer insVal = -1
            debug local boolean print = .print
        
            debug set .print = false
            
            set out = 0
            set ins = out +1
            set outVal = .get(out)
            set insVal = .get(ins)
            loop
                exitwhen out >= .Count
                
                if (insVal < outVal and asc) or (insVal > outVal and not asc) then
                    call .switch(insVal, outVal)
                    debug if .print then
                        debug set STACK_MSG = STACK_COLOR + "Stack|r[" + STACK_COLOR+ I2S(this) + "|r]: "
                        debug set STACK_MSG = STACK_MSG + "Replaced " + STACK_COLOR + I2S(outVal) + "|r "
                        debug set STACK_MSG = STACK_MSG + "with " + STACK_COLOR + I2S(insVal) + "|r"
                        debug call BJDebugMsg(STACK_MSG)
                    debug endif
                endif
                set ins = ins +1
                
                if ins >= .Count then
                    set out = out +1
                    set ins = out +1
                endif
                
                set insVal = .get(ins)
                set outVal = .get(out)
            endloop
            
            debug set .print = print
        endmethod
        
        method operator cursor takes nothing returns integer
            return .Cur
        endmethod
        
        method operator direction takes nothing returns boolean
            return .Dir
        endmethod
        
        public method hasNext takes nothing returns boolean
            return .Cur +1 < .Count
        endmethod
        
        public method getNext takes nothing returns integer
            if .hasNext() then
                set .Cur = .Cur +1
                set .Dir = true
                return .get(.Cur)
            endif
            return STACK_INVALID
        endmethod
        
        public method hasPrev takes nothing returns boolean
            return .Cur > 0
        endmethod
        
        public method getPrev takes nothing returns integer
            if .hasPrev() then
                set .Cur = .Cur -1
                set .Dir = false
                return .get(.Cur)
            endif
            return STACK_INVALID
        endmethod
        
        public method reset takes nothing returns nothing
            set .Cur = -1
        endmethod
        
        public method end takes nothing returns nothing
            set .Cur = .Count
        endmethod
        
        public method getFirst takes nothing returns integer
            if .Count > 0 then
                return .get(0)
            endif
            return STACK_INVALID
        endmethod
        
        public method getLast takes nothing returns integer
            if .Count > 0 then
                return .get(.Count -1)
            endif
            return STACK_INVALID
        endmethod
        
        public method destroy takes nothing returns nothing
            // tables will flush themselves on destroy
            call .IndexData.destroy()
            call .ValueData.destroy()
        endmethod
    endmodule
    
    struct Stack
        implement IsStack
    endstruct

endlibrary