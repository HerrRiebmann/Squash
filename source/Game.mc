using Toybox.System as Sys;
using Toybox.Application as App;

static class game
{	
	static var isRecording = false;
	static var serve = "P1";
	static var leftPlayer = "P1";	
	static var currentMatch;	
	static var matchList;
	static var matchListCounter = 0;
				
	static function init()
	{		
		if(matchList == null)
		{
			matchList = new [10];
		}										
	    currentMatch = new match();
	    Sys.println("Match Initialized!");	    	    
	}	

	static function SetScore(player)
	{		
		//Change Side:
		if(serve.equals(player))
		{
			if(leftPlayer.equals("P1"))
			{
				leftPlayer = "P2";
			}
			else
			{
				leftPlayer = "P1";
			}					
		}
		
		//Notify?
		if(_setup.notifyScore)
		{
			SquashView.Notify(true);
		}
		
		//Set Score
		currentMatch.SetScore(player);
		//Set serve
		serve = player;
		//Set Won
		for(var i = 0; i < currentMatch.sets.size(); i += 1)
		{
			//Last open set:
			if(!currentMatch.sets[i].finished)
			{	
				if((currentMatch.sets[i].GetScore("P1") + currentMatch.sets[i].GetScore("P2")) <= 0)
				{
					ChangeServe(player);					
				}
				break;
			}
		}
				
		//Match Won
		if(currentMatch.finished)
		{	
			matchList[matchListCounter] = currentMatch;
			init();
			matchListCounter += 1;
			ChangeServe(player);	
		}
	}
	
	static function GetScore(player)
	{				
		for(var i = 0; i < currentMatch.sets.size(); i += 1)
		{
			//Last open set:
			if(!currentMatch.sets[i].finished)
			{
				return currentMatch.sets[i].GetScore(player);
			}
		}
		return 0;
	}
	
	static function GetSide(player)
	{				
		if(leftPlayer.equals(player))
		{
			return "L";
		}
		else
		{
			return "R";
		}
	}
	
	static function ResetLastScore()
	{
		if(currentMatch == null)
		{
			return;
		}
		for(var i = 0; i < currentMatch.sets.size(); i += 1)
		{
			//Last open set:
			if(!currentMatch.sets[i].finished)
			{
				if(currentMatch.sets[i].lastScoreP1 && !currentMatch.sets[i].lastScoreP2)
				{
					if(currentMatch.sets[i].scoreP1 > 0)
					{
						currentMatch.sets[i].scoreP1 -= 1;
						currentMatch.sets[i].lastScoreP1 = false;
						return true;
					}
				}
				else if(currentMatch.sets[i].lastScoreP2 && !currentMatch.sets[i].lastScoreP1)
				{
					if(currentMatch.sets[i].scoreP2 > 0)
					{
						currentMatch.sets[i].scoreP2 -=1;
						currentMatch.sets[i].lastScoreP2 = false;
						return true;
					}
				}
			}
		}
		return false;
	}
	
	static function NewSet()
	{
		for(var i = 0; i < currentMatch.sets.size(); i += 1)
		{
			//Last open set:
			if(!currentMatch.sets[i].finished)
			{
				currentMatch.sets[i].finished = true;
				break;
			}
		}
		//Match Won?
		if(currentMatch.getSetsWon("P1") >= _setup.sets || currentMatch.getSetsWon("P2") >= _setup.sets)
		{
			currentMatch.finished = true;
			matchList[matchListCounter] = currentMatch;
			init();
			matchListCounter += 1;
			ChangeServe(serve);		
		}
	}
	
	static function NewMatch()
	{
		if(!currentMatch.finished)
		{	
			currentMatch.finished = true;
			matchList[matchListCounter] = currentMatch;
			init();
			matchListCounter += 1;			
		}
	}
	
	static function GetCurrentSetsWon(player)
	{		
		return currentMatch.getSetsWon(player);
	}
	
	static function GetSetsWon(player)
	{		
		var setsTotal = currentMatch.getSetsWon(player);
		for(var i = 0; i < matchList.size(); i += 1)
		{
			if(matchList[i] != null)
			{
				setsTotal += matchList[i].getSetsWon(player);		
				
			}			
		}
		return setsTotal;		
	}
	
	static function GetSetsTotal()
	{		
		var setsTotal = 0;
		for(var i = 0; i < currentMatch.sets.size(); i += 1)
		{			
			if(currentMatch.sets[i].finished)
			{
				setsTotal += 1;
			}
		}	
				
		for(var i = 0; i < matchList.size(); i += 1)
		{
			if(matchList[i] != null && matchList[i].finished)
			{
				for(var j = 0; j < matchList[i].sets.size(); j += 1)
				{			
					if(matchList[i].sets[j].finished)
					{
						setsTotal += 1;
					}
				}		
				
			}			
		}
		return setsTotal;		
	}
	
