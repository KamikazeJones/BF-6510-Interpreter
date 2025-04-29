5 printchr$(147);chr$(31);
6 print"++++++++++(>+++++++>+++++++++>+++<<<-)>++.---.+++++";
7 print"++..+++.>>++.<---.<.>-----.<---.--------.>>+.#"
8 print:print
10 i=0:c=-1:r$=""
15 bl$=left$("                                            ",21)
20 dim n%(30)
25 gosub 1100
30 gosub1000:c=c+1:a$=chr$(peek(7680+c)):gosub1100
40 printchr$(145);bl$:print chr$(145);c;"/";a$;"/";i;"/";n%(i)
100 if a$<>"+"goto200
110 ifn%(i)=32767thenn%(i)=0:goto30
120 n%(i)=n%(i)+1:goto30
200 if a$<>"-"goto300
210 if n%(i)=0thenn%(i)=32767:goto30
220 n%(i)=n%(i)-1:goto30
300 ifa$=">"theni=i+1:goto30
400 ifa$="<"theni=i-1:goto30
500 if a$="."then r$=r$+chr$(n%(i)and255):print r$:printchr$(145);:goto30
600 ifa$<>","goto700
610 getx$:ifx$=""goto610
620 n%(i)=asc(x$):goto30
700 ifa$<>"("then goto800
710 if n%(i)<>0thengoto30
715 k=0
730 ch=peek(7680+c)and127:if ch=40then k=k+1
740 if ch=41then k=k-1
750 if k=0then goto 30
760 gosub1000:c=c+1:gosub1100:goto 730
800 if a$<>")"then goto900
815 k=0
830 ch=peek(7680+c)and127:if ch=40then k=k-1
840 if ch=41then k=k+1
850 gosub1000:c=c-1:gosub1100:if k=0 goto 30
860 goto 830
900 if a$="#"then gosub 1000:end
999 goto 30
1000 rem reset cursor
1020 v%=peek(7680+c):if v%and128 then poke 7680+c,v%and127:goto 1040
1030 poke 7680+c,v%or128
1040 poke 38400+c,6:return
1100 rem mark cursor
1110 poke 38400+c,0
1120 v%=peek(7680+c):if v%and128 then poke 7680+c,v%and127:return
1130 poke 7680+c,v%or128:return
