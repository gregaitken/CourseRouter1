using Toybox.ActivityRecording;
using Toybox.Application;
using Toybox.Position;
using Toybox.Timer;
using Toybox.WatchUi;

const GEO_DELTA = 0.00025;

var gps_quality;
var cur_pos;

class ActivityDelegate extends WatchUi.BehaviorDelegate {
    hidden var timer, cues, cue, index;

    function initialize() {
        BehaviorDelegate.initialize();

        gps_quality = null;
        cur_pos = null;

        timer = new Timer.Timer();
        cues = Application.Storage.getValue(Application.Storage.getValue("selected_course_id"))["cues"];
        index = 0;

        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPositionUpdate));
    }

    // start/stop button handler
    function onSelect() {
        var ms;

        if (session == null) {
            // create session
            session = ActivityRecording.createSession({
                :name => "Cycling",
                :sport => ActivityRecording.SPORT_CYCLING
            });
            session.start();
            refreshScreen();
            timer.start(method(:refreshScreen), 1000, true);
        } else if (session.isRecording()) {
            // stop session
            session.stop();
            timer.stop();
            refreshScreen();
        } else {
            // resume session
            ms = Activity.getActivityInfo().timerTime % 1000;
            session.start();
            refreshScreen();
            timer.start(method(:resyncRefresh), 1000 - ms, false);
        }

        return true;
    }

    // back button handler
    function onBack() {
        if (session == null) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        } else if (session != null && session.isRecording() == false) {
            WatchUi.pushView(new Rez.Menus.EndActivityMenu(), new EndActivityDelegate(), WatchUi.SLIDE_IMMEDIATE);
        }

        return true;
    }

    // up button handler
    function onPreviousPage() {
        switch (page_num) {
        case 1:
            WatchUi.switchToView(new MapView(), self, WatchUi.SLIDE_DOWN);
            break;
        case 2:
            WatchUi.switchToView(new DataFieldView(), self, WatchUi.SLIDE_DOWN);
            break;
        }

        return true;
    }

    // down button handler
    function onNextPage() {
        switch (page_num) {
        case 1:
            WatchUi.switchToView(new MapView(), self, WatchUi.SLIDE_UP);
            break;
        case 2:
            WatchUi.switchToView(new DataFieldView(), self, WatchUi.SLIDE_UP);
            break;
        }

        return true;
    }

    // called when location is updated
    function onPositionUpdate(info) {
        gps_quality = info.accuracy;
        cur_pos = info.position.toDegrees();

        WatchUi.requestUpdate();
        showNavigation();
    }

    // show navigation cue, if any
    function showNavigation() {
        if (index < cues.size()) {
            cue = cues[index];
            if (inRange(cue[0])) {
                WatchUi.pushView(new NavigationAlertView(cue[1], cue[2]), new NavigationAlertDelegate(), WatchUi.SLIDE_IMMEDIATE);
                index++;
            }
        }
    }

    // check if next cue is "close"
    function inRange(cue_pos) {
        return (cur_pos[0] - cue_pos[0]).abs() < GEO_DELTA && (cur_pos[1] - cue_pos[1]).abs() < GEO_DELTA;
    }

    function resyncRefresh() {
        // one time refresh followed by repeating every second
        WatchUi.requestUpdate();
        timer.start(method(:refreshScreen), 1000, true);
    }

    function refreshScreen() {
        WatchUi.requestUpdate();
    }
}
