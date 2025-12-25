# ABSLDR

Run arbitrary programs on the Heath H89 microcomputer without a floppy drive
by loading them over the serial port.

____

# WARNING: THIS IS NOT YET WORKING.
____

## Description

After a user has keyed in Dwight Elvey's [BOOTSTRP][H89LDR] at the
Monitor, send first the QUARTERSHIM program from a host computer over
the serial port instead of H89LDR2.ASM. That program will read yet
another program over the serial port, ABSLDR, and execute it, similar to
BOOTSTRP.ASM. The difference is that the next file will be prefixed
with an HDOS .ABS header, which allows the data to be loaded into any
arbitrary address and to be of any length.

[H89LDR]: friends/H89LDR9/

## Quick Usage

1. Key in Dwight Elvey's [BOOTSTRP.OCL][BOOTSTRP.OCL]
2. Send [QUARTERSHIM.BIN](QUARTERSHIM.BIN)
3. Send [ABSLDR.BIN](ABSLDR.BIN])
4. Send SOMEFILE.ABS.

## Usage

After keying in Dwight Elvey's BOOTSTRP, send QUARTERSHIM and the
ABSLDR binary from a PC using hackerb9's [h89trans.py][h89trans.py].

0. Connect your PC with a straight (not null) serial cable to the port
   labelled **430** on the back of your H89.
1. Turn on your H89 with no disk in the drive. 
   1. At the **H:** prompt type `B`, and hit <kbd>Return</kbd>.
   2. Press <kbd>Right-Shift</kbd> + <kbd>Reset</kbd> to stop the boot
	  attempt.
   3. Type `S 43000` and type in the octal bytes from
	  [BOOTSTRP.OCL][BOOTSTRP.OCL] with each one separated by
	  <kbd>Space</kbd>. When done, hit <kbd>Return</kbd>. 
   4. At the **H:** prompt, enter `G 43000` and hit <kbd>Return</kbd>.
5. On your PC, run `h89trans.py` 
   1. Press <kbd>Q</kbd> to send QUARTERSHIM.BIN to your H89.
   2. Press <kbd>F</kbd> to send ABSLDR.BIN to your H89's Floppy RAM.
   3. Press <kbd>O</kbd> to open an existing .ABS file. _(Tip: Hit
      <kbd>Enter</kbd> to see the list of files. You can enter
      directory names, including `..` for the parent directory.)_
   4. Press <kbd>A</kbd> to send the ABS file to your H89. It will
      start running automatically.

[BOOTSTRP.OCL]: friends/H89LDR9/BOOTSTRP.OCL

## About

I wrote this because I recently purchased a Zenith Z-89 and its floppy
drive isn't working yet. 

There is a nifty program by Dwight Elvey called H89LDR which gives the
users a small "Stage 0" boot loader called BOOTSTRP.OCL they can key
into the builtin Monitor program. It is only 43 bytes, but it is just
enough that it can receive the main boot loader over the serial port
and start running it. Normally that program would be H89LDR2 which
lets your PC read from and write to the H89 floppy drives over the
serial port. 

But, if your floppy drive isn't working and you still want to try
running something without keying in every byte, what do you do?

Well, you can try this program. When you send ABSLDR (instead of
H89LDR2) to the Stage 0 bootstrap, it will wait for yet another
program to be sent over the serial port. This time it will expect an
8-byte header before the binary code. That header lets us choose where
the program will be loaded, how many bytes to receive, and jump to any
arbitrary address we want. (Even back to ABSLDR, if more parts are
needed to load into memory.)
 
### Header format

ABSLDR expects an 8 byte header which is the same as HDOS's .ABS
format.

	0: FFH	(binary type)
	1: 00H  (ABS object)
	2: ADDR L
	3: ADDR H
	4: LENGTH L
	5: LENGTH H
	6: ENTRYPOINT L
	7: ENTRYPOINT H

ABSLDR places received data starting at ADDR for LENGTH bytes and
then jumps to ENTRYPOINT. To send multiple files, set ENTRYPOINT to
this code's ORG (2329H).

## Creating the bin files

For cross assembly, you can run `make` which runs these commands.

    asmx -b2329H -e -w -C8080 QUARTERSHIM.ASM
    asmx -b1400H -e -w -C8080 ABSLDR.ASM


