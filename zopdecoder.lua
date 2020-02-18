-- local opcode = {}
-- opcode.instruction 0xff -- 0xffff
-- opcode.operands = {}
-- opcode.storevar = 0xff
-- opcode.branch = 0xff -- 0xffff
-- opcode.text = {}
-- 
-- opcode.operands[1] = {}
-- opcode.operands[1].type = 0 -- large
-- opcode.operands[1].large = 0xffff
-- opcode.operands[2] = {}
-- opcode.operands[2].type = 1 -- small
-- opcode.operands[2].small = 0xff
-- opcode.operands[3] = {}
-- opcode.operands[3].type = 2 -- variable
-- opcode.operands[3].variable = 0xff
-- opcode.operands[4] = {}
-- opcode.operands[4].type = 3 -- omitted
local zopdecoder = {}
zopdecoder.operand_types = {}
zopdecoder.operand_types.large = 0
zopdecoder.operand_types.small = 1
zopdecoder.operand_types.variable = 2
zopdecoder.operand_types.omitted = 3
zopdecoder.opcode_forms = {}
zopdecoder.opcode_forms.long = 0
zopdecoder.opcode_forms.short = 1
zopdecoder.opcode_forms.extended = 2
zopdecoder.opcode_forms.variable = 3
zopdecoder.oplist = {}

function zopdecoder:readOpcode(byteAddress)
	local form = nil
	local opcode = {}
	opcode.instruction = memory.getByte(byteAddress)
	if opcode.instruction == 0xBE then
		opcode.instruction = memory.getWordB(byteAddress)
		-- extended form
		
	elseif opcode.instruction < 0x20 then
		-- long form, 2 operands, small, small
		
	elseif opcode.instruction < 0x40 then
		-- long form, 2 operands, small, var
		
	elseif opcode.instruction < 0x60 then
		-- long form, 2 operands, var, small
		
	elseif opcode.instruction < 0x80 then
		-- long form, 2 operands, var, var
		
	elseif opcode.instruction < 0x90 then
		-- short form, 1 operand, large
		
	elseif opcode.instruction < 0xA0 then
		-- short form, 1 operand, small
		
	elseif opcode.instruction < 0xB0 then
		-- short form, 1 operands, var
		
	elseif opcode.instruction < 0xC0 then
		-- short form, 0 operands
		
	elseif opcode.instruction < 0xE0 then
		-- variable form, 2 operands.
		
	else
		-- variable form, variable operands
		
	end
	
end

return zopdecoder

