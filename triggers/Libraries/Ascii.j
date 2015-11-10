//TESH.scrollpos=0
//TESH.alwaysfold=0
library Ascii
///////////////////////////////////////////////////////////////////
//      function Char2Ascii takes string s returns integer
//          integer ascii = Char2Ascii("F")
//
//      function Ascii2Char takes integer a returns string
//          string char = Ascii2Char('F')
//
//      function A2S takes integer a returns string
//          string rawcode = A2S('CODE')
//
//      function S2A takes string s returns integer
//          integer rawcode = S2A("CODE")
//
///////////////////////////////////////////////////////////////////
    globals
        private integer array i //hash
        private string array c  //char
    endglobals
    function Char2Ascii takes string s returns integer
        local integer a
        if ("\\"==s) then
            return 92
        endif
        set a=i[StringHash(s)/0x1F0748+0x3EA]
        if (s!=c[a]) then
            debug if (0==a) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"ASCII ERROR: INVALID CHARACTER")
                debug return 0
            debug endif
            return a+32
        endif
        return a
    endfunction
    function Ascii2Char takes integer a returns string
        return c[a]
    endfunction
    function A2S takes integer a returns string
        local string s=""
        loop
            set s=c[a-a/256*256]+s
            set a=a/256
            exitwhen 0==a
        endloop
        return s
    endfunction
    function S2A takes string s returns integer
        local integer a=0
        local integer l=StringLength(s)
        local integer j=0
        local string m
        local integer h
        loop
            exitwhen j==l
            set m=SubString(s,j,j+1)
            if ("\\"==m) then
                set a=a*256+92
            else
                set h=i[StringHash(m)/0x1F0748+0x3EA]
                if (m!=c[h]) then
                    debug if (0==h) then
                        debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"ASCII ERROR: INVALID CHARACTER")
                        debug return 0
                    debug endif
                    set a=a*256+h+32
                else
                    set a=a*256+h
                endif
            endif
            set j=j+1
        endloop
        return a
    endfunction
    private module Init
        private static method onInit takes nothing returns nothing
            set i[931]=8
            set i[1075]=9
            set i[1586]=10
            set i[1340]=12
            set i[412]=13
            set i[198]=32
            set i[1979]=33
            set i[1313]=34
            set i[1003]=35
            set i[1264]=36
            set i[983]=37
            set i[1277]=38
            set i[306]=39
            set i[904]=40
            set i[934]=41
            set i[917]=42
            set i[1972]=43
            set i[1380]=44
            set i[1985]=45
            set i[869]=46
            set i[1906]=47
            set i[883]=48
            set i[1558]=49
            set i[684]=50
            set i[582]=51
            set i[668]=52
            set i[538]=53
            set i[672]=54
            set i[1173]=55
            set i[71]=56
            set i[277]=57
            set i[89]=58
            set i[1141]=59
            set i[39]=60
            set i[1171]=61
            set i[51]=62
            set i[305]=63
            set i[0]=64
            set i[222]=65
            set i[178]=66
            set i[236] =67
            set i[184]=68
            set i[1295]=69
            set i[1390]=70
            set i[1276]=71
            set i[203]=72
            set i[1314]=73
            set i[209]=74
            set i[1315]=75
            set i[170]=76
            set i[1357]=77
            set i[1343]=78
            set i[1397]=79
            set i[1420]=80
            set i[1419]=81
            set i[1396]=82
            set i[1374]=83
            set i[1407]=84
            set i[499]=85
            set i[1465]=86
            set i[736]=87
            set i[289]=88
            set i[986]=89
            set i[38]=90
            set i[1230]=91
            set i[1636]=93
            set i[1416]=94
            set i[1917]=95
            set i[217]=96
            set i[833]=123
            set i[1219]=124
            set i[553]=125
            set i[58]=126
            set c[8]="\b"
            set c[9]="\t"
            set c[10]="\n"
            set c[12]="\f"
            set c[13]="\r"
            set c[32]=" "
            set c[33]="!"
            set c[34]="\""
            set c[35]="#"
            set c[36]="$"
            set c[37]="%"
            set c[38]="&"
            set c[39]="'"
            set c[40]="("
            set c[41]=")"
            set c[42]="*"
            set c[43]="+"
            set c[44]=","
            set c[45]="-"
            set c[46]="."
            set c[47]="/"
            set c[48]="0"
            set c[49]="1"
            set c[50]="2"
            set c[51]="3"
            set c[52]="4"
            set c[53]="5"
            set c[54]="6"
            set c[55]="7"
            set c[56]="8"
            set c[57]="9"
            set c[58]=":"
            set c[59]=";"
            set c[60]="<"
            set c[61]="="
            set c[62]=">"
            set c[63]="?"
            set c[64]="@"
            set c[65]="A"
            set c[66]="B"
            set c[67]="C"
            set c[68]="D"
            set c[69]="E"
            set c[70]="F"
            set c[71]="G"
            set c[72]="H"
            set c[73]="I"
            set c[74]="J"
            set c[75]="K"
            set c[76]="L"
            set c[77]="M"
            set c[78]="N"
            set c[79]="O"
            set c[80]="P"
            set c[81]="Q"
            set c[82]="R"
            set c[83]="S"
            set c[84]="T"
            set c[85]="U"
            set c[86]="V"
            set c[87]="W"
            set c[88]="X"
            set c[89]="Y"
            set c[90]="Z"
            set c[92]="\\"
            set c[97]="a"
            set c[98]="b"
            set c[99]="c"
            set c[100]="d"
            set c[101]="e"
            set c[102]="f"
            set c[103]="g"
            set c[104]="h"
            set c[105]="i"
            set c[106]="j"
            set c[107]="k"
            set c[108]="l"
            set c[109]="m"
            set c[110]="n"
            set c[111]="o"
            set c[112]="p"
            set c[113]="q"
            set c[114]="r"
            set c[115]="s"
            set c[116]="t"
            set c[117]="u"
            set c[118]="v"
            set c[119]="w"
            set c[120]="x"
            set c[121]="y"
            set c[122]="z"
            set c[91]="["
            set c[93]="]"
            set c[94]="^"
            set c[95]="_"
            set c[96]="`"
            set c[123]="{"
            set c[124]="|"
            set c[125]="}"
            set c[126]="~"
        endmethod
    endmodule
    private struct Inits extends array
        implement Init
    endstruct
endlibrary