local bit = require("bit")

local zscii_input {} -- maps keyboard stuff to zscii
local zscii_output {} -- maps zscii to unicode
zscii_output[0] = '\x00'
zscii_output[9] = '\t' -- paragraph-indent; v6 only
zscii_output[11] = '\v' -- sentence space; v6 only
zscii_output[13] = '\n' -- z-machine uses cr for crlf
for i=32,126 do
	zscii_output[i] = string.char(i) -- ascii
end
-- zscii_input[8] = '\b' -- backspace
-- zscii_input[13] = '\n' -- newline
-- zscii_input[27] = string.byte(27) -- escape
-- zscii_input[129] = '' -- up
-- zscii_input[130] = '' -- down
-- zscii_input[131] = '' -- left
-- zscii_input[132] = '' -- right
-- zscii_input[133] = '' -- f1
-- zscii_input[134] = '' -- f2
-- zscii_input[135] = '' -- f3
-- zscii_input[136] = '' -- f4
-- zscii_input[137] = '' -- f5
-- zscii_input[138] = '' -- f6
-- zscii_input[139] = '' -- f7
-- zscii_input[140] = '' -- f8
-- zscii_input[141] = '' -- f9
-- zscii_input[142] = '' -- f10
-- zscii_input[143] = '' -- f11
-- zscii_input[144] = '' -- f12
-- zscii_input[145] = '' -- kp_0
-- zscii_input[146] = '' -- kp_1
-- zscii_input[147] = '' -- kp_2
-- zscii_input[148] = '' -- kp_3
-- zscii_input[149] = '' -- kp_4
-- zscii_input[150] = '' -- kp_5
-- zscii_input[151] = '' -- kp_6
-- zscii_input[152] = '' -- kp_7
-- zscii_input[153] = '' -- kp_8
-- zscii_input[154] = '' -- kp_9
-- 155-251 - story-specific 'extra characters'
-- zscii_input[252] = '' -- menu-click; v6 only
-- zscii_input[253] = '' -- double-click; v6 only
-- zscii_input[254] = '' -- single-click

local default_extra_mapping = {
	155 =
	0x00e4, -- a-diaeresis
	0x00f6, -- o-diaeresis
	0x00fc, -- u-fiaeresis
	0x00c4, -- A-diaeresis
	0x00d6, -- O-diaeresis
	0x00dc, -- U-diaeresis
	0x00df, -- sz-ligature
	0x00bb, -- >> quotation mark
	0x00ab, -- << quotation mark
	0x00eb, -- e-diaeresis
	0x00ef, -- i-diaeresis
	0x00ff, -- y-diaeresis
	0x00cb, -- E-diaeresis
	0x00cf, -- I-diaeresis
	0x00e1, -- a-acute
	0x00e9, -- e-acute
	0x00ed, -- i-acute
	0x00f3, -- o-acute
	0x00fa, -- u-acute
	0x00fd, -- y-acute
	0x00c1, -- A-acute
	0x00c9, -- E-acute
	0x00cd, -- I-acute
	0x00d3, -- O-acute
	0x00da, -- U-acute
	0x00dd, -- Y-acute
	0x00e0, -- a-grave
	0x00e8, -- e-grave
	0x00ec, -- i-grave
	0x00f2, -- o-grave
	0x00f9, -- u-grave
	0x00c0, -- A-grave
	0x00c8, -- E-grave
	0x00cc, -- I-grave
	0x00d2, -- O-grave
	0x00d9, -- U-grave
	0x00e2, -- a-circumflex
	0x00ea, -- e-circumflex
	0x00ee, -- i-circumflex
	0x00f4, -- o-circumflex
	0x00fb, -- u-circumflex
	0x00c2, -- A-circumflex
	0x00ca, -- E-circumflex
	0x00ce, -- I-circumflex
	0x00d4, -- O-circumflex
	0x00db, -- U-circumflex
	0x00e5, -- a-ring
	0x00c5, -- A-ring
	0x00f8, -- o-slash
	0x00d8, -- O-slash
	0x00e3, -- a-tilde
	0x00f1, -- n-tilde
	0x00f5, -- o-tilde
	0x00c3, -- A-tilde
	0x00d1, -- N-tilde
	0x00d5, -- O-tilde
	0x00e6, -- ae-ligature
	0x00c6, -- AE-ligature
	0x00e7, -- c-cedilla
	0x00c7, -- C-cedilla
	0x00fe, -- Icelandic thorn
	0x00f0, -- Icelandic eth
	0x00de, -- Icelandic Thorn
	0x00d0, -- Icelandic Eth
	0x00a3, -- pound symbol
	0x0153, -- oe-ligature
	0x0152, -- OE-ligature
	0x00a1, -- inverted !
	0x00bf, -- inverted ?
}

