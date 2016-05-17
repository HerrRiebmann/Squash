using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

class HistoryInputDelegate extends Ui.InputDelegate
{
    function onKey()
    {    	
    	Ui.popView(Ui.SLIDE_UP);
    	return false;       
    }
    
    function onTap(evt)
    {	    	
    	var coords = evt.getCoordinates();
    	System.println("X: " + coords[0] + " Y: " + coords[1]);
		//Y
		if(coords[1] >= 100 && coords[1] <= 132)
		{			
			//X			
			if(coords[0] >= 135 && coords[0] <= 205)
			{
				System.println("Reset data!");
				var app = App.getApp();
				app.clearProperties();				
				_setup.stepsTotal = 0;
				_setup.timeElapsedTotal = 0;	
				_setup.matchesTotal = 0;
				_setup.matchesWonTotal = 0;
				_setup.setsTotal = 0;
				_setup.setsWonTotal = 0;
				Ui.requestUpdate();			
				return true;
			}
		}
		return false;
	}
}

class HistoryView extends Ui.View
{
    function onUpdate(dc)
    {
    	var steps = 10;
    	var elapsed = 1234;
    
    	var stepsTotal = _setup.stepsTotal + steps;				
		var timeTotal = _setup.timeElapsedTotal + elapsed;		
		var matchesTotal = _setup.matchesTotal + game.matchListCounter;
		var matchesWonTotal = _setup.matchesWonTotal + game.GetMatchesWon("P1");
		var setsTotal = _setup.setsTotal + game.GetSetsTotal();
		var setsWonTotal = _setup.setsWonTotal + game.GetSetsWon("P1");
        	        
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        dc.clear();
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT );
				
        dc.drawText(10, 5, Gfx.FONT_MEDIUM, Ui.loadResource(Rez.Strings.history), Gfx.TEXT_JUSTIFY_LEFT);
        
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        dc.drawText(10, 15 + (1 * 15), Gfx.FONT_SMALL, Ui.loadResource(Rez.Strings.steps), Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(10, 15 + (2 * 15), Gfx.FONT_SMALL, Ui.loadResource(Rez.Strings.time), Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(10, 15 + (3 * 15), Gfx.FONT_SMALL, Ui.loadResource(Rez.Strings.match), Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(10, 15 + (4 * 15), Gfx.FONT_SMALL, Ui.loadResource(Rez.Strings.match) + " " + Ui.loadResource(Rez.Strings.won), Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(10, 15 + (5 * 15), Gfx.FONT_SMALL, Ui.loadResource(Rez.Strings.set), Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(10, 15 + (6 * 15), Gfx.FONT_SMALL, Ui.loadResource(Rez.Strings.set) + " " + Ui.loadResource(Rez.Strings.won), Gfx.TEXT_JUSTIFY_LEFT);
        
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT );
        dc.drawText(105, 15 + (1 * 15), Gfx.FONT_SMALL, stepsTotal.toString(), Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(105, 15 + (2 * 15), Gfx.FONT_SMALL, Convert.TimeToString(timeTotal), Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(105, 15 + (3 * 15), Gfx.FONT_SMALL, matchesTotal.toString(), Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(105, 15 + (4 * 15), Gfx.FONT_SMALL, matchesWonTotal.toString(), Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(105, 15 + (5 * 15), Gfx.FONT_SMALL, setsTotal.toString(), Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(105, 15 + (6 * 15), Gfx.FONT_SMALL, setsWonTotal.toString(), Gfx.TEXT_JUSTIFY_LEFT);
        
        dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_RED );
        dc.fillRectangle(150, 15 + (6 * 15), 60, 30);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        dc.drawText(160, 20 + (6 * 15), Gfx.FONT_SMALL, Ui.loadResource(Rez.Strings.reset), Gfx.TEXT_JUSTIFY_LEFT);
    }
}