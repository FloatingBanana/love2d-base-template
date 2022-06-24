local PATH = (...):gsub("/", ".")

local tiled = {
    utils = require(PATH..".utils.utils")
}

local tilelayer = require(PATH..".tilelayer")
local objectlayer = require(PATH..".objectlayer")
local layerFuncs = require(PATH..".layers")

local function merge_tables(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
end

local function set_layer_methods(t, obj)
    for i, layer in ipairs(t) do
        if layer.type == "tilelayer" then
            merge_tables(layer, tilelayer)
        end

        if layer.type == "objectgroup" then
            merge_tables(layer, objectlayer)
        end

        if layer.type == "group" then
            merge_tables(layer, layerFuncs)
            set_layer_methods(layer.layers, obj)
        end

        layer._root = obj
    end
end



function tiled.load(file)
    local obj = nil

    if type(file) == "table" then
        obj = file

    elseif type(file) == "string" then
        if file:sub(-4) == ".tmx" then
            local f, err = io.open(file, "r")

            assert(f, "Could not open ".. file..": ".. err)

            local xml = f:read("*a")
            f:close()

            local t = tiled.TMXtoLua(xml)
        else
            obj = require(file)
        end
    else
        error("Invalid argument of type "..type(file)..", must be a table or a string.")
    end

    set_layer_methods(obj.layers, obj)

    merge_tables(obj, layerFuncs)

    return obj
end


return tiled