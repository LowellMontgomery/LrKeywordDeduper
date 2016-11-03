local LrApplication = import 'LrApplication'   -- Import LR namespace which provides access to active catalog
local LrDialogs = import 'LrDialogs'   -- Import LR namespace for user dialog functions
local LrProgressScope = import 'LrProgressScope'
local LrTasks = import 'LrTasks'       -- Import functions for starting async tasks
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import 'LrPathUtils'
local LrPrefs = import 'LrPrefs'
local LUTILS = require 'LUTILS'
local KwUtils = require 'KwUtils'

-- Preferences:
local prefs = LrPrefs.prefsForPlugin(_PLUGIN.id)
local output = ''
local outputFilename = prefs.RedundantKeywordsFile
local ignoreBranchesSetting = prefs.ignoreKeywordTreeBranches
local topLevelKeywords = {}

-- Variables used for processing keyword dupes
local redundantKeywords = {}
local catalogKeywords = {}
local catalogKeywordPaths = {}

SEP = MAC_ENV and '/' or '\\'

local function writeFile(content, filename)
    local FileStr = LrPathUtils.getStandardFilePath( 'desktop' ) .. SEP .. filename
    Hnd = io.open(FileStr, "w")
    Hnd:write(content)
    Hnd:close()	
end

local function findAllKeywords(keywords, kpath)
    kpath = (kpath ~= nil) and kpath or ""

    local ignore_branches = LUTILS.split(ignoreBranchesSetting, ", ")
    if (#ignore_branches > 0) then
        for i=1,#ignore_branches do
            ignore_branches[i] = LUTILS.trim(ignore_branches[i])
         -- Get rid of any empty strings that might result from a trailing ", "
            ignore_branches[i] = (ignore_branches[i] ~= '' and ignore_branches[i]) or nil
        end
    end
   
    for _, kw in pairs(keywords) do
        local term = kw:getName()
        --Skip location terms as these will not be in the exported/shared tree
        local compare = term
        if prefs.ignore_case then
            compare = string.lower(term)
        end
      
        if LUTILS.inTable(term, ignore_branches) ~= true then
            if catalogKeywords[compare] == nil then
                catalogKeywords[compare] = { kw }
                catalogKeywordPaths[compare] = { kpath }
            else
                local num = #catalogKeywords[compare] + 1
                catalogKeywords[compare][num] = kw
                catalogKeywordPaths[compare][num] = kpath
            end
         -- Recursive call to process any children
            local kids = kw:getChildren()
            if #kids > 0 then
                local newkpath = kpath
                if newkpath ~= nil and newkpath ~= '' then
                    newkpath = kpath .. " | " .. term
                    else newkpath = term
                end
                findAllKeywords(kids, newkpath)
            end
        end
    end
end

function logRedundantKeyword(term, redKeys, counter)
    -- Output is initialized at the top of this file
    if output ~= '' then output = output .. "\n\n" end
    output = output .. 'Redundant term ' .. counter .. ': "' .. term .. '"'

    -- Convert term to lower case for comparison if using default preference,
    -- otherwise "dog" is not the same as "Dog"
    local compare = prefs.ignore_case and string.lower(term) or term
    for i, kw in ipairs(redKeys) do

        local path = catalogKeywordPaths[compare][i]

        local synTable = kw:getSynonyms() or {}
        local syns = ''
        if #synTable then
            syns = table.concat(synTable, ", ")
        end
        if syns ~= '' then syns = " (Synonyms: " .. syns .. ")" end
        local photos = kw:getPhotos()
        local photo_use = " with " .. #photos .. " photos"
        output = output .. "\n    In: " .. path .. photo_use .. syns
        local kidstring = KwUtils.getChildrenString(kw)
        if kidstring and #kidstring > 50 then
            kidstring = string.sub(kidstring, 1, 50) .. " ..."
        end
        if #kidstring > 0 then
            output = output .. "\n      (Children: " .. kidstring .. ")"
        end
    end
end

function printRedundantKeywordsTable()
    counter = 0
    for term, keywords in pairs(redundantKeywords) do
        counter = counter + 1
        logRedundantKeyword(term, keywords, counter)
    end
    
    writeFile(output, outputFilename)
    return counter;
end


LrTasks.startAsyncTask (function() --  Certain functions in LR which access the catalog
                                    -- must be called from an asyncTask.
    catalog = LrApplication.activeCatalog()   -- Get the active LR catalog. 

    local topLevelKeywords = catalog:getKeywords()

    -- Populate the catalogKeywords and catalogKeywordPaths tables
    findAllKeywords(topLevelKeywords)
    for keyname,keywords in pairs(catalogKeywords) do
        if #keywords > 1 then
            redundantKeywords[keyname] = catalogKeywords[keyname]
        end
    end

    local numFound = printRedundantKeywordsTable()

    message = "Found  " .. numFound .. " keyword pairs or groups. (See '" .. outputFilename .. "' on your desktop)"
    LrDialogs.message(message)
end)
