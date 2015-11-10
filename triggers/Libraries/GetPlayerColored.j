//TESH.scrollpos=3
//TESH.alwaysfold=0
library GetPlayerColored initializer init requires GetPlayerActualName
    // GetPlayerColored by Ammorth
    // v1.2
    // functions should be self-explanatory
    // Credits to DioD for multiple fixes

    globals
        private string array PlayerColor
        private integer array redhex
        private integer array greenhex
        private integer array bluehex
    endglobals

    function GetPlayerNameColored takes player p returns string // colored player name
        return PlayerColor[GetHandleId(GetPlayerColor(p))]+GetPlayerActualName(p)+"|r"
    endfunction

    function GetPlayerTextColor takes player p returns string // only textcode
        return PlayerColor[GetHandleId(GetPlayerColor(p))]
    endfunction

    function GetPlayerRedHex takes player p returns integer // integer value for red
        return redhex[GetHandleId(GetPlayerColor(p))]
    endfunction

    function GetPlayerGreenHex takes player p returns integer // integer value for green
        return greenhex[GetHandleId(GetPlayerColor(p))]
    endfunction

    function GetPlayerBlueHex takes player p returns integer // integer value for blue
        return bluehex[GetHandleId(GetPlayerColor(p))]
    endfunction

    private function init takes nothing returns nothing
        set PlayerColor[0] = "|CFFFF0303" // red
        set PlayerColor[1] = "|CFF0042FF" // blue
        set PlayerColor[2] = "|CFF1CE6B9" // teal
        set PlayerColor[3] = "|CFF540081" // purple
        set PlayerColor[4] = "|CFFFFFF01" // yellow
        set PlayerColor[5] = "|CFFFE8A0E" // orange
        set PlayerColor[6] = "|CFF20C000" // green
        set PlayerColor[7] = "|CFFE55BB0" // pink
        set PlayerColor[8] = "|CFF959697" // grey
        set PlayerColor[9] = "|CFF7EBFF1" // light blue
        set PlayerColor[10] = "|CFF106246" // dark green
        set PlayerColor[11] = "|CFF4E2A04" // brown
        set redhex[0] = 255
        set redhex[1] = 0
        set redhex[2] = 28
        set redhex[3] = 84
        set redhex[4] = 255
        set redhex[5] = 254
        set redhex[6] = 32
        set redhex[7] = 229
        set redhex[8] = 149
        set redhex[9] = 126
        set redhex[10] = 16
        set redhex[11] = 78
        set greenhex[0] = 3
        set greenhex[1] = 66
        set greenhex[2] = 230
        set greenhex[3] = 0
        set greenhex[4] = 255
        set greenhex[5] = 138
        set greenhex[6] = 192
        set greenhex[7] = 91
        set greenhex[8] = 150
        set greenhex[9] = 191
        set greenhex[10] = 98
        set greenhex[11] = 42
        set bluehex[0] = 3
        set bluehex[1] = 255
        set bluehex[2] = 185
        set bluehex[3] = 129
        set bluehex[4] = 1
        set bluehex[5] = 14
        set bluehex[6] = 0
        set bluehex[7] = 176
        set bluehex[8] = 151
        set bluehex[9] = 241
        set bluehex[10] = 70
        set bluehex[11] = 4
    endfunction

endlibrary