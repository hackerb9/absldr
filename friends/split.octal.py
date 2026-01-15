#!/bin/python
import sys
import re

def to_split_octal(h):
    """.SO: Display a 16-bit value in "split octal" notation.
    The .SO word was present but unused in the original Forth code.  

    "Split Octal" is shown as two bytes each represented by an octal
    number from 000 to 377, often just smushed together.
    Mathematically, that's wrong as the number after 000377 should be
    000400 (in normal octal), but in split octal it is 001000

    I'm allowing the convention of adding a space or punctuation
    between the two bytes to help disambiguate, but honestly there's a
    good reason this routine wasn't used: Hexadecimal is simply better
    for 8-bit bytes.
    """
    try:
        i = int(h, 16)
        if (i<0 or i>65535):
            raise OverflowError(f"Split octal can only represent numbers from 0 to FFFF, not '{h}'.") 
        print( f'{i//256:03o} {i%256:03o}Q' )
    except (ValueError) as e:
        print( f'INVALID HEXADECIMAL NUMBER: {e}' )
    except (OverflowError) as e:
        print( f'{e}' )

def from_split_octal(ostring):
    """Given a string in Split Octal, print the hexadecimal result.
    Accepted input: 	34200	34,200	34.200	34/200	34 200	
    """
    if not ostring: return

    try: 
        (a,b) = re.split(r'[^0-9]', ostring, maxsplit=2)
    except ValueError as e:
         a=ostring[0:-3]
         b=ostring[-3:]
    if a=='': a='000'
    if b=='': b='000'
    try:
        if int(a,8) > 255 or int(b,8) > 255:
            raise ValueError;
        print( f'{int(a,8):02X}{int(b,8):02X}H' )
    except ValueError as e:
        print(f'INVALID SPLIT OCTAL: "{a},{b}"')

if __name__ == "__main__":
    
    for arg in sys.argv[1:]:
        if arg.upper().endswith('H'):
            to_split_octal( arg[:-1] )
        elif arg.upper().endswith('Q'):
            from_split_octal( arg[0:-1] )
        elif arg.startswith('0x'):
            to_split_octal( arg )
        elif arg.startswith('0o'):
            from_split_octal( arg[2:] )
        elif re.findall('[-.,:;/ ]', arg):
            from_split_octal( arg )
        elif re.findall(r'[A-F89a-f]', arg):
            to_split_octal( arg )
        elif len(arg)>4 or len(arg)==3:
            from_split_octal( arg )
        else:
            try:
                to_split_octal( arg )
            except ValueError as e:
                from_split_octal( arg )
            
            
