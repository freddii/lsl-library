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
    {   string text="change_login_text";
        llSetText(text,<1,1,1>,1);
        llSetObjectName(text);   
    }
    
    listen(integer channel, string name, key id, string message)
    {
        llListenRemove(gListener);
        llSay (0,name+" changing login text to: "+message+".");
        integer res;
            
        res = osConsoleCommand("login text \""+message+"\"");
        if(res==FALSE)
            {
                llSay(0,"Unable to execute commnand 'login text'"); 
            }
        else
            {
                llSay(0,"Done changing login text (hopefully)");
            }
    }
   
    touch_start(integer num)
    {
        integer channel = random_integer(-1000000,1000000);
        gListener = llListen( channel, "", "", "");     
        llTextBox(llDetectedKey(0), "Type your new login text you want to use.", channel);
    }
}