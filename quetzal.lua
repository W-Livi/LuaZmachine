function byteStringBigEndian(int, size)
	local bytes = {}
	for offset=(size-1)*8,0,-8 do
		table.insert(bytes,bit32.extract(int,offset,8))
	end
	return string.char(table.unpack(bytes))
end

function inherit(self, o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

local IffChunk = {typeId = '    '}
function IffChunk:new(typeId)
	local o = inherit(self)
	if typeId then o.typeId = self:validateTypeId(typeId) end
	return o
end

function IffChunk.validateTypeId(typeId)
	local idlen = string.len(typeId)
	if (idlen < 4) then
		typeId = typeId .. string.rep(' ',4-idlen)
	elseif (idlen > 4) then
		typeId = string.sub(typeId,1,4)
	end	
	return typeId
end

function IffChunk:getDataBytes()
	-- to be filled-in by inhereting classes
	return ''
end

function IffChunk:toByteString()
	local data = self:getDataBytes()
	local size = string.len(data)
	local padding = ''
	if size%2 == 1 then
		padding = '\0'
	end
	size = byteStringBigEndian(size,4)
	local bytes = self.typeId .. size .. data .. padding
	return bytes
end

local IffForm = IffChunk.new('FORM')

function IffForm:new(subtypeId, chunkList)
	o = inherit(self)
	o.subtypeId = self.validateTypeId(subtypeId)
	o.chunkList = chunkList or {}
	return o
end

function IffForm:getDataBytes()
	local substrings = {subtypeId}
	for i,chunk in ipairs(self.chunkList) do
		table.insert(substrings, chunk.toByteString())
	end
	return table.concat(substrings)
end

function IffForm:getChunksById(chunkId)
	chunkId = self.validateTypeId(chunkId)
	local results = {}
	for i,chunk in ipairs(self.chunkList) do
		if chunk.typeId == chunkId then
			table.insert(results, chunk)
		end
	end
	return results
end

local QuetzalUMem = IffChunk.new('UMem')

function QuetzalUMem:new(memdump)
	o = inherit(self)
	o.memdump = memdump
	return o
end

function QuetzalUMem:getDataBytes()
	return self.memdump
end

function QuetzalUMem:readmem(memorig)
	return o.memdump
end

local QuetzalCMem = IFFChunk.new('CMem')
function QuetzalCMem:new(memdump, memorig)
	o = inherit(self)
	o.memcomp = self.compress(memdump, memorig)
	return o
end

local QuetzalCMem:readmem(memorig)
	local bytes = self.decompress(self.memcomp, memorig)
	return bytes
end

function QuetzalCMem.compress(memdump, memorig)
	local arraydump = {string.byte(memdump)}
	local arrayorig = {string.byte(memorig)}
	local rle = {}
	local zerocount = 0
	local int i = 1
	while arraydump[i] != nil and arrayorig[i] != nil do
		local nextbyte = bit32.bxor(arraydump[i], arrayorig[i])
		if nextbyte == 0 then
			zerocount = zerocount + 1
		else
			if zerocount != 0 then
				table.insert(rle,'\0'..string.char(zerocount))
			end
			table.insert(rle,string.char(nextbyte))
		end
		i = i + 1
	end
	return table.concat(rle)
end

function QuetzalCMem.decompress(memcomp, memorig)
	local arraycomp = {string.byte(memcomp)}
	local arrayorig = {string.byte(memorig)}
	local arraydump = {}
	local compindex = 1
	local origindex = 1
	while arrayorig[origindex] != nil then
		if arraycomp[compindex] != 0 then
			-- straight byte
			table.insert(arraydump, bit32.bxor(arraycomp[compindex], arrayorig[origindex]))
			origindex = origindex + 1
			compindex = compindex + 1
		else
			-- run of nulls
			local length = arraycomp[compindex+1]
			for runindex = origindex,origindex+length-1 do
				table.insert(arraydump, arrayorig[runindex])
			end
			origindex = origindex + length
			compindex = compindex + 2
		end
	end
	local memdump = string.char(table.unpack(arraydump))
end


