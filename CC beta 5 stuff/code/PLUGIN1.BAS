DECLARE SUB zoom (x!)

DECLARE SUB neatfont (txt$, sx%, sy%, clr%, sty%, size%)
DIM SHARED txt AS STRING, sx%, sy%, clr%, sty%, size%
DIM melt%(3000)
DIM SHARED palhold(0 TO 255, 1 TO 3) AS INTEGER
DECLARE SUB fadeout ()
DECLARE SUB fadein ()
DECLARE SUB bmp (data$)
DECLARE SUB melter ()
DECLARE SUB qlogo ()
CLS

'Set up sceduler and cusmorizations
ON ERROR GOTO temp
OPEN "START.CCL" FOR INPUT AS #5
INPUT #5, scedone, sdone$, stone$, sfone$
INPUT #5, scedtwo, sdtwo$, sttwo$, sftwo$
INPUT #5, scedthree, sdthree$, stthree$, sfthree$
INPUT #5, scedfour, sdfour$, stfour$, sffour$
INPUT #5, scedfive, sdfive$, stfive$, sffive$
INPUT #5, scedsix, sdsix$, stsix$, sfsix$
INPUT #5, redaz, blueaz, greenaz, redsx, bluesx, greensx, reddc, bluedc, greendc, redfv, bluegb, greenfv, redgb, bluegb, greengb, redhn, bluehn, greenhn
INPUT #5, ccol, lptt, qlo, melt, stgr, stgf$

CLOSE #5


GOTO missmeme
temp:
scedone = 0: sdone = 0: stone = 0: sfone = 0
scedtwo = 0: sdtwo = 0: sttwo = 0: sftwo = 0
scedthree = 0: sdthree = 0: stthree = 0: sfthree = 0
scedfour = 0: sdfour = 0: stfour = 0: sffour = 0
scedfive = 0: sdfive = 0: stfive = 0: sffive = 0
scedsix = 0: sdsix = 0: stsix = 0: sfsix = 0
ccol = 0
lptt = 1: qlo = 0: melt = 0: stgr = 0

missmeme:
'Set up groups
Groupfile$ = "Group file not loaded": gro = 0: one = 0: two = 0: thr = 0: fff = 0: fiv = 0: six = 0: sev = 0: eig = 0: nin = 0: zer = 0


'Error hander definitions
CONST BADFILENAME = 53
'GOTO restart
'  BIOS places address of parallel ports starting at absolute address &H408
'  LPT1 low byte at &h408, high byte at &H409
'  LPT2 low byte at &H40A, high byte at &H40B
'  LPT3 low byte at &H40C, high byte at &H40D
'  Possible values are &H0278, &H0378, &H03BC, and 0 if not installed

'  Find printer ports if installed

DEF SEG = 0
lpt1 = PEEK(&H408) + 256 * PEEK(&H409)
lpt2 = PEEK(&H40A) + 256 * PEEK(&H40B)
lpt3 = PEEK(&H40C) + 256 * PEEK(&H40D)
DEF SEG

IF lpt1 = 0 THEN
        PRINT "1.  lpt1 is not installed."
ELSE
        PRINT "1.  lpt1 is installed at address "; lpt1; " decimal."
END IF

IF lpt2 = 0 THEN
        PRINT "2.  lpt2 is not installed."
ELSE
        PRINT "2.  lpt2 is installed at address "; lpt2; " decimal."
END IF

IF lpt3 = 0 THEN
        PRINT "3.  lpt3 is not installed."
ELSE
        PRINT "3.  lpt3 is installed at address "; lpt3; " decimal."
END IF

PRINT
DO
n% = lptt
30
'  Assign Base0% to selected port address
'  Base is a keyword in Qbasic so Base0% is used instead

    IF n% = 1 THEN Base0% = lpt1
    IF n% = 2 THEN Base0% = lpt2
    IF n% = 3 THEN Base0% = lpt3

    IF Base0% = 0 THEN
        PRINT "That port doesn't exits, try again."
        n% = 0
    END IF
IF qlo = 1 THEN CALL qlogo: GOTO restart

LOOP WHILE n% > 3 OR n% < 1
PRINT : PRINT : PRINT : PRINT "                …ÕÕÕÕÕÕª"
                        PRINT "                ∫  PC  ∫                         …ÕÕÕÕÕÕª      "
                        PRINT "                »ÕÀÕÕÀÕº                         ∫"; CHR$(15); CHR$(15); CHR$(15); CHR$(15); CHR$(15); CHR$(15); "∫"
                        PRINT "                 €€€€€"; CHR$(8); "                          "; CHR$(8); "ÕÕÕÕÕÕº"
FOR y = 0 TO 1
FOR x = 24 TO 49
LOCATE 11, x
PRINT CHR$(16)
FOR a = 0 TO 1999: NEXT a
NEXT x

FOR x = 24 TO 49
LOCATE 11, x
PRINT CHR$(0)
FOR a = 0 TO 1999: NEXT a
NEXT x

FOR x = 49 TO 25 STEP -1
LOCATE 11, x
PRINT CHR$(17)
FOR a = 0 TO 1999: NEXT a
NEXT x
FOR x = 49 TO 25 STEP -1
LOCATE 11, x
PRINT CHR$(0)
FOR a = 0 TO 1999: NEXT a

NEXT x

NEXT y

SCREEN 13

CLS

pause = TIMER + 1
DO WHILE pause > TIMER
LOOP

x = 50: Xdelta = 8: r = 32: B = 0: G = 32

DO WHILE x < 680 AND x > 1
    
PALETTE 72, 65536 * B
    
      x = x + Xdelta
      CALL zoom(x)
        FOR I = 1 TO 4000
        NEXT I
  
        B = B + 1
            IF B > 63 THEN B = 63

     'D
    LINE (-135, 100)-(-210, 100), 0
    LINE (-135, 100)-(-135, -100), 0
    LINE (-135, -100)-(-210, -100), 0
    LINE (-200, 100)-(-200, -100), 0
  
  

    'A
    LINE (-50, 100)-(25, 100), 0
    LINE (-50, 100)-(-50, -100), 0
    LINE (-50, 0)-(25, 0), 0
    LINE (25, 100)-(25, -100), 0
    'N
    LINE (105, 100)-(180, -100), 0
    LINE (180, 100)-(180, -100), 0
  
    LINE (105, 100)-(105, -100), 0

LOOP

B = 1


FOR a = 75 TO 1 STEP -1

    PALETTE B, 256 * B + B
    PALETTE 100, 18
    PALETTE 101, 10

    CIRCLE (-500, 0), a, B
COLOR B
LOCATE 7, 15
PRINT "Extravaganza"
LOCATE 19, 17
PRINT "Presents..."
   
    PAINT (-500, 0), B
  
    LINE (-420, -10)-(450, 5), 101, BF
    LINE (-415, -3)-(445, -3), 100

    CALL zoom(x)

    B = B + 1
        IF B > 63 THEN B = 63


NEXT

CALL zoom(x)
FOR att = 0 TO 139999: NEXT att
CALL fadeout
'Set up laching, BIT, etc...
rrecone = 0: rrectwo = 0: rrec = 0: opened = 0: playing = 0: l = 0: Q = 0: qon = 0: won = 0: W = 0: eon = 0: E = 0: ron = 0: r = 0: ton = 0: T = 0: y = 0: yon = 0: U = 0: uon = 0: I = 0: ion = 0
Qbit = 0: Wbit = 0: Ebit = 0: Rbit = 0: Tbit = 0: Ybit = 0: Ubit = 0: Ibit = 0
grops = 0
'Base1% = Base0% + 1  'assign addresses
'Base2% = Base0% + 2
FullByte% = 0

'  activate Base2% for high open collectors and disable interrupt
OUT Base2%, 8


restart:
CALL fadeout
SCREEN 12
PALETTE
IF ccol = 0 THEN GOTO ccolmiss
coloraz = 65536 * blueaz + 256 * greenaz + redaz
colorsx = 65536 * bluesx + 256 * greensx + redsx
colordc = 65536 * bluedc + 256 * greendc + reddc
colorfv = 65536 * bluefv + 256 * greenfv + redfv
colorgb = 65536 * bluegb + 256 * greengb + redgb
colorhn = 65536 * bluehn + 256 * greenhn + redhn
PALETTE 2, coloraz
PALETTE 7, colorsx
PALETTE 15, colordc
PALETTE 9, colorfv
PALETTE 14, colorgb
PALETTE 4, colorhn
ccolmiss:
CLS
COLOR 7
LOCATE 2, 1
PRINT "Controlling LPT"; n%; "with-"
CALL neatfont("Computer Control", -1, 5, 2, 2, 2)
COLOR 7
LOCATE 2, 57
PRINT "- By Daniel Vincent"
LINE (265, 225)-(355, 250), 8, BF
LINE (270, 245)-(270, 230), 7
LINE (270, 245)-(283.5, 237.5), 7
LINE (283.5, 237.5)-(270, 230), 7
PAINT (275, 235), 7
CIRCLE (300, 237.5), 8
PAINT (300, 237.5), 7
LINE (315, 230)-(330, 245), 14, BF
LINE (342, 245)-(337, 230), 7, BF
LINE (340, 245)-(350, 240), 7, BF

LOCATE 2, 1
PRINT : PRINT : PRINT "                              …ÕÀÕÀÕÀÕÀÕÀÕÀÕÀÕªO"
                PRINT "                              ∫ ∫ ∫ ∫ ∫ ∫ ∫ ∫ ∫U"
                PRINT "                              »Õ Õ Õ Õ Õ Õ Õ ÕºT"
                PRINT "                               q w e r t y u i"

