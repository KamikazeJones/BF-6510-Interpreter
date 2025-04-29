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
;   .: read    | liest ein Zeichen von der Eingabe (Tastatur, Datei) nach *ptr 
;   ,: write   | schreibt *ptr in die Ausgabe (auf den Bildschirm oder in eine
                 Datei)

; Die Speicherzellen in BF enthalten 16-Bit vorzeichenlose Integer-Werte.
; Damit werden für eine Speicherzelle 2 Byte benötigt.
; Da im 6510-Assembler die Speicherzellen nur ein Byte groß sind, muss decptr 
; den ptr um 2 verringern, und incptr muss um 2 erhöhen.

; Code für decptr
2000: A5 FB      ; LDA $FB - Lade niederwertiges Byte des Zeigers
2002: D0 02      ; BNE $2006 - Wenn $FB != 0, überspringe DEC $FC
2004: C6 FC      ; DEC $FC - Verringere höherwertiges Byte des Zeigers
2006: C6 FB      ; DEC $FB - Verringere niederwertiges Byte um 1
2008: C6 FB      ; DEC $FB - Verringere niederwertiges Byte erneut um 1
200A: 60         ; RTS - Rückkehr aus Subroutine

; Code für incptr
2010: E6 FB      ; INC $FB - Erhöhe niederwertiges Byte des Zeigers um 1
2012: E6 FB      ; INC $FB - Erhöhe niederwertiges Byte erneut um 1
2014: D0 02      ; BNE $2018 - Wenn $FB != 0, überspringe INC $FC
2016: E6 FC      ; INC $FC - Erhöhe höherwertiges Byte des Zeigers
2018: 60         ; RTS - Rückkehr aus Subroutine

; Code für decpval
2020: 20 30 20   ; JSR $2030 - Rufe decpvlo auf
2023: B0 03      ; BCS $2028 - Wenn kein Überlauf, springe zu done
2025: 20 40 20   ; JSR $2040 - Rufe decpvhi auf
2028: 60         ; RTS - Rückkehr aus der Subroutine

; Code für decpvlo
2030: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
2032: B1 FB      ; LDA ($FB),Y - Lade niederwertiges Byte der Speicherzelle
2034: 38         ; SEC - Setze Carry-Flag
2035: E9 01      ; SBC #$01 - Subtrahiere 1 vom niederwertigen Byte
2037: 91 FB      ; STA ($FB),Y - Speichere das Ergebnis ins niederwertige Byte
2039: 60         ; RTS - Rückkehr aus der Subroutine

; Code für decpvhi
2040: A0 01      ; LDY #$01 - Setze Y-Register auf 1
2042: B1 FB      ; LDA ($FB),Y - Lade höherwertiges Byte der Speicherzelle
2044: 38         ; SEC - Setze Carry-Flag
2045: E9 01      ; SBC #$01 - Subtrahiere 1 vom höherwertigen Byte
2047: 91 FB      ; STA ($FB),Y - Speichere das Ergebnis ins höherwertige Byte
2049: 60         ; RTS - Rückkehr aus der Subroutine

; Code für incpval
2050: 20 60 20   ; JSR $2060 - Rufe incpvlo auf
2053: 90 03      ; BCC $2058 - Wenn kein Überlauf, springe zu done
2055: 20 70 20   ; JSR $2070 - Rufe incpvhi auf
2058: 60         ; RTS - Rückkehr aus der Subroutine

; Code für incpvlo
2060: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
2062: B1 FB      ; LDA ($FB),Y - Lade niederwertiges Byte der Speicherzelle
2064: 18         ; CLC - Lösche Carry-Flag
2065: 69 01      ; ADC #$01 - Addiere 1 zum niederwertigen Byte
2067: 91 FB      ; STA ($FB),Y - Speichere das Ergebnis ins niederwertige Byte
2069: 60         ; RTS - Rückkehr aus der Subroutine

; Code für incpvhi
2070: A0 01      ; LDY #$01 - Setze Y-Register auf 1
2072: B1 FB      ; LDA ($FB),Y - Lade höherwertiges Byte der Speicherzelle
2074: 18         ; CLC - Lösche Carry-Flag
2075: 69 01      ; ADC #$01 - Addiere 1 zum höherwertigen Byte
2077: 91 FB      ; STA ($FB),Y - Speichere das Ergebnis ins höherwertige Byte
2079: 60         ; RTS - Rückkehr aus der Subroutine

; Hilfsroutine init_search für while/wend
; ---------------------------------------
; Prüft den Wert der aktuellen Speicherzelle (*ptr) und
; bricht die Suche direkt ab, falls *ptr != 0.
;
; Funktionsweise:
; - Prüft den Wert der aktuellen Speicherzelle (*ptr).
; - falls *ptr != 0 wird die Rücksprungadresse vom Stack enternt und per RTS direkt zu 
;   increment_codeptr zurückgegehrt
; - Initialisiert den Klammerzähler ($2083) mit 1, falls *ptr == 0.

