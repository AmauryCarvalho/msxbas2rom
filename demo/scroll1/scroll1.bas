' SCROLL DEMONSTRATION 1
' by: Amaury Carvalho (2022)

10 SCREEN 1

20 LOCATE 15, 12 : PRINT "X";

30 S% = STICK(0)
40 B% = STRIG(0)

50 IF B% <> 0 THEN 20
60 IF S% = 0 THEN 30

70 SCREEN SCROLL S%
80 GOTO 30

