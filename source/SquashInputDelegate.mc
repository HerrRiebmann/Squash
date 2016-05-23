using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.ActivityRecording as Record;

class SquashInputDelegate extends Ui.InputDelegate
{
    var killed = false;
	hidden var _parent;		
	function initialize(parent)
	{
        self._parent = parent;
    }
			
    function onTap(evt)
    {	
    	var coords = evt.getCoordinates();    	
		//Y
		if(coords[1] >= 70 && coords[1] <= 70 + 65)
		{			
			//X
			//Player 1
			if(coords[0] >= 15 && coords[0] <= 15 + 70)
			{
				Sys.println("Player 1");
				game.SetScore("P1");
				Tapped();
				return true;				
			}
			//Player 2
			else if(coords[0] >= 125 && coords[0] <= 125 + 70)
			{
				Sys.println("Player 2");
				game.SetScore("P2");
				Tapped();
				return true;
			}
		}
		return false;
    }
        
    function onSwipe(evt)
    {
    	var dir = evt.getDirection();
    	Sys.println("onSwipe");
    	if(dir == Ui.SWIPE_LEFT)
    	{
    		game.ChangeSide();
			Tapped();
			return true;
    	}else if(dir == Ui.SWIPE_RIGHT)
    	{
    		game.ChangeSide();
			Tapped();
			return true;
    	}
    	return false;
    }
    
    function onHold(evt)
    {
    	var type = evt.getType();
    	if(type == CLICK_TYPE_HOLD)
    	{
    		Sys.println("onHold");    		
    		game.ChangeServe(game.serve);
			Tapped();
			return true;    		
		}
		return false;
    } 
        
    function onKey(evt)    
    {
    	var key = evt.getKey();		  	      
    	//Action
		if(key == Ui.KEY_ENTER)
	    {    
        	Sys.println("Start/Stop Activity");
        	ToggleRecording();
        	Tapped();
        	return true;
    	}
		//Light/Power
	    else if(key == Ui.KEY_POWER)
	    {    
        	Sys.println("Power/Light-Key");
        	Tapped();
        	return true;
    	}
    	//Back
    	else if(key == Ui.KEY_ESC)
	    {	    	   
        	Sys.println("ESC-Key: Rollback");
        	if(killed)
        	{
        		Ui.popView(SLIDE_IMMEDIATE);
        		return false;
        	}
        	if(game.ResetLastScore())
        	{
	        	Tapped();
	        	return true;
        	}
        	else
        	{
        		if(game.Recording(null))
        		{
        			return true;
        		}  		
	        	var testString = Ui.loadResource(Rez.Strings.quit);			
	        	var cd = new Ui.Confirmation( testString );
	        	Ui.pushView( cd, new QuitDelegate(self), Ui.SLIDE_UP );	        	        	
	        	return true;	        	        	        	      	
        	}        	
    	}
    	//Menu
		else if(key == Ui.KEY_MENU)
	    {   
	    	Sys.println("Menu");	   
	    	Ui.pushView(new Rez.Menus.MainMenu(), new SquashMenuDelegate(), Ui.SLIDE_UP); 	       	        	
        	return true;
    	}
    	else
    	{
    		Sys.println("Key" + key.toString());
		}
		return false;
    }
    
    function ToggleRecording()
    {    	
		if(hasRecording)
    	{
    		if(session == null)
    		{
    			//session = Record.createSession({:name=>"Squash", :sport=>Record.SPORT_TENNIS, :subSport=>Record.SUB_SPORT_MATCH});                
				session = Record.createSession({:name=>"Squash", :sport=>Record.SPORT_TENNIS});				
    		}
            if(session.isRecording())
            {   
            	session.stop();                
				game.Recording(false);                         
				Sys.println("Recording stopped");                				
            }
            else
            {            	
                session.start();
                recorded = true;                
				game.Recording(true);
				Sys.println("Recording started");
            }
        }
    }
    
    function Tapped()
    {
    	tapped = true;
    	Ui.requestUpdate();    	
    }  
    
