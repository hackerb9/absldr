; BOOTSTRAP LOADER WITH INIT FOR 8251
; INTENDED FOR THE H8 W/ CASSETTE/SERIAL BOARD
; 30-MAY-04  D K ELVEY

LP      EQU     0FAH
RX      EQU     LP
TX      EQU     LP
CNTL    EQU     LP+1
STAT    EQU     LP+1

DBEND   EQU     265BH   ; FROM H89LDR.PRN

        ORG 2300H
LDR:    MVI A, 0AAH
        OUT CNTL
        MVI A, 040H
        OUT CNTL        ; RESET 8251
        MVI A, 0CEH        ; ASYNC 2 STOP 8 BIT NO PARITY 16X
        OUT CNTL
        MVI A, 015H        ; MAYBE 37 BUT DON'T WANT INTRPTS
        OUT CNTL        ; ENABLE TX/RX
        IN STAT
        IN RX           ; RX=0FAH HERE USED TO DETECT H8-5
        LXI H, LDR1
        LXI D, DBEND-1  ; DEPENDS ON SIZE (TO BE DETERMINED)
        NOP
        NOP
        NOP
        NOP
LDR1:   IN STAT
        RAR
        RAR
        JNC LDR1        ; WAIT FOR CHAR
        IN RX
        STAX D
        DCX D
        PCHL            ; TO BE OVER WRITTEN BY LOADER WITH NOP
                        ;  $ SHOULD BE 2329H


