local saveFile = SavePath .. "quotes.txt"
local quotes = {
    "nuh uh",
    "this quote is NOT sponsored by shadow raid legends",
    "dont forget to update your mods!",
    "have a nice day! :)",
    "I forgot the quote :(",
    "BAINNN???",
    "Hello",
    "Don't try this at home",
    "I stole 3mil $ from federal government and didn't get caught",
    "Don't act dumb",
    "Guys, the thermal drill, go get it!",
    "Fo sho!",
    "That civ you killed had a wife and six kids",
    "Pager answering simulator 2013",
    "Also try Minecraft and Terraria",
    "Don't forget to touch some grass",
    "Press any key (not power button)",
    "Stop stealing money! That's illegal!",
    "This is a random quote"
}

--[[
    Checks if an element is present in the given array.

    Params:
    - array (table): The array to search in.
    - element (any): The element to search for.

    Return:
    - boolean: True if the element is found in the array, false otherwise.
]]
local function isInArray(array, element)
    for _, value in ipairs(array) do
        if value == element then
            return true
        end
    end
    return false
end

--[[
    Checks if all possible indexes of the `array` are present in the `indexesArray`.

    Params:
    - array (table): The first array.
    - indexesArray (table): The second array.

    Return:
    - boolean: True if all possible indexes of `array` are present in `indexesArray`, false otherwise.
]]
local function containsAllIndexes(array, indexesArray)
   

    for i = 1, #array do
        if not isInArray(indexesArray, i) then
            return false
        end
    end
    return true
end

--[[
    Logs a custom message with the provided arguments.

    Params:
    - ... (any): The arguments to be logged.
]]
local function customLog(...) 
    log("[RANDOM QUOTE]: " .. table.concat({...}, " "))
end

--[[
    Writes the provided string to the `saveFile`.

    Params:
    - string (string): The content to be written to the file.
]]
local function writeSave(string)
    local file, err = io.open(saveFile, "w+")
    if file then
        file:write(string .. "\n")
        file:close()
    else
        customLog("Error: Unable to open the file for appending. " .. err)
    end
end

--[[
    Reads the content of the `saveFile`.

    Return:
    - string|nil: The content read from the file or nil if the file cannot be read.
]]
local function readSave()
    local file, err = io.open(saveFile, "r") -- "r" mode for reading
    if file then
        local content = file:read("*a") -- "*a" reads the entire content of the file
        file:close()
        return content
    else
        customLog("Error: Unable to read the file. " .. err)
    end
end

--[[
    Converts a string with numbers separated by non-numeric characters to an array of numbers.

    Params:
    - str (string): The input string to convert.

    Return:
    - table: The array of numbers extracted from the input string.
]]
local function stringToArray(str)
    local result = {}
    for num in str:gmatch("%d+") do
        table.insert(result, tonumber(num))
    end
    return result
end

--[[
    Converts an array of values to a comma-separated string representation.

    Params:
    - arr (table): The input array to convert to a string.

    Return:
    - string: The comma-separated string representation of the input array.
]]
local function arrayToString(arr)
    return table.concat(arr, ", ")
end


--[[
    Reads the array of seen quote indexes from the `saveFile`.

    Return:
    - table: The array of seen quote indexes read from the file.
]]
local function readArray()
    local content = readSave()
    if content then
        return stringToArray(content)
    end
    return {}
end

--[[
    Saves the array of seen quote indexes to the `saveFile`.

    Params:
    - array (table): The array of seen quote indexes to be saved.
]]
local function saveArray(array)
    writeSave(arrayToString(array))
end

--[[
    Returns a random quote from the `quotes` table.
    Quotes are tracked to avoid repeating the same quote until all quotes have been shown.
    If all quotes have been seen, the tracking is reset, and quotes start to be shown from the beginning again.
    Throws an error if `quotes` is not a table or if the `quotes` table is empty.

    Return:
    - string: The randomly selected quote.
]]
local function getRandomQuote()
    if type(quotes) ~= "table" then
        error("Input is not a table (array).")
    end

    if #quotes == 0 then
        error("Array is empty.")
    end

    local seenQuotesIndexes = readArray()
    if containsAllIndexes(quotes, seenQuotesIndexes) then
        -- reset array if all quotes have been seen
        seenQuotesIndexes = {}
    end

    local randomIndex
    repeat
        randomIndex = math.random(#quotes)
    until not isInArray(seenQuotesIndexes, randomIndex)

    table.insert(seenQuotesIndexes, randomIndex)
    saveArray(seenQuotesIndexes)
    customLog("Saved index " .. randomIndex .. " as seen")
    return quotes[randomIndex]
end

-- Store the original LocalizationManager.text function
local original_text = LocalizationManager.text
local quote = nil -- save quote here for not creating second quote

--[[
    Overrides the `LocalizationManager.text` function to provide custom behavior for a specific string_id.
    When the string_id is "menu_visit_forum3", a random quote is obtained and returned as the localized text.
    For other string_ids, the original `LocalizationManager.text` function is called to get the default localized text.
]]
function LocalizationManager:text(string_id, ...)
    -- why its called menu_visit_forum3 if they have menu_press_start????
    if string_id == "menu_visit_forum3" then
        if not quote then
            quote = getRandomQuote()
            customLog("Quote is " .. quote)
        end
        return quote
    end

    local original = original_text(self, string_id, ...)
    -- debug
    -- appendToFile("S:\\Coding\\Mods\\PAYDAY 2\\RandomLoadingQuotes\\test.txt", string_id .. " = " .. original)

    return original
end
