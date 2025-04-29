; Brainfuck hat 8 Sprachelemente:
;   <: decptr  | verringert den ptr um eins; in C: ptr--
;   >: incptr  | erhöht den ptr um eins; in C: ptr++
;   -: decpval | verringert den Wert der Speicherzelle, auf die ptr zeigt, um
                 eins; in C: (*ptr)--
;   +: incpval | erhöht den Wert der Speicherzelle, auf die ptr zeigt, um eins
                 in C: (*ptr)++  
;   (: while   | Anfang einer Whileschleife, bricht bei *ptr == 0 ab.
;   ): wend    | Ende einer Whileschleife, springt zum korrespondierenden 
                 Anfang
;   .: write   | schreibt *ptr in die Ausgabe (auf den Bildschirm oder in eine Datei)
;   ,: read    | liest ein Zeichen von der Eingabe (Tastatur, Datei) nach *ptr

; Die Speicherzellen in BF enthalten 16-Bit vorzeichenlose Integer-Werte.
; Damit werden für eine Speicherzelle 2 Byte benötigt.
; Da im 6510-Assembler die Speicherzellen nur ein Byte groß sind, muss decptr 
; den ptr um 2 verringern, und incptr muss um 2 erhöhen.

; Code für decptr
1600: A5 FB      ; LDA $FB - Lade niederwertiges Byte des Zeigers
1602: D0 02      ; BNE $1606 - Wenn $FB != 0, überspringe DEC $FC
1604: C6 FC      ; DEC $FC - Verringere höherwertiges Byte des Zeigers
1606: C6 FB      ; DEC $FB - Verringere niederwertiges Byte um 1
1608: C6 FB      ; DEC $FB - Verringere niederwertiges Byte erneut um 1
160A: 60         ; RTS - Rückkehr aus Subroutine

; Code für incptr
1610: E6 FB      ; INC $FB - Erhöhe niederwertiges Byte des Zeigers um 1
1612: E6 FB      ; INC $FB - Erhöhe niederwertiges Byte erneut um 1
1614: D0 02      ; BNE $1618 - Wenn $FB != 0, überspringe INC $FC
1616: E6 FC      ; INC $FC - Erhöhe höherwertiges Byte des Zeigers
1618: 60         ; RTS - Rückkehr aus Subroutine

; Code für decpval
1620: 20 30 16   ; JSR $1630 - Rufe decpvlo auf
1623: B0 03      ; BCS $1628 - Wenn kein Überlauf, springe zu done
1625: 20 40 16   ; JSR $1640 - Rufe decpvhi auf
1628: 60         ; RTS - Rückkehr aus der Subroutine

; Code für decpvlo
1630: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
1632: B1 FB      ; LDA ($FB),Y - Lade niederwertiges Byte der Speicherzelle
1634: 38         ; SEC - Setze Carry-Flag
1635: E9 01      ; SBC #$01 - Subtrahiere 1 vom niederwertigen Byte
1637: 91 FB      ; STA ($FB),Y - Speichere das Ergebnis ins niederwertige Byte
1639: 60         ; RTS - Rückkehr aus der Subroutine

; Code für decpvhi
1640: A0 01      ; LDY #$01 - Setze Y-Register auf 1
1642: B1 FB      ; LDA ($FB),Y - Lade höherwertiges Byte der Speicherzelle
1644: 38         ; SEC - Setze Carry-Flag
1645: E9 01      ; SBC #$01 - Subtrahiere 1 vom höherwertigen Byte
1647: 91 FB      ; STA ($FB),Y - Speichere das Ergebnis ins höherwertige Byte
1649: 60         ; RTS - Rückkehr aus der Subroutine

; Code für incpval
1650: 20 60 16   ; JSR $1660 - Rufe incpvlo auf
1653: 90 03      ; BCC $1658 - Wenn kein Überlauf, springe zu done
1655: 20 70 16   ; JSR $1670 - Rufe incpvhi auf
1658: 60         ; RTS - Rückkehr aus der Subroutine

; Code für incpvlo
1660: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
1662: B1 FB      ; LDA ($FB),Y - Lade niederwertiges Byte der Speicherzelle
1664: 18         ; CLC - Lösche Carry-Flag
1665: 69 01      ; ADC #$01 - Addiere 1 zum niederwertigen Byte
1667: 91 FB      ; STA ($FB),Y - Speichere das Ergebnis ins niederwertige Byte
1669: 60         ; RTS - Rückkehr aus der Subroutine

