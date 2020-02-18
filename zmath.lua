-- comparison, arithmetic and printing are signed
-- bitwise is unsigned
-- illegal to div/mod by zero


local zmath = {}

zmath.unsigned_bound = 0x10000
zmath.signed_bound = 0x08000

function zmath:clip(unsigned)
  return unsigned % self.unsigned_bound
end

function zmath:toSigned(unsigned)
  local value = self:clip(unsigned)
  if value >= self.signed_bound then
    value = value - self.unsigned_bound
  end
  return value;
end

function zmath:toUnsigned(signed)
  local value = signed;
  if value < 0 then
    value = self.unsigned_bound + signed
  end
  return self:clip(value)
end

function zmath:toInt(float)
  if float >= 0 then
    return math.floor(float)
  else
    return math.ceil(float)
  end
end

function zmath:isEqual(a, b, c, d)
  if a == nil then return false end
  if a == b or a == c or a == d then
    return true
  else
    return false
  end
end

function zmath:isGreater(a, b)
  return (self:toSigned(a) > self:toSigned(b))
end

function zmath:isLesser(a, b)
  return (self:toSigned(a) < self:toSigned(b))
end

function zmath:isZero(a)
  return (a == 0)
end

function zmath:add(a, b)
  return self:toUnsigned(self:toSigned(a) + self:toSigned(b))
end

function zmath:subtract(a, b)
  return self:toUnsigned(self:toSigned(a) - self:toSigned(b))
end

function zmath:multiply(a, b)
  return self:toUnsigned(self:toSigned(a) * self:toSigned(b))
end

function zmath:divide(a, b)
  if b == 0 then return nil end
  return self:toUnsigned(self:toInt(self:toSigned(a) / self:toSigned(b)))
end

function zmath:modulo(a, b)
  if b == 0 then return nil end
  return self:toUnsigned(math.fmod(self:toSigned(a),self:toSigned(b)))
end

-- the following three methods exist purely to demonstrate to myself that
-- division and modulo operate as specified by the Z-Machine Standards Document 1.1
function zmath:divDemo(a, b)
  local result = self:toSigned(self:divide(self:toUnsigned(a), self:toUnsigned(b)))
  print (a.." / "..b.." = "..result)
end
function zmath:modDemo(a, b)
  local result = self:toSigned(self:modulo(self:toUnsigned(a), self:toUnsigned(b)))
  print (a.." % "..b.." = "..result)
end
function zmath:standardDemonstration()
  self:divDemo(-11,2)
  self:divDemo(-11,-2)
  self:divDemo(11,-2)
  self:modDemo(-13,5)
  self:modDemo(13,-5)
  self:modDemo(-13,-5)
end

--zmath:standardDemonstration()

return zmath
