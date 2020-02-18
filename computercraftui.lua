local ComputerCraftUI = {}
ComputerCraftUI.memory;

function ComputerCraftUI.openstory(path)
	handle = fs.open(ComputerCraftUI, "rb")
	local story = {}
	if handle then
		local nextbyte = handle.read()
		while nextbyte do
			table.insert(story, nextbyte)
			nextbyte = handle.read()
		end
		handle.close();
	end
	memory.loadStory(story)
end

--[[
  2 = black       (true $0000, $$0000000000000000)
  3 = red         (true $001D, $$0000000000011101)
  4 = green       (true $0340, $$0000001101000000)
  5 = yellow      (true $03BD, $$0000001110111101)
  6 = blue        (true $59A0, $$0101100110100000)
  7 = magenta     (true $7C1F, $$0111110000011111)
  8 = cyan        (true $77A0, $$0111011110100000)
  9 = white       (true $7FFF, $$0111111111111111)
 10 = light grey  (true $5AD6, $$0101101011010110)
 11 = medium grey (true $4631, $$0100011000110001)
 12 = dark grey   (true $2D6B, $$0010110101101011)
 --
 16 = orange
 17 = lightBlue
 18 = lime
 19 = pink
 20 = purple
 21 = brown
 
 black_bg = 0000
 red = 2539
 green = 268A
 yellow = 377B
 blue = 6586
 magenta = 6DFC
 cyan = 5A69
 white = 7BDE
 lightGray = 4E73
 gray = 2529
 black_fg = 0C63
 
 orange = 1ADE
 lightBlue = 7AD3
 lime = 0F2F
 pink = 66DE
 purple = 7196
 brown = 258F

]]--

