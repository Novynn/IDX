//TESH.scrollpos=184
//TESH.alwaysfold=0
library Multibars initializer InitMultibars

globals
    // ====================
    // PUBLIC CONSTANTS
    // ====================    
    
    // These constants should not be modified
    
    constant integer MULTIBAR_TYPE_HEALTH = 1
    constant integer MULTIBAR_TYPE_MANA = 2
    constant integer MULTIBAR_TYPE_EXPERIENCE = 3
    constant integer MULTIBAR_TYPE_BUILD = 4
    constant integer MULTIBAR_TYPE_CHUNK = 5
    constant integer MULTIBAR_TYPE_RADIO = 6
    constant integer MULTIBAR_TYPE_MAC = 7
    constant integer MULTIBAR_TYPE_ORANGE = 8
    constant integer MULTIBAR_TYPE_HEARTS = 9
    constant integer MULTIBAR_TYPE_HEARTS_UP = 10
    constant integer MULTIBAR_TYPE_MAGIC = 11
    
    
    // ====================
    // END PUBLIC CONSTANTS
    // ====================
    
    
    //Private Variables    
    
    private integer Gcurrent = 0        
    private string array Gbartype
    private string array Gfiletype
    private string array Gdir
    private integer array Gdivs     
      
endglobals

struct Multibar
    integer row
    integer colstart
    integer numcols
    integer numdivs
    real max
    real current
    string bartype
    string filetype
    string dir
    multiboard whichboard
    integer array curfill[16]

    static method create takes multiboard whichboard, integer colstart, integer row, integer size, real maxval, real currentval, integer bartype returns Multibar
        local Multibar b = Multibar.allocate()
        local integer i = 0
        set b.whichboard = whichboard
        if row > 32 then
            debug call BJDebugMsg("Multibars Error: Multiboards only have 32 rows!")
        elseif row < 0 then
            debug call BJDebugMsg("Multibars Error: Multiboards do not have negative rows!")
        endif
        set b.row = row
        set b.colstart = colstart
        if colstart > 16 then
            debug call BJDebugMsg("Multibars Error: Multiboards only have 16 columns")
        elseif colstart < 0 then
            debug call BJDebugMsg("Multibars Error: Multiboards do not have negative columns!")
        endif
        if size < 2 then
            debug call BJDebugMsg("Multibars Error: Bar size must be greater than 1!")
        elseif size > 16 then
            debug call BJDebugMsg("Multibars Error: Bar size must be less than 17!")
        endif
        set b.numcols = size
        set b.max = maxval
        if maxval < 0 then
            debug call BJDebugMsg("Multibars Error: Multibars does not support negative values!")
            set b.max = 1
        endif
        set b.current = currentval
        if currentval < 0 then
            debug call BJDebugMsg("Multibars Error: Multibars does not support negative values!")
            set b.current = 0
        elseif currentval > b.max then
            debug call BJDebugMsg("Multibars Error: Value cannot exceed max value!")
            set b.current = b.max
        endif
        if bartype > Gcurrent then
            debug call BJDebugMsg("Multibars Error: Invalid bartype!")
        endif
        set b.numdivs = Gdivs[bartype]
        set b.bartype = Gbartype[bartype]
        set b.filetype = Gfiletype[bartype]
        set b.dir = Gdir[bartype]
        loop
            exitwhen i > 15
            set b.curfill[i] = -1
            set i = i + 1
        endloop
        call b.SetMultiboardBar()
        call b.UpdateBoard()
        return b
    endmethod
    
    method onDestroy takes nothing returns nothing
        set .whichboard = null
    endmethod
    
    private method UpdateBoard takes nothing returns nothing
        local real step = .max/.numcols
        local real step2 = step/.numdivs
        local real val = .current
        local multiboarditem mbi
        local integer col = .colstart
        local integer num
        loop
            exitwhen val <= 0.
            if val >= step then
                if .curfill[col] != .numdivs then // check if it requires an update
                    set mbi = MultiboardGetItem(.whichboard, .row, col)
                    if col == .colstart then
                        call MultiboardSetItemIcon(mbi, .dir+.bartype+"L"+I2S(.numdivs)+.filetype) // Left
                    elseif col == .colstart+.numcols-1 then
                        call MultiboardSetItemIcon(mbi, .dir+.bartype+"R"+I2S(.numdivs)+.filetype) // Right
                    else
                        call MultiboardSetItemIcon(mbi, .dir+.bartype+"M"+I2S(.numdivs)+.filetype) // Middle
                    endif
                    call MultiboardReleaseItem(mbi)
                    set .curfill[col] = .numdivs
                endif
                set val = val - step
            else
                set num = R2I((val/step2)+0.5)
                if .curfill[col] != num then // check if it requires an update
                    set mbi = MultiboardGetItem(.whichboard, .row, col)
                    if col == .colstart then
                        call MultiboardSetItemIcon(mbi, .dir+.bartype+"L"+I2S(num)+.filetype) // Left
                    elseif col == .colstart+.numcols-1 then
                        call MultiboardSetItemIcon(mbi, .dir+.bartype+"R"+I2S(num)+.filetype) // Right
                    else
                        call MultiboardSetItemIcon(mbi, .dir+.bartype+"M"+I2S(num)+.filetype) // Middle
                    endif
                    call MultiboardReleaseItem(mbi)
                    set .curfill[col] = num
                endif
                set val = 0.
            endif
            set col = col + 1
        endloop
        loop
            exitwhen col >= .colstart + .numcols
            if .curfill[col] != 0 then // check if it requires an update
                set mbi = MultiboardGetItem(.whichboard, .row, col)
                if col == .colstart then
                    call MultiboardSetItemIcon(mbi, .dir+.bartype+"L0"+.filetype) // Left
                elseif col == .colstart+.numcols-1 then
                    call MultiboardSetItemIcon(mbi, .dir+.bartype+"R0"+.filetype) // Right
                else
                    call MultiboardSetItemIcon(mbi, .dir+.bartype+"M0"+.filetype) // Middle
                endif
                call MultiboardReleaseItem(mbi)
                set .curfill[col] = 0
            endif
            set col = col + 1
        endloop
        set mbi = null
    endmethod
    
    method UpdateValue takes real newvalue, boolean update returns nothing
        if newvalue > .max then
            set .current = .max
        elseif newvalue < 0. then
            set .current = 0.
        else
            set .current = newvalue
        endif
        if update then
            call .UpdateBoard()
        endif
    endmethod
    
    method UpdateMaxValue takes real newvalue, boolean update returns nothing
        if newvalue < 1 then
            set .max = 1
        else
            set .max = newvalue
        endif
        if .current > .max then
                set .current = .max
            endif
        if update then
            call .UpdateBoard()
        endif
    endmethod
    
    private method SetMultiboardBar takes nothing returns nothing
        local integer col = .colstart
        local integer end = col + .numcols
        local multiboarditem mbi
        loop
            exitwhen col >= end
            set mbi = MultiboardGetItem(.whichboard, .row, col)
            call MultiboardSetItemWidth(mbi, 0.01)
            call MultiboardSetItemStyle(mbi, false, true)
            call MultiboardReleaseItem(mbi)
            set col = col + 1
        endloop
        set mbi = null
    endmethod
