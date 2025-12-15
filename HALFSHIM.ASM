;;; STAGE 1/2 SHIM LOADER
;;;
;;; After a user has keyed in Dwight Elvey's BOOTSTRP.ASM at the
;;; Monitor, send this shim program from a host computer over the
;;; serial port instead of H89LDR2.ASM. This program will read yet
;;; another program over the serial port and execute it, similar to
;;; BOOTSTRP.ASM. The difference is that the next program can be
;;; loaded into any arbitrary address and can be of any length.

;;; Version 0.1 December 14, 2025
;;; -- fixed up by b9 so it should actually work. Untested.
;;; Version 0.0 December 14, 2025
;;; -- major scaffolding from AI. Completely broken, but a start.
;;; -- requires H8-4/H89/Z89.

;;; Loaded by BOOTSTRP.ASM (Stage 0) at 2329H-265BH
;;; Expects 4 byte header, [ADDR H/L][LENGTH H/L], followed by LENGTH bytes.
;;; Places received data starting at ADDR and then jumps to that location.

;;; For cross compilation, use asmx -l -e -b2329H -C8080 HALFSHIM.ASM

LP      EQU     0E0H 	; Base I/O address of 1st port on H-88-3 (340 Octal)
RX      EQU     LP	; Received byte
LSTAT   EQU     LP+5	; Line Status: Bit 0 is set if data has arrived.
DBEND   EQU     265BH	; Data Block End address from BOOTSTRP.ASM

        ORG	2329H	; Matches with last byte of BOOTSTRP.ASM

	;; --- READ HEADER --- 
SHIM:	CALL    GETCH       ; Get Destination ADDR into HL
        MOV     H,A
        CALL    GETCH
        MOV     L,A

        CALL    GETCH       ; Get LENGTH into BC
        MOV     B,A
        CALL    GETCH
        MOV     C,A

	;; --- MAIN LOAD LOOP ---
	MOV	D,H         ; DE points to next address to write 
	MOV	E,L
LOOP:	CALL    GETCH       ; Get data byte in A
	STAX	D	    ; Store byte in Stage 1 destination (DE)
	INX	D	    ; Next memory location
        DCX     B           ; Decrement LENGTH (BC)
        JNZ     LOOP	    ; Loop until LENGTH bytes done

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
;;; 3. The DS assembler macro is used to bulk out this program to DBEND
;;;    so that BOOTSTRP.ASM does not need to be changed.

;;; TODO
;;; A. Test it on actual hardware.
;;; 
;;; B. This version does not yet handle the H8 w/ cassette/serial board.
;;;    Should check if COMTYPE at byte 2313H from BOOTSTRP/BOTSTRP8 is FAH.
;;;    If so, then should use H8-5 code instead of the H8-4/H89 code.
;;;    (See H89LDR2.ASM).
