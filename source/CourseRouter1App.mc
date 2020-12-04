using Toybox.Application;

class CourseRouter1App extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    // called on application start up
    function onStart(state) {
        var course_id, courses = {};

        // load default course into storage and set it as selected
        course_id = default_course["service"] + default_course["courseId"];
        Application.Storage.setValue(course_id, default_course);
        courses.put(course_id, default_course["courseName"]);

        Application.Storage.setValue("courses", courses);
        Application.Storage.setValue("selected_course_id", course_id);
    }

    // called when application is exiting
    function onStop(state) {
    }

    // return initial view of application
    function getInitialView() {
        return [new CourseRouter1View(), new CourseRouter1Delegate()];
    }
}
