10 REM globo e cornucopia - LIMA. Desenhos basicos para MSX, 1989
20 SCREEN 2
30 LINE(0,0)-(126,191),,B : LINE(130,0)-(255,191),,B
40 PI = 4 * ATN(1)
45 REM GLOBO
50 C=0
60 FOR A=0 TO PI STEP 2*PI/48
70 R=40*SIN(A)
80 CIRCLE(C+40,96),R
90 C=C+2 : NEXT A
95 REM CORNUCOPIA
100 R=2
110 FOR A=0 TO 4.5*PI STEP 2*PI/48
120 C=20*SIN(A) : L = 10*A
130 CIRCLE(200+C, L-20), R
140 R=R+0.3 : IF R > 30 THEN GOTO 200
150 NEXT A : GOTO 110
200 GOTO 200
