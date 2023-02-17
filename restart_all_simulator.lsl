say (string status_msg)
{
        llSay (0,status_msg);
       
}

default
{
    state_entry()
    {   string text="restart_all_simulator";
        llSetText(text,<1,1,1>,1);
        llSetObjectName(text);   
    }
    touch_start(integer total_number) 
    {
        integer res = osConsoleCommand("restart");
        if(res==FALSE)
            {
                say("Unable to execute commnand 'restart'"); 
            }
        else
            {
                say("Done restart (hopefully)");
            }
    }
}