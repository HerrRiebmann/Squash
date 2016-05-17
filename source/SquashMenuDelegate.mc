using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class SquashMenuDelegate extends Ui.MenuInputDelegate
{
    function onMenuItem(item)
    {
        if (item == :item_1)
        {
        	game.NewMatch();
        	tapped = true;            
        }
        else if (item == :item_2)
        {
        	game.NewSet();
        	tapped = true;            
        }
        else if (item == :item_3)
        {
        	Ui.pushView( new HistoryView(), new HistoryInputDelegate(), Ui.SLIDE_UP );
        	//Ui.switchToView( new HistoryView(), new HistoryInputDelegate(), Ui.SLIDE_UP );            
        }
        else if (item == :item_4)
        {
        	Ui.pushView(new Rez.Menus.PreferencesMenu(), new SquashPreferencesMenuDelegate(), Ui.SLIDE_UP);                        
        }
        return false;
    }
}

class SquashPreferencesMenuDelegate extends Ui.MenuInputDelegate
{
    function onMenuItem(item)
    {
        if (item == :pref_1)
        {        	
        	Ui.pushView(new Rez.Menus.PreferencesSets(), new SquashPreferencesSetsDelegate(), Ui.SLIDE_UP);            
        }
        else if (item == :pref_2)
        {
        	Ui.pushView(new Rez.Menus.PreferencesPoints(), new SquashPreferencesPointsDelegate(), Ui.SLIDE_UP);            
        }        
    }
}

class SquashPreferencesSetsDelegate extends Ui.MenuInputDelegate
{
    function onMenuItem(item)
    { 
        if (item == :sets_2)
        {
        	_setup.sets = 2;
        }
        else if (item == :sets_3)
        {	
        	_setup.sets = 3;
        }        
    }
}

class SquashPreferencesPointsDelegate extends Ui.MenuInputDelegate
{
    function onMenuItem(item)
    {
        if (item == :points_9)
        {
        	_setup.points = 9;
        }
        else if (item == :points_11)
        {	
        	_setup.points = 11;
        }  
        else if (item == :points_13)
        {	
        	_setup.points = 13;
        }        
    }
}