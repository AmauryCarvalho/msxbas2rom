01 defint a-z ' BY: FABIO BENTO
10 screen1,2:width32:color15,1,1:keyoff
11 CALL TURBO ON
12 dim di(20,34)  ' BY: FABIO BENTO
21 data 0,0,0,0,0,0,0,0:data144,36,9,2,0,0,0,0:data0,0,0,64,144,36,9,2:data0,0,0,2,9,36,144,64:data9,36,144,64,0,0,0,0
32 data 240,124,31,7,1,0,0,0:data0,0,0,192,240,124,31,7:data0,0,0,3,15,62,248,224:data15,62,248,224,128,0,0,0:data0,0,0,0,0,0,0,3:data0,0,0,0,0,0,0,192
43 data 64,0,4,0,0,0,0,0:data0,0,0,0,64,0,4,0:data0,0,0,0,0,8,0,128:data0,8,0,128,0,0,0,0
50 data 96,248,254,127,31,7,1,0,0,0,0,0,0,0,0,0,0,0,0,128,224,248,254,127,31,6,0,0,0,0,0,0
51 data 0,0,0,0,0,0,1,3,3,1,0,0,0,0,0,0,0,0,0,0,0,0,128,192,192,128,0,0,0,0,0,0
70 data 1,12,2,13,32,10,33,11,34,8,35,9,36,13,64,8,65,9,66,18,67,19,68,8,69,9,98,8,99,9,100,10,101,11
71 data 1,0,2,13,32,18,33,19,34,8,35,9,36,13,64,16,65,17,66,18,67,19,68,8,69,9,98,16,99,17,100,18,101,19
72 data 1,12,2,13,32,10,33,11,34,8,35,9,36,0,64,16,65,17,66,10,67,11,68,16,69,17,98,8,99,9,100,10,101,11
73 data 1,12,2,13,32,10,33,11,34,8,35,9,36,13,64,16,65,17,66,10,67,11,68,8,69,9,98,16,99,17,100,10,101,11
74 data 1,0,2,13,32,18,33,19,34,8,35,9,36,13,64,8,65,9,66,10,67,11,68,8,69,9,98,16,99,17,100,18,101,19
75 data 1,12,2,0,32,10,33,11,34,16,35,17,36,13,64,8,65,9,66,10,67,11,68,8,69,9,98,16,99,17,100,10,101,11
76 data 1,12,2,0,32,10,33,11,34,16,35,17,36,13,64,8,65,9,66,10,67,11,68,8,69,9,98,8,99,9,100,10,101,11
77 data 1,12,2,13,32,10,33,11,34,8,35,9,36,13,64,16,65,17,66,18,67,19,68,8,69,9,98,16,99,17,100,18,101,19
78 data 1,12,2,13,32,10,33,11,34,8,35,9,36,13,64,8,65,9,66,10,67,11,68,8,69,9,98,8,99,9,100,10,101,11
79 data 1,12,2,13,32,10,33,11,34,8,35,9,36,13,64,8,65,9,66,10,67,11,68,8,69,9,98,16,99,17,100,10,101,11
80 data 1,12,2,13,32,10,33,11,34,8,35,9,36,13,64,8,65,9,66,10,67,11,68,16,69,17,98,8,99,9,100,18,101,19
81 data 1,12,2,13,32,10,33,11,34,8,35,9,36,13,64,8,65,9,66,18,67,19,68,8,69,9,98,8,99,9,100,18,101,19
82 data 1,12,2,0,32,10,33,11,34,16,35,17,36,13,64,8,65,9,66,18,67,19,68,8,69,9,98,8,99,9,100,10,101,11
110 for i=0 to 8*5-1:read a:vpoke i,a:next I
111 for i=0 to 8*6-1:read a:vpoke i+8*8,a:next I
112 for i=0 to 8*4-1:read a:vpoke i+16*8,a:next I
130 vpoke &h2000, &hf1 : vpoke &h2001, &h81 : vpoke &h2002, &h41
200 for i=0 to 31:reada:b$=b$+chr$(a):next I:sprite$(0)=b$
201 for i=0 to 31:reada:c$=c$+chr$(a):next I:sprite$(1)=c$
300 for j=0 to 12:for i=0 to 33:reada:di(j,i)=a:next i,j
440 cls
450 for i=0 to 16:vpoke&h1800+di(10,i*2)+10*32+7,di(10,i*2+1):next I
451 for i=0 to 16:vpoke&h1800+di(0,i*2)+8*32+11,di(0,i*2+1):next I
452 for i=0 to 16:vpoke&h1800+di(11,i*2)+6*32+15,di(11,i*2+1):next I
453 for i=0 to 16:vpoke&h1800+di(12,i*2)+4*32+19,di(12,i*2+1):next I
460 for i=0 to 5000:next I:cls
461 cls:p1=0:p2=0
500 for i=0 to 9:vpoke&h1800+448-i*30,3:vpoke&h1800+449-i*30,4:vpoke&h1800+652-i*30,3:vpoke&h1800+653-i*30,4:next i
501 for i=0 to 5:vpoke&h1800+480+i*34,1:vpoke&h1800+481+i*34,2:vpoke&h1800+330+i*34,1:vpoke&h1800+331+i*34,2:vpoke&h1800+180+i*34,1:vpoke&h1800+181+i*34,2:next I
600 for i=0 to 16:vpoke&h1800+di(p1,i*2)+18*32,di(p1,i*2+1):next I
601 for i=0 to 16:vpoke&h1800+di(p2,i*2)+3*32+26,di(p2,i*2+1):next I
650 x1=45:y1=130:x2=195:y2=65:x3=120:y3=88:v=3:xx=0:yy=v
700 putsprite 0,(x1,y1),15,0:putsprite 1,(x2,y2),15,0:putsprite 2,(x3,y3),15,1
710 j=stick(0)
711 if j=3 and x1<89 then x1=x1+2:y1=y1+1
712 if j=7 and x1>11 then x1=x1-2:y1=y1-1
720 j=stick(1)
721 if j=3 and x2<229 then x2=x2+2:y2=y2+1
722 if j=7 and x2>151 then x2=x2-2:y2=y2-1
800 x3=x3+xx:y3=y3+yy
801 b1=-x3/2+198:b2=x3/2+114:b3=-x3/2+112:b4=x3/2-45:b5=b2-15:b6=b4+15
811 if y3>b1 and yy=v then xx=-v:yy=0
812 if y3>b2 then gosub1000
813 if y3<b3 and yy=-v then xx=v:yy=0
814 if y3>b1 and xx=v then xx=0:yy=-v
815 if y3<b4 then gosub1200
816 if y3<b3 and xx=-v then xx=0:yy=v
817 if y3<b6 and y3>b6-8 and x3>x2-10 and x3<x2+10 and yy=-v then xx=-v:yy=0
818 if y3<b6 and y3>b6-8 and x3>x2-10 and x3<x2+10 and xx=v then xx=0:yy=v
819 if y3>b5 and y3<b5+8 and x3>x1-10 and x3<x1+10 and yy=v then xx=v:yy=0
820 if y3>b5 and y3<b5+8 and x3>x1-10 and x3<x1+10 and xx=-v then xx=0:yy=-v
890 if p1=9 or p2=9 then for i=0 to 5000:next I:goto 440
900 goto 700
1000 x3=120:y3=88:xx=0:yy=-v
1001 p1=p1+1
1002 for i=0 to 16:vpoke&h1800+di(p1,i*2)+18*32,di(p1,i*2+1):next i
1003 return
1200 x3=120:y3=88:xx=0:yy=v
1201 p2=p2+1
1202 for i=0 to 16:vpoke&h1800+di(p2,i*2)+3*32+26,di(p2,i*2+1):next i
1203 return




