using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActMon;
using Toybox.Activity as Act;
using Toybox.Attention as Att;

var hasElapsed;
var hasSteps;
var hasRecording;
var hasVibrate;
var hasTone;
var _setup;
var session = null;
var tapped = true;
var recorded = false;

class SquashView extends Ui.View
{
	var timer;
	var callbackTime = 1000;//1 Sec
	var ticks = 60;

	var _matchLang;
	var _setLang;
	var _stepsLang;
	var _pulseLang;
	var _serveLang;
	var _tieBreakLang;	
		
	var string_HR = "---";
	var startSteps = 0;
	var steps = 0;
	var time = "00:00:00";	
	
	var saveComplete = false;
				
	//! Constructor
    function initialize()
    {
    	_setup = new Setup();
    	timer = new Timer.Timer();
        timer.start(method(:onTimer), callbackTime, true);
        Snsr.setEnabledSensors( [Snsr.SENSOR_HEARTRATE] );
        Snsr.enableSensorEvents( method(:onSnsr));
        game.init();
    }
		
    //! Load your resources here
    function onLayout(dc)
    {
    	readProperties();    	
        setLayout(Rez.Layouts.MainLayout(dc));
        _matchLang = Ui.loadResource(Rez.Strings.match);
        _setLang = Ui.loadResource(Rez.Strings.set);
		_stepsLang = Ui.loadResource(Rez.Strings.steps);
		_pulseLang = Ui.loadResource(Rez.Strings.pulse);
		_serveLang = Ui.loadResource(Rez.Strings.serve);
		_tieBreakLang = Ui.loadResource(Rez.Strings.tieBreak);
		setLanguage();
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow()
    {
    
    }

    //! Update the view
    function onUpdate(dc)
    {   
    	//Update on every Score (User Tapped Screen) 
		if(tapped)
		{	
    		setScores();
    		setServe();
		}
    	//Every Second when recording
		if(game.isRecording)
		{
    		setAvtivity();
    	}
    	
    	//Every Minute...
		ticks += 1;
		if(ticks >= 60)
		{
    		setTime();
    		ticks = 0;
    	}
    	
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        getRecStatus(dc);        
        tapped = false;
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide()
    {
    	storeProperties();
    }
    
    function onTimer()
    {
    	if(game.isRecording)
    	{
    		RecordingInfo();
    	}
        //Kick the display update
        Ui.requestUpdate();
    }
    
    function onSnsr(sensor_info)
    {
        var HR = sensor_info.heartRate;        
        if(sensor_info.heartRate != null)
        {
            string_HR = HR.toString();
        }
        else
        {
            string_HR = "---";
        }        
    }
    
    function setLanguage()
    {
    	var view = View.findDrawableById("lblMatch");
        view.setText(_matchLang);
        view = View.findDrawableById("lblSet");
        view.setText(_setLang);
        view = View.findDrawableById("lblSetP1");
        view.setText(_setLang);
        view = View.findDrawableById("lblSetP2");
        view.setText(_setLang);        
        view = View.findDrawableById("lblSteps");
        view.setText(_stepsLang);
        view = View.findDrawableById("lblPulse");
        view.setText(_pulseLang);
        view = View.findDrawableById("Serve");
    	view.setText(_serveLang);                
    }
    
    function setTime()
    {
    	var clockTime = Sys.getClockTime();
        var hour;
        var min;
        
        if(clockTime.hour <= 9)
        {
        	hour = "0" + clockTime.hour.toString();
    	}
    	else
    	{
    		hour = clockTime.hour.toString();
    	} 
        if(clockTime.min <= 9)
        {
        	min = "0" + clockTime.min.toString();
    	}
    	else
    	{
    		min = clockTime.min.toString();
    	}
        var view = View.findDrawableById("time");
        view.setText(hour + ":" + min);
    }
    
    function setScores(dc)
    {    	
    	var view = View.findDrawableById("SetP1");
        view.setText(game.GetCurrentSetsWon("P1").toString());
        view = View.findDrawableById("SetP2");
        view.setText(game.GetCurrentSetsWon("P2").toString());
        view = View.findDrawableById("ScoreP1");
        view.setText(game.GetScore("P1").toString());
        view = View.findDrawableById("ScoreP2");
        view.setText(game.GetScore("P2").toString());  
        view = View.findDrawableById("match");
        view.setText(game.GetMatchesWon("P1").toString() + "/" + game.matchListCounter.toString());
        view = View.findDrawableById("set");
        view.setText(game.GetCurrentSetsWon("P1").toString() + "/" + _setup.sets.toString());
    }
    
    function setAvtivity(dc)
    { 
    	var view = View.findDrawableById("steps");
        view.setText(steps.toString());
        view = View.findDrawableById("pulse");
        view.setText(string_HR);        
        view = View.findDrawableById("stopwatch");
        view.setText(time);
    }
    
    function setServe()
    {
    	var serveLocation;
		if(game.serve.equals("P1"))
		{
			serveLocation = 25;
		}
		else
		{
			serveLocation = 130;
		}
		var view = View.findDrawableById("Serve");
    	view.setLocation(serveLocation, 130);
    	    
	    view = View.findDrawableById("TieBreak");   
        if(game.GetScore("P1") + game.GetScore("P2") >= _setup.points * 2)
        {	        
	    	view.setText(_tieBreakLang);
        }
        else
        {
        	view.setText("");
        }
        
        view = View.findDrawableById("SideP1");
        view.setText(game.GetSide("P1"));
        view = View.findDrawableById("SideP2");
        view.setText(game.GetSide("P2"));
    }
    
    function getRecStatus(dc)
    {
    	if(hasRecording == null)
    	{
    		hasRecording = Toybox has :ActivityRecording;    		
    	}    		
        
        if(game.Recording(null))
        {
        	dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_RED);            	                    		
        }
        else
        {
         	dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        }   
        dc.fillCircle(12, 10, 4);        
    }
    
    function RecordingInfo()
    {
    	if(hasSteps == null)
    	{
    		if(ActMon has :getInfo)
			{
				var Info = ActMon.getInfo();
				hasSteps = Info has :steps;				
			}
			else
			{
				hasSteps = false;
			}
    	}
    	if(hasElapsed == null)
    	{
    		if(Act has :getActivityInfo)
			{
				var activityInfo = Act.getActivityInfo();
				hasElapsed = activityInfo has :elapsedTime;				
			}
			else
			{
				hasElapsed = false;
			}
    	}
    	if(game.isRecording)
		{
	    	if(hasSteps)
			{
				var Info = ActMon.getInfo();				
				if(startSteps == 0)
				{
			    	startSteps = Info.steps;			    	
				}
				else
				{
					steps = Info.steps - startSteps;
				}													
			}
		
			if(hasElapsed)
			{
				var activityInfo = Act.getActivityInfo();
				var elapsed = activityInfo.elapsedTime;
				time = Convert.TimeToString(elapsed);
				if(_setup.notifyMinutes > 0)
				{					
					if(elapsed == null || elapsed <= 1000)
					{						
						elapsed /= 1000;					
						if((elapsed/60%60) == _setup.notifyMinutes)
						{
							SquashView.Notify(false);
							_setup.notifyMinutes = 0;
						}
					}					
				}						               									
			}			
    	}
    }
    
    function GetTimer()
    {
    	if(hasElapsed)
		{
			var activityInfo = Act.getActivityInfo();					
			var elapseSec = activityInfo.elapsedTime;				
			if(elapseSec != null)
			{
				return elapseSec; 
			}
		}
		return 0;
    }
    
    function readProperties()
    {
    	var app = App.getApp();
    	//app.clearProperties();
    	_setup.sets = app.getProperty(Sets_KEY);
        _setup.points = app.getProperty(Points_KEY);
        _setup.gps = app.getProperty(Gps_KEY);

		_setup.stepsTotal = app.getProperty(Steps_KEY);
		_setup.timeElapsedTotal = app.getProperty(TimeElapsed_KEY);
				
		_setup.matchesTotal = app.getProperty(Matches_KEY);
		_setup.matchesWonTotal = app.getProperty(MatchesWon_KEY); 
		_setup.setsTotal = app.getProperty(SetsTotal_KEY);
		_setup.setsWonTotal = app.getProperty(SetsWon_KEY);
		
        if(_setup.sets == null)
        {
            _setup.sets = 3;                        
        }		
		
        if(_setup.points == null)
        {
            _setup.points = 11;
        }

        if(_setup.gps == null)
        {
            _setup.gps = false;
        }
        if(_setup.stepsTotal == null)
        {
        	_setup.stepsTotal = 0;
        }
        if(_setup.timeElapsedTotal == null)
        {
        	_setup.timeElapsedTotal = 0;
        }        
        if(_setup.matchesTotal == null)
        {
        	_setup.matchesTotal = 0;
        }
        if(_setup.matchesWonTotal == null)
        {
        	_setup.matchesWonTotal = 0;
        }
        if(_setup.setsTotal == null)
        {
        	_setup.setsTotal = 0;
        }
        if(_setup.setsWonTotal == null)
        {
        	_setup.setsWonTotal = 0;
        }
        Sys.println("Sets: " + _setup.sets + " Points: " + _setup.points);
    }
    
    function storeProperties()
    {    	   
    	var app = App.getApp();
    	app.setProperty(Sets_KEY, _setup.sets);
        app.setProperty(Points_KEY, _setup.points);
        app.setProperty(Gps_KEY, _setup.gps);
                        
        app.setProperty(Steps_KEY, _setup.stepsTotal);        
        app.setProperty(Matches_KEY, _setup.matchesTotal);
        app.setProperty(MatchesWon_KEY, _setup.matchesWonTotal);
        app.setProperty(SetsTotal_KEY, _setup.setsTotal);
        app.setProperty(SetsWon_KEY, _setup.setsWonTotal);
        app.setProperty(TimeElapsed_KEY, _setup.timeElapsedTotal);	                    	    
	}
	
	function storeRecording(save)
	{		
        if(hasRecording)
    	{	
            if(session != null)
            {
            	if(session.isRecording())
            	{
                	session.stop();
            	}
            	if(save)
            	{
                	session.save();
                	Sys.println("Session saved!");
            	}
            	else
            	{
            		session.discard();            		
            	}
            }         
    	}
    	Sys.println("Store Recording: " + save);    	
		saveComplete = true;    	
	}
	
	static function Notify(short)
	{	
		if(hasTone == null)
		{
			hasTone = Att has :playTone;
		}
		if(hasVibrate == null)
		{
			hasVibrate = Att has :vibrate;
		}
		if(hasTone)
	    {
	    	if(short)
	    	{
	    		Att.playTone(Att.TONE_KEY);
	    	}
	    	else
	    	{
    	    	Att.playTone(Att.TONE_TIME_ALERT);
	    	}
    	}
	    if(hasVibrate)
	    {
	    	var vibrateData;
	    	if(short)
	    	{
	    		vibrateData = [new Att.VibeProfile( 50, 100 )];	    		
            }
	    	else
	    	{	    		
    	    	vibrateData = [new Att.VibeProfile(  25, 100 ),                                     
                    new Att.VibeProfile( 100, 100 ),                    
                    new Att.VibeProfile(  25, 100 )];
	    	}               	    
    	    Att.vibrate(vibrateData);    	    
    	}
	}   
}