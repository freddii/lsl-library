say (string status_msg)
{
        llSay (0,status_msg);
}

default
{
    state_entry()
    {   string text="shutdown_simulator";
        llSetText(text,<1,1,1>,1);
        llSetObjectName(text);   
    }
    touch_start(integer total_number) 
    {
        integer res = osConsoleCommand("shutdown");
        if(res==FALSE)
            {
                say("Unable to execute commnand 'shutdown'"); 
            }
        else
            {
                say("Done shutdown (hopefully)");
            }
    }
}