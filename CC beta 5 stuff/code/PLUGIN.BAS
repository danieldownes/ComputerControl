DECLARE SUB neatfont (txt$, sx%, sy%, clr%, sty%, size%)
DIM SHARED txt AS STRING, sx%, sy%, clr%, sty%, size%
DIM melt%(3000)

DIM SHARED palhold(0 TO 255, 1 TO 3) AS INTEGER
DECLARE SUB bmp (data$)
DECLARE SUB melter ()
DECLARE SUB Wavplay (wavfile$)

SCREEN 12
'CALL Wavplay("C:\Dan\Welcome.wav")
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
INPUT #5, ccol, lptt, qlo, melt, stgr, stgf$, plugin
CLOSE #5
IF plugin <> 1 THEN GOTO needcom

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

n% = lptt
30

    IF n% = 1 THEN Base0% = lpt1
    IF n% = 2 THEN Base0% = lpt2
    IF n% = 3 THEN Base0% = lpt3

    IF Base0% = 0 THEN
        PRINT "That port doesn't exits, try again."
        n% = 0
    END IF
'Set up laching, BIT, etc...
rrecone = 0: rrectwo = 0: rrec = 0: opened = 0: playing = 0: l = 0: Q = 0: qon = 0: won = 0: W = 0: eon = 0: E = 0: ron = 0: r = 0: ton = 0: t = 0: y = 0: yon = 0: U = 0: uon = 0: I = 0: ion = 0
Qbit = 0: Wbit = 0: Ebit = 0: Rbit = 0: Tbit = 0: Ybit = 0: Ubit = 0: Ibit = 0
grops = 0
'Base1% = Base0% + 1  'assign addresses
'Base2% = Base0% + 2
FullByte% = 0

'  activate Base2% for high open collectors and disable interrupt
OUT Base2%, 8


restart:
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
PRINT "                                       ∫                                       "
PRINT "    This is a Plug-in test             ∫                                       "
PRINT "                                       ∫                                       "
PRINT "                                       ∫                                       "
PRINT "                                       ∫                                       "
PRINT "                                       ∫                                       "
PRINT "                                       ∫                                       "
PRINT "                                       ∫       o = Options                     "
PRINT "                                       ∫       x = Exit                        "
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
            CASE 122
'CALL Wavplay("C:\Dan\uptol.wav")
CALL Wavplay("C:\Dan\livdoor.wav")
CALL Wavplay("C:\Dan\isopen.wav")

            CASE 113
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: t = 0: y = 0: U = 0: I = 0: gro = 0
                IF Q = 0 THEN qon = 1: Q = 1: l = l + 128
                IF Q = 1 AND qon = 0 THEN Q = 0: l = l - 128
                qon = 0
            CASE 119
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: t = 0: y = 0: U = 0: I = 0: gro = 0
                IF W = 0 THEN won = 1: W = 1: l = l + 64
                IF W = 1 AND won = 0 THEN W = 0: l = l - 64
                won = 0
            CASE 101
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: t = 0: y = 0: U = 0: I = 0: gro = 0
                IF E = 0 THEN eon = 1: E = 1: l = l + 32
                IF E = 1 AND eon = 0 THEN E = 0: l = l - 32
                eon = 0
            CASE 114
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: t = 0: y = 0: U = 0: I = 0: gro = 0
                IF r = 0 THEN ron = 1: r = 1: l = l + 16
                IF r = 1 AND ron = 0 THEN r = 0: l = l - 16
                ron = 0
            CASE 116
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: t = 0: y = 0: U = 0: I = 0: gro = 0
                IF t = 0 THEN ton = 1: t = 1: l = l + 8
                IF t = 1 AND ton = 0 THEN t = 0: l = l - 8
                ton = 0
            CASE 121
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: t = 0: y = 0: U = 0: I = 0: gro = 0
                IF y = 0 THEN yon = 1: y = 1: l = l + 4
                IF y = 1 AND yon = 0 THEN y = 0: l = l - 4
                yon = 0
            CASE 117
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: t = 0: y = 0: U = 0: I = 0: gro = 0
                IF U = 0 THEN uon = 1: U = 1: l = l + 2
                IF U = 1 AND uon = 0 THEN U = 0: l = l - 2
                uon = 0
            CASE 105
                IF gro = 1 THEN l = 0: Q = 0: W = 0: E = 0: r = 0: t = 0: y = 0: U = 0: I = 0: gro = 0
                IF I = 0 THEN ion = 1: I = 1: l = l + 1
                IF I = 1 AND ion = 0 THEN I = 0: l = l - 1
                ion = 0
            CASE 120
                GOTO Endplug
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

