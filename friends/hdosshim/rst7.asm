; HDOS System Call Vector
; Redirects RST 7 (RST 38H) to the resident HDOS handler.
	ORG 0038H
	JMP 2011H    ; Jump to HDOS SCALL handler entry point

	
