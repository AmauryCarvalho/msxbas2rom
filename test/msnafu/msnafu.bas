100 COLOR 15,0,0:SCREEN 3,,0:DIM P%(1),X%(1),Y%(1),A%(1),B%(1),O%(1)
105 FOR R%=0 TO 4:LINE (32,0)-STEP(191,191),0,BF:LINE (32,0)-STEP(191,191),15,B
110 X%(0)=31*4:Y%(0)=11*4:A%(0)=0:B%(0)=4:O%(0)=5
115 X%(1)=32*4:Y%(1)=36*4:A%(1)=0:B%(1)=-4:O%(1)=1
120 FOR I%=0 TO 1:PSET(X%(I%),Y%(I%)),5+I%:J%=STICK(I%)
125 IF J%=1 AND O%(I%)<>5 THEN A%(I%) = 0:B%(I%)=-4:O%(I%)=J%:GOTO 145
130 IF J%=3 AND O%(I%)<>7 THEN A%(I%) = 4:B%(I%)= 0:O%(I%)=J%:GOTO 145
135 IF J%=5 AND O%(I%)<>1 THEN A%(I%) = 0:B%(I%)= 4:O%(I%)=J%:GOTO 145
140 IF J%=7 AND O%(I%)<>3 THEN A%(I%) =-4:B%(I%)= 0:O%(I%)=J%
145 X%(I%)=X%(I%)+A%(I%):Y%(I%)=Y%(I%)+B%(I%)
150 IF POINT(X%(I%),Y%(I%))<>0 THEN P%(I%)=P%(I%)+1: GOTO 160
151 'T% = TIME 
152 'D% = (TIME - T%) : IF D% < 3 THEN 152
155 NEXT I%:GOTO 120
160 FOR I%=0 TO 1:IF P%(I%)>0 THEN PSET(24+204*I%,4+8*P%(I%)),5+I%
165 NEXT I%,R%:FOR J%=0 TO 1:J%=-1:NEXT J%