LOCATE 7, 1
PRINT : PRINT : PRINT "                              …ÕÀÕÀÕÀÕÀÕÀÕÀÕÀÕªI"
                PRINT "                              ∫ ∫ ∫ ∫ ∫ ∫ ∫ ∫ ∫N"
                PRINT "                              »Õ Õ Õ Õ Õ Õ Õ Õº"
                PRINT "                                Input monitor"


ok = 0
IF stgr = 1 THEN loadg$ = stgf$:  GOTO xloadgroup
main:

COLOR 9
LOCATE 4, 53: PRINT "Group N¯ KEY 0 <"; zer; ">  "
LOCATE 5, 53: PRINT "Group N¯ KEY 1 <"; one; ">  "
LOCATE 6, 53: PRINT "Group N¯ KEY 2 <"; two; ">  "
LOCATE 7, 53: PRINT "Group N¯ KEY 3 <"; thr; ">  "
LOCATE 8, 53: PRINT "Group N¯ KEY 4 <"; fff; ">  "
LOCATE 9, 53: PRINT "Group N¯ KEY 5 <"; fiv; ">  "
LOCATE 10, 53: PRINT "Group N¯ KEY 6 <"; six; ">  "
LOCATE 11, 53: PRINT "Group N¯ KEY 7 <"; sev; ">  "
LOCATE 12, 53: PRINT "Group N¯ KEY 8 <"; eig; ">  "
LOCATE 13, 53: PRINT "Group N¯ KEY 9 <"; nin; ">  "
LOCATE 15, 53: PRINT "                         "
LOCATE 15, 53: PRINT Groupfile$
COLOR 7
LOCATE 3, 1
PRINT "ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø"
COLOR 1
PRINT "         File Info        "; : COLOR 7: PRINT "≥"
PRINT "                          ≥"
PRINT "                          ≥"
PRINT "                          ≥"
PRINT "                          ≥"
PRINT "                          ≥"
IF opened = 1 THEN LOCATE 5, 1: COLOR 1: PRINT recordation$: LOCATE 6, 1: PRINT longp; "seconds long": LOCATE 7, 1: PRINT numbit; "operations": LOCATE 10, 1
COLOR 7
PRINT "ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥"
COLOR 14
PRINT "         Scheduler"; : COLOR 7: PRINT "        ≥"
PRINT "                          ≥"
PRINT "                          ≥"
PRINT "                          ≥"
PRINT "                          ≥"
PRINT "                          ≥"
PRINT "                          ≥"

PRINT "ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ"
LINE (211, 260)-(211, 276)
LINE (212, 260)-(212, 276)
PRINT "                                       ∫       p = Play                        "
PRINT "    Welcome to Computer Control b4     ∫       c = Record                      "
PRINT "                                       ∫       s = Stop                        "
PRINT "       (under constuction)             ∫       g = Group                       "
PRINT "This is BETA version 4, this means     ∫       d = Schedule                    "
PRINT " you MUST report errors to the author. ∫                                       "
PRINT "                                       ∫                                       "
PRINT " Use the keys below the out box to     ∫       o = Options                     "
PRINT "          control output               ∫       x = Exit                        "
PRINT "                                       ∫       h = Help                        "

nextrecbit:
IF playing = 0 THEN GOTO missplay


INPUT #1, vbit, vtime
l = vbit
IF vtime = 888 THEN playing = 0: CLOSE #1: played = 1: LINE (315, 230)-(330, 245), 14, BF: LINE (270, 245)-(270, 230), 7: LINE (270, 245)-(283.5, 237.5), 7: LINE (283.5, 237.5)-(270, 230), 7: PAINT (275, 235), 7
missplay:

10

IF ok = 0 THEN GOTO miss
rrecone = TIMER
    
d = l
       
IF l >= 128 THEN Qbit = 1 ELSE Qbit = 0
IF Qbit = 1 THEN l = l - 128
IF l >= 64 THEN Wbit = 1 ELSE Wbit = 0
IF Wbit = 1 THEN l = l - 64
IF l >= 32 THEN Ebit = 1 ELSE Ebit = 0
IF Ebit = 1 THEN l = l - 32
IF l >= 16 THEN Rbit = 1 ELSE Rbit = 0
IF Rbit = 1 THEN l = l - 16
IF l >= 8 THEN Tbit = 1 ELSE Tbit = 0
IF Tbit = 1 THEN l = l - 8
IF l >= 4 THEN Ybit = 1 ELSE Ybit = 0
IF Ybit = 1 THEN l = l - 4
IF l >= 2 THEN Ubit = 1 ELSE Ubit = 0
IF Ubit = 1 THEN l = l - 2

Ibit = l
l = d
            


IF Qbit = 0 THEN COLOR 0: LOCATE 5, 32: PRINT CHR$(15) ELSE COLOR 4: LOCATE 5, 32: PRINT CHR$(15)
IF Wbit = 0 THEN COLOR 0: LOCATE 5, 34: PRINT CHR$(15) ELSE COLOR 4: LOCATE 5, 34: PRINT CHR$(15)
IF Ebit = 0 THEN COLOR 0: LOCATE 5, 36: PRINT CHR$(15) ELSE COLOR 4: LOCATE 5, 36: PRINT CHR$(15)
IF Rbit = 0 THEN COLOR 0: LOCATE 5, 38: PRINT CHR$(15) ELSE COLOR 4: LOCATE 5, 38: PRINT CHR$(15)
IF Tbit = 0 THEN COLOR 0: LOCATE 5, 40: PRINT CHR$(15) ELSE COLOR 4: LOCATE 5, 40: PRINT CHR$(15)
IF Ybit = 0 THEN COLOR 0: LOCATE 5, 42: PRINT CHR$(15) ELSE COLOR 4: LOCATE 5, 42: PRINT CHR$(15)
IF Ubit = 0 THEN COLOR 0: LOCATE 5, 44: PRINT CHR$(15) ELSE COLOR 4: LOCATE 5, 44: PRINT CHR$(15)
IF Ibit = 0 THEN COLOR 0: LOCATE 5, 46: PRINT CHR$(15) ELSE COLOR 4: LOCATE 5, 46: PRINT CHR$(15)
ok = 0

IF rrec = 1 THEN rrecfin = rrectwo - rrecone: rrecfin = rrecfin - rrecfin - rrecfin: WRITE #1, l, rrecfin
miss:



    OUT Base0%, l
    IF playing = 1 THEN GOTO missplay2
    
    IF rrec = 1 THEN rrectwo = TIMER
LINE (342, 245)-(337, 230), 7, BF
LINE (340, 245)-(350, 240), 7, BF
IF scedone <> 0 OR scedtwo <> 0 OR scedthree <> 0 OR scedfour <> 0 OR scedfive <> 0 OR scedsix <> 0 THEN scon = 1 ELSE scon = 0
scpn = 0
IF scon = 1 THEN GOTO scudtest
redo:
ssd = 0
dodo:
ssd = ssd + 1
COLOR 0
LOCATE 19, 3
PRINT ssd

IF scedone = 1 AND DATE$ = sdone$ AND TIME$ = stone$ THEN recordation$ = sfone$: scedone = 3: GOTO scplay
IF scedtwo = 1 AND DATE$ = sdtwo$ AND TIME$ = sttwo$ THEN recordation$ = sftwo$: scedtwo = 3: GOTO scplay
IF scedthree = 1 AND DATE$ = sdthree$ AND TIME$ = stthree$ THEN recordation$ = sfthree$: scedthree = 3: GOTO scplay
IF scedfour = 1 AND DATE$ = sdfour$ AND TIME$ = stfour$ THEN recordation$ = sffour$: scedfour = 3: GOTO scplay
IF scedfive = 1 AND DATE$ = sdfive$ AND TIME$ = stfive$ THEN recordation$ = sffive$: scedfive = 3: GOTO scplay
IF scedsix = 1 AND DATE$ = sdsix$ AND TIME$ = stsix$ THEN recordation$ = sfsix$: scedsix = 3: GOTO scplay
IF ssd > 9999 AND scon = 1 THEN GOTO scudtest

    B1% = INP(Base1%) AND &HF0
    B2% = INP(Base2%) AND &HF
    FullByte% = B1% OR B2%
    FullByte% = FullByte% XOR &H8B
    IF Ofull% <> FullByte% THEN GOTO reinput

 Choice$ = INKEY$
    IF Choice$ <> "" THEN GOTO nextdo:
GOTO dodo
nextdo:
    IF LEN(Choice$) = 1 THEN
        ok = 1
LINE (342, 245)-(337, 230), 15, BF
LINE (340, 245)-(350, 240), 15, BF
     COLOR 7
   

     IF played = 1 THEN l = 0: played = 0
     ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 113
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: T = 0: y = 0: U = 0: I = 0: gro = 0
                IF Q = 0 THEN qon = 1: Q = 1: l = l + 128
                IF Q = 1 AND qon = 0 THEN Q = 0: l = l - 128
                qon = 0
            CASE 119
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: T = 0: y = 0: U = 0: I = 0: gro = 0
                IF W = 0 THEN won = 1: W = 1: l = l + 64
                IF W = 1 AND won = 0 THEN W = 0: l = l - 64
                won = 0
            CASE 101
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: T = 0: y = 0: U = 0: I = 0: gro = 0
                IF E = 0 THEN eon = 1: E = 1: l = l + 32
                IF E = 1 AND eon = 0 THEN E = 0: l = l - 32
                eon = 0
            CASE 114
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: T = 0: y = 0: U = 0: I = 0: gro = 0
                IF r = 0 THEN ron = 1: r = 1: l = l + 16
                IF r = 1 AND ron = 0 THEN r = 0: l = l - 16
                ron = 0
            CASE 116
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: T = 0: y = 0: U = 0: I = 0: gro = 0
                IF T = 0 THEN ton = 1: T = 1: l = l + 8
                IF T = 1 AND ton = 0 THEN T = 0: l = l - 8
                ton = 0
            CASE 121
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: T = 0: y = 0: U = 0: I = 0: gro = 0
                IF y = 0 THEN yon = 1: y = 1: l = l + 4
                IF y = 1 AND yon = 0 THEN y = 0: l = l - 4
                yon = 0
            CASE 117
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: T = 0: y = 0: U = 0: I = 0: gro = 0
                IF U = 0 THEN uon = 1: U = 1: l = l + 2
                IF U = 1 AND uon = 0 THEN U = 0: l = l - 2
                uon = 0
            CASE 105
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: T = 0: y = 0: U = 0: I = 0: gro = 0
                IF I = 0 THEN ion = 1: I = 1: l = l + 1
                IF I = 1 AND ion = 0 THEN I = 0: l = l - 1
                ion = 0
            CASE 120
                GOTO Endprog
            CASE 104
                IF melt = 1 THEN CALL melter
                GOTO help
            CASE 111
                IF melt = 1 THEN CALL melter
                GOTO options
            CASE 115
                tripeight% = 888
                IF rrec = 1 THEN WRITE #1, l, tripeight%: FOR time = 0 TO 199999: NEXT time: CLOSE #1: rrec = 0
                SOUND 100, 3
                COLOR 7
                CIRCLE (300, 237.5), 8
                PAINT (300, 237.5), 7
                LINE (315, 230)-(330, 245), 14, BF
                LINE (270, 245)-(270, 230), 7
                LINE (270, 245)-(283.5, 237.5), 7
                LINE (283.5, 237.5)-(270, 230), 7
                PAINT (275, 235), 7
            CASE 103
                IF melt = 1 THEN CALL melter
                GOTO groups
            CASE 112
                IF opened = 0 THEN GOTO loadrec
                OPEN recordation$ FOR INPUT AS #1
                playing = 1
                LINE (315, 230)-(330, 245), 7, BF
                LINE (270, 245)-(270, 230), 2
                LINE (270, 245)-(283.5, 237.5), 2
                LINE (283.5, 237.5)-(270, 230), 2
                PAINT (275, 235), 2
                GOTO main
            CASE 99
                IF melt = 1 THEN CALL melter
                GOTO record
            CASE 49
                gro = 1
                l = one
            CASE 50
                gro = 1
                l = two
            CASE 51
                gro = 1
                l = thr
            CASE 52
                gro = 1
                l = fff
            CASE 53
                gro = 1
                l = fiv
            CASE 54
                gro = 1
                l = six
            CASE 55
                gro = 1
                l = sev
            CASE 56
                gro = 1
                l = eig
            CASE 57
                gro = 1
                l = nin
            CASE 48
                gro = 1
                l = zer
            CASE 100
                IF melt = 1 THEN CALL melter
                GOTO sced
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO 10
reinput:
Base1% = Base0% + 1  'assign addresses
Base2% = Base0% + 2
Ofull% = FullByte%
FullByte% = 255 - FullByte%
IF FullByte% >= 128 THEN inQbit = 1 ELSE inQbit = 0
IF inQbit = 1 THEN FullByte% = FullByte% - 128
IF FullByte% >= 64 THEN inWbit = 1 ELSE inWbit = 0
IF inWbit = 1 THEN FullByte% = FullByte% - 64
IF FullByte% >= 32 THEN inEbit = 1 ELSE inEbit = 0
IF inEbit = 1 THEN FullByte% = FullByte% - 32
IF FullByte% >= 16 THEN inRbit = 1 ELSE inRbit = 0
IF inRbit = 1 THEN FullByte% = FullByte% - 16
IF FullByte% >= 8 THEN inTbit = 1 ELSE inTbit = 0
IF inTbit = 1 THEN FullByte% = FullByte% - 8
IF FullByte% >= 4 THEN inYbit = 1 ELSE inYbit = 0
IF inYbit = 1 THEN FullByte% = FullByte% - 4
IF FullByte% >= 2 THEN inUbit = 1 ELSE inUbit = 0
IF inUbit = 1 THEN FullByte% = FullByte% - 2
inIbit = FullByte%

IF inQbit = 0 THEN COLOR 0: LOCATE 10, 32: PRINT CHR$(15) ELSE COLOR 4: LOCATE 10, 32: PRINT CHR$(15)
IF inWbit = 0 THEN COLOR 0: LOCATE 10, 34: PRINT CHR$(15) ELSE COLOR 4: LOCATE 10, 34: PRINT CHR$(15)
IF inEbit = 0 THEN COLOR 0: LOCATE 10, 36: PRINT CHR$(15) ELSE COLOR 4: LOCATE 10, 36: PRINT CHR$(15)
IF inRbit = 0 THEN COLOR 0: LOCATE 10, 38: PRINT CHR$(15) ELSE COLOR 4: LOCATE 10, 38: PRINT CHR$(15)
IF inTbit = 0 THEN COLOR 0: LOCATE 10, 40: PRINT CHR$(15) ELSE COLOR 4: LOCATE 10, 40: PRINT CHR$(15)
IF inYbit = 0 THEN COLOR 0: LOCATE 10, 42: PRINT CHR$(15) ELSE COLOR 4: LOCATE 10, 42: PRINT CHR$(15)
IF inUbit = 0 THEN COLOR 0: LOCATE 10, 44: PRINT CHR$(15) ELSE COLOR 4: LOCATE 10, 44: PRINT CHR$(15)
IF inIbit = 0 THEN COLOR 0: LOCATE 10, 46: PRINT CHR$(15) ELSE COLOR 4: LOCATE 10, 46: PRINT CHR$(15)
GOTO 10



'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Options>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
options:
LOCATE 19, 1
PRINT "              Options                  ∫                                     "
PRINT "                                       ∫   c  =  Colour settings             "
PRINT "To slightly customize how this program ∫   p  =  Select Parallel Port        "
PRINT "works, please choose an option ----->  ∫   m  =  Melter effect On/Off        "
PRINT "                                       ∫   q  =  Quick logo on startup On/Off"
PRINT "Using LPT"; n%; "                           ∫   g  =  Load group on start up "
IF melt = 1 THEN PRINT "Melter effect is on                    ∫                                     " ELSE PRINT "Melter effect is off                   ∫                                     "
IF qlo = 1 THEN PRINT "Quick logo is on                       ∫   d  =  Load Defults                " ELSE PRINT "Quick logo is off                      ∫   d  =  Load Defults                "
PRINT "No group file on start up              ∫   s  =  Exit and Save               "
PRINT "                                       ∫   x  =  Exit, without saving        "
IF stgr = 1 THEN LOCATE 27, 1: PRINT "                                       ∫": LOCATE 27, 1: PRINT stgf$; " loads on start up"
optloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 100
                ccol = 0
                lpt = 1
                melt = 0
                qlo = 0
                stgr = 0
                PALETTE
                GOTO options
            CASE 103
                grops = 1
                GOTO loadgroupes
            CASE 120
                 grops = 0
                 IF melt = 1 THEN CALL melter
                 GOTO main
            CASE 109
                IF melt = 0 THEN melt = 1: GOTO options ELSE melt = 0: GOTO options
            CASE 113
                IF qlo = 0 THEN qlo = 1: GOTO options ELSE qlo = 0: GOTO options
            CASE 112
                IF melt = 1 THEN CALL melter
                GOTO lptch
            CASE 115
                IF melt = 1 THEN CALL melter
                GOTO sfin
            CASE 99
                IF melt = 1 THEN CALL melter
                ccol = 1
                GOTO colo
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO optloop
lptch:
LOCATE 19, 1
PRINT "         Parallel Port Selector        ∫                                     "
PRINT "                                       ∫                                     "
PRINT "Please choose an installed port by     ∫                                     "
PRINT "pressing the representing number.      ∫                                     "
PRINT "                                       ∫                                     "
PRINT "(Or exit)                              ∫                                     "
PRINT "                                       ∫                                     "
PRINT "                                       ∫                                     "
PRINT "                                       ∫                                     "
PRINT "Note: Addresses shown in decimal.      ∫      x     = Exit this A/Q box      "
LOCATE 22, 41
IF lpt1 = 0 THEN
        PRINT "1.  lpt1 is not installed."
ELSE
        PRINT "1.  lpt1 is installed at address"; lpt1
END IF

LOCATE 23, 41
IF lpt2 = 0 THEN
        PRINT "2.  lpt2 is not installed."
ELSE
        PRINT "2.  lpt2 is installed at address"; lpt2
END IF
LOCATE 24, 41
IF lpt3 = 0 THEN
        PRINT "3.  lpt3 is not installed."
ELSE
        PRINT "3.  lpt3 is installed at address"; lpt3
END IF

lptloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 49
                IF lptt = 1 THEN LOCATE 26, 41: PRINT "Already assiged to this port!": FOR time = 0 TO 199999: NEXT time: GOTO options
                IF lpt1 = 0 THEN LOCATE 26, 41: PRINT "This port is not installed!": FOR time = 0 TO 199999: NEXT time: GOTO options
                lptt = 1
            CASE 50
                IF lptt = 2 THEN LOCATE 26, 41: PRINT "Already assiged to this port!": FOR time = 0 TO 199999: NEXT time: GOTO options
                IF lpt2 = 0 THEN LOCATE 26, 41: PRINT "This port is not installed!": FOR time = 0 TO 199999: NEXT time: GOTO options
                lptt = 2
            CASE 51
                IF lptt = 3 THEN LOCATE 26, 41: PRINT "Already assiged to this port!": FOR time = 0 TO 199999: NEXT time: GOTO options
                IF lpt3 = 0 THEN LOCATE 26, 41: PRINT "This port is not installed!": FOR time = 0 TO 199999: NEXT time: GOTO options
                lptt = 3
            CASE 120
                GOTO options
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO lptloop