Although it is not necessary for this program, you may wish to try
[Mark Garlanger's hacked version of asmx][mgasmx] which has been
modified for Heathkit computers, such as the ability to directly
create HDOS .ABS files. [Note: As of 2025 there is a bug which caused
the MG's asmx to create incorrect binary files.]

[mgasmx]: https://github.com/mgarlanger/asmx

## Caveats

* This is completely untested. If you try this, please leave feedback to
  let me know.

* Arbitrary .ABS files from HDOS are unlikely to work.

  * They may call HDOS routines which aren't loaded into memory.
    Theoretically, one might be able to chain together custom .ABS
    files which load the necessary parts of HDOS into RAM, using the
    ENTRYPOINT address to return to ABSLDR after each one.

  * Programs which reference other files on a disk will of course
    completely fail.

* H8 with cassette/serial is not currently supported and is unlikely
  to ever be. The code to handle two different UART chips is uglier
  than I'd like for a tiny program like this. It seems better to
  create a separate program. Additionally, in the future, the plan is
  to have ABSLDR show text on the H89 screen when it is running,
  which would rule out the H8-5 serial card which uses the same I/O
  port as the terminal part of the H89.

## Notes
1. The DS assembler macro is used to bulk out QUARTERSHIM to DBEND so
   that BOOTSTRP.ASM does need not be changed. It will be loaded into
   2329H-265BH, same as H89LDR2.
1. The DS assembler macro is used to bulk out ABSLDR to 1024 bytes. It
   will be loaded into 1400-16FFH, the floppy RAM area.
1. These programs don't initialize the stack pointer, which should be
   fine since it is initialized to end of memory by MTR at power-on.
1. CPU speed should not be an issue.
   1. At 9600 baud, a byte arrives approximately every millisecond.
   2. Execution path from GETCH to GETCH is 54 T-states ≈ 0.027 ms.

## Questions
1. Should this be more like Dwight's H89LDR2?
   * Dwight's H89LDR2 is able to slide its own code to the correct
	  location if there was an error before the serial transmission to
	  BOOTLDR. (It can handle up to four extraneous bytes.) I haven't
	  seen the need for this, yet, and left it out.
  * Why does H89LDR2 re-initialize the serial card after BOOTLDR has
	 already done so? It cannot run standalone as it reads a specific
	 byte in BOOTLDR to determine the COMTYPE.
  * Why does H89LDR2 create its own stack area instead of using the
     default set by MTR (end of memory)? Should ABSLDR do something
     similar?

1. For sending files to QUARTERSHIM and ABSLDR, is it better to:
   * Use the same one character handshake Dwight's H89TRANS.COM
     program uses so we can send files from existing programs?

     Bad idea as it requires renaming each file to send as
     "H89LDR2.BIN"!

   * Use no handshakes at all? They are only necessary for H89LDR2
     because it is a server waiting for commands and returning results
     when done. Both QUARTERSHIM and ABSLDR only do one thing: load
     incoming data from the serial port into memory. I've tested
     sending files over the serial port using `cat FILENAME >
     /dev/ttyUSB0` and it works fine.
	 
	 Probably not a good idea to do it this way as it would hinder
     merging ABSLDR and H89LDR2 in the future. 

   * Create new handshakes? Perhaps 
   
     * 'F' for "Load next 1K to 1400H (Floppy RAM) and jump to it",
       and
	 * 'B' for "Load .ABS file and start to its specified entry point".
	 
	 I've already created my own h89trans.py which could easily handle
     a new protocol. The downside is that would mean H89TRANS and all
     the current H89TRANS-compatible programs would not work until
     they were updated.
	 
	 (Note: I cannot use 'A' for the "Load ABS" command, because
     H89TRANS.COM uses that character as a test to see if H89LDR2 is
     Alive on the H89 before sending disk images. It waits for '?' in
     response. It would have made more sense to use '?' as the command
     to check if the server is responding, but done is done.)

## TODO

1. Remove references h8clxfer from this file. 
1. Solidify protocol: 'F' for sending a 1K file to be placed in Floppy
   RAM at 1400H. 'B' for sending an ABS file. 'A' for Alive check
   (responds with '?').
1. Get it working on actual hardware.
1. Output text to the H89 / H19 screen.
1. Try running non-trivial HDOS .ABS programs by preloading parts of
   HDOS into RAM. 

## Support programs

### h8clxfer (moribund)

`h8clxfer.py` was an old Python 2 program that I spent some time
fixing up so I wouldn't have to run H89TRANS.COM in DOSBox. I ported
it to Python 3 and improved it to the point where it should work as
well as it ever did (or better). But as I delved deeper into it I
realized it wasn't a good starting point for what I wanted to do since
its behaviour differs from Dwight's official H89TRANS. You can see
where I left off on my Python 3 version of h8clxfer here:
[friends/h8clxfer.py](h8clxfer.py).

### h89trans.py (recommended)

When h8clxfer was a bust, I started over from scratch, porting
H89TRANS.SEQ from Forth to Python. (See [h89trans.py][h89trans.py]). I
worked at the function-call level, so it should function identically
to the original H89TRANS.COM, except for some added frills, like
autodetecting your serial ports and not dying on errors.

`h89trans.py` should work on any operating system that can run Python,
but has only been tested on Debian GNU/Linux. If you try h89trans.py
on Microsoft Windows or Apple MacOS, I'd like to hear from you
regardless of whether it works or not.



[h89trans.py]: friends/H89LDR9/h89trans.py "Hackerb9's Python port of Dwight's H89TRANS"
