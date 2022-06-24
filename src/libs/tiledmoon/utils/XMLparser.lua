local function trim(text)
    return text:match("^[%s\n\t]*(.-)[%s\n\t]*$")
end

local function escapeSpecialChars(text, escape)
    if escape then
        return text:gsub("\"", "&quot;")
                   :gsub("<", "&lt;")
                   :gsub(">", "&gt;")
    else
        return text:gsub("&quot;", "\"")
                   :gsub("&lt;", "<")
                   :gsub("&gt;", ">")
    end
end

local function parseAttributes(text)
    local attributes = {}

    for name, value in text:gmatch("(%w-)%s*=%s*\"(.-)\"") do
        attributes[name] = escapeSpecialChars(value, true)
    end

    return attributes
end

local function getOffsetLine(code, offset)
    local n = 1
    for _ in code:sub(1, offset):gmatch("\n") do
        n = n + 1
    end

    return n
end

local function parsingError(type, line, ...)
    if type == "unclosedTag" then
        return ("Line %d: Missing closing tag for element \"%s\"."):format(line, ...)
    
    elseif type == "strayClosingTag" then
        return ("Line %d: Unmatched closing tag for element \"%s\"."):format(line, ...)
    end
end

local function tokenize(code)
    local results = {}

    -- Parse texts first
    local start = 1
    while true do
        -- Get the offset and length
        local first, last = code:find(">.-<", start)

        -- Break the loop if there's no more matches
        if not first then
            break
        end

        start = last + 1

        --Get the substring
        local text = code:sub(first, last):match(">(.-)<")
        local trimmed = trim(text)

        -- If there's any characters besides line breaks, spaces and tabs then it's a text element
        if trimmed ~= "" then
            local element = {
                type = "text",
                first = first,
                last = last,
                line = getOffsetLine(code, first),
                content = escapeSpecialChars(trimmed)
            }

            table.insert(results, element)
        end
    end

    -- Parse tags
    start = 1
    while true do
        local first, last = code:find("<.->", start)

        if not first then
            break
        end

        start = last + 1
        local tag = code:sub(first, last)
        local element = nil


        local elementType = ""
        local content = ""

        if tag:match("</.->") then
            --Closing tag
            elementType = "closing"
            content = tag:match("</(.-)>")

        elseif tag:match("<.-/>") then
            --Single tag
            elementType = "single"
            content = tag:match("<(.-)/>")

        elseif tag:match("<%?.->") then
            --Config tag
            elementType = "config"
            content = tag:match("<%?(.-)>")

        else
            --Opening tag
            elementType = "opening"
            content = tag:match("<(.-)>")
        end

        element = {
            type = elementType,
            tag = content:match("^%w*"),
            attributes = parseAttributes(content:gsub("^%w*", "")),
            first = first,
            last = last,
            line = getOffsetLine(code, first)
        }

        table.insert(results, element)
    end

    -- Reorganize elements to the same order they were written
    table.sort(results, function(a, b)
        return a.first < b.first
    end)

    return results
end

local function createAST(tokens)
    local stack = {
        {type = "root", child = {}}
    }
    
    for _, element in ipairs(tokens) do
        if element.type == "opening" then
            element.child = {}
            table.insert(stack, element) -- Add element to the parent stack
        else
            local current = stack[#stack]
            local parent = stack[#stack-1]
    
            if element.type == "closing" then
                if element.tag == current.tag then
                    -- Close element and add it to parent's child list
                    table.insert(parent.child, current)
                    table.remove(stack, #stack)
                else
                    -- Warn if a unmatched closig element is found
                    return nil, parsingError("strayClosingTag", element.line, element.tag)
                end
            else
                -- Add element to parent's child list
                table.insert(current.child, element)
            end
        end
    end
    
    -- Trigger a error warning if there's any open tag in the stack
    if stack[#stack].type ~= "root" then
        return nil, parsingError("unclosedTag", stack[#stack].line, stack[#stack].tag)
    end

    return stack[1].child
end

local function parseXML(code)
    -- Remove commented text
    local clean = code:gsub("<!%-%-.-%-%->", "")

    local tokens = tokenize(clean)

    local ast, err = createAST(tokens)

    if not ast then
        error(err)
    end

    return ast
end

return parseXML