2090: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
2092: B1 FB      ; LDA ($FB),Y - Lade den Wert der aktuellen Speicherzelle
2094: F0 04      ; BEQ $209A - Wenn *ptr == 0, springe zur Initialisierung
2096: PLA        ; Entferne die aktuelle Rücksprungadresse (niederwertiges Byte)
2097: PLA        ; Entferne die aktuelle Rücksprungadresse (höherwertiges Byte)
2098: RTS        ; Kehre direkt zu increment_codeptr zurück
209A: A9 01      ; LDA #$01 - Lade 1 in den Akkumulator
209C: 8D 83 20   ; STA $2083 - Initialisiere den Klammerzähler mit 1
209F: 60         ; RTS - Rückkehr zur aufrufenden Routine

; Code für while
20A0: 20 90 20   ; JSR $2090 - Rufe init_search auf
; find_paren_loop:
20A3: E6 FD      ; INC $FD - Erhöhe niederwertiges Byte von codeptr um 1
20A5: D0 02      ; BNE $20A9 - Wenn kein Überlauf, springe zu check_paren
20A7: E6 FE      ; INC $FE - Erhöhe höherwertiges Byte von codeptr
; check_paren:
20A9: 20 64 21   ; JSR $2164 - Rufe compare_close_paren auf
20AC: D0 F5      ; BNE $20A3 - Wenn Suche nicht abgeschlossen, wiederhole
20AE: 60         ; RTS - Rückkehr zur Hauptschleife

; Code für wend
20B0: 20 90 20   ; JSR $2090 - Rufe init_search auf
; find_paren_loop:
20B3: C6 FD      ; DEC $FD - Verringere niederwertiges Byte von codeptr um 1
20B5: 10 02      ; BPL $20B9 - Wenn kein Unterlauf, springe zu check_paren
20B7: C6 FE      ; DEC $FE - Verringere höherwertiges Byte von codeptr
; check_paren:
20B9: 20 60 21   ; JSR $2160 - Rufe compare_open_paren auf
20BC: D0 F5      ; BNE $20B3 - Wenn Suche nicht abgeschlossen, wiederhole
20BE: 60         ; RTS - Rückkehr zur Hauptschleife

; Code für read
20D0: 20 E4 FF   ; JSR $FFE4 - Rufe KERNAL-Routine GETCHIN auf (liest ein Zeichen von der Tastatur)
20D3: C9 00      ; CMP #$00 - Vergleiche das gelesene Zeichen mit 0
20D5: F0 F9      ; BEQ $20D0 - Wenn kein Zeichen gelesen wurde, wiederhole die Abfrage
20D7: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
20D9: 91 FB      ; STA ($FB),Y - Speichere das gelesene Zeichen in der aktuellen Speicherzelle
20DB: 60         ; RTS - Rückkehr zur Hauptschleife

; Code für write
20E0: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
20E2: B1 FB      ; LDA ($FB),Y - Lade das Zeichen aus der aktuellen Speicherzelle
20E4: 20 D2 FF   ; JSR $FFD2 - Rufe KERNAL-Routine CHROUT auf (gibt das Zeichen aus)
20E7: 60         ; RTS - Rückkehr zur Hauptschleife

; Code für interpreter
; increment_codeptr:
2100: E6 FD      ; INC $FD - Erhöhe niederwertiges Byte von codeptr um 1
2102: D0 02      ; BNE $2106 - Wenn kein Überlauf, springe zu next
2104: E6 FE      ; INC $FE - Erhöhe höherwertiges Byte von codeptr
; Interpreter Startadresse $2106
2106: A9 FF      ; LDA #<increment_codeptr-1 - Lade niederwertiges Byte von (increment_codeptr - 1)
2108: 48         ; PHA - Push niederwertiges Byte auf den Stack
2109: A9 21      ; LDA #>increment_codeptr-1 - Lade höherwertiges Byte von (increment_codeptr - 1)
210B: 48         ; PHA - Push höherwertiges Byte auf den Stack
210C: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
210E: B1 FD      ; LDA ($FD),Y - Lade das aktuelle Zeichen aus dem BF-Code
2110: C9 3C      ; CMP #$3C - Vergleiche mit '<'
2112: D0 03      ; BNE $2117 - Wenn ungleich, springe zu check_incptr
2114: 4C 00 20   ; JMP $2000 - Springe direkt zu decptr
2117: C9 3E      ; CMP #$3E - Vergleiche mit '>'
2119: D0 03      ; BNE $211E - Wenn ungleich, springe zu check_decpval
211B: 4C 10 20   ; JMP $2010 - Springe direkt zu incptr
211E: C9 2D      ; CMP #$2D - Vergleiche mit '-'
2120: D0 03      ; BNE $2125 - Wenn ungleich, springe zu check_incpval
2122: 4C 20 20   ; JMP $2020 - Springe direkt zu decpval
2125: C9 2B      ; CMP #$2B - Vergleiche mit '+'
2127: D0 03      ; BNE $212C - Wenn ungleich, springe zu check_while
2129: 4C 50 20   ; JMP $2050 - Springe direkt zu incpval
212C: C9 28      ; CMP #$28 - Vergleiche mit '('
212E: D0 03      ; BNE $2133 - Wenn ungleich, springe zu check_wend
2130: 4C 90 20   ; JMP $2090 - Springe direkt zu while
2133: C9 29      ; CMP #$29 - Vergleiche mit ')'
2135: D0 03      ; BNE $213A - Wenn ungleich, springe zu check_write
2137: 4C B0 20   ; JMP $20B0 - Springe direkt zu wend
213A: C9 2E      ; CMP #$2E - Vergleiche mit '.'
213C: D0 03      ; BNE $2141 - Wenn ungleich, springe zu check_read
213E: 4C D0 20   ; JMP $20D0 - Springe direkt zu read
2141: C9 2C      ; CMP #$2C - Vergleiche mit ','
2143: D0 03      ; BNE $2148 - Wenn ungleich, springe zu check_end
2145: 4C E0 20   ; JMP $20E0 - Springe direkt zu write
2148: C9 23      ; CMP #$23 - Vergleiche mit '#'
214A: F0 01      ; BEQ $214D - Wenn gleich, springe zu end_interpreter
214C: 60         ; RTS - Rückkehr zu increment_codeptr
; end_interpreter:
214D: 68         ; PLA - Entferne höherwertiges Byte von increment_codeptr vom Stack
214E: 68         ; PLA - Entferne niederwertiges Byte von increment_codeptr vom Stack
214F: 60         ; RTS - Rückkehr ins BASIC

