using Toybox.Time;
using Toybox.WatchUi;

class CourseRouter1View extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.StartPageLayout(dc));
    }

    function onShow() {
    }

    function onUpdate(dc) {
        var field, time, hour, period, battery_level;

        // set clock
        time = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        if (time.hour < 12) {
            if (time.hour == 0) {
                hour = 12;
            } else {
                hour = time.hour;
            }
            period = "AM";
        } else {
            if (time.hour == 12) {
                hour = 12;
            } else {
                hour = time.hour - 12;
            }
            period = "PM";
        }

        field = View.findDrawableById("Clock");
        field.setText(Lang.format("$1$:$2$ $3$", [hour, time.min.format("%02d"), period]));

        // set battery indicator
        battery_level = System.getSystemStats().battery;

        field = View.findDrawableById("Battery");
        field.setText(battery_level.format("%d") + '%');

        field = View.findDrawableById("Bolt");

        if (battery_level >= 50) {
            field.setBitmap(Rez.Drawables.BoltGreen);
        } else if (battery_level >= 20) {
            field.setBitmap(Rez.Drawables.BoltYellow);
        } else {
            field.setBitmap(Rez.Drawables.BoltRed);
        }

        View.onUpdate(dc);
    }

    function onHide() {
    }
}
