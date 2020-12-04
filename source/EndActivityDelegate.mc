using Toybox.Position;
using Toybox.WatchUi;

class EndActivityDelegate extends WatchUi.MenuInputDelegate {
    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(option) {
        if (option == :option_save) {
            session.save();
        } else if (option == :option_discard) {
            session.discard();
        }

        session = null;
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
