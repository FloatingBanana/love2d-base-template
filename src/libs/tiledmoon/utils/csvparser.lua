local function parse_csv(csv)
    local values = {}
    for value in csv:gmatch("[^,]+") do
        values[#values+1] = value:match("^[%s\n\t]*(.-)[%s\n\t]*$")
    end
end