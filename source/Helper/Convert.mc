static class Convert
{
	static function TimeToString(elapsedSeconds)
	{		
		var time;				
		if(elapsedSeconds == null || elapsedSeconds <= 0)
		{	
			return "00:00:00";
		}
		elapsedSeconds /= 1000;
        var hr = elapsedSeconds/3600;
        if(hr <= 9)
        {
        	time = "0" + hr.toString();
        }
        else
       	{
       		time = hr.toString();
       	}
        var min = elapsedSeconds/60%60;
        if(min <= 9)
        {
        	time += ":0" + min.toString();
        }
        else
       	{
       		time += ":" + min.toString();
       	}
        var sec = elapsedSeconds%60;
        if(sec <= 9)
        {
        	time += ":0" + sec.toString();
        }
        else
       	{
       		time += ":" + sec.toString();
       	}
       	return time;
	}
}