TEXT "CDEFGAB"
TEXT "BAGFEDC"
10 CLS
20 PRINT "NOW PLAYING MELODY 1"
30 CMD PLAY 0
40 PRINT "PRESS A KEY TO CONTINUE"
50 IF STRIG(0) = 0 THEN GOTO 50
60 PRINT "NOW PLAYING MELODY 2"
70 CMD PLAY 1
80 PRINT "PRESS A KEY TO FINISH"
90 IF STRIG(0) = 0 THEN GOTO 90
