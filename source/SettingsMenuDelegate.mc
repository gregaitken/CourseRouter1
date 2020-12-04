using Toybox.Application;
using Toybox.WatchUi;

class SettingsMenuDelegate extends WatchUi.MenuInputDelegate {
    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(setting) {
        if (setting == :setting_reset) {
            Application.Storage.clearValues();
        }
    }
}