colo:
ON ERROR GOTO colo
LOCATE 19, 1
PRINT "           Colour Settings             ∫                                     "
PRINT "               =  Red Green Blue       ∫                                     "
COLOR 2
PRINT "Title colour/Play indicator            "; : COLOR 7: PRINT "∫     a = colour up, z = colour down. "
COLOR 7
PRINT "Normal text colour                     "; : COLOR 7: PRINT "∫     s = colour up, x = colour down. "
COLOR 15
PRINT "High lighted text/Lock indicator       "; : COLOR 7: PRINT "∫     d = colour up, c = colour down. "
COLOR 9
PRINT "Group banks text colour                "; : COLOR 7: PRINT "∫     f = colour up, v = colour down. "
COLOR 14
PRINT "Scedule text colour/Stop indicator     "; : COLOR 7: PRINT "∫     g = colour up, b = colour down. "
COLOR 4
PRINT "Record indicator                       "; : COLOR 7: PRINT "∫     h = colour up, n = colour down. "
PRINT "                                       ∫                                     "
PRINT "Note: Will be upgraded soon!           ∫      e     = Exit this A/Q box      "
cololoop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 101
                 GOTO options
            CASE 97
                greenaz = greenaz + 2
                LOCATE 20, 3: PRINT redaz
                LOCATE 20, 7: PRINT greenaz
                LOCATE 20, 11: PRINT blueaz
                GOTO az
            CASE 122
                greenaz = greenaz - 2
                LOCATE 20, 3: PRINT redaz
                LOCATE 20, 7: PRINT greenaz
                LOCATE 20, 11: PRINT blueaz
               
                GOTO az
            CASE 115
                greensx = greensx + 2
                LOCATE 20, 3: PRINT redsx
                LOCATE 20, 7: PRINT greensx
                LOCATE 20, 11: PRINT bluesx
               
                GOTO sx
            CASE 120
                greensx = greensx - 2
                LOCATE 20, 3: PRINT redsx
                LOCATE 20, 7: PRINT greensx
                LOCATE 20, 11: PRINT bluesx
               
                GOTO sx
            CASE 100
                greendc = greendc + 2
                LOCATE 20, 3: PRINT reddc
                LOCATE 20, 7: PRINT greendc
                LOCATE 20, 11: PRINT bluedc
               
                GOTO dc
            CASE 99
                greendc = greendc - 2
                LOCATE 20, 3: PRINT reddc
                LOCATE 20, 7: PRINT greendc
                LOCATE 20, 11: PRINT bluedc
               
                GOTO dc
            CASE 102
                greenfv = greenfv + 2
                LOCATE 20, 3: PRINT redfv
                LOCATE 20, 7: PRINT greenfv
                LOCATE 20, 11: PRINT bluefv
                GOTO fv
            CASE 118
                greenfv = greenfv - 2
                LOCATE 20, 3: PRINT redfv
                LOCATE 20, 7: PRINT greenfv
                LOCATE 20, 11: PRINT bluefv
                GOTO fv
            CASE 103
                greengb = greengb + 2
                LOCATE 20, 3: PRINT redgb
                LOCATE 20, 7: PRINT greengb
                LOCATE 20, 11: PRINT bluegb
                GOTO gb
            CASE 98
                greengb = greengb - 2
                LOCATE 20, 3: PRINT redgb
                LOCATE 20, 7: PRINT greengb
                LOCATE 20, 11: PRINT bluegb
                GOTO gb
            CASE 104
                greenhn = greenhn + 2
                LOCATE 20, 3: PRINT redhn
                LOCATE 20, 7: PRINT greenhn
                LOCATE 20, 11: PRINT bluehn
                GOTO hn
            CASE 110
                greenhn = greenhn - 2
                LOCATE 20, 3: PRINT redhn
                LOCATE 20, 7: PRINT greenhn
                LOCATE 20, 11: PRINT bluehn
                GOTO hn
            CASE ELSE
                BEEP: GOTO colo
        END SELECT
END IF
GOTO colo
az:
IF greenaz > 60 THEN redaz = redaz + 2: greenaz = 2
IF redaz > 60 THEN blueaz = blueaz + 4: redaz = 2
IF blueaz > 56 THEN blueaz = 0

IF greenaz < 2 THEN redaz = redaz - 2: greenaz = 56
IF redaz < 2 THEN blueaz = blueaz - 4: redaz = 56
IF blueaz < 4 THEN blueaz = 56
coloraz = 65536 * blueaz + 256 * greenaz + redaz
PALETTE 2, coloraz
GOTO cololoop

sx:
IF greensx > 60 THEN redsx = redsx + 2: greensx = 2
IF redsx > 60 THEN bluesx = bluesx + 4: redsx = 2
IF bluesx > 60 THEN bluesx = 0

IF greensx < 2 THEN redsx = redsx - 2: greensx = 56
IF redsx < 2 THEN bluesx = bluesx - 4: redsx = 56
IF bluesx < 2 THEN bluesx = 56
colorsx = 65536 * bluesx + 256 * greensx + redsx
PALETTE 7, colorsx
GOTO cololoop

dc:
IF greendc > 60 THEN reddc = reddc + 2: greendc = 2
IF reddc > 60 THEN bluedc = bluedc + 4: reddc = 2
IF bluedc > 60 THEN bluedc = 0

IF greendc < 2 THEN reddc = reddc - 2: greendc = 56
IF reddc < 2 THEN bluedc = bluedc - 4: reddc = 56
IF bluedc < 2 THEN bluedc = 56
colordc = 65536 * bluedc + 256 * greendc + reddc
PALETTE 15, colordc
GOTO cololoop

fv:
IF greenfv > 60 THEN redfv = redfv + 2: greenfv = 2
IF redfv > 60 THEN bluefv = bluefv + 4: redfv = 2
IF bluefv > 60 THEN bluefv = 0

IF greenfv < 2 THEN redfv = redfv - 2: greenfv = 56
IF redfv < 2 THEN bluefv = bluefv - 4: redfv = 56
IF bluefv < 2 THEN bluefv = 56
colorfv = 65536 * bluefv + 256 * greenfv + redfv
PALETTE 9, colorfv
GOTO cololoop

gb:
IF greengb > 60 THEN redgb = redgb + 2: greengb = 2
IF redgb > 60 THEN bluegb = bluegb + 4: redgb = 2
IF bluegb > 60 THEN bluegb = 0

IF greengb < 2 THEN redgb = redgb - 2: greengb = 56
IF redgb < 2 THEN bluegb = bluegb - 4: redgb = 56
IF bluegb < 2 THEN bluegb = 56
colorgb = 65536 * bluegb + 256 * greengb + redgb
PALETTE 14, colorgb
GOTO cololoop

hn:
IF greenhn > 60 THEN redhn = redhn + 2: greenhn = 2
IF redhn > 60 THEN bluehn = bluehn + 4: redhn = 2
IF bluehn > 60 THEN bluehn = 2

IF greenhn < 2 THEN redhn = redhn - 2: greenhn = 56
IF redhn < 2 THEN bluehn = bluehn - 4: redhn = 56
IF bluehn < 2 THEN bluehn = 56
colorhn = 65536 * bluehn + 256 * greenhn + redhn
PALETTE 4, colorhn
GOTO cololoop



'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Sceduler>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
scplay:
                OPEN recordation$ FOR INPUT AS #1
                playing = 1
                LINE (315, 230)-(330, 245), 7, BF
                LINE (270, 245)-(270, 230), 2
                LINE (270, 245)-(283.5, 237.5), 2
                LINE (283.5, 237.5)-(270, 230), 2
                PAINT (275, 235), 2
LINE (342, 245)-(337, 230), 15, BF
LINE (340, 245)-(350, 240), 15, BF
               
                GOTO main



scudtest:

IF scpn = 1 THEN GOTO scudt
scpn = 1
COLOR 14
LOCATE 11, 1
IF scedone = 3 THEN scedone = 0: GOTO endscd
IF scedtwo = 3 THEN scedtwo = 0: GOTO endscd
IF scedthree = 3 THEN scedthree = 0: GOTO endscd
IF scedfour = 3 THEN scedfour = 0: GOTO endscd
IF scedfive = 3 THEN scedfive = 0: GOTO endscd
IF scedsix = 3 THEN scedsix = 0: GOTO endscd


PRINT "         Scheduler ˛"; : COLOR 7: PRINT "      ≥"
IF scedone = 1 THEN PRINT "1} "; sdone$; " at "; stone$; " ≥"
IF scedtwo = 1 THEN PRINT "2} "; sdtwo$; " at "; sttwo$; " ≥"
IF scedthree = 1 THEN PRINT "3} "; sdthree$; " at "; stthree$; " ≥"
IF scedfour = 1 THEN PRINT "4} "; sdfour$; " at "; stfour$; " ≥"
IF scedfive = 1 THEN PRINT "5} "; sdfive$; " at "; stfive$; " ≥"
IF scedsix = 1 THEN PRINT "6} "; sdsix$; " at "; stsix$; " ≥"

GOTO redo

