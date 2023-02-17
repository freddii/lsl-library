say (string status_msg)
{
        llSay (0,status_msg);
       
}

default
{
    state_entry()
    {   string text="region_restart_notice";
        llSetText(text,<1,1,1>,1);
        llSetObjectName(text);   
    }
    touch_start(integer total_number) 
    {
        integer res = osConsoleCommand("region restart notice \"the region will restart in 15 sec.\" 15");
        if(res==FALSE)
            {
                say("Unable to execute commnand 'region restart notice'"); 
            }
        else
            {
                say("Done region restart notice (hopefully)");
            }
    }
}