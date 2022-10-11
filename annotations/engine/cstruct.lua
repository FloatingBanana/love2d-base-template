--- @meta

---
--- Helper for creating C structs using FFI.
---
--- If JIT is disabled then it falls back to using tables, which are slower.
---
--- @class CStruct
---
--- @field typename string: The name of this struct
---
--- @operator call: CStruct
local CStruct = {}


--- Returns a table array containing the components of this struct sequentialy.
--- This struct is used as an easy way to pass structs to shaders.
---
--- DO NOT store this table anywhere, the table returned here is reused internally
--- by all instances of the same struct.
--- @return table
function CStruct:toFlatTable() end


--- Defines a new C struct.
--- This function creates a small piece of C code and compiles it using FFI.
---
--- The C code is: `typedef { <definition> } <structname>;`
--- @param structname string: The struct's type name
--- @param definition string: The struct's definition code
--- @return CStruct: An object representing the struct
local function DefineStruct(structname, definition) end

return DefineStruct