local LrApplication = import 'LrApplication'   -- Import LR namespace which provides access to active catalog
local LrDialogs = import 'LrDialogs'   -- Import LR namespace for user dialog functions
local LrProgressScope = import 'LrProgressScope'
local LrTasks = import 'LrTasks'       -- Import functions for starting async tasks
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import 'LrPathUtils'
local LrPrefs = import 'LrPrefs'

-- Preferences:
local prefs = LrPrefs.prefsForPlugin(_PLUGIN.id)
local output = ''
local outputFilename = prefs.RedundantKeywordsFile
local ignoreBranchesSetting = prefs.ignoreKeywordTreeBranches
local compareLowerCase = prefs.ignore_case
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

-- Check simple table for a given value's presence
local function inTable (val, t)
    if type(t) ~= "table" then
        return false
    else
        for i, tval in pairs(t) do
            if val == tval then return true end
        end
    end
    return false
end

-- Given a string and delimiter (e.g. ', '), break the string into parts and return as table
-- This works like PHP's explode() function.
local function split(s, delim)
   if (delim == '') then return false end
   local pos = 0
   local t = {}
   -- For each delimiter found, add to return table
   for st, sp in function() return string.find(s, delim, pos, true) end do
      -- Get chars to next delimiter and insert in return table
      t[#t + 1] = string.sub(s, pos, st - 1)
      -- Move past the delimiter
      pos = sp + 1
   end
   -- Get chars after last delimiter and insert in return table
   t[#t + 1] = string.sub(s, pos)

   return t
end

-- Basic trim functionality to remove whitespace from either end of a string
local function trim(s)
   if s == nil then return nil end
   return string.gsub(s, '^%s*(.-)%s*$', '%1')
end


local function findAllKeywords(keywords, kpath)
   kpath = (kpath ~= nil) and kpath or ""
   
   local ignore_branches = split(ignoreBranchesSetting, ", ")
   if (#ignore_branches > 0) then
      for i=1,#ignore_branches do
         ignore_branches[i] = trim(ignore_branches[i])
         if (compareLowerCase) then
            ignore_branches[i] = string.lower(ignore_branches[i])
         end
         ignore_branches[i] = (ignore_branches[i] ~= '') or nil
      end
   end
   
   for _, kw in pairs(keywords) do
      local term = kw:getName()
        --Skip location terms as these will not be in the exported/shared tree
      local compare = term
      if compareLowerCase then
         compare = string.lower(term)
      end
      
      if not inTable(compare, ignore_branches) then
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
            if newkpath ~= nil then
               newkpath = term .. " | " .. kpath
            else newkpath = term
            end
            findAllKeywords(kids, newkpath)
         end
      end
   end
end

--Returns array of keywords with a given name
local function getAllKeywordsByName(name, keywords, found)
    found = found or {}
    if type(found) == 'LrKeyword' then
        found = {found}
        elseif type(found) ~= 'table' then
            found = {}
    end
    for i, kw in pairs(keywords) do
        -- If we have found the keyword we want, return it:
        if kw:getName() == name and kwInTable(kw, found) == false then
            found[#found + 1] = kw
        -- Otherwise, use recursion to check next level if kw has child keywords:
        else
            local kchildren = kw:getChildren()
            if #kchildren > 0 then
                found = getAllKeywordsByName(name, kchildren, found)
            end
        end
    end
    -- By now, we should have them all
    return found
end

function kwInTable(kw, tb)
    kwid = kw.localIdentifier
    for _, k in pairs(tb) do
        if k.localIdentifier == kwid then return true end
    end
    return false
end

function logRedundantKeyword(term, redKeys, counter)
   -- Output is initialized at the top
   if output ~= '' then output = output .. "\n\n" end
   output = output .. 'Redundant term ' .. counter .. ': "' .. term .. '"'
   local compare = compareLowerCase and string.lower(term) or term
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
      output = output .. "\n    In:" .. path .. photo_use .. syns
      local kidstring = getChildrenString(kw)
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


function getAncestryString(kw, ancestryString)
    ancestryString = ancestryString or ''
    local parent = kw:getParent()
    if parent ~= nil then
        ancestryString = parent:getName() .. " | " .. ancestryString
        ancestryString = getAncestryString(parent, ancestryString)
    end
    return ancestryString;
end

-- Return a comma-separated string listing all children of a term
function getChildrenString(kw)
    local childNamesTable = getKeywordChildNamesTable(kw)
    if #childNamesTable > 0 then
        return table.concat(childNamesTable, ", ")
    else return ""
    end
end


--General Lightroom API helper functions for keywords
function getKeywordChildNamesTable(parentKey)
    local kchildren = parentKey:getChildren()
    local childNames = {}
    if kchildren and #kchildren > 0 then
       childNames = getKeywordNames(kchildren)
    end
    -- Return the table of child terms (empty if no child terms for passed keyword)
    return childNames;
end


-- Common Lua helper functions: -------------------------------
-- Merge two tables (like PHP array_merge())
function tableMerge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            tableMerge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1;
end

-- Get names of all Keyword objects in a table
function getKeywordNames(keywords)  
    local names = {}
    for i, kw in pairs(keywords) do
       names[#names +1] = kw:getName() 
    end
    return names;
end


-- Connect with the ZBS debugger server.
LrTasks.startAsyncTask (function()          -- Certain functions in LR which access the catalog need to be wrapped in an asyncTask.
    -- LrMobdebug.on()                           -- Make this coroutine known to ZBS
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
