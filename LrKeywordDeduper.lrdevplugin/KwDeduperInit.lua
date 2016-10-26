-- Provide initial default values for plugin preferences.

local LrPrefs = import 'LrPrefs'

local defaultPrefValues = {
   RedundantKeywordsFile = 'Lightroom-Redundant-Keywords-report.txt',
   ignore_case = true,
   ignoreKeywordTreeBranches = '',
}

local prefs = LrPrefs.prefsForPlugin(_PLUGIN.id)
for k,v in pairs(defaultPrefValues) do
  if prefs[k] == nil then prefs[k] = v end
end