--	table of opcodes, as per the Z-Machine Standards Document 1.1					
--	st: stores a result
--	br: branches
--
--	Two-operand opcodes 2OP					
--	St	Br	Opcode	Hex	V	Inform name and syntax
--			------	 0	---	---
--		*	2OP: 1	 1		je a b ?(label)
--		*	2OP: 2	 2		jl a b ?(label)
--		*	2OP: 3	 3		jg a b ?(label)
--		*	2OP: 4	 4		dec_chk (variable) value ?(label)
--		*	2OP: 5	 5		inc_chk (variable) value ?(label)
--		*	2OP: 6	 6		jin obj1 obj2 ?(label)
--		*	2OP: 7	 7		test bitmap flags ?(label)
--	*		2OP: 8	 8		or a b -> (result)
--	*		2OP: 9	 9		and a b -> (result)
--		*	2OP:10	 A		test_attr object attribute ?(label)
--			2OP:11	 B		set_attr object attribute
--			2OP:12	 C		clear_attr object attribute
--			2OP:13	 D		store (variable) value
--			2OP:14	 E		insert_obj object destination
--	*		2OP:15	 F		loadw array word-index -> (result)
--	*		2OP:16	10		loadb array byte-index -> (result)
--	*		2OP:17	11		get_prop object property -> (result)
--	*		2OP:18	12		get_prop_addr object property -> (result)
--	*		2OP:19	13		get_next_prop object property -> (result)
--	*		2OP:20	14		add a b -> (result)
--	*		2OP:21	15		sub a b -> (result)
--	*		2OP:22	16		mul a b -> (result)
--	*		2OP:23	17		div a b -> (result)
--	*		2OP:24	18		mod a b -> (result)
--	*		2OP:25	19	4	call_2s routine arg1 -> (result)
--			2OP:26	1A	5	call_2n routine arg1
--			2OP:27	1B	5	set_colour foreground background
--						6	set_colour foreground background window
--			2OP:28	1C	5/6	throw value stack-frame
--			------	1D	---	---
--			------	1E	---	---
--			------	1F	---	---
--						
--	Opcode numbers 32 to 127: other forms of 2OP with different types.					
--						
--						
--	One-operand opcodes 1OP					
--	St	Br	Opcode	Hex	V	Inform name and syntax
--		*	1OP:128	0		jz a ?(label)
--	*	*	1OP:129	1		get_sibling object -> (result) ?(label)
--	*	*	1OP:130	2		get_child object -> (result) ?(label)
--	*		1OP:131	3		get_parent object -> (result)
--	*		1OP:132	4		get_prop_len property-address -> (result)
--			1OP:133	5		inc (variable)
--			1OP:134	6		dec (variable)
--			1OP:135	7		print_addr byte-address-of-string
--	*		1OP:136	8	4	call_1s routine -> (result)
--			1OP:137	9		remove_obj object
--			1OP:138	A		print_obj object
--			1OP:139	B		ret value
--			1OP:140	C		jump ?(label)
--			1OP:141	D		print_paddr packed-address-of-string
--	*		1OP:142	E		load (variable) -> (result)
--	*		1OP:143	F	1/4	not value -> (result)
--						5	call_1n routine
--						
--	Opcode numbers 144 to 175: other forms of 1OP with different types.					
--						
--						
--	Zero-operand opcodes 0OP					
--	St	Br	Opcode	Hex	V	Inform name and syntax
--			0OP:176	0		rtrue
--			0OP:177	1		rfalse
--			0OP:178	2		print (literal-string)
--			0OP:179	3		print_ret (literal-string)
--			0OP:180	4	1/-	nop
--		*	0OP:181	5	1	save ?(label)
--						4	save -> (result)
--						5	[illegal]
--		*	0OP:182	6	1	restore ?(label)
--						4	restore -> (result)
--						5	[illegal]
--			0OP:183	7		restart
--			0OP:184	8		ret_popped
--			0OP:185	9	1	pop
--		*				5/6	catch -> (result)
--			0OP:186	A		quit
--			0OP:187	B		new_line
--			0OP:188	C	3	show_status
--						4	[illegal]
--		*	0OP:189	D	3	verify ?(label)
--			0OP:190	E	5	[first byte of extended opcode]
--		*	0OP:191	F	5/-	piracy ?(label)
--						
--	Opcode numbers 192 to 223: VAR forms of 2OP:0 to 2OP:31.					
--						
--						
--	Variable-operand opcodes VAR					
--	St	Br	Opcode	Hex	V	Inform name and syntax
--	*		VAR:224	 0	1	call routine ...0 to 3 args... -> (result)
--						4	call_vs routine ...0 to 3 args... -> (result)
--			VAR:225	 1		storew array word-index value
--			VAR:226	 2		storeb array byte-index value
--			VAR:227	 3		put_prop object property value
--			VAR:228	 4	1	sread text parse
--						4	sread text parse time routine
--		*				5	aread text parse time routine -> (result)
--			VAR:229	 5		print_char output-character-code
--			VAR:230	 6		print_num value
--	*		VAR:231	 7		random range -> (result)
--			VAR:232	 8		push value
--			VAR:233	 9	1	pull (variable)
--		*				6	pull stack -> (result)
--			VAR:234	 A	3	split_window lines
--			VAR:235	 B	3	set_window window
--	*		VAR:236	 C	4	call_vs2 routine ...0 to 7 args... -> (result)
--			VAR:237	 D	4	erase_window window
--			VAR:238	 E	4/-	erase_line value
--						6	erase_line pixels
--			VAR:239	 F	4	set_cursor line column
--						6	set_cursor line column window
--			VAR:240	10	4/6	get_cursor array
--			VAR:241	11	4	set_text_style style
--			VAR:242	12	4	buffer_mode flag
--			VAR:243	13	3	output_stream number
--						5	output_stream number table
--						6	output_stream number table width
--			VAR:244	14	3	input_stream number
--			VAR:245	15	5/3	sound_effect number effect volume routine
--	*		VAR:246	16	4	read_char 1 time routine -> (result)
--	*	*	VAR:247	17	4	scan_table x table len form -> (result)
--	*		VAR:248	18	5/6	not value -> (result)
--			VAR:249	19	5	call_vn routine ...up to 3 args...
--			VAR:250	1A	5	call_vn2 routine ...up to 7 args...
--			VAR:251	1B	5	tokenise text parse dictionary flag
--			VAR:252	1C	5	encode_text zscii-text length from coded-text
--			VAR:253	1D	5	copy_table first second size
--			VAR:254	1E	5	print_table zscii-text width height skip
--		*	VAR:255	1F	5	check_arg_count argument-number
--						
--						
--	Extended opcodes EXT					
--	St	Br	Opcode	Hex	V	Inform name and syntax
--	*		EXT: 0	 0	5	save table bytes name prompt -> (result)
--	*		EXT: 1	 1	5	restore table bytes name prompt -> (result)
--	*		EXT: 2	 2	5	log_shift number places -> (result)
--	*		EXT: 3	 3	5/-	art_shift number places -> (result)
--	*		EXT: 4	 4	5	set_font font -> (result)
--	*					6/-	set_font font window -> (result)
--			EXT: 5	 5	6	draw_picture picture-number y x
--		*	EXT: 6	 6	6	picture_data picture-number array ?(label)
--			EXT: 7	 7	6	erase_picture picture-number y x
--			EXT: 8	 8	6	set_margins left right window
--	*		EXT: 9	 9	5	save_undo -> (result)
--	*		EXT:10	 A	5	restore_undo -> (result)
--			EXT:11	 B	5/*	print_unicode char-number
--			EXT:12	 C	5/*	check_unicode char-number -> (result)
--			EXT:13	 D	5/*	set_true_colour foreground background
--						6/*	set_true_colour foreground background window
--			-------	 E	---	---
--			-------	 F	---	---
--			EXT:16	10	6	move_window window y x
--			EXT:17	11	6	window_size window y x
--			EXT:18	12	6	window_style window flags operation
--	*		EXT:19	13	6	get_wind_prop window property-number -> (result)
--			EXT:20	14	6	scroll_window window pixels
--			EXT:21	15	6	pop_stack items stack
--			EXT:22	16	6	read_mouse array
--			EXT:23	17	6	mouse_window window
--		*	EXT:24	18	6	push_stack value stack ?(label)
--			EXT:25	19	6	put_wind_prop window property-number value
--			EXT:26	1A	6	print_form formatted-table
--		*	EXT:27	1B	6	make_menu number table ?(label)
--			EXT:28	1C	6	picture_table table
--	*		EXT:29	1D	6/*	buffer_screen mode -> (result)
