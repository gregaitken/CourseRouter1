using Toybox.WatchUi;

const ALERT_WIDTH = 222;
const ALERT_HEIGHT = 112;

const BORDER_WIDTH = 5;

class NavigationAlertView extends WatchUi.View {
    hidden var direction, street;
    hidden var small_font, medium_font;
    hidden var dc_width, dc_height;

    function initialize(_direction, _street) {
        View.initialize();

        direction = _direction;
        street = _street;
    }

    function onLayout(dc) {
        small_font = WatchUi.loadResource(Rez.Fonts.HighwayGothicSmall);
        medium_font = WatchUi.loadResource(Rez.Fonts.HighwayGothicMedium);

        dc_width = dc.getWidth();
        dc_height = dc.getHeight();
    }

    function onShow() {
    }

    function onUpdate(dc) {
        // draw navigation alert pop-up
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(dc_width/2 - ALERT_WIDTH/2, dc_height/2 - ALERT_HEIGHT/2, ALERT_WIDTH, ALERT_HEIGHT);
  
        dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(BORDER_WIDTH);
        dc.drawRectangle(dc_width/2 - ALERT_WIDTH/2, dc_height/2 - ALERT_HEIGHT/2, ALERT_WIDTH, ALERT_HEIGHT);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc_width/2, dc_height/2 - ALERT_HEIGHT/8, medium_font, "TURN " + direction.toUpper(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc_width/2, dc_height/2 + ALERT_HEIGHT/5, small_font, "On " + street, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() {
    }
}