; Code für incpvhi
1670: A0 01      ; LDY #$01 - Setze Y-Register auf 1
1672: B1 FB      ; LDA ($FB),Y - Lade höherwertiges Byte der Speicherzelle
1674: 18         ; CLC - Lösche Carry-Flag
1675: 69 01      ; ADC #$01 - Addiere 1 zum höherwertigen Byte
1677: 91 FB      ; STA ($FB),Y - Speichere das Ergebnis ins höherwertige Byte
1679: 60         ; RTS - Rückkehr aus der Subroutine

; Variablen
1680: 28         ; "(" öffnende Klammer
1681: 29         ; ")" schließende Klammer
1682: 28         ; "(" öffnende Klammer
1683: 00         ; Zähler für Klammern

; Hilfsroutine init_search für while/wend
; ---------------------------------------
; Prüft den Wert der aktuellen Speicherzelle (*ptr) und
; bricht die Suche direkt ab, falls *ptr != 0.
;
; Funktionsweise:
; - Prüft den Wert der aktuellen Speicherzelle (*ptr).
; - falls *ptr != 0 wird die Rücksprungadresse vom Stack enternt und per RTS direkt zu 
;   increment_codeptr zurückgegehrt
; - Initialisiert den Klammerzähler ($1683) mit 1, falls *ptr == 0.

1688: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
168A: B1 FB      ; LDA ($FB),Y - Lade den Wert der aktuellen Speicherzelle
168C: D0 05      ; BNE continue_loop - Wenn *ptr != 0, dann weiter in Schleife
168E: C8         ; INY
168F: B1 FB      ; LDA ($FB),Y - prüfe Hi-Byte
1691: F0 03      ; BEQ start_search
; continue_loop:                 
1693: 68         ; PLA - Entferne die aktuelle Rücksprungadresse (niederwertiges Byte)
1694: 68         ; PLA - Entferne die aktuelle Rücksprungadresse (höherwertiges Byte)
1695: 60         ; RTS - Kehre direkt zu increment_codeptr zurück
; start_search:      
1696: A9 01      ; LDA #$01 - Lade 1 in den Akkumulator
1698: 8D 83 16   ; STA $1683 - Initialisiere den Klammerzähler mit 1
169B: 60         ; RTS - Rückkehr zur aufrufenden Routine

; Code für while
16A0: 20 88 16   ; JSR $1688 - Rufe init_search auf
; find_paren_loop:
16A3: E6 FD      ; INC $FD - Erhöhe niederwertiges Byte von codeptr um 1
16A5: D0 02      ; BNE $16A9 - Wenn kein Überlauf, springe zu check_paren
16A7: E6 FE      ; INC $FE - Erhöhe höherwertiges Byte von codeptr
; check_paren:
16A9: 20 64 17   ; JSR $1764 - Rufe compare_close_paren auf
16AC: D0 F5      ; BNE $16A3 - Wenn Suche nicht abgeschlossen, wiederhole
16AE: 60         ; RTS - Rückkehr zur Hauptschleife

; Code für wend
16B0: 20 96 16   ; JSR $1696 - Initialisiere den Klammerzähler mit 1
; find_paren_loop:
16B3: C6 FD      ; DEC $FD - Verringere niederwertiges Byte von codeptr um 1
16B5: 10 02      ; BPL $16B9 - Wenn kein Unterlauf, springe zu check_paren
16B7: C6 FE      ; DEC $FE - Verringere höherwertiges Byte von codeptr
; check_paren:
16B9: 20 60 17   ; JSR $1760 - Rufe compare_open_paren auf
16BC: D0 F5      ; BNE $16B3 - Wenn Suche nicht abgeschlossen, wiederhole
16BE: C6 FD      ; DEC $FD - Verringere niederwertiges Byte von codeptr um 1
16C0: 10 02      ; BPL $16C4 - Wenn kein Unterlauf, dann weiter
16C2: C6 FE      ; DEC $FE - Verringere höherwertiges Byte von codeptr
16C4: 60         ; RTS - Rückkehr zur Hauptschleife