	static function GetMatchesWon(player)
	{
		var matches = 0;
		for(var i = 0; i < matchList.size(); i += 1)
		{
			if(matchList[i] != null && matchList[i].finished)
			{		
				if(matchList[i].getSetsWon("P1") > matchList[i].getSetsWon("P2"))
				{
					if(player.equals("P1"))
					{
						matches += 1;
					}				
				}
				else
				{
					if(player.equals("P2"))
					{
						matches += 1;
					}
				}
			}			
		}
		return matches;
	}	
	
	static function ChangeServe(player)
	{
		Sys.println("Change serve");
		//Change servant
		if(serve.equals(player))
		{
			if(serve.equals("P1"))
			{
				serve = "P2";
			}
			else
			{
				serve = "P1";
			}
		}
	}
	
	static function ChangeSide()
	{
		if(leftPlayer.equals("P1"))
		{
			leftPlayer = "P2";
		}
		else
		{
			leftPlayer = "P1";
		}
	}
	
	static function Recording(rec)
	{
		if(rec == null)
		{
			return isRecording;
		}
		else
		{
			isRecording = rec;
		}
		return isRecording;
	}
	
	static function StoreGame(steps, elapsed)
	{		
		_setup.stepsTotal += steps;					
		_setup.timeElapsedTotal += elapsed;				
		_setup.matchesTotal += matchListCounter;			
		_setup.matchesWonTotal += GetMatchesWon("P1");			
		_setup.setsTotal += GetSetsTotal();			
		_setup.setsWonTotal += GetSetsWon("P1");
	}
}

class match
{		
	var sets;
	var scoreP1 = 0;
	var scoreP2 = 0;
	var finished = false;
	
	function initialize()
	{				
        //2 / 3 Sets to win. Max 3 / 5 Sets to play:
	 	sets = new [_setup.sets * 2 -1];
	 	for(var i = 0; i < sets.size(); i += 1)
		{
	    	sets[i] = new set();
		}
	}
	
	function SetScore(player)
	{		
		Sys.println("SetScore:" + player);
		for(var i = 0; i < sets.size(); i += 1)
		{
			//Last open set:
			if(!sets[i].finished)
			{
				sets[i].SetScore(player);
				//Set now is finished:
				if(sets[i].finished)
				{	
					//Finished Sets are greater then Counter 		
					if(getSetsWon("P1") >= _setup.sets || getSetsWon("P2") >= _setup.sets)
					{
						if(player.equals("P1"))
						{
							scoreP1 +=1;			
						}
						else
						{
							scoreP2 +=1;
						}
						finished = true;
						Sys.println("Match Finished");
					}
				}
				return;
			}
		}
	}
	
	function getSetsWon(player)
	{		
		var setsWon = 0; 
		for(var i = 0; i < sets.size(); i += 1)
		{
			if(sets[i].finished)
			{
				if(player.equals("P1"))
				{
					if(sets[i].scoreP1 > sets[i].scoreP2)
					{
						setsWon += 1;
					}
				}
				else
				{
					if(sets[i].scoreP2 > sets[i].scoreP1)
					{
						setsWon += 1;
					}
				}
			}
		}
		return setsWon;
	}	
}

class set
{	
	var scoreP1 = 0;
	var scoreP2 = 0;
	var lastScoreP1 = false;
	var lastScoreP2 = false;
	var finished = false;
		
	function SetScore(player)
	{
		Sys.println("SetScore Set:" + player);
		if(player.equals("P1"))
		{
			//Only count point when it´s your serve 9-Points only
			if(!(_setup.points == 9 && lastScoreP2))
			{
				scoreP1 +=1;
			}			
			lastScoreP1 = true;
			lastScoreP2 = false;			
		}
		else if(player.equals("P2"))
		{
			//Only count point when it´s opponents serve (9-Points only)
			if(!(_setup.points == 9 && lastScoreP1))
			{
				scoreP2 +=1;
			}			
			lastScoreP1 = false;
			lastScoreP2 = true;
		}
		
		Sys.println("P1: " + scoreP1);
		Sys.println("P2: " + scoreP2);
		
		if(scoreP2 >= _setup.points || scoreP1 >= _setup.points )
		{
			//2 Points difference
			if(scoreP1 + 1 < scoreP2)
			{
				finished = true;				
				Sys.println("Set Finished P1");
			}
			if(scoreP2 + 1 < scoreP1)
			{
				finished = true;								
				Sys.println("Set Finished P2");
			}
		}
	}
	function GetScore(player)
	{
		if(player.equals("P1"))
		{
			return scoreP1;
		}
		else
		{
			return scoreP2;
		}
	}	
}