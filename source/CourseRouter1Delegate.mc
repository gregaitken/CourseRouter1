using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi;

var session = null;
var page_num = 0;

class CourseRouter1Delegate extends WatchUi.BehaviorDelegate {
    hidden var timer;

    function initialize() {
        var seconds;

        BehaviorDelegate.initialize();

        // update clock on next minute and every minute thereafter
        timer = new Timer.Timer();
        seconds = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).sec;
        timer.start(method(:resyncRefresh), (60 - seconds)*1000, false);
    }

    // start/stop button handler
    function onSelect() {
        WatchUi.pushView(new DataFieldView(), new ActivityDelegate(), WatchUi.SLIDE_LEFT);
        return true;
    }

    // up button handler
    function onPreviousPage() {
        WatchUi.pushView(new Rez.Menus.CourseMenu(), new CourseMenuDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }

    // down button handler
    function onNextPage() {
        WatchUi.pushView(new Rez.Menus.SettingsMenu(), new SettingsMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function resyncRefresh() {
        // one time refresh followed by repeating every minute
        WatchUi.requestUpdate();
        timer.start(method(:refreshScreen), 60*1000, true);
    }

    function refreshScreen() {
        WatchUi.requestUpdate();
    }
}
