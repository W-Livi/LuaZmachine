local zheaderdefs = {}
zheaderdefs.addresses = {
	bottom				=0x00, -- start of header
	top						=0x39, -- end of header
	
	version				=0x00, -- 1 byte
	flags1				=0x01, -- 1 byte? (v3+)
	himem					=0x04, -- byte addr; start of high memory
	
	entrypoint		=0x06, -- byte addr; program counter initial value (most versions) OR
	entryroutine	=0x06, -- packed routine address; "main" routine (v6)
	
	dictionary		=0x08, -- byte addr; dictionary
	objects				=0x0a, -- byte addr; object table
	globalvars		=0x0c, -- byte addr; global variables table
	static				=0x0e, -- byte addr; start of static memory (addresses below this are dynamic)
	
	flags2				=0x10, -- 2 bytes?
	synonyms			=0x18, -- byte addr; first byte of 'synonyms table' (v2+)
	length				=0x1a, -- 2 bytes (divided by constant) (v3+)
	checksum			=0x1c, -- 2 bytes (v3+)
	intrnum				=0x1e, -- 1 byte (v4+)
	intrver				=0x1f, -- 1 byte (v4+) 
	
	screeny_chars =0x20, -- 1 byte; height of screen in characters (255 = infinite)
	screenx_chars =0x21, -- 1 byte; width of screen in characters
	screenx_units =0x22, -- 2 bytes; width of screen in 'units'
	screeny_units =0x24, -- 2 bytes; height of screen in 'units'
	fontx					=0x26, -- 1 byte; width of a zero in 'units' (swapped with fonty in v6)
	fonty					=0x27, -- 1 byte; height of a character in 'units' (swapped with fontx in v6)
	roffset				=0x28, -- Routines offset, divided by eight (v6)
	soffset				=0x2a, -- Static strings offset, divided by eight (v6)
	colorbg_def		=0x2c, -- 1 byte; default background color (v5)
	colorfg_def		=0x2d, -- 1 byte; default forground color (v5)
	terminators		=0x2e, -- byte addr; terminating characters table
	
	str3x					=0x30, -- 2 bytes; total width in px of text sent to output stream 3
	standard			=0x32, -- 2 bytes; Standard revision number (leave as zeroes unless )
	alpha					=0x34, -- byte addr; 'Alphabet Table' (if 0, usedefault)
	ext						=0x36, -- byte addr; header extension table
}
zheaderdefs.storyByteEdits = {
	zheaderdefs.addresses.flags2 = 0x07;
}

zheaderdefs.intrnums = { 1=
	'DECSystem-20',
	'Apple IIe',
	'Macintosh',
	'Amiga',
	'Atari ST',
	'IBM PC',
	'Commodore 128',
	'Commodore 64',
	'Apple IIc',
	'Apple IIgs',
	'Tandy Color',
}
zheaderdefs.extAddresses = {
	size=0,
	mousex=1,
	mousey=2,
	unicode=3,
	flags3=4,
	colorfg_tdef=5,
	colorbg_tdef=6,
}
zheaderdefs.flags1 = {}
zheaderdefs.flags1[1] = {
	statustype=1,
	disksplit=2,
	tandybit=3,
	nostatus=4,
	scrsplit=5,
	fontvar=6,
}
zheaderdefs.flags1[2] = header.flags.v1
zheaderdefs.flags1[3] = header.flags.v1
zheaderdefs.flags1[4] = {
	colors=0,
	pics=1,
	bold=2,
	italic=3,
	fixed=4,
	sound=5,
	timedkbd=6,
}
zheaderdefs.flags1[5] = header.flags.v4
zheaderdefs.flags1[6] = header.flags.v4
zheaderdefs.flags1[7] = header.flags.v4
zheaderdefs.flags1[8] = header.flags.v4
zheaderdefs.flags2 = {
	transcripting=0,
	fixedpls=1,
	redrawpls=2,
	picspls=3,
	undopls=4,
	mousepls=5,
	colorpls=6,
	soundpls=7,
	menupls=8,
}
zheaderdefs.flags3 = {
	transparencypls=0,
}

return zheaderdefs