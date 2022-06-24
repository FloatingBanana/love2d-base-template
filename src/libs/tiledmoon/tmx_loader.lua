local parseXML = require "utils.XMLparser"
local utils = require "utils.utils"
local layers = require "tiledmoon.layers"

local function push(t, ...)
    for i = 1, select("#", ...) do
        t[#t+1] = select(i, ...)
    end
end

local function get_properties(elm)
    local properties = {}

    for _, prop in pairs(elm.child)do
        if prop.tag == "property" then
            local attr = prop.attributes
            local val = nil

            if attr.type == "bool" then
                val = attr.value == "true"

            elseif attr.type == "int" or attr.type == "float" then
                val = tonumber(attr.value)
            else
                val = attr.value
            end

            properties[attr.name] = val
        end
    end

    return properties
end

local layer_types = {tilelayer = true, objectgroup = true, group = true, imagelayer = true}
local shape_types = {ellipse = true, point = true, polygon = true, polyline = true}
local function get_layer(layerElm)
    local layerType = layerElm.tag
    local attr = layerElm.attributes
    local layer = {
        type = layerType,
        x = 0,
        y = 0,
        width = tonumber(attr.width),
        height = tonumber(attr.height),
        id = tonumber(attr.id),
        name = attr.name,
        visible = not attr.visible or attr.visible == 1,
        opacity = tonumber(attr.opacity or 1),
        offsetx = tonumber(attr.offsetx or 0),
        offsety = tonumber(attr.offsety or 0),
        parallaxx = tonumber(attr.parallaxx or 1),
        parallaxy = tonumber(attr.parallaxy or 1),

        properties = {}
    }

    if layerType == "objectgroup" then
        layer.draworder = attr.draworder or "topdown"
        layer.objects = {}
    end

    if layerType == "group" then
        layer.layers = {}
    end

    for _, elm in ipairs(layerElm.child) do
        if layerType == "tilelayer" then
            if elm.tag == "data" then
                if elm.attributes.encoding == "csv" then
                    layer.data = utils.parseCSV(elm.attributes.data[1].content)
                end
            end
        end

        if layerType == "objectgroup" then
            if elm.tag == "object" then
                local objAttr = elm.attributes
                local object = {
                    id = tonumber(objAttr.id),
                    name = objAttr.name or "",
                    type = objAttr.type or "",
                    shape = "rectangle",
                    x = tonumber(objAttr.x),
                    y = tonumber(objAttr.y),
                    width = tonumber(objAttr.width or 0),
                    height = tonumber(objAttr.height or 0),
                    rotation = tonumber(objAttr.rotation or 0),
                    visible = not objAttr.visible or objAttr.visible == 1,
                    properties = {}
                }

                for _, child in ipairs(elm.child or {}) do
                    if shape_types[child.tag] then
                        object.shape = child.tag
                    end

                    if child.tag == "polyline" or child.tag == "polygon" then
                        local points = {}

                        for pos in child.attributes.points:gmatch("[^%s]+") do
                            local point = pos:gmatch("[^,]+")
                            push(points, {
                                x = tonumber(point()),
                                y = tonumber(point())
                            })
                        end

                        object[child.tag] = points
                    end

                    if child.tag == "properties" then
                        object.properties = get_properties(child)
                    end
                end

                push(layer.objects, object)
            end
        end

        if layerType == "group" then
            if layer_types[elm.tag] then
                push(layer.layers, get_layer(elm))
            end
        end

        if layerType == "imagelayer" then
            if elm.tag == "image" then
                layer.image = elm.attributes.source
            end
        end

        if elm.tag == "properties" then
            layer.properties = get_properties(elm.properties)
        end
    end

    return layer
end

local function xml_to_lua(code)
    local xml = parseXML(code)
    local map = xml[2]

    local result = {
        version = map.attributes.version,
        luaversion = "5.1",
        tiledversion = map.attributes.tiledversion,
        orientation = map.attributes.orientation,
        renderorder = map.attributes.renderorder,
        width = tonumber(map.attributes.width),
        height = tonumber(map.attributes.height),
        tilewidth = tonumber(map.attributes.tilewidth),
        tileheight = tonumber(map.attributes.tileheight),
        nextlayerid = tonumber(map.attributes.nextlayerid),
        nextobjectid = tonumber(map.attributes.nextobjectid),

        properties = {},
        tilesets = {},
        layers = {},
    }

    for _, elm in ipairs(map.child) do
        -- Map properties
        if elm.tag == "properties" then
            result.properties = get_properties(elm)
        end

        -- Tilesets
        if elm.tag == "tileset" then
            
        end

        -- Layers
        if layer_types[elm.tag] then
            push(result.layers, get_layer(elm))
        end
    end

    return result
end