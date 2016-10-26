# LrKwDeduper - (Lightroom Keyword Deduper)
The lofty goal for this project is to build up functionality which helps streamline the workflow of merging duplicate keywords (keywords by the same name and with the same meaning/context in a hierarchical keyword list).

Currently, this plugin only *identifies* duplicate keywords and prints out a report that includes the number of photos associated with each keyword, any synonyms and/or child terms as well as the "ancestry path" for each keyword (parent terms up to the top level)

## The problem: Duplicate keywords cause fragmentation in searches
 My personal interest when designing this plugin was to improve the structure of my keyword vocabulary by finding any areas of unintended overlap in my keyword hierarchy and merging them, wherever possible. The main purpose was that then I could use AI auto-tagging solutions, tweaked to work with a hierarchical keyword list, with as few duplicate terms as possible.
 
## Installing the Lightroom Keyword Deduper Lightroom plugin
Installing and using this plugin is the same as for any other Lightroom plugin, so you may already know what to do, but I will still outline the installation process:

### Adding a plugin via the Plugin Manager
If you add a new plugin to the standard directory in Mac or Windows, Lightroom should recognize the new plugin and it will already be shown as "Installed and running" when you open the Plugin Manager.

:point_right: On a Mac, that’s the `~/Library/Application Support/Adobe/Lightroom/Modules` directory.

:point_right: On Windows, it should be `C:\Users\your-username\AppData\Roaming\Adobe\Lightroom\Modules`.

It’s possible that the `Modules` directory does not already exist. If so, you can create it.

Alternatively, you can use the Plugin Manager to install a Lightroom plugin which is stored in any directory accessible to the user:

1. Start Lightroom
2. Open `File > Plug-in Manager…`

![The Lightroom plugin manager menu item](lightroom-open-plugin-manager.jpg "Open the “File > Plug-in Manager…” menu item in Lightroom")

3. Click on the `Add` button
![Click the Add button at the bottom](lightroom-plugin-manager-add-button.png "Find and click the “Add” button")

4. Locate the plugin, wherever you have downloaded it (here in a sub-folder within my Downloads directory)
![Select the plugin you want to add to Lightroom](lightroom-plugin-manager-select-plugin.png "Select the plugin, from wherever you want to keep it")

5. You should now see that the plugin is “installed and running”
![Lightroom Plugin Manager: Plugin Installed and Running](lightroom-plugin-manager-installed-running.png "In the plugin manager, you should now see that the Lightroom Keyword Deduper plugin is “installed and running”")

### Preparing to use the Lightroom Keyword Deduper
For now, settings for this plugin are only visible in the Plugin Manager; read on…

#### Settings in the Lightroom Plugin Manager


### Using the Lightroom Keyword Deduper Lightroom Plugin
Once the plugin is configured and running, it’s simply a matter selecting the menu item, `Library > Plugin Extras > Keyword Deduper`:

