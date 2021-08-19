# Bubble Ghost music and sound effects
 Music and sound effects modules for Wubsoft's Bubble Ghost conversion to the SAM Coupé

Copied by ear from the original Gameboy version by FCI / ERE Informatique, originally composed by Hitoshi Sakimoto ("Ymoh. S").

Written in Z80 assembler for the Sam Coupé computer.  Includes tweaked Protracker compiled music player and sound effects processor expanded from Tetris/Flappy Bird.  Also included, demo program I used to show Rob Evans my progress.


CREDITS

In addition to my code, the source includes:

    Protracker player routines and Sam Coupe Diskimage manager by Andrew Collier
    Keyboard reading and redefine routines adapted from an original by Steve Taylor
    Various maths routines written/collated by Milos Bazelides
    SAMDOS2 binary, needed for loading of object file from the compiled diskimage.


COMPILING AND PLAYING

This version is compiled with pyZ80, a freely-available Z80 cross-assembler found at https://github.com/simonowen/pyz80. After installing PYZ80 you can compile the diskimage by running make_bb.bat. You'll need to amend the filepaths in this file for your system.

It can be run in SimCoupe or ASCD, both up-to-date popular emulators for the original machine, from https://wwww.simcoupe.org/ and http://www.keprt.cz/sam/

This can be used on a real Sam by converting the diskimage to a floppy disk with SAMDisk by Simon Owen, available from http://simonowen.com/samdisk/.


GETTING STARTED

For instant gratification, run demo program/auto.dsk.  Keys are:
	F7-9:  Play tune
	F1-6:  Play sound effect
	Cursor up/down:  Music volume up/down