needcom:
CLS
PRINT "This is a Plugin Program. You need Computer Control beta 5 and over to use it"
PRINT "Get the latest version at 'vincent99.freeserve.co.uk/page5.htm'"
PRINT "Any key to end"
DO: LOOP WHILE INKEY$ = ""
END

xloadgroup:
Groupfile$ = loadg$
OPEN loadg$ FOR INPUT AS #2
'IF grops = 1 THEN CLOSE #2: stgr = 1: stgf$ = loadg$: GOTO options
INPUT #2, one, two, thr, fou, fiv, six, sev, eig, nin, zer
one = one: two = two: thr = thr: fou = fou: fiv = fiv: six = six: sev = sev: eig = eig: nin = nin: zer = zer
CLOSE #2
'FOR time = 0 TO : NEXT time
GOTO main

missplay2:
    ok = 1
    start = TIMER
    DO
    IF INKEY$ = "s" THEN playing = 0: l = 0: LINE (315, 230)-(330, 245), 14, BF: CLOSE #1: LINE (270, 245)-(270, 230), 7: LINE (270, 245)-(283.5, 237.5), 7: LINE (283.5, 237.5)-(270, 230), 7: PAINT (275, 235), 7: GOTO main
    finish = TIMER - start
    LOOP UNTIL finish > vtime: GOTO nextrecbit

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

endscd:
OPEN "START.CCL" FOR OUTPUT AS #5
WRITE #5, scedone, sdone$, stone$, sfone$
WRITE #5, scedtwo, sdtwo$, sttwo$, sftwo$
WRITE #5, scedthree, sdthree$, stthree$, sfthree$
WRITE #5, scedfour, sdfour$, stfour$, sffour$
WRITE #5, scedfive, sdfive$, stfive$, sffive$
WRITE #5, scedsix, sdsix$, stsix$, sfsix$, plugin
CLOSE #5
LOCATE 27, 41
PRINT "Secdule has been deleted!"
FOR time = 0 TO 119999: NEXT time
GOTO main:


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

Endplug:
END

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

SUB Wavplay (wavfile$)
 VocFile$ = wavfile$
 VocFile% = FREEFILE
 OPEN VocFile$ FOR BINARY AS #VocFile%
 Bytes& = LOF(VocFile%)          ' number of bytes
 BytesRemaining& = Bytes&        ' number of remaining bytes
 BufferMax% = 19000             ' largest buffer

'The maximum buffer size in QBasic is about 19K.
' in QB45 this can be at least &H7F00 bytes (over 32K).

  Buffer$ = SPACE$(BufferMax%)    ' create buffer
       WAIT &H22C, &H80, &HFF       ' wait for data-ready on SB
       OUT &H22C, &HD1              ' ON
                     ' Soundblaster on

  DO
     BytesRemaining& = BytesRemaining& - BufferLen%
     IF BytesRemaining& = 0 THEN EXIT DO ' nothing left over?
     IF BytesRemaining& > BufferMax% THEN ' how many bytes?
        BufferLen% = BufferMax%          '
     ELSE
        BufferLen% = BytesRemaining&     ' remaining (<BufferMax%)..
        'Buffer$ = SPACE$(BufferLen%)     ' ..throw it into SB :-)

'NB line remmed out - works OK without it.
   
     END IF

     GET #VocFile%, , Buffer$            ' read buffer
     DEF SEG = VARSEG(Buffer$)           ' get address of buffer
     Voff& = SADD(Buffer$)               ' .

'NB Voff% changed to Voff& throughout
   
     FOR t% = 1 TO BufferLen%            ' output od {bufferlen%}
       
         FOR time = 0 TO 1: NEXT time
         WAIT &H22C, &H80, &HFF         ' wait for data-ready
         OUT &H22C, &H10
         WAIT &H22C, &H80, &HFF
         OUT &H22C, PEEK(Voff&)
         Voff& = Voff& + 1
     NEXT t%

  LOOP WHILE INKEY$ = ""

       WAIT &H22C, &H80, &HFF
       OUT &H22C, &HD3              ' OFF
  CLOSE #VocFile%                       ' close file
END SUB

