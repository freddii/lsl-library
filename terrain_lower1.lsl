//best wear the script when you use it. (Hud or in hand)
//XEngine:
//set scripting threat level to High in opensim.ini

default
    {
        state_entry()
        {   string text="terrain_lower1";
            llSetText(text,<1,1,1>,1);
            llSetObjectName(text);   
        }
        
        touch_start(integer total_number)
        {
            float high=1;
            integer test=osConsoleCommand("terrain lower "+(string)high);
            if (test==FALSE)
                {llShout(0,"terrain lower "+(string)high+ " failed.");}
            else
                {llShout(0,"terrain lower "+(string)high+" worked.");}
        }
}