local unicode_to_ascii { -- in case we find ourselves on a platform with limited unicode support
	0x00a0 = 
	' ',	-- non-breaking space
	'!',	-- inverted exclamation mark
	'c',	-- cent sign
	'L',	-- pound sign (gbp)
	'$',	-- currency sign
	'Y',	-- yen sign
	'|',	-- broken bar
	'$',	-- section sign
	'"',	-- diaresis
	'(C)',	-- copyright sign
	'a',	-- feminine ordinal indicator
	'<<',	-- left-pointing double angle quotation mark
	'~',	-- not sign
	'-',	-- soft hyphen
	'(R)',	-- registered sign
	'-',	-- macron
	'deg',	-- degree sign
	'+/-',	-- plus-minus sign
	'^2',	-- superscript two
	'^3',	-- superscript three
	"'",	-- acute accent
	'u',	-- micro sign
	'//',	-- pilcrow sign
	'.',	-- middle dot
	',',	-- cedilla
	'^1',	-- superscript one
	'o',	-- masculine ordinal indicator
	'>>',	-- right-pointing double angle quotation mark
	'1/4',	-- vulgar fraction one quarter
	'1/2',	-- vulgar fraction one half
	'3/4',	-- vulgar fraction three quarters
	'?',	-- inverted question mark
	'A',	-- latin capital letter a with grave
	'A',	-- latin capital letter a with acute
	'A',	-- latin capital letter a with circumflex
	'A',	-- latin capital letter a with tilde
	'Ae',	-- latin capital letter a with diaeresis
	'A',	-- latin capital letter a with ring above
	'AE',	-- latin capital letter ae
	'C',	-- latin capital letter c with cedilla
	'E',	-- latin capital letter e with grave
	'E',	-- latin capital letter e with acute
	'E',	-- latin capital letter e with circumflex
	'E',	-- latin capital letter e with diaeresis
	'I',	-- latin capital letter i with grave
	'I',	-- latin capital letter i with acute
	'I',	-- latin capital letter i with circumflex
	'I',	-- latin capital letter i with diaeresis
	'Th',	-- latin capital letter eth
	'N',	-- latin capital letter n with tilde
	'O',	-- latin capital letter o with grave
	'O',	-- latin capital letter o with acute
	'O',	-- latin capital letter o with circumflex
	'O',	-- latin capital letter o with tilde
	'Oe',	-- latin capital letter o with diaeresis
	'x',	-- multiplication sign
	'O',	-- latin capital letter o with stroke
	'U',	-- latin capital letter u with grave
	'U',	-- latin capital letter u with acute
	'U',	-- latin capital letter u with circumflex
	'Ue',	-- latin capital letter u with diaeresis
	'Y',	-- latin capital letter Y with acute
	'Th',	-- latin capital letter thorn
	'ss',	-- latin small letter sharp s
	'a',	-- latin small letter a with grave
	'a',	-- latin small letter a with acute
	'a',	-- latin small letter a with circumflex
	'a',	-- latin small letter a with tilde
	'ae',	-- latin small letter a with diaeresis
	'a',	-- latin small letter a with ring above
	'ae',	-- latin small letter ae
	'c',	-- latin small letter c with cedilla
	'e',	-- latin small letter e with grave
	'e',	-- latin small letter e with acute
	'e',	-- latin small letter e with circumflex
	'e',	-- latin small letter e with diaeresis
	'i',	-- latin small letter i with grave
	'i',	-- latin small letter i with acute
	'i',	-- latin small letter i with circumflex
	'i',	-- latin small letter i with diaeresis
	'th',	-- latin small letter eth
	'n',	-- latin small letter n with tilde
	'o',	-- latin small letter o with grave
	'o',	-- latin small letter o with acute
	'o',	-- latin small letter o with circumflex
	'o',	-- latin small letter o with tilde
	'oe',	-- latin small letter o with diaeresis
	'/',	-- division sign
	'o',	-- latin small letter o with stroke
	'u',	-- latin small letter u with grave
	'u',	-- latin small letter u with acute
	'u',	-- latin small letter u with circumflex
	'ue',	-- latin small letter u with diaeresis
	'y',	-- latin small letter y with acute
	'th',	-- latin small letter thorn
	'y',	-- latin small letter y with diaeresis
	-- 0x0100
		 'A','a','A','a','A','a','C','c','C','c','C','c','C','c','D','d','D','d','E','e','E','e','E','e','E','e','E','e','G','g','G','g',
	-- Ā	 ā	 Ă	 ă	 Ą	 ą	 Ć	 ć	 Ĉ	 ĉ	 Ċ	 ċ	 Č	 č	 Ď	 ď	 Đ	 đ	 Ē	 ē	 Ĕ	 ĕ	 Ė	 ė	 Ę	 ę	 Ě	 ě	 Ĝ	 ĝ	 Ğ	 ğ
	-- 0x0120
		 'G','g','G','g','H','h','H','h','I','i','I','i','I','i','I','i','I','i','IJ','ij','J','j','K','k','q','L','l','L','l','L','l','L',
	-- Ġ	 ġ	 Ģ	 ģ	 Ĥ	 ĥ	 Ħ	 ħ	 Ĩ	 ĩ	 Ī	 ī	 Ĭ	 ĭ	 Į	 į	 İ	 ı	 Ĳ		ĳ		Ĵ	 ĵ	 Ķ	 ķ	 ĸ	 Ĺ	 ĺ	 Ļ	 ļ	 Ľ	 ľ	 Ŀ 
	-- 0x0140
		 'l','L','l','N','n','N','n','N','n','n','NG','ng','O','o','O','o','O','o','OE','oe','R','r','R','r','R','r','S','s','S','s','S','s',
	-- ŀ	 Ł	 ł	 Ń	 ń	 Ņ	 ņ	 Ň	 ň	 ŉ	 Ŋ		ŋ		Ō	 ō	 Ŏ	 ŏ	 Ő	 ő	 Œ		œ		Ŕ	 ŕ	 Ŗ	 ŗ	 Ř	 ř	 Ś	 ś	 Ŝ	 ŝ	 Ş	 ş
	-- 0x0160
		 'S','s','T','t','T','t','T','t','U','u','U','u','U','u','U','u','U','u','U','u','W','w','Y','y','Y','Z','z','Z','z','Z','z','s',
	-- Š	 š	 Ţ	 ţ	 Ť	 ť	 Ŧ	 ŧ	 Ũ	 ũ	 Ū	 ū	 Ŭ	 ŭ	 Ů	 ů	 Ű	 ű	 Ų	 ų	 Ŵ	 ŵ	 Ŷ	 ŷ	 Ÿ	 Ź	 ź	 Ż	 ż	 Ž	 ž	 ſ
	-- 0x0180
		 'b','B','MB','mb','H','h','O','C','c','D','D','ND','nd','zw','E','e','E','F','f','G','Y','hv','I','I','K','k','l','l','w','N','n','O',
	-- ƀ	 Ɓ	 Ƃ		ƃ		Ƅ	 ƅ	 Ɔ	 Ƈ	 ƈ	 Ɖ	 Ɗ	 Ƌ		ƌ		ƍ		Ǝ	 Ə	 Ɛ	 Ƒ	 ƒ	 Ɠ	 Ɣ	 ƕ		Ɩ	 Ɨ	 Ƙ	 ƙ	 ƚ	 ƛ	 Ɯ	 Ɲ	 ƞ	 Ɵ
	-- 0x01a0
		 'O','o','OI','oi','P','p','R','S','s','S',
	-- Ơ	 ơ	 Ƣ		ƣ		Ƥ	 ƥ	 Ʀ	 Ƨ	 ƨ	 Ʃ	 ƪ	 ƫ	 Ƭ	 ƭ	 Ʈ	 Ư	 ư	 Ʊ	 Ʋ	 Ƴ	 ƴ	 Ƶ	 ƶ	 Ʒ	 Ƹ	 ƹ	 ƺ	 ƻ	 Ƽ	 ƽ	 ƾ	 ƿ
	-- 0x01c0
	-- ǀ	 ǁ	 ǂ	 ǃ	 Ǆ	 ǅ	 ǆ	 Ǉ	 ǈ	 ǉ	 Ǌ	 ǋ	 ǌ	 Ǎ	 ǎ	 Ǐ	 ǐ	 Ǒ	 ǒ	 Ǔ	 ǔ	 Ǖ	 ǖ	 Ǘ	 ǘ	 Ǚ	 ǚ	 Ǜ	 ǜ	 ǝ	 Ǟ	 ǟ
	-- 0x01e0
	-- Ǡ	 ǡ	 Ǣ	 ǣ	 Ǥ	 ǥ	 Ǧ	 ǧ	 Ǩ	 ǩ	 Ǫ	 ǫ	 Ǭ	 ǭ	 Ǯ	 ǯ	 ǰ	 Ǳ	 ǲ	 ǳ	 Ǵ	 ǵ	 Ƕ	 Ƿ	 Ǹ	 ǹ	 Ǻ	 ǻ	 Ǽ	 ǽ	 Ǿ	 ǿ
	
	-- in case we get fancy quotation marks
}
for i=32,126 do
	unicode_ascii_mapping[i] = string.byte(i) -- ascii