; Code für read
16D0: 20 E4 FF   ; JSR $FFE4 - Rufe KERNAL-Routine GETCHIN auf (liest ein Zeichen von der Tastatur)
16D3: C9 00      ; CMP #$00 - Vergleiche das gelesene Zeichen mit 0
16D5: F0 F9      ; BEQ $16D0 - Wenn kein Zeichen gelesen wurde, wiederhole die Abfrage
16D7: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
16D9: 91 FB      ; STA ($FB),Y - Speichere das gelesene Zeichen in der aktuellen Speicherzelle
16DB: 60         ; RTS - Rückkehr zur Hauptschleife

; Code für write
16E0: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
16E2: B1 FB      ; LDA ($FB),Y - Lade das Zeichen aus der aktuellen Speicherzelle
16E4: 20 D2 FF   ; JSR $FFD2 - Rufe KERNAL-Routine CHROUT auf (gibt das Zeichen aus)
16E7: 60         ; RTS - Rückkehr zur Hauptschleife

; Code für interpreter
; increment_codeptr:
1700: E6 FD      ; INC $FD - Erhöhe niederwertiges Byte von codeptr um 1
1702: D0 02      ; BNE $1706 - Wenn kein Überlauf, springe zu next
1704: E6 FE      ; INC $FE - Erhöhe höherwertiges Byte von codeptr
; Interpreter Startadresse $1706
1706: A9 16      ; LDA #>increment_codeptr-1 - Lade höherwertiges Byte von (increment_codeptr - 1)
1708: 48         ; PHA - Push höherwertiges Byte auf den Stack
1709: A9 FF      ; LDA #<increment_codeptr-1 - Lade niederwertiges Byte von (increment_codeptr - 1)
170B: 48         ; PHA - Push niederwertiges Byte auf den Stack
170C: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
170E: B1 FD      ; LDA ($FD),Y - Lade das aktuelle Zeichen aus dem BF-Code
1710: C9 3C      ; CMP #$3C - Vergleiche mit '<'
1712: D0 03      ; BNE $1717 - Wenn ungleich, springe zu check_incptr
1714: 4C 00 16   ; JMP $1600 - Springe direkt zu decptr
1717: C9 3E      ; CMP #$3E - Vergleiche mit '>'
1719: D0 03      ; BNE $171E - Wenn ungleich, springe zu check_decpval
171B: 4C 10 16   ; JMP $1610 - Springe direkt zu incptr
171E: C9 2D      ; CMP #$2D - Vergleiche mit '-'
1720: D0 03      ; BNE $1725 - Wenn ungleich, springe zu check_incpval
1722: 4C 20 16   ; JMP $1620 - Springe direkt zu decpval
1725: C9 2B      ; CMP #$2B - Vergleiche mit '+'
1727: D0 03      ; BNE $172C - Wenn ungleich, springe zu check_while
1729: 4C 50 16   ; JMP $1650 - Springe direkt zu incpval
172C: CD 80 16   ; CMP $1680 - Vergleiche mit dem Zeichen in Speicheradresse $1680
172F: D0 03      ; BNE $1733 - Wenn ungleich, springe zu check_wend
1731: 4C A0 16   ; JMP $16A0 - Springe direkt zu while
1733: CD 81 16   ; CMP $1681 - Vergleiche mit dem Zeichen in Speicheradresse $1681
1736: D0 03      ; BNE $173A - Wenn ungleich, springe zu check_write
1738: 4C B0 16   ; JMP $16B0 - Springe direkt zu wend
173A: C9 2E      ; CMP #$2E - Vergleiche mit '.'
173C: D0 03      ; BNE $1741 - Wenn ungleich, springe zu check_read
173E: 4C E0 16   ; JMP $16E0 - Springe direkt zu write
1741: C9 2C      ; CMP #$2C - Vergleiche mit ','
1743: D0 03      ; BNE $1748 - Wenn ungleich, springe zu check_end
1745: 4C D0 16   ; JMP $16D0 - Springe direkt zu read
1748: C9 23      ; CMP #$23 - Vergleiche mit '#'
174A: F0 01      ; BEQ $174D - Wenn gleich, springe zu end_interpreter
174C: 60         ; RTS - Rückkehr zu increment_codeptr
; end_interpreter:
174D: 68         ; PLA - Entferne höherwertiges Byte von increment_codeptr vom Stack
174E: 68         ; PLA - Entferne niederwertiges Byte von increment_codeptr vom Stack
1750: 60         ; RTS - Rückkehr ins BASIC

