using Toybox.Application;
using Toybox.Communications;
using Toybox.Timer;
using Toybox.WatchUi;

const GARMIN_URL = "https://connect.garmin.com/modern/proxy/course-service-1.0/json/course/";

class DownloadCoursesDelegate extends WatchUi.MenuInputDelegate {
    hidden var courses, course_id;

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(service) {
        if (service == :service_garmin) {
            courses = Application.Storage.getValue("courses");

            if (courses == null) {
                courses = {};

                // load default course into storage
	            course_id = default_course["service"] + default_course["courseId"];
	            Application.Storage.setValue(course_id, default_course);
	            courses.put(course_id, default_course["courseName"]);

                Application.Storage.setValue("courses", courses);
            }

            WatchUi.pushView(new CoursePicker(), new CoursePickerDelegate(), WatchUi.SLIDE_IMMEDIATE);
        } else if (service == :service_strava) {
            System.println("Unimplemented");
        } else if (service == :service_rwgps) {
            System.println("Unimplemented");
        }
    }
}

class CourseRequestDelegate extends WatchUi.BehaviorDelegate {
    hidden var progress_bar, course_id;

    function initialize(_progress_bar, _course_id) {
        BehaviorDelegate.initialize();

        progress_bar = _progress_bar;
        course_id = _course_id;

        makeRequest();
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function onReceive(responseCode, data) {
        var string, value, timer;

        System.println("Response: " + responseCode);

        if (responseCode == 200) {
            string = "Complete";
            value = 100;
        } else {
            string = "Error";
            value = 0;
        }

        progress_bar.setDisplayString(string);
        progress_bar.setProgress(value);

        timer = new Timer.Timer();
        timer.start(method(:onBack), 1000, false);
    }

    function makeRequest() {
        var url = GARMIN_URL + course_id;
        var params = {};
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(url, params, options, method(:onReceive));
    }
}

class CoursePicker extends WatchUi.Picker {
    function initialize() {
        var title = new WatchUi.Text({
            :text => "Enter Course ID",
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
            :color => Graphics.COLOR_WHITE
        });
        var digit_factory = new NumberFactory(0, 9, 1, {});
        var stored_values = Application.Storage.getValue("course_id_values");

        if (stored_values == null) {
            stored_values = [0, 0, 0, 0, 0, 0, 0];
        }

        Picker.initialize({
            :title => title,
            :pattern => [digit_factory, digit_factory, digit_factory, digit_factory, digit_factory, digit_factory, digit_factory],
            :defaults => stored_values
        });
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}

class CoursePickerDelegate extends WatchUi.PickerDelegate {
    hidden var progress_bar, course_id;

    function initialize() {
        PickerDelegate.initialize();
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function onAccept(values) {
        Application.Storage.setValue("course_id_values", values);

        progress_bar = new WatchUi.ProgressBar("Downloading...", null);
        course_id = "";

        for (var i = 0; i < values.size(); i++) {
            course_id += values[i];
        }

        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.pushView(progress_bar, new CourseRequestDelegate(progress_bar, course_id), WatchUi.SLIDE_IMMEDIATE);
    }
}