end
local unicode_to_ascii_default = '?'
for i=0x0000,0xffff do
	if unicode_ascii_mapping[i] == nil then
		uncode_ascii_mapping[i] = unicode_ascii_mapping_default
	end
end

local textBits = {}
textBits = {}
-- conclusion bit
textBits[0] = {masks={0 + 2^7, 0}, shifts={-7, 0}}
-- letters 1-3
textBits[1] = {masks={0 + 2^2 + 2^3 + 2^4 + 2^5 + 2^6, 0}, shifts={-2, 0}}
textBits[2] = {masks={0 + 2^0 + 2^1, 0 + 2^5 + 2^6 + 2^7}, shifts={3, -5}}
textBits[3] = {masks={0, 0 + 2^0 + 2^1 + 2^2 + 2^3 + 2^4}, shifts={0, 0}}

local nextWord = {}

local function expandTextWord (bytes, start)
	local value, mask, bshift
	for index,def in pairs(textBits) do
		value = 0
		for b=start,start+1 do
			mask = def["masks"][b];
			if mask ~= 0 then 
				bshift = def["shifts"][b]
				value = value + bit.lshift(bit.band(bytes[b], mask), bshift)
			end
		end
		nextWord[index] = value
	end
	return nextWord
end

local defaultAlpha = {}
-- A0-A2
defaultAlpha[0] = {6='a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
defaultAlpha[1] = {6='A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'}
defaultAlpha[2] = {	 7='\r','0','1','2','3','4','5','6','7','8','9','.',',','!','?','_','#',"'",'"','/','\\','-',':','(',')'}
-- A2 for v1
defaultAlpha[3] = {		7='0','1','2','3','4','5','6','7','8','9','.',',','!','?','_','#',"'",'"','/','\\','<','-',':','(',')'}

local alpha = {}	-- current character sets
alpha[0] = defaultAlpha[0]
alpha[1] = defaultAlpha[1]
alpha[2] = defaultAlpha[2]	-- v1 replaces this with defaultAlpha[3]

local extraMapping = default_extra_mapping	-- current extended character set

-- special characters, occupying Z-characters 0-5 (different versions use different ones)
-- sp = space
-- cr = carriage return
-- su = shift up (next char will be in the next-highest character set)
-- sd = shift down (next char will be in the next-lowest character set)
-- lu = lock up (subsequent chars will be in the next-highest character set)
-- ld = lock down (subsequent chars will be in the next-lowest character set)
-- s1 = synonym 1 (next character is an index into synonym bank 1; entries 0-31)
-- s2 = synonym 2 (next character is an index into synonym bank 2; entries 32-63)
-- s3 = synonym 3 (next character is an index into synonym bank 3; entries 64-95)
local zcharsV1 = {0="sp", "cr", "su", "sd", "lu", "ld"}	-- version 1
local zcharsV2 = {0="sp", "s1", "su", "sd", "lu", "ld"}	-- version 2
local zcharsV3 = {0="sp", "s1", "s2", "s3", "su", "sd"}	-- version 3+

local zchars = zcharsV3	-- special chars for the current version

local zcharfuncs = {
	"sp" = function(state) state["alphaShift"] = state["alpha"]; return 32 end,
	"cr" = function(state) state["alphaShift"] = state["alpha"]; return 13 end,
	"su" = function(state) state["alphaShift"] = (state["alpha"] + 1) % 3; return nil end,
	"sd" = function(state) state["alphaShift"] = (state["alpha"] + 2) % 3; return nil end,
	"lu" = function(state) state["alphaShift"] = state["alpha"] = ((state["alpha"] + 1) % 3); return nil end,
	"ld" = function(state) state["alphaShift"] = state["alpha"] = ((state["alpha"] + 2) % 3); return nil end,
	"s1" = function(state) state["synonym"] = 1; return nil end,
	"s2" = function(state) state["synonym"] = 2; return nil end,
	"s3" = function(state) state["synonym"] = 3; return nil end
}

local function printZscii(chr)
	local native
	if zscii >= 155 and zscii <= 251 then
		native = extraMapping[zscii]
	else
		native = zscii_output[zscii]
	end
	-- TODO respect whatever screen window nonsense may be currently defined
	-- TODO output to current-platform wrapper
	-- TODO fonts?! formatting?!
	io.stdout:write(native)
end

local printState = {alpha=0, alphaShift=0, multi=nil, synonym=nil}
local function printNextAlpha(chr)

	if printState["synonym"] ~= nil and printState["synonym"] ~= 0 then
		-- abbreviation time!
		printSynonym(printState["synonym"], char)
		printState["synonym"] = nil
		
	elseif printState["multi"] ~= nil then
		-- multi-char construction
		table.insert(printState["multi"], chr)
		if *(printState["multi"]) == 2 then
			-- we've read ten bits; lets write the result to the screen
			local zscii = bit.bor(bit.lshift(printState["multi"][1], 5), printState["multi"][2])
			printZscii(zscii)
			printState["multi"] = nil
		end

	elseif chr <= #zchars then
		-- special character
		local zscii = zcharfuncs[zchars[chr]](printState)
		if (zscii ~= nil) then
			printZscii(zscii)
		end
		
	else
	
	end
	
end

local function printString(bytes, start)
	local next = start
	local done = 0
	while done == 0 do
		word = expandTextWord(bytes, start)
		
		done = word[0]
	end
end

local function printSynonym(bank, index) {
	printState["synonym"] = 0 -- marker to trap recursive synonyms
	-- TODO ... everything...
}
