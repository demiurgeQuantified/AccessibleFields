local getNumClassFields = getNumClassFields
local getClassField = getClassField
local getClassFieldVal = getClassFieldVal
local setmetatable = setmetatable
local match = string.match
local tostring = tostring
local pairs = pairs
local __classmetatables = __classmetatables

for _, metatable in pairs(__classmetatables) do
    if metatable.__index then -- something weird in here breaks it, Vector's exposure seems to be bugged?
        local metaMetatable = {}
        
        local getField = function(self, key)
            local fieldGetter = metaMetatable.fieldGetters[key]
            if fieldGetter then
                return fieldGetter(self)
            end
        end
        
        metaMetatable.__index = function(self, key)
            local fieldGetters = {}
            for i = 0, getNumClassFields(self)-1 do
                local field = getClassField(self, i)
                local fieldName = match(tostring(field), "([^%.]+)$")
                fieldGetters[fieldName] = function(self) return getClassFieldVal(self, field) end
            end
            metaMetatable.fieldGetters = fieldGetters
            metaMetatable.__index = getField
            return self[key]
        end
        
        setmetatable(metatable.__index, metaMetatable)
    end
end