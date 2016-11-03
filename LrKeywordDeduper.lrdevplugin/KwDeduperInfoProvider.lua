local LrView = import 'LrView'
local LrPrefs = import 'LrPrefs'

local PluginAbout = 'Despite its promising name, this plugin (so far) only logs a list of keywords\nwhich share the same name (in a large hierarchical keyword set, many keyword\npairs may exist. If the meaning is not the same for, you may wish to rename\na keyword to better differentiate the meaning. You could also add a synonym\nso that the original name is added on export. Or, where the intended meaning\nis the same, you may wish to delete one keyword after adding photos tagged\nwith it to the other similar keyword.'

local PluginLicense = 'Copyright © 2016 Lowell Montgomery / www.lowemo.photo\n\nUse of this plugin is at your own risk.\nNo warranty is provided against loss of data or any other loss. (That said, if\nyou have any problems, please do let me know by creating an issue on Github)'

local KwDeduperInfoProvider = {}

function KwDeduperInfoProvider.sectionsForTopOfDialog(viewFactory, propertyTable)
   local prefs = LrPrefs.prefsForPlugin(_PLUGIN.id)
   local bind = LrView.bind

   return {
   {
      title = LOC '$$$/LrKeywordDeduper/Preferences/SettingsTitle=Settings for keyword deduper script',

      viewFactory:row {
         viewFactory:static_text {
            width_in_chars = 80,
            height_in_lines = 8,
            title = PluginAbout
         },
      },

      viewFactory:row {
         spacing = viewFactory:label_spacing(),
         viewFactory:static_text {
            title = LOC '$$$/LrKeywordDeduper/Preferences/DuplicateKeywordsFile=Redundant Keywords Report name',
            tooltip = 'The output file will be stored in the documents directory, but you can name it here.',
            alignment = 'right',
         },
         -- Name of report file output to the desktop
         viewFactory:edit_field {
            tooltip = 'The output file will be stored on your desktop by the name you choose here.',
            fill_horizonal = 1,
            width_in_chars = 35,
            value = bind { key = 'RedundantKeywordsFile', object = prefs },
         },
      },

      viewFactory:separator { fill_horizontal = 1 },
      viewFactory:row {
         spacing = viewFactory:control_spacing(),
      -- Ignore case when comparing keywords
         viewFactory:checkbox {
            title = LOC '$$$/IptcCodeHelper/Preferences/ignoreCase=Ignore text case when comparing keyword names',
            tooltip = 'Ignore text case means that "DOG", "dog", and "Dog" would all be seen as the same',
            value = bind { key = 'ignore_case', object = prefs },
         },
      },

      viewFactory:row {
         spacing = viewFactory:label_spacing(),

         viewFactory:static_text {
            title = LOC '$$$/ClarifaiTagger/Preferences/ignoreKeywordBranches=Ignore keyword branches:',
            tooltip = 'Comma-separated list of keyword terms to ignore (including chilren and descendants).',
            alignment = 'left',
            -- width = share 'title_width',
         },

         viewFactory:edit_field {
            tooltip = 'Comma-separated list of keyword terms to ignore (including chilren and descendants).',
            width_in_chars = 35,
            height_in_lines = 4,
            enabled = true,
            alignment = 'left',
            value = bind { key = 'ignoreKeywordTreeBranches', object = prefs },
         },
      },
   },
   };
end

function KwDeduperInfoProvider.sectionsForBottomOfDialog(viewFactory, propertyTable)   
   return {
      {
         title = LOC '$$$/LrKeywordDeduper/Preferences/CopyrightTitle=Copyright and License',
            viewFactory:static_text {
               width_in_chars = 80,
               height_in_lines = 6,
               title = PluginLicense
            }
      }
   };
end

return KwDeduperInfoProvider

