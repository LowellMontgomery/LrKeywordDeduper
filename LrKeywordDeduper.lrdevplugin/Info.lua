local menuItems = {
    title = "Find duplicate keywords", -- The display text for the menu item.
    file = "LrKeywordDeduper.lua", -- The script that runs when the item is selected
}

return {
    LrSdkVersion = 5.0,
    LrSdkMinimumVersion = 4.0, -- minimum SDK version required by this plug-in
    LrToolkitIdentifier = 'photo.lowemo.lightroom.LrKeywordDeduper',
    LrPluginInfoUrl = "https://LoweMo.photo/lightroom-KeywordDeduper",
    LrPluginName = 'Lightroom Keyword Deduper',
    -- Add menu item to both standard menu locations.
    LrExportMenuItems = menuItems, -- Items that you add in LrExportMenuItems appear in the Plug-in Extras submenu of the File menu 
    LrLibraryMenuItems = menuItems,-- Items that you add in LrLibraryMenuItems appear in the Plug-in Extras submenu of the Library menu 
    LrPluginInfoProvider = 'KwDeduperInfoProvider.lua',
    LrInitPlugin = 'KwDeduperInit.lua',
    VERSION = {display='1.0.0', major=1, minor=0, revision=0, build=1}
}
