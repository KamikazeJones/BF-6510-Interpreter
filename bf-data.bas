5 a0 = 48:r=22*256
10 reada$:if a$="-2"then end
40 if a$="-1"then gosub 210:goto10
50 v=0:for i=1to2:h$=mid$(a$,i,1):gosub 110:v=v*16+h:next i
70 poke r,v:r=r+1:goto 10
rem 100 rem ---- hexval ----
110 h=asc(h$)-a0:if h>9 then h=h-7
120 return
rem 200 rem ---- read new address from data ----
210 read a$:v=0
220 for i=1to4:h$=mid$(a$,i,1):gosub 110:v=v*16+h:next i
240 r=v:print "ad";r:return
rem 1000 rem decptr
1005 data -1,1600,a5,fb,d0,02,c6,fc,c6,fb,c6,fb,60
rem 1010 rem incptr
1015 data -1,1610,e6,fb,e6,fb,d0,02,e6,fc,60
rem 1020 rem decpval
1025 data -1,1620,20,30,16,b0,03,20,40,16,60
rem 1030 rem decpvlo
1035 data -1,1630,a0,00,b1,fb,38,e9,01,91,fb,60
rem 1040 rem decpvhi
1045 data -1,1640,a0,01,b1,fb,38,e9,01,91,fb,60
rem 1050 rem incpval
1055 data -1,1650,20,60,16,90,03,20,70,16,60
rem 1060 rem incpvlo
1065 data -1,1660,a0,00,b1,fb,18,69,01,91,fb,60
rem 1070 rem incpvhi
1075 data -1,1670,a0,01,b1,fb,18,69,01,91,fb,60
rem 1080 rem variables
1085 data -1,1680,1b,1d,1b,00
rem 1090 rem init-search
1095 data -1,1688,a0,00,b1,fb,d0,05,c8,b1,fb,f0,03,68,68,60,a9,01
1096 data 8d,83,16,60
rem 1100 rem while
1105 data -1,16a0,20,88,16,e6,fd,d0,02,e6,fe,20,64,17,d0,f5,60
rem 1110 rem wend
1115 data -1,16b0,20,96,16,c6,fd,10,02,c6,fe,20,60,17,d0,f5
1116 data c6,fd,10,02,c6,fe,60
rem 1130 rem read
1135 data -1,16d0,20,e4,ff,c9,00,f0,f9,a0,00,91,fb,60
rem 1140 rem write
1145 data -1,16e0,a0,00,b1,fb,20,d2,ff,60
rem 1200 rem interpreter
1205 data -1,1700,e6,fd,d0,02,e6,fe,a9,16,48,a9,ff,48,a0,00,b1,fd
1206 data c9,3c,d0,03,4c,00,16,c9,3e,d0,03,4c,10,16,c9,2d,d0,03
1207 data 4c,20,16,c9,2b,d0,03,4c,50,16,cd,80,16,d0,03,4c,a0,16
1208 data cd,81,16,d0,03,4c,b0,16,c9,2c,d0,03,4c,d0,16,c9,2e,d0
1209 data 03,4c,e0,16,c9,23,f0,01,60,68,68,60
rem 1260 rem compare-paren
1265 data -1,1760,a2,00,f0,02,a2,01,a0,00,b1,fd,dd,80,16,f0,0a,dd
1266 data 81,16,f0,01,60,ee,83,16,60,ce,83,16,60
rem 1300 rem main
1300 data -1,1790,a9,00,85,fd,a9,1e,85,fe,a9,00,85,fb,a9,18,85,fc
1310 data -1,17a0,a9,00,a2,00,9d,00,18,e8,d0,fa,4c,06,17,-2
