require text.lua

local zmachine = {}
zmachine.memory = require("memory")
zmachine.opdecoder = require("opdecoder")

zmachine.platform = 'Atari ST'	-- number 6
zmachine.version = 0x30	-- ASCII 0

zmachine.feature_capability = {
	-- flags 1, ver 1-3
	nostatusbar		= false,
	screensplit		= false,
	fontvardef		= false,
	
	-- flags 1, ver 4+
	colors			= false,
	pics			= false,
	fontbold		= false,
	fontitalic		= false,
	fontfix			= true,
	sound			= false,
	timedkbd		= false,
}

zmachine.feature_requestability = {
	transcripting	= true,
	fontfixpls		= true,
	--redrawpls		= nil,	-- this one the *interpreter* sets to ask something of the *story*
	picspls			= false,
	undopls			= true,
	mousepls		= false,
	--colorpls		= false,	-- interpreter doesn't explicitly reject this value?  weird, but okay
	soundpls		= false,
	menupls			= false,
}

function zmachine:initHeader()
	-- the purpose of this method is to let the storyfile know what capabilities this interpreter has.
	
end

return zmachine