; Subroutine compare_paren
; ------------------------
; Diese Subroutine führt einen Schritt bei der Suche nach der passenden Klammer 
; in einem Brainfuck-Programm aus.
; Wenn die passende Klammer gefunden wurde, wird der codeptr ($FD/$FE) auf das 
; Zeichen hinter der gefundenen Klammer gesetzt und das Zero-Flag gesetzt.
;
; Voraussetzungen:
; - $1683 wird als Klammerzähler verwendet und muss vor der Suche auf 1 gesetzt werden.
;
; Funktionsweise:
; - Die Subroutine prüft das Zeichen an der aktuellen Position von codeptr ($FD/$FE).
; - Wenn das Zeichen eine öffnende oder schließende Klammer ist, wird der Klammerzähler
;   ($1683) entsprechend erhöht oder verringert.
; - Wenn der Klammerzähler $1683 auf 0 fällt, wurde die passende Klammer gefunden.
; - Das Zero-Flag wird gesetzt, wenn die Suche erfolgreich abgeschlossen wurde
;   (d. h., die passende Klammer wurde gefunden).
; - Das Zero-Flag bleibt gelöscht, wenn die Suche nicht abgeschlossen ist.
;
; Hinweis:
; - Diese Subroutine führt nur einen einzelnen Suchschritt aus. Die Schleifenlogik,
;   die den codeptr weiterbewegt, muss außerhalb dieser Subroutine implementiert werden.

; Einstiegspunkt für die Suche nach einer öffnenden Klammer ')'
compare_open_paren:
1760: A2 00      ; LDX #$00 - Setze X auf 0 (Suche nach '(')
1762: F0 02      ; BEQ $1766 - Springe zur gemeinsamen Logik

; Einstiegspunkt für die Suche nach einer schließenden Klammer '('
compare_closed_paren:
1764: A2 01      ; LDX #$01 - Setze X auf 1 (Suche nach ')')
; Gemeinsame Logik:
1766: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
1768: B1 FD      ; LDA ($FD),Y - Lade das aktuelle Zeichen aus dem BF-Code
176A: DD 80 16   ; CMP $1680,X - Vergleiche mit der ersten Klammer '(' oder ')'
176D: F0 0a      ; BEQ $1779 - Wenn gleich, springe zu decrement_counter
176F: DD 81 16   ; CMP $1681,X - Vergleiche mit der zweiten Klammer '(' oder ')'
1772: F0 01      ; BEQ $1775 - Wenn gleich, springe zu increment_counter
1774: 60         ; RTS - Rückkehr, wenn kein relevantes Zeichen gefunden

; increment_counter:
1775: EE 83 16   ; INC $1683 - Erhöhe den Klammerzähler
1778: 60         ; RTS - Rückkehr zur Hauptschleife

; decrement_counter:
1779: CE 83 16   ; DEC $1683 - Verringere den Klammerzähler
177C: 60         ; RTS - Rückkehr (Zero-Flag zeigt Status der Suche)

; main
1790: A9 00      ; LDA #$00 - Lade 0 in den Akkumulator
1792: 85 FD      ; STA $FD - Speichere 0 in das niederwertige Byte von codeptr
1794: A9 1E      ; LDA #$1E - Lade $1E in den Akkumulator
1796: 85 FE      ; STA $FE - Speichere $1E in das höherwertige Byte von codeptr
1798: A9 00      ; LDA #$00 - Lade 0 in den Akkumulator
179A: 85 FB      ; STA $FB - Speichere 0 in das niederwertige Byte von ptr
179C: A9 18      ; LDA #$18 - Lade $18 in den Akkumulator
179E: 85 FC      ; STA $FC - Speichere $18 in das höherwertige Byte von ptr
; Schleife zum Setzen der Werte in $1800-$18FF auf 0
17A0: A9 00      ; LDA #$00 - Lade 0 in den Akkumulator
17A2: A2 00      ; LDX #$00 - Initialisiere X-Register mit 0 (Startadresse Offset)
17A4: 9D 00 18   ; STA $1800,X - Schreibe 0 an die Adresse $1800 + X
17A7: E8         ; INX - Erhöhe X um 1
17A8: D0 FA      ; BNE $17A4 - Wiederhole, solange X nicht 0 (nach $FF wird es 0)
17AA: 4C 06 17   ; JMP $1706 - Springe zur Interpreter-Routine