scudt:
scpn = 0
COLOR 14
LOCATE 11, 1
PRINT "       ˛ Scheduler"; : COLOR 7: PRINT "        ≥"
PRINT "                          ≥"
PRINT "                          ≥"
PRINT "                          ≥"
PRINT "                          ≥"
PRINT "                          ≥"
PRINT "                          ≥"
LOCATE 12, 1
IF scedone = 1 THEN PRINT sfone$
IF scedtwo = 1 THEN PRINT sftwo$
IF scedthree = 1 THEN PRINT sfthree$
IF scedfour = 1 THEN PRINT sffour$
IF scedfive = 1 THEN PRINT sffive$
IF scedsix = 1 THEN PRINT sfsix$
GOTO redo
sced:
sceds = 0
IF scedone = 1 THEN sceds = sceds + 1
IF scedtwo = 1 THEN sceds = sceds + 1
IF scedthree = 1 THEN sceds = sceds + 1
IF scedfour = 1 THEN sceds = sceds + 1
IF scedfive = 1 THEN sceds = sceds + 1
IF scedsix = 1 THEN sceds = sceds + 1
LOCATE 19, 1
PRINT "            Sceduler                   ∫                                        "
PRINT "                                       ∫      m     = Make a scedule        "
PRINT "There are currently"; sceds; "sceduler banks   ∫      d     = Delete a scedule bank  "
PRINT "being used, a maximum of 6 can be used.∫                                        "
PRINT "                                       ∫                                        "
PRINT "This sceduler runs recored files at    ∫                                        "
PRINT "a set time and date.                   ∫                                        "
PRINT "                                       ∫      r     = Goto Record section       "
PRINT "Note: You must be in the main A/Q box  ∫      h     = Help on sceduler          "
PRINT "before a sceduled bank will exicute!   ∫      x     = Exit this A/Q box         "
scloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 109
                IF melt = 1 THEN CALL melter
                GOTO makesce
            CASE 100
                IF scon = 0 THEN LOCATE 22, 41: PRINT "There are no banks to delete!": FOR time = 0 TO 1199999: NEXT time: GOTO main
                GOTO scdel
            CASE 114
                IF melt = 1 THEN CALL melter
                GOTO record
            CASE 120
                IF melt = 1 THEN CALL melter
                GOTO main
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO scloop

makesce:
LOCATE 19, 1
PRINT "       Making a Scedule                ∫                                     "
PRINT "                                       ∫      s    = Start making scedule    "
PRINT "When making a scedule use the defult   ∫                                     "
PRINT "date (Todays date) or a date beyond:   ∫                                     "
PRINT "                       (mm-dd-yyyy)    ∫                                     "
PRINT "Also note that the time is:            ∫                                     "
PRINT "                                       ∫                                     "
PRINT "In 24 hour time.                       ∫                                     "
PRINT "                                       ∫      h    = Help on making a scedule"
PRINT "                                       ∫      x    = Exit this A/Q box       "
msceloop:
    DO
     LOCATE 23, 7: PRINT DATE$
     LOCATE 25, 8: PRINT TIME$
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 115
                GOTO ssce
            CASE 120
                IF melt = 1 THEN CALL melter
                GOTO sced
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO msceloop
scdel:
LOCATE 19, 1
PRINT "           Deleting a scedule          ∫                                     "
PRINT "                                       ∫     1     = Delete bank 1           "
PRINT "Tap the bank number you wish to        ∫     2     = Delete bank 2           "
PRINT "delete, or cancel by exiting.          ∫     3     = Delete bank 3           "
PRINT "                                       ∫     4     = Delete bank 4           "
PRINT "                                       ∫     5     = Delete bank 5           "
PRINT "Note: - If you need to edit a bank,    ∫     6     = Delete bank 6           "
PRINT "        it is surgested you delete then∫                                     "
PRINT "        it and remake it with edited   ∫                                     "
PRINT "        changes in this version.       ∫     x     = Exit this A/Q box       "
scdelloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 49
                IF scedone = 0 THEN LOCATE 27, 41: PRINT "Bank not in use!": FOR time = 0 TO 119999: NEXT time: GOTO main
                
scedone = 0: sdone = 0: stone = 0: sfone = 0
GOTO endscd:
            CASE 50
IF scedtwo = 0 THEN LOCATE 27, 41: PRINT "Bank not in use!": FOR time = 0 TO 119999: NEXT time: GOTO main
scedtwo = 0: sdtwo = 0: sttwo = 0: sftwo = 0
GOTO endscd:
            CASE 51
IF scedthree = 0 THEN LOCATE 27, 41: PRINT "Bank not in use!": FOR time = 0 TO 119999: NEXT time: GOTO main
scedthree = 0: sdthree = 0: stthree = 0: sfthree = 0
GOTO endscd:
            CASE 52
IF scedfour = 0 THEN LOCATE 27, 41: PRINT "Bank not in use!": FOR time = 0 TO 119999: NEXT time: GOTO main
scedfour = 0: sdfour = 0: stfour = 0: sffour = 0
GOTO endscd:
            CASE 53
IF scedfive = 0 THEN LOCATE 27, 41: PRINT "Bank not in use!": FOR time = 0 TO 119999: NEXT time: GOTO main
scedfive = 0: sdfive = 0: stfive = 0: sffive = 0
GOTO endscd:
            CASE 54
IF scedsix = 0 THEN LOCATE 27, 41: PRINT "Bank not in use!": FOR time = 0 TO 119999: NEXT time: GOTO main
scedsix = 0: sdsix = 0: stsix = 0: sfsix = 0
GOTO endscd:

            CASE 120
                 IF melt = 1 THEN CALL melter
                 GOTO main
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO scdelloop

endscd:
OPEN "START.CCL" FOR OUTPUT AS #5
WRITE #5, scedone, sdone$, stone$, sfone$
WRITE #5, scedtwo, sdtwo$, sttwo$, sftwo$
WRITE #5, scedthree, sdthree$, stthree$, sfthree$
WRITE #5, scedfour, sdfour$, stfour$, sffour$
WRITE #5, scedfive, sdfive$, stfive$, sffive$
WRITE #5, scedsix, sdsix$, stsix$, sfsix$
CLOSE #5
LOCATE 27, 41
PRINT "Secdule has been deleted!"
FOR time = 0 TO 119999: NEXT time
GOTO main:
ssce:
LOCATE 19, 1
PRINT "   Now Making a Scedule                ∫                                     "
PRINT "                                       ∫                                     "
PRINT "Type the date if left emtpy it will    ∫                                     "
PRINT "defult to todays date. Use in this     ∫                                     "
PRINT "configeration:      mm/dd/yyyy         ∫                                     "
PRINT "                or  mm-dd-yyyy         ∫                                     "
PRINT "For time use this configeration:       ∫                                     "
PRINT "                    hh:mm:ss           ∫                                     "
PRINT "Then a record file name is needed.     ∫                                     "
PRINT "For more info see help.                ∫                                     "
dscre:
LOCATE 20, 41
INPUT "Date:"; ddate$
IF ddate$ = "" THEN ddate$ = DATE$
IF ddate$ < DATE$ THEN GOTO ddateerr
LOCATE 22, 41
INPUT "Time:"; ttime$
scre:
LOCATE 24, 41
INPUT "File:"; serecordation$
ON ERROR GOTO screcfileerr
OPEN serecordation$ FOR INPUT AS #1
CLOSE #1
IF scedone = 1 THEN GOTO scedtwo
scedone = 1
sdone$ = ddate$
stone$ = ttime$
sfone$ = serecordation$
GOTO sfin
scedtwo:
IF scedone = 1 THEN GOTO scedthree
scedtwo = 1
sdtwo$ = ddate$
sttwo$ = ttime$
sftwo$ = serecordation$
GOTO sfin
scedthree:
IF scedthree = 1 THEN GOTO scedfour
scedthree = 1
sdthree$ = ddate$
stthree$ = ttime$
sfthree$ = serecordation$
GOTO sfin
scedfour:
IF scedfour = 1 THEN GOTO scedfive
scedfour = 1
sdfour$ = ddate$
stfour$ = ttime$
sffour$ = serecordation$
GOTO sfin
scedfive:
IF scedfive = 1 THEN GOTO scedsix
scedfive = 1
sdfive$ = ddate$
stfive$ = ttime$
sffive$ = serecordation$
GOTO sfin:
scedsix:
IF scedsix = 1 THEN GOTO scefull
scedsix = 1
sdsix$ = ddate$
stsix$ = ttime$
sfsix$ = serecordation$

sfin:
CLOSE #5
OPEN "START.CCL" FOR OUTPUT AS #5
WRITE #5, scedone, sdone$, stone$, sfone$
WRITE #5, scedtwo, sdtwo$, sttwo$, sftwo$
WRITE #5, scedthree, sdthree$, stthree$, sfthree$
WRITE #5, scedfour, sdfour$, stfour$, sffour$
WRITE #5, scedfive, sdfive$, stfive$, sffive$
WRITE #5, scedsix, sdsix$, stsix$, sfsix$
WRITE #5, redaz, blueaz, greenaz, redsx, bluesx, greensx, reddc, bluedc, greendc, redfv, bluegb, greenfv, redgb, bluegb, greengb, redhn, bluehn, greenhn
WRITE #5, ccol, lptt, qlo, melt, stgr, stgf$
CLOSE #5
GOTO main

ddateerr:
LOCATE 20, 42
PRINT "That date has expired"
LOCATE 20, 44
PRINT "Use a different date, y/n?"

dynsceloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 110
                GOTO sced
            CASE 121
      LOCATE 24, 41
      PRINT "                          "
      LOCATE 26, 41
      PRINT "                         "
      LOCATE 28, 41
      PRINT "                       "
              
                GOTO dscre
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO dynsceloop


screcfileerr:
      ' some other error, so print message and abort
      LOCATE 26, 41
      PRINT "Invaled file, Error - "; ERR
      LOCATE 28, 41
      PRINT "Use different file y/n?"
ynsceloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 110
                GOTO scnore
            CASE 121
      LOCATE 24, 41
      PRINT "                          "
      LOCATE 26, 41
      PRINT "                         "
      LOCATE 28, 41
      PRINT "                       "
               
                GOTO scre
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO ynsceloop
scnore:
      CLOSE #1
      GOTO main
      RESUME
   
scefull:
LOCATE 20, 47
PRINT "Sorry but there are no free banks!"
FOR time20 = 0 TO 199999: NEXT time20
GOTO main


'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Record section>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
record:
COLOR 15
LOCATE 19, 1
PRINT "           Record selection"; : COLOR 7: PRINT "            ∫                                  "
PRINT "                                       ∫                                  "
PRINT "To record in realtime means, as you    ∫     t = RealTime recorder          "
PRINT "cotrol the output it records.          ∫     v = Variable recorder          "
PRINT "                                       ∫                                  "
PRINT "It is also possable to record the      ∫     l = load recorded file       "
PRINT "outputs by giving the BIT number then  ∫     s = Search for recorded file "
PRINT "the time delay, looping until you      ∫                                  "
PRINT "stop it.                               ∫     h = Help                     "
PRINT "Note: It records onto a new file.      ∫     x = Exit this A/Q box        "
recloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 120
                IF melt = 1 THEN CALL melter
                GOTO main
            CASE 118
                IF melt = 1 THEN CALL melter
                GOTO var
            CASE 108
                IF melt = 1 THEN CALL melter
                GOTO loadrec
            CASE 116
                IF melt = 1 THEN CALL melter
                GOTO realtime
            CASE 115
                Sea$ = "rec"
                GOTO search
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO recloop

realtime:
LOCATE 19, 1
PRINT "      RealTime Recorder                ∫                                  "
PRINT "                                       ∫                                  "
PRINT "First type the new file name.          ∫                                  "
PRINT "E.g. c:\offon.seq                      ∫                                  "
PRINT "When a valed file has been made you    ∫                                  "
PRINT "will go back to control and record     ∫                                  "
PRINT "the BITs. To stop recording, press s.  ∫                                  "
PRINT "                                       ∫ Valid file name   = Record in    "
PRINT "                                       ∫                     RealTime     "
PRINT "                                       ∫ Invalid file name = Exit         "

LOCATE 20, 41
INPUT "File"; saver$
ON ERROR GOTO invalid
OPEN saver$ FOR OUTPUT AS #1
LOCATE 22, 41
PRINT "Get ready to record"
count = TIMER + 5
looper:
 LOCATE 24, 41
 PRINT "  in T - "; count - countdown; "       "
 countdown = TIMER
IF countdown > count THEN GOTO getout
GOTO looper
getout:
rrec = 1
l = 0
rrectwo = TIMER
COLOR 4
CIRCLE (300, 237.5), 8
PAINT (300, 237.5), 4
LINE (315, 230)-(330, 245), 7, BF
GOTO main
invalid:
   IF ERR = BADFILENAME THEN
      LOCATE 22, 41
      PRINT "File "; UCASE$(filename$);
      LOCATE 22, 43
      PRINT " is invaled."
      FOR time = 0 TO 1999999: NEXT time
      CLOSE #1
      IF melt = 1 THEN CALL melter
      GOTO main
      RESUME
   ELSE
      ' some other error, so print message and abort
      LOCATE 22, 41
      PRINT "Invaled file, Error - "; ERR
      FOR time = 0 TO 1999999: NEXT time
      CLOSE #1
      IF melt = 1 THEN CALL melter
      GOTO main
      RESUME
    END IF

loadrec:
LOCATE 19, 1
COLOR 15
PRINT "       Load saved recording"; : COLOR 7: PRINT "            ∫                                  "
PRINT "   Please type in the directory and    ∫                                  "
PRINT "file name in Ms-DOS format.            ∫                                  "
PRINT "                                       ∫                                  "
PRINT "E.g. c:\Dan\rec1.rec                   ∫                                  "
PRINT "                                       ∫                                  "
PRINT " Note:    -  You must know where the   ∫                                  "
PRINT "          file is you want to load!    ∫                                  "
PRINT "          If you don't, use the        ∫ Invalid = Exit this box, no save "
PRINT "          search ability.              ∫ Valid   = Exit this box and save "
LOCATE 20, 41
CLOSE
INPUT recordation$
ON ERROR GOTO recfileerr
OPEN recordation$ FOR INPUT AS #1
numbit = 0
longp = 0
loadtest:
numbit = numbit + 1
INPUT #1, trash, longpx
longp = longp + longpx
IF EOF(1) = -1 THEN GOTO endloadtest
GOTO loadtest
endloadtest:
FOR timeeer = 0 TO 19999: NEXT timeeer
CLOSE #1
okload:
LOCATE 22, 46
PRINT "Recorded file ready!"
opened = 1
FOR time = 0 TO 199999: NEXT time
IF melt = 1 THEN CALL melter
GOTO main
recfileerr:
      ' some other error, so print message and abort
      LOCATE 22, 41
      PRINT "Invaled file, Error - "; ERR
      FOR time = 0 TO 1999999: NEXT time
      CLOSE #1
      IF melt = 1 THEN CALL melter
IF grops = 1 THEN GOTO options
     
      GOTO main
    

missplay2:
    ok = 1
    start = TIMER
    DO
    IF INKEY$ = "s" THEN playing = 0: l = 0: LINE (315, 230)-(330, 245), 14, BF: CLOSE #1: LINE (270, 245)-(270, 230), 7: LINE (270, 245)-(283.5, 237.5), 7: LINE (283.5, 237.5)-(270, 230), 7: PAINT (275, 235), 7: GOTO main
    finish = TIMER - start
    LOOP UNTIL finish > vtime: GOTO nextrecbit
var:
LOCATE 19, 1
PRINT "      Variable Recorder                ∫                                  "
PRINT "                                       ∫                                  "
PRINT "First type the new file name.          ∫                                  "
PRINT "E.g. c:\onoff.seq                      ∫                                  "
PRINT "Then type the first BIT number, see    ∫                                  "
PRINT "help aboute BIT numbers.               ∫                                  "
PRINT "After BIT number type in a time delay  ∫                                  "
PRINT "before next BIT to activate.           ∫                                  "
PRINT "                                       ∫                                  "
PRINT "                                       ∫ Time =  888  = Exit box and stop "

LOCATE 20, 41
INPUT "File"; savev$
ON ERROR GOTO verr
OPEN savev$ FOR APPEND AS #1
DO
dobit:
LOCATE 22, 41
INPUT "BIT number"; vbit
IF vbit < 1 OR bit > 255 THEN GOTO dobit
LOCATE 24, 41
INPUT "Delay time(sec)"; vtime
WRITE #1, vbit, vtime
LOOP UNTIL vtime = 888
CLOSE #1
PRINT : PRINT "File created!"
FOR time = 0 TO 199999: NEXT time
recordation$ = savev$
GOTO main

verr:
   IF ERR = BADFILENAME THEN
      LOCATE 22, 41
      PRINT "File "; UCASE$(filename$);
      LOCATE 22, 42
      PRINT " is invaled."
      FOR time = 0 TO 1999999: NEXT time
      CLOSE #1
      GOTO main
      RESUME
   ELSE
      ' some other error, so print message and abort
      LOCATE 22, 41
      PRINT "Invaled file, Error - "; ERR
      FOR time = 0 TO 1999999: NEXT time
      CLOSE #1
      GOTO main
      RESUME
    END IF

search:

LOCATE 19, 1
PRINT "         Search for file               ∫     a = Search A drive (Floppy)  "
PRINT "                                       ∫     b = Search B drive (Floppy)  "
PRINT "Press the drive you wish to search     ∫     c = Search C drive (Master)  "
PRINT "*."; Sea$; "'s. Make a note of the location   ∫     d = Search D drive (If pres) "
PRINT "and name.                              ∫     e = Search E drive (If pres) "
PRINT "If the drive you want to search is not ∫     f = Search F drive (If pres) "
PRINT "listed, please contact the author.     ∫     g = Search G drive (If pres) "
PRINT "Warning: The searcher may find files   ∫                                  "
PRINT "not made with Computer Control, these  ∫                                  "
PRINT "will not work.                         ∫     x = Exit this A/Q box        "
sealoop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 120
                 IF melt = 1 THEN CALL melter
                 GOTO main
            CASE 97
                drive$ = "a"
                GOTO nextsea
            CASE 98
                drive$ = "b"
                GOTO nextsea
            CASE 99
                drive$ = "c"
                GOTO nextsea
            CASE 100
                drive$ = "d"
                GOTO nextsea
            CASE 101
                drive$ = "e"
                GOTO nextsea
            CASE 102
                drive$ = "f"
                GOTO nextsea
            CASE 103
                drive$ = "g"
                GOTO nextsea
           
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO sealoop

nextsea:
CLS
COLOR 7
SHELL drive$ + ":/"
SHELL "cd\"
SHELL "dir /p /s *." + Sea$
COLOR 14
INPUT "Press enter to exit"; enter$
GOTO restart

