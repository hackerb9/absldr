;;; STAGE 1/2 SHIM LOADER by Hackerb9.
;;; 
;;; After a user has keyed in Dwight Elvey's BOOTSTRP.ASM at the
;;; Monitor, send this shim program from a host computer over the
;;; serial port instead of H89LDR2.ASM. This program will read yet
;;; another program over the serial port and execute it, similar to
;;; BOOTSTRP.ASM. The difference is that the next file will be
;;; prefixed with an HDOS .ABS header, which allows the data to be
;;; loaded into any arbitrary address and to be of any length.

;;; Expects an 8 byte header similar to HDOS's .ABS format
;;; 
;;; 	0: FFH	(binary type)
;;; 	1: 00H  (ABS object)
;;; 	2: ADDR L
;;; 	3: ADDR H
;;; 	4: LENGTH L
;;; 	5: LENGTH H
;;; 	6: ENTRYPOINT L
;;; 	7: ENTRYPOINT H
;;; 
;;; Places received data starting at ADDR and then jumps to ENTRYPOINT.
;;; To send multiple files, set ENTRYPOINT to this code's ORG (2329H).

;;; CREATING THE BIN FILE
;;; For cross assembly, use asmx -l -e -b2329H -C8080 HALFSHIM.ASM

;;; USAGE
;;; After keying in BOOTSTRP.OCL, send the HALFSHIM binary from a PC:
;;; 	h8clxfer.py -l -f HALFSHIM.ASM.bin
;;; After sending HALFSHIM, send an ABS file to start it running:
;;; 	h8clxfer.py -l -f GACTAGA.ABS

;;; Version 0.2 December 14, 2025
;;; -- read .ABS files directly using HDOS's 8-byte header.
;;; Version 0.1 December 14, 2025
;;; -- fixed up by b9 so it should actually work. Untested.
;;; Version 0.0 December 14, 2025
;;; -- major scaffolding from AI. Completely broken, but a start.
;;; -- requires H8-4/H89/Z89.

LP      EQU     0E0H 	; Base I/O address of 1st port on H-88-3 (340 Octal)
RX      EQU     LP	; Received byte
LSTAT   EQU     LP+5	; Line Status: Bit 0 is set if data has arrived.
DBEND   EQU     265BH	; Data Block End address from BOOTSTRP.ASM

        ORG	2329H	; Matches with last byte of BOOTSTRP.ASM

	;; --- READ HEADER --- 
SHIM:	CALL    GETCH       ; Ignore first two bytes of .ABS file
	CALL    GETCH	    ; (TODO: Maybe halt execution if not FF00?)

	CALL    GETCH       ; Get Destination ADDR into DE
        MOV     E,A
        CALL    GETCH
        MOV     D,A

        CALL    GETCH       ; Get LENGTH into BC
        MOV     C,A
        CALL    GETCH
        MOV     B,A

	CALL    GETCH       ; Get Jump ADDR into HL
        MOV     L,A
        CALL    GETCH
        MOV     H,A

	;; --- MAIN LOAD LOOP ---
LOOP:	CALL    GETCH       ; Read byte from serial into A
	STAX	D	    ; Store byte in destination (*DE)
	INX	D	    ; Next memory location
        DCX     B           ; Decrement LENGTH (BC) -- (Does not set Z-flag!)
	MVI	A,0         ; Probably there's a better way to do this....
	CMP	C	    ; Is C (low byte) == 0?
	JNZ     LOOP	    ; Nope, so loop for next byte
	CMP	B	    ; Is B (high byte) also 0?
	JNZ	LOOP	    ; Nope, so loop for another 256 bytes.
	
	;; --- EXECUTE NEXT STAGE ---
        PCHL                ; Jump to the received code.

;;; --- SERIAL INPUT ROUTINE ---
;;; (Presumes serial port already configured by Stage 0 loader.)
GETCH:	IN      LSTAT       ; Get serial port status 
        RAR		    ; Put "ready" bit in Carry
        JNC     GETCH       ; Wait for char
        IN      RX	    ; Read the byte into A
        RET

;;; --- PAD GAP ---
;;; Reserve enough bytes to match the length of H89LDR2.
PRGEND:	DS	DBEND-PRGEND-1
	NOP


;;; NOTES
;;; 1. Stack pointer is initialized to end of memory by MTR at power-on.
;;; 2. CPU speed should not be an issue.
;;;    a. At 9600 baud, a byte arrives approximately every millisecond.
;;;    b. Execution path from GETCH to GETCH is 54 T-states ≈ 0.027 ms.
;;; 3. The DS assembler macro is used to bulk out this program to
;;;    DBEND so that BOOTSTRP.ASM does need not be changed. This
;;;    program will be loaded into 2329H-265BH, same as H89LDR2.


;;; TODO
;;; A. Test it on actual hardware.
;;; 
;;; B. This version does not yet handle the H8 w/ cassette/serial board.
;;;    Should check if COMTYPE at byte 2313H from BOOTSTRP/BOTSTRP8 is FAH.
;;;    If so, then should use H8-5 code instead of the H8-4/H89 code.
;;;    (See H89LDR2.ASM).