; Subroutine compare_paren
; ------------------------
; Diese Subroutine führt einen Schritt bei der Suche nach der passenden Klammer 
; in einem Brainfuck-Programm aus.
; Wenn die passende Klammer gefunden wurde, wird der codeptr ($FD/$FE) auf das 
; Zeichen hinter der gefundenen Klammer gesetzt und das Zero-Flag gesetzt.
;
; Voraussetzungen:
; - $2083 wird als Klammerzähler verwendet und muss vor der Suche auf 1 gesetzt werden.
;
; Funktionsweise:
; - Die Subroutine prüft das Zeichen an der aktuellen Position von codeptr ($FD/$FE).
; - Wenn das Zeichen eine öffnende oder schließende Klammer ist, wird der Klammerzähler
;   ($2083) entsprechend erhöht oder verringert.
; - Wenn der Klammerzähler $2083 auf 0 fällt, wurde die passende Klammer gefunden.
; - Das Zero-Flag wird gesetzt, wenn die Suche erfolgreich abgeschlossen wurde
;   (d. h., die passende Klammer wurde gefunden).
; - Das Zero-Flag bleibt gelöscht, wenn die Suche nicht abgeschlossen ist.
;
; Hinweis:
; - Diese Subroutine führt nur einen einzelnen Suchschritt aus. Die Schleifenlogik,
;   die den codeptr weiterbewegt, muss außerhalb dieser Subroutine implementiert werden.

; Einstiegspunkt für die Suche nach einer schließenden Klammer ')'
compare_close_paren:
2160: A2 00      ; LDX #$00 - Setze X auf 0 (Suche nach ')')
2162: D0 02      ; BNE $2166 - Springe zur gemeinsamen Logik

; Einstiegspunkt für die Suche nach einer öffnenden Klammer '('
compare_open_paren:
2164: A2 01      ; LDX #$01 - Setze X auf 1 (Suche nach '(')
; Gemeinsame Logik:
2166: A0 00      ; LDY #$00 - Initialisiere Y-Register mit 0
2168: B1 FD      ; LDA ($FD),Y - Lade das aktuelle Zeichen aus dem BF-Code
216A: DD 80 20   ; CMP $2080,X - Vergleiche mit der ersten Klammer '(' oder ')'
216D: F0 06      ; BEQ $2175 - Wenn gleich, springe zu increment_counter
216F: DD 81 20   ; CMP $2081,X - Vergleiche mit der zweiten Klammer '(' oder ')'
2172: F0 06      ; BEQ $217A - Wenn gleich, springe zu decrement_counter
2174: 60         ; RTS - Rückkehr, wenn kein relevantes Zeichen gefunden

; increment_counter:
2175: EE 83 20   ; INC $2083 - Erhöhe den Klammerzähler
2178: 60         ; RTS - Rückkehr zur Hauptschleife

; decrement_counter:
217A: CE 83 20   ; DEC $2083 - Verringere den Klammerzähler
217D: D0 06      ; BNE $2185 - Wenn Zähler != 0, springe zu finish
217F: E6 FD      ; INC $FD - Erhöhe niederwertiges Byte von codeptr um 1 (springe hinter ')')
2181: D0 02      ; BNE $2185 - Wenn kein Überlauf, springe zu finish
2183: E6 FE      ; INC $FE - Erhöhe höherwertiges Byte von codeptr
; finish:
2185: 98         ; TYA - Kopiere Y-Register in Akkumulator (setzt das Zero-Flag, da Y = 0)
2186: 60         ; RTS - Rückkehr, Suche beendet (Zero-Flag zeigt Status der Suche)