'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< HELP >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
help:
COLOR 7
LOCATE 19, 1
PRINT "                                       ∫                                  "
PRINT "     Select a catagorie ---------->    ∫      Controling outputs   press c"
PRINT "                                       ∫      Making an interface  press m"
PRINT "                                       ∫      Using groups         press g"
PRINT "                                       ∫      Recording/Playback   press r"
PRINT "                                       ∫      Using/making schdule press u"
PRINT "                                       ∫      Trobleshooting       press t"
PRINT "                                       ∫                                  "
PRINT "                                       ∫      Aboute the author    press a"
PRINT "                                       ∫      Exit this help box   press x"
hloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 120
                 IF melt = 1 THEN CALL melter
                 GOTO main
            CASE 97
                IF melt = 1 THEN CALL melter
                GOTO author
            CASE 99
                IF melt = 1 THEN CALL melter
                GOTO controling
            CASE 103
                IF melt = 1 THEN CALL melter
                GOTO usgroups
            CASE 109
                CALL bmp("data1.dcc")
                GOTO restart
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO hloop

author:

LOCATE 19, 1
PRINT "           Daniel Vincent              ∫                                  "
PRINT "                                       ∫                                  "
PRINT "Daniel Vincent started to program at   ∫                                  "
PRINT "the age of 7. The language was BASIC   ∫                                  "
PRINT "on an Acorn Electron microcomputer     ∫                                  "
PRINT "(Which was almost the same as a BBC,   ∫                                  "
PRINT "but slower).                           ∫                                  "
PRINT "                                       ∫                                  "
PRINT "                                       ∫                                  "
PRINT "                                       ∫  x = exit  n = turn over         "
aloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 120
                 IF melt = 1 THEN CALL melter
                 GOTO help
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO aloop

controling:
LOCATE 19, 1
PRINT "          Controling Outputs           ∫                                  "
PRINT "                                       ∫                                  "
PRINT "To manuly turn the parallel port's     ∫                                  "
PRINT "BITs on or off press a key below the   ∫                                  "
PRINT "on-srceen BIT box once, this will      ∫                                  "
PRINT "latch that bit on. Unlatching is done  ∫                                  "
PRINT "by pressing the same key. You can      ∫                                  "
PRINT "latch or unlatch any other BITs while  ∫                                  "
PRINT "not afecting other BIts.               ∫                                  "
PRINT "                                       ∫      x     = Exit this A/Q box   "
conloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 120
                 IF melt = 1 THEN CALL melter
                 GOTO main
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO conloop

usgroups:
LOCATE 19, 1
PRINT "         Using Groups                  ∫       Saving a set of groups     "
PRINT "                                       ∫                                  "
PRINT "Groups enable you to turn multiple     ∫This feature will save a whole    "
PRINT "BITs on.                               ∫set of banks into a new file that "
PRINT "To Configure groups, go in to groups   ∫can be reopened on new sessions.  "
PRINT "to save the current set of lached BITs ∫  To save, go into groups then    "
PRINT "into number keys 0-9. To do this press ∫save. The file name must be in DOS"
PRINT "the number key(s), then exit with 'x'. ∫                             PTO  "
PRINT "Then refigure the BITs and repeat,     ∫      n     = Next page           "
PRINT "saving into different keys (banks).    ∫      x     = Exit this A/Q box   "
ugloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 120
                 IF melt = 1 THEN CALL melter
                 GOTO help
            CASE 110
                IF melt = 1 THEN CALL melter
                GOTO ugp2
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO ugloop

ugp2:
LOCATE 19, 1
PRINT "format. E.g.'s:                        ∫letters of groups so is suggested and "
PRINT "                                       ∫ the searcher looks for this file "
PRINT "   C:\Motors.gro   -root of drive      ∫ type as well.                    "
PRINT "   LEDsig.gro      -saves where pro-   ∫                                  "
PRINT "                    gram is            ∫                                  "
PRINT "   C:\Qbasic\Groups.gro                ∫                                  "
PRINT "   A:\All.seq                          ∫                                  "
PRINT "                                       ∫                                  "
PRINT "The extenshion (3 letters after dot)   ∫      p     = pervious page       "
PRINT "can be anything. *.gro is the first    ∫      x     = Exit this A/Q box   "
ugloop2:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 120
                 IF melt = 1 THEN CALL melter
                 GOTO help
            CASE 112
                IF melt = 1 THEN CALL melter
                GOTO usgroups
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO ugloop2



'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Groups>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
groups:
LOCATE 19, 1
COLOR 15
PRINT "                Groups"; : COLOR 7: PRINT "                 ∫                                 "
PRINT "                                       ∫      0 - 9 = Save a N¯ KEY       "
PRINT "This will now save the current output  ∫                                  "
PRINT "configeration into keys 0-9.           ∫      s     = Save set of groups  "
PRINT "                                       ∫      l     = Load set of groups  "
COLOR 15
PRINT "   Press a number key you wish to"; : COLOR 7: PRINT "      ∫                                  "
COLOR 15
PRINT "      save the output state as."; : COLOR 7: PRINT "        ∫      a     = Search for group files"
PRINT "                                       ∫                                  "
PRINT "Note: Exit to change to a different    ∫      h     = Help about groups   "
PRINT "    state, then come back into groups  ∫      x     = Exit this A/Q box   "
gloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 97
                IF melt = 1 THEN CALL melter
                Sea$ = "gro"
                GOTO search
            CASE 120
                IF melt = 1 THEN CALL melter
                GOTO main
            CASE 49
                one = l
            CASE 50
                two = l
            CASE 51
                thr = l
            CASE 52
                fff = l
            CASE 53
                fiv = l
            CASE 54
                six = l
            CASE 55
                sev = l
            CASE 56
                eig = l
            CASE 57
                nin = l
            CASE 48
                zer = l
            CASE 115
                IF melt = 1 THEN CALL melter
                GOTO savegroupes
            CASE 108
                IF melt = 1 THEN CALL melter
                GOTO loadgroupes
            CASE 104
                IF melt = 1 THEN CALL melter
                GOTO usgroups
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO gloop
loadgroupes:
LOCATE 19, 1
COLOR 15
PRINT "          Load saved groups"; : COLOR 7: PRINT "            ∫                                     "
PRINT "   Please type in the directory and    ∫                                     "
PRINT "file name in Ms-DOS format.            ∫                                     "
PRINT "                                       ∫                                     "
PRINT "E.g. D:\Qbasic\dan's\seq\groups1.gro   ∫                                     "
PRINT "                                       ∫                                     "
PRINT " Note:    -  You must know where the   ∫                                     "
PRINT "          file is you whant to load!   ∫                                     "
PRINT "          If you don't use the search  ∫ Invalid file name = Exit, no save   "
PRINT "          ability                      ∫ Valid = Exit this box and save      "
LOCATE 20, 41
INPUT loadg$
xloadgroup:
IF grops = 0 THEN Groupfile$ = loadg$
ON ERROR GOTO recfileerr
OPEN loadg$ FOR INPUT AS #2
IF grops = 1 THEN CLOSE #2: stgr = 1: stgf$ = loadg$: GOTO options

INPUT #2, one, two, thr, fou, fiv, six, sev, eig, nin, zer
one = one: two = two: thr = thr: fou = fou: fiv = fiv: six = six: sev = sev: eig = eig: nin = nin: zer = zer
CLOSE #2
LOCATE 22, 46
PRINT "Loaded group file!"
FOR time = 0 TO 199999: NEXT time
GOTO main

savegroupes:
LOCATE 19, 1
COLOR 15
PRINT "         Save current groups"; : COLOR 7: PRINT "           ∫                                     "
PRINT "   Please type in the directory and    ∫                                     "
PRINT "file name in Ms-DOS format.            ∫                                     "
PRINT "                                       ∫                                     "
PRINT "E.g. D:\Qbasic\dan's\seq\groups1.gro   ∫                                     "
PRINT "                                       ∫                                     "
PRINT " Note:    -  File name must not be     ∫                                     "
PRINT "          over 7 letters (characters)  ∫                                     "
PRINT "          long.                        ∫ Esc   = Exit this box, don't save   "
PRINT "                                       ∫ Enter = Exit this box and save      "
LOCATE 20, 41
INPUT saveg$
ON ERROR GOTO gserr
OPEN saveg$ FOR OUTPUT AS #1
WRITE #1, one, two, thr, fou, fiv, six, sev, eig, nin, zer
CLOSE #1
LOCATE 24, 45
PRINT "Current goupes saved"
FOR time = 0 TO 199999: NEXT time
GOTO main

gserr:
   IF ERR = BADFILENAME THEN
      LOCATE 22, 41
      PRINT "File "; UCASE$(filename$);
      LOCATE 24, 42
      PRINT " is invaled."
      FOR time = 0 TO 1999999: NEXT time
      CLOSE #1
      GOTO main
      RESUME
   ELSE
      ' some other error, so print message and abort
      LOCATE 22, 41
      PRINT "Invaled file, Error - "; ERR
      FOR time = 0 TO 1999999: NEXT time
      CLOSE #1
      GOTO main
      RESUME
    END IF


'<<<<<<<<<<<<<<<<<<<<<<<<<<<Exiting>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Endprog:
CALL fadeout
CLS
CALL neatfont("Good bye!", -1, 25, 2, 3, 2)
CALL neatfont("Tell me what you think at...", -1, 55, 15, 8, 1)
CALL neatfont("Daniel@vincent99.freeserve.co.uk", -1, 70, 5, 6, 2)
COLOR 7
LOCATE 15, 2
PRINT "                 For the latest version and info visit..."
CALL neatfont("http://www.vincent99.freeserve.co.uk/page5.htm", -1, 290, 3, 9, 1.35)
CALL fadein
FOR a = 0 TO 199999: NEXT a
COLOR 12
LOCATE 25, 2
PRINT "                         Any key to exit"
DO
LOOP WHILE INKEY$ = ""
END


