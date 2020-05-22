using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Sensor;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;

class OnAGlimpseView extends WatchUi.WatchFace {

	var timeLabelView, batteryLabelView, hrLabelView, woyLabelView, dateLabelView, stepsLabelView, floorsLabelView, messagesLabelView, view10;
	hidden var bluetoothView;
	var cX, cY;
	var heartRate;
	var lastHeartRate;
	var lastMessageCount;
	//var test;

    function initialize() {
        WatchFace.initialize(); 
        bluetoothView = WatchUi.loadResource(Rez.Drawables.bluetooth);
        //test = "";
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        timeLabelView = View.findDrawableById("TimeLabel");
        batteryLabelView = View.findDrawableById("BatteryLabel");
        hrLabelView = View.findDrawableById("HrLabel");
        woyLabelView = View.findDrawableById("WeekofYearLabel");
        dateLabelView = View.findDrawableById("DateLabel");
        stepsLabelView = View.findDrawableById("StepsLabel");
        floorsLabelView = View.findDrawableById("FloorsLabel");
        messagesLabelView = View.findDrawableById("MessagesLabel");
        //view10 = View.findDrawableById("TestLabel");
        cX = dc.getWidth() / 2;
        cY = dc.getHeight() / 2;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {  	
    }
    
    // Not used at the moment due to the onExitSleep()-Bug on the VA4
    /*function onPartialUpdate(dc) { 
    	var hr = getHeartRate();
    	if (lastHeartRate != hr) {	
	    	setClipBoundaries (hrLabelView, dc);
	    	hrLabelView.setText(formatHeartRate(hr));
	    	hrLabelView.draw(dc);
	    	//System.println (lastHeartRate + " " + hr);
	    	lastHeartRate = hr;
	   }
	   var messages = getMessageCount();
	   if (lastMessageCount != messages) {   		
	   		setClipBoundaries (messagesLabelView, dc);
	    	var messagesString = Lang.format ("$1$", [messages]); 
        	messagesLabelView.setText(messagesString);
        	messagesLabelView.draw(dc);
        	//System.println ("messages: " + messagesString);
        	lastMessageCount = messages;
	   }
    }*/
    
    function setClipBoundaries (timeLabelView, dc) {
    	var labelX = timeLabelView.locX - timeLabelView.width/2;
    	var labelY = timeLabelView.locY;
    	var labelW = timeLabelView.width;
    	var labelH = timeLabelView.height;   		
   		dc.setClip(labelX-4, labelY, labelW+8, labelH);
    	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    	dc.fillRectangle(labelX-4, labelY, labelW+8, labelH);
    }

    // Update the timeLabelView
    function onUpdate(dc) {
    	dc.clearClip();
    
        // Get and show the current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        timeLabelView.setText(timeString);
        
        // Battery
        var battery = System.getSystemStats().battery;
        var batteryString = Lang.format ("$1$%", [battery.format("%i")]);
        batteryLabelView.setText(batteryString);
        
        // Heartrate
        var hr = getHeartRate();
        if (lastHeartRate != hr) {
        	//System.println ("Main: " + lastHeartRate + " " + hr);   	
        	hrLabelView.setText(formatHeartRate(hr));
        	lastHeartRate = hr;
        }
        
        // Week of year
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateString = Lang.format ("KW $1$", [iso_week_number(today.year, today.month, today.day).format("%02d")]);
        woyLabelView.setText(dateString);
        
        // Date
        dateString = Lang.format ("$1$.$2$.$3$", [today.day.format("%02d"), today.month.format("%02d"), today.year]);
        dateLabelView.setText(dateString);
        
        // Steps
		var info = ActivityMonitor.getInfo();
		var steps = info.steps;
		var stepsString = Lang.format ("$1$", [steps.format("%05d")]);
        stepsLabelView.setText(stepsString);
        
        // Floors
        var floors = info.floorsClimbed;
		var floorsString = Lang.format ("$1$", [floors.format("%02d")]);
        floorsLabelView.setText(floorsString);
        
        // Messages 
        var messages = getMessageCount ();
        if (lastMessageCount != messages) {
			var messagesString = Lang.format ("$1$", [messages]); 
	        messagesLabelView.setText(messagesString);
	        lastMessageCount = messages;
	    }
        
       	// Test
		//var testString = Lang.format ("$1$", [test]);
        //view10.setText(testString);
        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        // Bluetooth
        if (isPhoneConnected()) {
        	dc.drawBitmap(cX-12, 45, bluetoothView);
        } 
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    	//test = "Exit";
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    	lastHeartRate = getHeartRate ();
    	lastMessageCount = getMessageCount ();
    	//test = "Sleep";
    }
    
    function getHeartRate () {
        heartRate = Activity.getActivityInfo().currentHeartRate;
        return heartRate;         
	}
	
	function isPhoneConnected () {
		var mySettings = System.getDeviceSettings();
        return mySettings.phoneConnected;
	}
	
	function getMessageCount () {
		 var mySettings = System.getDeviceSettings();
		 return mySettings.notificationCount;
	}
	
	function formatHeartRate (hr) {
		var hrString = "---"; 
        if (hr != null) {
	        hrString = Lang.format ("$1$", [hr]);
	    }
	    return hrString;
	}
    
    // thanks to travis.vitek @ https://forums.garmin.com/developer/connect-iq/f/discussion/2778/week-of-year
    function julian_day(year, month, day)
	{
		var a = (14 - month) / 12;
		var y = (year + 4800 - a);
		var m = (month + 12 * a - 3);
		return day + ((153 * m + 2) / 5) + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32045;
	}

	function is_leap_year(year)
	{
		if (year % 4 != 0) {
			return false;
		}
		else if (year % 100 != 0) {
			return true;
		}
		else if (year % 400 == 0) {
			return true;
		}
		return false;
	}

	function iso_week_number(year, month, day)
	{
		var first_day_of_year = julian_day(year, 1, 1);
		var given_day_of_year = julian_day(year, month, day);
		
		var day_of_week = (first_day_of_year + 3) % 7; // days past thursday
		var week_of_year = (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
		
		// week is at end of this year or the beginning of next year
		if (week_of_year == 53) 
		{	
			if (day_of_week == 6) {
				return week_of_year;
			}
			else if (day_of_week == 5 && is_leap_year(year)) {
				return week_of_year;
			}
			else {
				return 1;
			}
		}	
		else if (week_of_year == 0) { // week is in previous year, try again under that year
			first_day_of_year = julian_day(year - 1, 1, 1);
			day_of_week = (first_day_of_year + 3) % 7;
			return (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
		}	
		else { // any old week of the year
			return week_of_year;
		}
	}	
}