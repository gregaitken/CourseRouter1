using Toybox.Application;
using Toybox.WatchUi;

class CourseMenuDelegate extends WatchUi.MenuInputDelegate {
    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(option) {
        if (option == :option_select) {
            // show list of courses to select from
            var select_course_menu = new WatchUi.Menu();
            var courses = Application.Storage.getValue("courses");

            select_course_menu.setTitle("Select From");

            if (courses == null) {
                select_course_menu.addItem("No downloaded courses...", null);
            } else {
                var course_ids = courses.keys();
                var course_id, course_name;

                for (var i = 0; i < course_ids.size(); i++) {
                    course_id = course_ids[i];
                    course_name = courses[course_id];
                    select_course_menu.addItem(course_name, course_id);
                }
            }

            WatchUi.pushView(select_course_menu, new SelectCourseDelegate(), WatchUi.SLIDE_LEFT);
        } else if (option == :option_download) {
            // show list of services to download from
            WatchUi.pushView(new Rez.Menus.ServicesMenu(), new DownloadCoursesDelegate(), WatchUi.SLIDE_LEFT);
        }
    }
}
