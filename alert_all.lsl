//   - Current script may be activated by the prim owner 
//   - Requires OSSL functions treat level set to "Severe"
//file destination of the iar file to load

integer gListener;
 
integer random_integer(integer min, integer max)
{
    return min + (integer)(llFrand(max - min + 1));
}

default
{
    state_entry()
    {   string text="alert_all";
        llSetText(text,<1,1,1>,1);
        llSetObjectName(text);   
    }
    
    listen(integer channel, string name, key id, string message)
    {
        llListenRemove(gListener);
        llSay (0,name+" alerting all: "+message+".");
        integer res;
            
        res = osConsoleCommand("alert "+message);
        if(res==FALSE)
            {
                llSay(0,"Unable to execute commnand 'alert'"); 
            }
        else
            {
                llSay(0,"Done alerting all (hopefully)");
            }
    }
   
    touch_start(integer num)
    {
        integer channel = random_integer(-1000000,1000000);
        gListener = llListen( channel, "", "", "");     
        llTextBox(llDetectedKey(0), "Type the alert message you want to send.", channel);
    }
}