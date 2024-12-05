-- cancel execution if Starlit Library is enabled, as it replaces this mod
-- if your mod still depends on Accessible Fields, consider replacing that dependency with Starlit Library
-- you don't need to make any code changes whatsoever, just change the required mod id and workshop page requirement
-- if you had to require this file for load order reasons, require Starlit/utils/Reflection instead
-- requiring it could also now be unnecessary as Starlit manages load order better
if getActivatedMods():contains("StarlitLibrary") then
    -- require starlit's equivalent so that files that needed to require this file for load order reasons will still work
    require("Starlit/utils/Reflection")
    return
end

local getNumClassFields = getNumClassFields
local getClassField = getClassField
local getClassFieldVal = getClassFieldVal
local setmetatable = setmetatable
local match = string.match
local tostring = tostring
local pairs = pairs
local __classmetatables = __classmetatables
local type = type

local classtables = {}

---@param t table
local function addClassesRecurse(t)
    for _,v in pairs(t) do
        if type(v) == "table" then
            local class = v.class
            if class then
                table.insert(classtables, __classmetatables[class].__index)
            else
                addClassesRecurse(v)
            end
        end
    end
end
addClassesRecurse(zombie)

for i = 1, #classtables do
    local classtable = classtables[i]
    local metatable = {}

    local getField = function(self, key)
        local fieldGetter = metatable.fieldGetters[key]
        if fieldGetter then
            return fieldGetter(self)
        end
    end

    metatable.__index = function(self, key)
        local fieldGetters = {}
        for i = 0, getNumClassFields(self)-1 do
            local field = getClassField(self, i)
            local fieldName = match(tostring(field), "([^%.]+)$")
            fieldGetters[fieldName] = function(self) return getClassFieldVal(self, field) end
        end
        metatable.fieldGetters = fieldGetters
        metatable.__index = getField
        return self[key]
    end

    setmetatable(classtable, metatable)
end
