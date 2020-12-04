using Toybox.Graphics;
using Toybox.Math;
using Toybox.WatchUi;

const M_PER_MI = 1609.344;

class DataFieldView extends WatchUi.View {
    hidden var distanceValue, timerValue, speedValue;
    hidden var miles, hours, minutes, seconds, centiseconds, mph;
    hidden var extra_small_font, small_font;
    hidden var dc_width, dc_height;

    function initialize() {
        View.initialize();

        page_num = 1;

        distanceValue = 0;
        timerValue = 0;
        speedValue = 0;
        miles = 0;
        hours = 0;
        minutes = 0;
        seconds = 0;
        centiseconds = 0;
        mph = 0;
    }

    function onLayout(dc) {
        extra_small_font = WatchUi.loadResource(Rez.Fonts.HighwayGothicExtraSmall);
        small_font = WatchUi.loadResource(Rez.Fonts.HighwayGothicSmall);

        dc_width = dc.getWidth();
        dc_height = dc.getHeight();
    }

    function onUpdate(dc) {
        var distance, units_x, timer_primary, timer_secondary, speed;

        // calculate data to display
        compute(Activity.getActivityInfo());

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();

        // draw distance
        distance = miles.format("%.2f");

        // set display position for units
        if (miles < 10) {
            units_x = 0.6*dc_width;
        } else if (miles < 100) {
            units_x = 0.68*dc_width;
        } else {
            units_x = 0.76*dc_width;
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0.28*dc_width, 0.24*dc_height, extra_small_font, "Distance", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(0.3*dc_width, 0.2*dc_height, Graphics.FONT_NUMBER_MEDIUM, distance, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(units_x, 0.24*dc_height, small_font, "mi", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // draw timer
        if (hours == 0) {
            timer_primary = minutes.format("%02d") + ':' + seconds.format("%02d");
	        if ((session != null) && (session.isRecording() == false)) {
	            timer_secondary = '.' + centiseconds.format("%02d");
	        } else {
	            timer_secondary = "";
	        }
        } else {
            timer_primary = hours.format("%02d") + ':' + minutes.format("%02d");
            timer_secondary = ':' + seconds.format("%02d");
        }

        dc.drawText(0.28*dc_width, 0.51*dc_height, extra_small_font, "Timer", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(0.3*dc_width, 0.5*dc_height, Graphics.FONT_NUMBER_HOT, timer_primary, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(0.78*dc_width, 0.46*dc_height, Graphics.FONT_NUMBER_MILD, timer_secondary, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // draw speed
        speed = mph.format("%.1f");

        // set display position for units
        if (mph < 10) {
            units_x = 0.52*dc_width;
        } else {
            units_x = 0.6*dc_width;
        }

        dc.drawText(0.28*dc_width, 0.77*dc_height, extra_small_font, "Speed", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(0.3*dc_width, 0.8*dc_height, Graphics.FONT_NUMBER_MEDIUM, speed, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(units_x, 0.77*dc_height, small_font, "mph", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        drawStateArc(dc);
    }

    function compute(info) {
        if (info.elapsedDistance != null) {
            // elapsed distance in meters (m)
            distanceValue = info.elapsedDistance;
        }

        miles = distanceValue / M_PER_MI;

        if (info.timerTime != null) {
            // current timer value in milliseconds (ms)
            timerValue = info.timerTime;
        }

        hours = Math.floor(timerValue / (3600*1000));
        minutes = Math.floor((timerValue - hours*3600*1000) / (60*1000));
        seconds = Math.floor((timerValue - hours*3600*1000 - minutes*60*1000) / 1000);
        centiseconds = Math.floor((timerValue - hours*3600*1000 - minutes*60*1000 - seconds*1000) / 10);

        if (info.currentSpeed != null) {
            // current speed in meters per second (mps)
            speedValue = info.currentSpeed;
        } else {
            speedValue = 0;
        }

        mph = speedValue / M_PER_MI * 3600;
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