    function QuitApp()
    {
    	Sys.println("QuitApp-Progressbar");
    	var progressBar;
    	progressBar = new Ui.ProgressBar( "Save", null );
    	Ui.popView(Ui.SLIDE_IMMEDIATE);
    	Ui.pushView( progressBar, null, Ui.SLIDE_DOWN );
		    	
    	progressBar.setDisplayString( "Game" );
    	progressBar.setProgress( 10 );
    	game.StoreGame(_parent.steps, _parent.GetTimer());
    	
    	progressBar.setDisplayString( "Properties" );
		progressBar.setProgress( 30 );    		
    	_parent.storeProperties();
    	
		progressBar.setDisplayString( "Activity" );
		progressBar.setProgress( 50 );
		Sys.println("Stored succesfully");
		//Kill Quit Dialog
		//Ui.popView(Ui.SLIDE_IMMEDIATE);
		if(recorded)
		{
			_parent.storeRecording(true);
			while(_parent.saveComplete == false)
			{
				progressBar.setProgress(null);
			}
			
    		progressBar.setDisplayString(Ui.loadResource(Rez.Strings.successDlg) );
 			progressBar.setProgress(100);
    	    Ui.popView(Ui.SLIDE_LEFT);
			return true;
			
			Sys.println("Push Confirmation");
			var testString = Ui.loadResource(Rez.Strings.save);			
	    	var cd = new Ui.Confirmation( testString );
	    	//Pop ProgressBar
	    	//Ui.popView(Ui.SLIDE_LEFT);	    	
	    	Ui.pushView(cd, new ConfDelegate(_parent), Ui.SLIDE_RIGHT );
	    	return true;
    	}
    	else
    	{    		
	    	progressBar.setDisplayString( "Completed" );
	    	progressBar.setProgress( 100 );			
			//Pop ProgressBar
			Ui.popView(Ui.SLIDE_IMMEDIATE);
		}	
		//System.exit;
		return false;	
    }
}

class ConfDelegate extends Ui.ConfirmationDelegate
{
	var progressBar;
	var progressTimer;
	var progressCloseDelayCount = 2;
	hidden var _parent;
	
	function initialize(parent)
	{		
		Sys.println("ConfDelegateInitialized");	
        _parent = parent;        
    }
    
    function onResponse(value)
    {    
    	Sys.println(value);	
        if( value == CONFIRM_YES )
        {	
    		_parent.storeRecording(true);    		       	
        }
        else
        {
        	_parent.storeRecording(false);
        }
        
        Sys.println("Confirmation Responded?!?");
        progressTimer = new Timer.Timer();
                
        //progressBar = new Ui.ProgressBar(Ui.loadResource(Rez.Strings.saveDlg), null );
        
        //Pop Kill (Confirmation) View        
        Ui.popView(Ui.SLIDE_IMMEDIATE); 
                         		 
       	//Ui.pushView( progressBar, null, Ui.SLIDE_DOWN );
		Ui.switchToView(progressBar, null, Ui.SLIDE_DOWN );
		
       	progressTimer.start( method(:timerCallback), 1000, true );
        
        //Pop Kill Parent View        
        //Ui.popView(Ui.SLIDE_IMMEDIATE);
        
        //Pop/kill one View
        return true;		
    }
    
    function timerCallback()
	{
		Sys.println("TimerCallback started");
		progressBar = new Ui.ProgressBar(Ui.loadResource(Rez.Strings.saveDlg), null );
		Ui.pushView( progressBar, null, Ui.SLIDE_DOWN );
    	if ( _parent.saveComplete == false )
    	{
    		Sys.println("Operation Not Complete");
    		progressBar.setProgress(null);
    	}
    	else 
    	{
    	    if ( progressCloseDelayCount == 2 )
    	    {
    	        Sys.println("Starting counter to show for 2 seconds");
     			progressBar.setDisplayString( Ui.loadResource(Rez.Strings.successDlg) );
     			progressBar.setProgress(100);
    	    }
    	
    			
    	   if ( progressCloseDelayCount == 0 )
    	   {
    	   		progressTimer.stop();
    	        Sys.println("Finished, stop timers and pop view");    			
    			//Kill progressBar
    			Ui.popView( Ui.SLIDE_IMMEDIATE );
    			//Pop Kill Parent View        
        		Ui.popView(Ui.SLIDE_IMMEDIATE);
        		Ui.popView(Ui.SLIDE_IMMEDIATE);					        		
    	   }    		
    	   progressCloseDelayCount--;
       }
       return true;
 	}    
}

class QuitDelegate extends Ui.ConfirmationDelegate
{	
	hidden var _parent;
	function initialize(parent)
	{	
        _parent = parent;
    }
    
    function onResponse(value)
    {
        if( value == CONFIRM_YES )
        {     
        	_parent.killed = true;
    		//if(!recorded)
    		//{
    			Ui.popView(Ui.SLIDE_IMMEDIATE);    			
    		//}
    		_parent.QuitApp();    		   		        	
        }      
        //Pop/kill one View		
        //return true;
		return recorded;        
    }
}