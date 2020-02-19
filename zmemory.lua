require headerdefs.lua

local zmemory = {}
zmemory.bytes = {}
zmemory.header_start = 0
zmemory.header_end = 63
zmemory.dynamic_start = 0
zmemory.dynamic_end = -1
zmemory.static_start = -1
zmemory.static_end = -1
zmemory.static_max = 0x0ffff
zmemory.high_start = -1
zmemory.high_end = -1
zmemory.routine_offset = -1
zmemory.string_offset = -1
zmemory.routine_offset_default = 0
zmemory.string_offset_default = 0
zmemory.routine_offset_factor = 8
zmemory.string_offset_factor = 8
zmemory.addresspack_factor = 4
zmemory.headerdefs = require("headerdefs")

function zmemory:translateWordAddress(wordaddress)
	local byteaddress = wordaddress * 2
	return byteaddress
end

function zmemory:translatePackedAddress_routine(packedaddress)
	local byteaddress = packedaddress * self.addresspack_factor + self.routine_offset
	return byteaddress
end

function zmemory:translatePackedAddress_string(packedaddress)
	local byteaddress = packedaddress * self.addresspack_factor + self.string_offset
	return byteaddress
end

function zmemory:getBytes(byteaddress, count)
	local bytes = {}
	for address = byteaddress,byteaddress+count-1 do
		table.insert(bytes, self.bytes[address])
	end
	return table.unpack(bytes)
end

function zmemory:getByte(byteaddress)
	return self.bytes[byteaddress]
end

function zmemory:getWordB(byteaddress)
	local high, low = self:getBytes(byteaddress,2)
	local word = bit32.bor(bit32.rshift(high,8), low)
	return word
end

function zmemory:getWordW(wordaddress)
	return self:getWordB(self:translateWordAddress(wordaddress))
end

function zmemory:setByte(byteaddress, byte)
	self.bytes[byteaddress] = byte
end

function zmemory:getHeaderByte(byteoffset)
	return self.bytes[byteoffset + self.header_start]
end

function zmemory:getHeaderWord(byteoffset)
	return self:getWordB(byteoffset + self.header_start)
end

function zmemory:getHeaderAddress(name)
	local addy = self.headerdefs.addresses[name]
	if addy == nil then
		addy = self.headerdefs.extAddresses[name]
		if addy ~= nil then
			addy += self:getHeaderAddress("ext")
		end
	end
	return addy
end

function zmemory:getHeaderByteByName(name)
	return self:getHeaderByte(self:getHeaderAddress(name))
end

function zmemory:getHeaderWordByName(name)
	return self:getHeaderWord(self:getHeaderAddress(name))
end

function zmemory:byteStringBigEndian(int, size)
	local bytes = {}
	for offset=(size-1)*8,0,-8 do
		table.insert(bytes,bit32.extract(int,offset,8))
	end
	return string.char(table.unpack(bytes))
end

function zmemory:dumpDynamic()
	local memdump = {self.dynamic_start = self:getBytes(self.dynamic_start, self.dynamic_end - self.dynamic_start + 1)}
	return memdump
end

function zmemory:readVersion()
	return self:getHeaderByteByName("version")
end

function zmemory:readStaticStart()
	return self:getHeaderWordByName("static")
end

function zmemory:readHimemStart()
	return self:getHeaderWordByName("himem")
end

function zmemory:initAddresses()
	self.header_start = headerdefs.addresses.bottom
	self.header_end = headerdefs.addresses.top
	self.dynamic_start = 0
	self.static_start = self:checkStaticStart()
	self.dynamic_end = self.static_start -1
	self.high_start = self:checkHimemStart()
	self.high_end = #(self.bytes)
	self.static_end = math.min(self.high_end, 0x0ffff)
	local version = self:checkVersion()
	if version == 6 or version == 7 then
		self.routune_offset = self.routine_offset_factor * self:getHeaderWordByName("roffset")
		self.string_offset = self.string_offset_factor * self:getHeaderWordByName("soffset")
	else
		self.routune_offset = self.routine_offset_default
		self.string_offset = self.string_offset_default
	end
end

function zmemory:loadStory(bytes)
	self.bytes = bytes;
	
end

return zmemory