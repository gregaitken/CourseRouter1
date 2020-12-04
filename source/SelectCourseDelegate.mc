using Toybox.Application;
using Toybox.WatchUi;

class SelectCourseDelegate extends WatchUi.MenuInputDelegate {
    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(course_id) {
        if (course_id != null) {
            Application.Storage.setValue("selected_course_id", course_id);
        }
    }
}
