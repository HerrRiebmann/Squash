using Toybox.Application as App;
using Toybox.WatchUi as Ui;

enum
	{
	    Sets_KEY,
	    Points_KEY,
	    Gps_KEY,
	    Steps_KEY,
	    Matches_KEY,
	    MatchesWon_KEY,
	    SetsTotal_KEY,
	    SetsWon_KEY,
	    TimeElapsed_KEY	    
	}

class SquashApp extends App.AppBase
{	
    //! onStart() is called on application start up
    function onStart()
    {    	
    }

    //! onStop() is called when your application is exiting
    function onStop()
    {    	
    }

    //! Return the initial view of your application here
    function getInitialView()
    {       
    	var squashView = new SquashView();
		return [ squashView, new SquashInputDelegate(squashView) ];
    }
}