// Adapted from: connectiq-sdk-mac-3.1.9-2020-06-24-1cc9d3a70/samples/Picker/source/factories/NumberFactory.mc

using Toybox.Graphics;
using Toybox.WatchUi;

class NumberFactory extends WatchUi.PickerFactory {
    hidden var mStart, mStop, mIncrement, mFormatString, mFont;

    function getIndex(value) {
        var index = (value / mIncrement) - mStart;
        return index;
    }

    function initialize(start, stop, increment, options) {
        PickerFactory.initialize();

        mStart = start;
        mStop = stop;
        mIncrement = increment;

        if (options != null) {
            mFormatString = options.get(:format);
            mFont = options.get(:font);
        }

        if (mFont == null) {
            mFont = Graphics.FONT_NUMBER_HOT;
        }

        if (mFormatString == null) {
            mFormatString = "%d";
        }
    }

    function getDrawable(index, selected) {
        return new WatchUi.Text({
            :text => getValue(index).format(mFormatString),
            :color => Graphics.COLOR_WHITE,
            :font => mFont,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_CENTER
        });
    }

    function getValue(index) {
        return mStart + (index * mIncrement);
    }

    function getSize() {
        return (mStop - mStart) / mIncrement + 1;
    }
}
