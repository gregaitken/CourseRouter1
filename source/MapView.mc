using Toybox.Application;
using Toybox.WatchUi;

const FR735XT_PX_WIDTH = 215;
const FR735XT_PX_HEIGHT = 180;

const LINE_WIDTH = 4;
const ARC_WIDTH = 12;
const OUTLINE_WIDTH = 2;
const PT_RADIUS = 7;
const MAP_PADDING = 0.2;

const FIRST_GPS_BAR_X = 80;
const FIRST_GPS_BAR_Y = 16;

const TOP_CONTROL_X = 8;
const TOP_CONTROL_Y = 102;
const BOTTOM_CONTROL_X = 23;
const BOTTOM_CONTROL_Y = 138;

const PLUS_MINUS_MODE = 0;
const LEFT_RIGHT_MODE = 1;
const UP_DOWN_MODE = 2;
const NUM_CONTROL_MODES = 3;

//var control_mode = PLUS_MINUS_MODE;

//function changeControlMode() {
//    control_mode = (control_mode + 1) % NUM_CONTROL_MODES;
//    WatchUi.requestUpdate();
//}

class MapView extends WatchUi.View {
    hidden var course;
    hidden var zoom_level;
    hidden var min_lat, min_long, max_lat, max_long;
    hidden var geo_width, geo_height;
    hidden var extra_small_font;
    hidden var north_arrow, map_scale, plus_icon, minus_icon;
    hidden var left_arrow, right_arrow, up_arrow, down_arrow;
    hidden var dc_width, dc_height;
    hidden var pts, cur_pt;

    function initialize() {
        var bounding_box;

        View.initialize();

        page_num = 2;

        course = Application.Storage.getValue(Application.Storage.getValue("selected_course_id"));
        zoom_level = 0;

        bounding_box = course["boundingBox"];

        min_lat = bounding_box[0][0];
        min_long = bounding_box[0][1];
        max_lat = bounding_box[1][0];
        max_long = bounding_box[1][1];

        geo_width = max_long - min_long;
        geo_height = max_lat - min_lat;
    }

    function onLayout(dc) {
        extra_small_font = WatchUi.loadResource(Rez.Fonts.HighwayGothicExtraSmall);
        north_arrow = WatchUi.loadResource(Rez.Drawables.NorthArrow);
        map_scale = WatchUi.loadResource(Rez.Drawables.MapScale);
        plus_icon = WatchUi.loadResource(Rez.Drawables.Plus);
        minus_icon = WatchUi.loadResource(Rez.Drawables.Minus);
        left_arrow = WatchUi.loadResource(Rez.Drawables.ArrowLeft);
        right_arrow = WatchUi.loadResource(Rez.Drawables.ArrowRight);
        up_arrow = WatchUi.loadResource(Rez.Drawables.ArrowUp);
        down_arrow = WatchUi.loadResource(Rez.Drawables.ArrowDown);

        dc_width = dc.getWidth();
        dc_height = dc.getHeight();

        pts = coordsToPts(course["geoPoints"]);
        cur_pt = pts[0];
    }

    function onShow() {
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();

        drawCourse(dc);
        drawPosition(dc);
        drawIcons(dc);
        drawStateArc(dc);
    }

    function onHide() {
    }

    function longToX(long) {
        var norm_long = (long - min_long) / geo_width;
        return (MAP_PADDING + (1 - 2*MAP_PADDING) * norm_long) * dc_width;
    }

    function latToY(lat) {
        var norm_lat = (lat - min_lat) / geo_height;
        return ((1 - MAP_PADDING) - (1 - 2*MAP_PADDING) * norm_lat) * dc_height;
    }

    function coordsToPts(coords) {
        var pts = new [coords.size()];

        for (var i = 0; i < coords.size(); i++) {
            pts[i] = [longToX(coords[i][1]), latToY(coords[i][0])];
        }

        return pts;
    }

    function absToRelX(x) {
        return x * dc_width / FR735XT_PX_WIDTH;
    }

    function absToRelY(y) {
        return y * dc_height / FR735XT_PX_HEIGHT;
    }

    function drawIcons(dc) {
        drawGps(dc);
        drawCompass(dc);
        drawScale(dc);
//        drawControls(dc);
    }

