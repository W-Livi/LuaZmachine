local bit = require("bit")

local zobjecthandler = {}

function zobjecthandler:setConfig(version, objtable_address, prop_count, objid_bytes, attrib_bytes, prop_mode)
	self.version = version
	self.objtable_address = objtable_address
	self.prop_count = prop_count
	self.objid_bytes = objid_bytes
	self.attrib_bytes = attrib_bytes
	self.prop_mode = prop_mode
	
	self.objid_min = 1 -- semantically, id 0 is 'no object'
	self.objid_max = (2^(8*objid_bytes))-1
	self.attrib_min = 0
	self.attrib_max = (2^(8*attrib_bytes))-1
	self.prop_min = 1
	self.prop_max = prop_count
	
	self.objdef_offset_attrib = 0
	self.objdef_offset_parent = self.objdef_offset_attrib + attrib_bytes
	self.objdef_offset_sibling = self.objdef_offset_parent + objid_bytes
	self.objdef_offset_child = self.objdef_offset_sibling + objid_bytes
	self.objdef_offset_prop = self.objdef_offset_child + objid_bytes
	self.objdef_size = self.objdef_offset_prop + 2

	self.defprop1_offset = 0
	self.defprop1_address = objtable_address + self.defprop1_offset
	
	self.obj1_offset = self.defprop1_offset + (2 * prop_count) -- one word each
	self.obj1_address = objtable_address + self.obj1_offset
	
end

function zobjecthandler:configFor(version, objtable_address)
	if version >= 1 and version < 4 then
		-- versions 1, 2, 3
		self:setConfig(version, objtable_address, 31, 1, 4, 1)
	elseif version >= 4 and version < 9 then 
		-- versions 4, 5, 6, 7, 8
		self:setConfig(version, objtable_address, 63, 2, 6, 2)
	else
		-- uninitialized/invalid
		self:setConfig(0, 0, 0, 0, 0, 0)
	end
end

function zobjecthandler:objectAddress(id)
	if id < self.objid_min or id > self.objid_max then
		return nil
	else
		return self.obj1_address + ((id-1) * self.objdef_size)
	end
end

function zobjecthandler:defaultPropertyAddress(id)
	if id < self.propid_min or id > self.propid_max then
		return nil
	else
		return self.defprop1_address + ((id-1) * 2)
	end
end

function zobjecthandler:readProperty(objid, propid, memory)
	local first_addy = memory.getWordB(self:objectAddress(objid) + self.objdef_offset_prop)
	if self.prop_mode == 1 then
		return self:readPropertyMode1(first_addy, propid, memory)
	elseif self.prop_mode == 2 then
		return self:readPropertyMode2(first_addy, propid, memory)
	end
end

function zobjecthandler:readPropertyDefault(propid, memory)
	local addy = self:defaultPropertyAddress(propid)
	if (addy == nil) then
		return nil
	else
		return memory:getBytes(addy, 2)
	end
end

function zobjecthandler:readPropertyMode1(next_addy, propid, memory)
	local topbyte = memory:getByte(next_addy)
	local id = bit.band(topbyte, 0x1f)
	if (id < propid)
		return self:readPropertyDefault(propid, memory)
	end
	local size = bit.rshift(bit.band(topbyte, 0xe0), 5)+1
	if (id > propid)
		return self:readPropertyMode1(next_addy+1+size, propid, memory)
	end
	return memory:getBytes(next_addy+1, size)
end

function zobjecthandler:readPropertyMode2(next_addy, propid, memory)
	local topbyte = memory:getByte(next_addy)
	local id, size, value_addy
	id = bit.band(topbyte, 0x3f)
	if (id < propid)
		return self:readPropertyDefault(propid, memory)
	end
	
	if (bit.band(topbyte, 0x80) == 0)
		-- one bytes
		value_addy = next_addy+1
		size = bit.rshift(bit.band(topbyte, 0x40), 6)+1
	else
		-- two byte
		local nextbyte = memory:getByte(next_addy+1)
		value_addy = next_addy+2
		size = bit.band(nextbyte, 0x3f)
		if size == 0 then
			size = 64
		end
	end
	if (id > propid)
		return self:readPropertyMode2(value_addy+size, propid, memory)
	end
	return memory:getBytes(value_addy, size)
end







zobjecthandler:configFor(nil, nil);

return zobjecthandler