local PATH = (...):gsub("/", ".")

local utils = {}

function utils.HEXcolor(hex)
    return {
        tonumber(hex:sub(4, 5), 16) / 255,
        tonumber(hex:sub(6, 7), 16) / 255,
        tonumber(hex:sub(8, 9), 16) / 255,
        tonumber(hex:sub(2, 3), 16) / 255
    }
end

function utils.parseCSV(csv)
    local values = {}

    for value in csv:gmatch("[^,]+") do
        values[#values+1] = value:match("^[%s\n\t]*(.-)[%s\n\t]*$")
    end

    return values
end

return utils