'  Neat font spec...
'  Some neat font thingys
'
'
' txt$  = Text to display
' sx%    = Starting x coordinate for text, use -1 to center
' sy%    = Starting y coordinate for text
' clr%   = Color of neat text
' sty%   = sty%le of text to use
' size%  = size% to make neat text (1 TO 10)
'
' lnh   = Length of text
'
'  sty%les of the neat fonts
' 1. Filled in square
' 2. Hollow square
' 3. Hollow circle
' 4. Filled in circle
' 5. Single pixle
' 6. Hollow triangle
' 7. Filled in triangle
' 8. Forward slant
' 9. Backward slant
'

LOCATE 19, 1
PRINT "                                       ∫                                     "
PRINT "                                       ∫                                     "
PRINT "                                       ∫                                     "
PRINT "                                       ∫                                     "
PRINT "                                       ∫                                     "
PRINT "                                       ∫                                     "
PRINT "                                       ∫                                     "
PRINT "                                       ∫                                     "
PRINT "                                       ∫                                     "
PRINT "                                       ∫      x     = Exit this A/Q box      "
xloop:
    DO
     Choice$ = INKEY$
    LOOP WHILE Choice$ = ""

    IF LEN(Choice$) = 1 THEN
        ' Handle ASCII keys
        SELECT CASE ASC(Choice$)
            CASE 120
                 GOTO main
            CASE ELSE
                BEEP
        END SELECT
    END IF
GOTO xloop

SUB bmp (data$)
DEFINT A-Z
DIM byte AS STRING * 1
CLS

IF LTRIM$(RTRIM$(data$)) = "" THEN END
OPEN data$ FOR BINARY AS #1
IF LOF(1) = 0 THEN GOTO fnf
GOTO back
fnf:
PRINT : PRINT "The file "; data$; " was not found! It should be in the same directre as this"
PRINT "program. If not have a look at http://www.vincent99.freeserve.co.uk/page5.htm"
CLOSE
KILL data$
FOR ttime = 0 TO 19999: NEXT ttime
DO: LOOP UNTIL INKEY$ <> ""
GOTO eEND:

back:
table$ = INPUT$(54, #1)
DIM table&(30)
DEF SEG = VARSEG(table&(1))
pointer% = VARPTR(table&(1))

FOR x% = 0 TO 51
 POKE pointer% + x%, ASC(MID$(table$, x% + 3, 1))
NEXT
DEF SEG

IF MID$(table$, 1, 2) <> "BM" OR table&(4) <> 40 THEN
   PRINT "Not a valid *.BMP file!": END
END IF
IF table&(8) <> 0 THEN
   PRINT "This program will not diplay RLE encoded files": END
END IF

IF (table&(5) < 321) AND (table&(6) < 201) THEN
   SCREEN 13
ELSE
   SCREEN 12
END IF
'LOCATE 2, 1
'PRINT " Image is "; table&(5); " by "; table&(6)

thecolors$ = INPUT$(table&(3) - 54, #1)

DEF SEG = VARSEG(pal&)
pointer% = VARPTR(pal&)

FOR x% = 0 TO 63 STEP 4
 POKE pointer%, (ASC(MID$(thecolors$, x% + 3, 1))) \ 4
 POKE pointer% + 1, (ASC(MID$(thecolors$, x% + 2, 1))) \ 4
 POKE pointer% + 2, (ASC(MID$(thecolors$, x% + 1, 1))) \ 4
 POKE pointer% + 3, 0
PALETTE x% \ 4, pal&
NEXT
DEF SEG

y% = table&(6) 'Put number of vertical pixels into y%
DO
  data$ = INPUT$((((table&(5) - 1) OR 7) + 1) \ 2, #1)
    IF (table&(5) \ 2) < LEN(data$) THEN
       linelength% = table&(5) \ 2
    ELSE
       linelength% = LEN(data$)
    END IF
    FOR x% = 1 TO linelength%
      pixel% = ASC(MID$(data$, x%, 1))
      PSET (x% * 2 + 1, y%), pixel% AND 15
      PSET (x% * 2, y%), pixel% \ 16
     NEXT
    y% = y% - 1
LOOP UNTIL EOF(1)
CLOSE #1
eEND:
DO: LOOP UNTIL INKEY$ <> ""
END SUB

DEFSNG A-Z
SUB fadein

FOR fina = 1 TO 62
FOR finc = 0 TO 255
OUT &H3C7, finc: rgg = INP(&H3C9): ggg = INP(&H3C9): bgg = INP(&H3C9)
IF rgg < palhold(finc, 1) THEN rgg = rgg + 1
IF ggg < palhold(finc, 2) THEN ggg = ggg + 1
IF bgg < palhold(finc, 3) THEN bgg = bgg + 1
OUT &H3C8, finc: OUT &H3C9, rgg: OUT &H3C9, ggg: OUT &H3C9, bgg
NEXT finc
WAIT &H3DA, 8
NEXT fina
END SUB

SUB fadeout

FOR fout = 0 TO 255
OUT &H3C7, fout: rgg = INP(&H3C9): ggg = INP(&H3C9): bgg = INP(&H3C9)
palhold(fout, 1) = rgg
palhold(fout, 2) = ggg
palhold(fout, 3) = bgg
NEXT fout

FOR foutq = 1 TO 62
FOR foutc = 0 TO 255
OUT &H3C7, foutc: r = INP(&H3C9): ggg = INP(&H3C9): bgg = INP(&H3C9)
IF rgg > 0 THEN rgg = rgg - 1
IF ggg > 0 THEN ggg = ggg - 1
IF bgg > 0 THEN bgg = bgg - 1
OUT &H3C8, foutc: OUT &H3C9, rgg: OUT &H3C9, ggg: OUT &H3C9, bgg
NEXT foutc
WAIT &H3DA, 8
NEXT foutq
END SUB

SUB melter
DIM melt%(3000)
 
  FOR RR = 1 TO 3000
    RANDOMIZE TIMER
    XX = INT(RND * 271)
    RANDOMIZE TIMER
    YX = INT(RND * 150 + 280)
    GET (XX, YX)-(XX + 320, YX + 10), melt%
    PUT (XX, YX + 3), melt%, PSET
    IF INKEY$ = CHR$(27) THEN END
  NEXT RR

END SUB

SUB neatfont (txt$, sx%, sy%, clr%, sty%, size%)

 lnh% = LEN(txt$)
 IF sx% = -1 THEN sx% = (640 - ((lnh% * 8) * size%)) / 2
 sx2% = sx%: l% = lnh% * 8
 COLOR 8: LOCATE 1, 1: PRINT txt$

 FOR y% = 0 TO 15
  FOR x% = 0 TO l%
  IF POINT(x%, y%) <> 0 THEN
   IF sty% = 1 THEN LINE (sx2% - size%, sy% - size%)-(sx2%, sy%), clr%, BF
   IF sty% = 2 THEN LINE (sx2% - size%, sy% - size%)-(sx2%, sy%), clr%, B
   IF sty% = 3 THEN CIRCLE (sx2% - (size% / 2), sy% - (size% / 2)), size% / 2, clr%
   IF sty% = 4 THEN
    CIRCLE (sx2% - (size% / 2), sy% - (size% / 2)), size% / 2, clr%
    PAINT (sx2% - (size% / 2), sy% - (size% / 2)), clr%
   END IF
   IF sty% = 5 THEN PSET (sx2% - (size% / 2), sy% - (size% / 2)), clr%
   IF sty% = 6 OR sty% = 7 THEN
    LINE (sx2% - (size% / 2), sy% - size%)-(sx2% - size%, sy%), clr%
    LINE (sx2% - (size% / 2), sy% - size%)-(sx2%, sy%), clr%
    LINE (sx2% - size%, sy%)-(sx2%, sy%), clr%
   END IF
   IF sty% = 7 THEN PAINT (sx2% - (size% / 2), sy% - (size% / 2)), clr%
   IF sty% = 8 THEN LINE (sx2%, sy% - size%)-(sx2% - size%, sy%), clr%
   IF sty% = 9 THEN LINE (sx2% - size%, sy% - size%)-(sx2%, sy%), clr%
  END IF
  sx2% = sx2% + size%
  NEXT x%
  sy% = sy% + size%: sx2% = sx%
 NEXT y%
 LOCATE 1, 1: COLOR 0: PRINT txt$

END SUB

SUB qlogo
SCREEN 13

x = 500
CALL zoom(x)
    COLOR 2
    LINE (-420, -10)-(450, 5), 101, BF
    LINE (-415, -3)-(445, -3), 100

COLOR 2
LOCATE 7, 15
PRINT "Extravaganza"
LOCATE 19, 17
PRINT "Presents..."


END SUB

SUB zoom (x) STATIC
  WINDOW (-x, -x)-(x, x)
    'D
    LINE (-135, 100)-(-210, 100), 72
    LINE (-135, 100)-(-135, -100), 72
    LINE (-135, -100)-(-210, -100), 72
    LINE (-200, 100)-(-200, -100), 72
   
    'A
    LINE (-50, 100)-(25, 100), 72
    LINE (-50, 100)-(-50, -100), 72
    LINE (-50, 0)-(25, 0), 72
    LINE (25, -100)-(25, 100), 72
    'N
    LINE (105, 100)-(180, -100), 72
    LINE (180, 100)-(180, -100), 72
    
    LINE (105, 100)-(105, -100), 72


END SUB

