#!/bin/python
import sys
import re

def to_split_octal(i):
    """.SO: Display a 16-bit value in "split octal" notation.
    The .SO word was present but unused in the original Forth code.  

    "Split Octal" is shown as two bytes each represented by an octal
    number from 000 to 377, often just smushed together.
    Mathematically, that's wrong as the number after 000377 should be
    000400 (in normal octal), but in split octal it is 001000

    I'm using the convention of adding a space between the two bytes
    to help disambiguate, but honestly there's a good reason this
    routine wasn't used: Hexadecimal is simply better for 8-bit bytes.
    """
    if (i<0 or i>65535):
        raise OverflowError('Split octal can only represent numbers from 0 to 65535') 
    print( f'{i//256:03o} {i%256:03o}Q' )

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
        if int(a) > 255 or int(b) > 255:
            print( f'{int(a,8):02X}{int(b,8):02X}H' )
        else:
            raise ValueError;
    except ValueError as e:
        print(f'INVALID SPLIT OCTAL: "{a},{b}"')

if __name__ == "__main__":
    
    for arg in sys.argv[1:]:
        if arg.upper().endswith('H'):
            to_split_octal( int(arg[:-1], 16) )
        elif arg.upper().endswith('Q'):
            from_split_octal( arg[0:-1] )
        elif arg.startswith('0x'):
            to_split_octal( int(arg, 16 ) )
        elif re.findall(r'[A-F89a-f]', arg):
            to_split_octal( int(arg, 16 ) )
        elif arg.startswith('0o'):
            from_split_octal( arg[2:] )
        elif re.findall('[-.,;/ ]', arg) or len(arg)>4 or len(arg)==3:
            from_split_octal( arg )
        else:
            try:
                to_split_octal( int(arg) )
            except ValueError as e:
                from_split_octal( arg )
            
            