    function drawGps(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(absToRelX(54), absToRelY(4), extra_small_font, "GPS", Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
        if (gps_quality == null || gps_quality == Position.QUALITY_NOT_AVAILABLE) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(absToRelX(FIRST_GPS_BAR_X), absToRelY(FIRST_GPS_BAR_Y), 3, 2);
        if (gps_quality == Position.QUALITY_LAST_KNOWN) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(absToRelX(FIRST_GPS_BAR_X + 5), absToRelY(FIRST_GPS_BAR_Y - 3), 3, 5);
        if (gps_quality == Position.QUALITY_POOR) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(absToRelX(FIRST_GPS_BAR_X + 10), absToRelY(FIRST_GPS_BAR_Y - 6), 3, 8);
        if (gps_quality == Position.QUALITY_USABLE) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(absToRelX(FIRST_GPS_BAR_X + 15), absToRelY(FIRST_GPS_BAR_Y - 9), 3, 11);
    }

    function drawCompass(dc) {
        dc.drawBitmap(absToRelX(8), absToRelY(29), north_arrow);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(absToRelX(20), absToRelY(36), extra_small_font, "N", Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawScale(dc) {
        dc.drawBitmap(absToRelX(54), absToRelY(167), map_scale);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(absToRelX(74), absToRelY(160), extra_small_font, "0.1 mi", Graphics.TEXT_JUSTIFY_CENTER);
    }

//    function drawControls(dc) {
//        switch (control_mode) {
//        case PLUS_MINUS_MODE:
//            drawPlusMinus(dc);
//            break;
//        case LEFT_RIGHT_MODE:
//            drawLeftRight(dc);
//            break;
//        case UP_DOWN_MODE:
//            drawUpDown(dc);
//            break;
//        }
//    }

    function drawPlusMinus(dc) {
        drawTopControl(dc, plus_icon);
        drawBottomControl(dc, minus_icon);
    }

    function drawLeftRight(dc) {
        drawTopControl(dc, left_arrow);
        drawBottomControl(dc, right_arrow);
    }

    function drawUpDown(dc) {
        drawTopControl(dc, up_arrow);
        drawBottomControl(dc, down_arrow);
    }

    function drawTopControl(dc, icon) {
        dc.drawBitmap(absToRelX(TOP_CONTROL_X), absToRelY(TOP_CONTROL_Y), icon);
    }

    function drawBottomControl(dc, icon) {
        dc.drawBitmap(absToRelX(BOTTOM_CONTROL_X), absToRelY(BOTTOM_CONTROL_Y), icon);
    }

    function drawCourse(dc) {
        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(LINE_WIDTH);

        for (var i = 0; i < pts.size()-1; i++) {
            dc.drawLine(pts[i][0], pts[i][1], pts[i+1][0], pts[i+1][1]);
        }

        var start_pt = pts[0];
        var end_pt = pts[pts.size()-1];

        if (start_pt[0] == end_pt[0] && start_pt[1] == end_pt[1]) {
            drawPt(dc, start_pt[0], start_pt[1], Graphics.COLOR_GREEN, Graphics.COLOR_RED);
        } else {
	        drawPt(dc, end_pt[0], end_pt[1], Graphics.COLOR_RED, Graphics.COLOR_BLACK);
            drawPt(dc, start_pt[0], start_pt[1], Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        }
    }

    function drawPosition(dc) {
        if (cur_pos != null) {
            var x = longToX(cur_pos[1]);
            var y = latToY(cur_pos[0]);
            var fill_color;

            if (gps_quality >= Position.QUALITY_POOR) {
                fill_color = Graphics.COLOR_BLUE;
            } else {
                fill_color = Graphics.COLOR_YELLOW;
            }

            drawPt(dc, x, y, fill_color, Graphics.COLOR_BLACK);
        }
    }

    function drawPt(dc, x, y, fill_color, outline_color) {
        dc.setColor(fill_color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, PT_RADIUS);

        dc.setColor(outline_color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(OUTLINE_WIDTH);
        dc.drawCircle(x, y, PT_RADIUS);
    }

    // green/red arc to indicate activity state
    function drawStateArc(dc) {
        if (session != null) {
            if (session.isRecording()) {
		        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
	        } else {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
	        }

	        dc.setPenWidth(ARC_WIDTH);
	        dc.drawArc(dc_width/2 - ARC_WIDTH/2 + 2, dc_height/2, dc_width/2, Graphics.ARC_CLOCKWISE, 63, 297);

            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(OUTLINE_WIDTH);
            dc.drawArc(dc_width/2 - ARC_WIDTH/2 + 2, dc_height/2, dc_width/2 - ARC_WIDTH/2, Graphics.ARC_CLOCKWISE, 63, 297);
            dc.drawArc(dc_width/2 - ARC_WIDTH/2 + 2, dc_height/2 - 1, dc_width/2 - ARC_WIDTH/2, Graphics.ARC_CLOCKWISE, 63, 297);
        }
    }
}