endstruct

public function CreateBartype takes string name, string filetype, string directory, integer divisions returns integer
    set Gcurrent = Gcurrent + 1
    set Gbartype[Gcurrent] = name
    set Gfiletype[Gcurrent] = filetype
    set Gdir[Gcurrent] = directory
    set Gdivs[Gcurrent] = divisions
    return Gcurrent
endfunction

private function CreateNativeBartype takes integer bartype, string name, string filetype, string directory, integer divisions returns nothing
    if bartype > Gcurrent then
        set Gcurrent = bartype
    endif
    set Gbartype[bartype] = name
    set Gfiletype[bartype] = filetype
    set Gdir[bartype] = directory
    set Gdivs[bartype] = divisions
endfunction

private function InitMultibars takes nothing returns nothing    
    // Set-up Native Bartypes
    call CreateNativeBartype(MULTIBAR_TYPE_HEALTH, "Health", ".tga", "war3mapImported\\", 8)
    call CreateNativeBartype(MULTIBAR_TYPE_MANA, "Mana", ".tga", "war3mapImported\\", 8)
    call CreateNativeBartype(MULTIBAR_TYPE_EXPERIENCE, "Experience", ".tga", "war3mapImported\\", 8)
    call CreateNativeBartype(MULTIBAR_TYPE_BUILD, "Build", ".tga", "war3mapImported\\", 8)
    call CreateNativeBartype(MULTIBAR_TYPE_CHUNK, "Chunk", ".tga", "war3mapImported\\", 2)
    call CreateNativeBartype(MULTIBAR_TYPE_RADIO, "Radio", ".tga", "war3mapImported\\", 8)
    call CreateNativeBartype(MULTIBAR_TYPE_MAC, "Mac", ".tga", "war3mapImported\\", 8)
    call CreateNativeBartype(MULTIBAR_TYPE_ORANGE, "Orange", ".tga", "war3mapImported\\", 2)
    call CreateNativeBartype(MULTIBAR_TYPE_HEARTS, "ZeldaHearts", ".tga", "war3mapImported\\", 4)
    call CreateNativeBartype(MULTIBAR_TYPE_HEARTS_UP, "ZeldaHeartsUp", ".tga", "war3mapImported\\", 4)
    call CreateNativeBartype(MULTIBAR_TYPE_MAGIC, "ZeldaMagic", ".tga", "war3mapImported\\", 8)
endfunction

endlibrary