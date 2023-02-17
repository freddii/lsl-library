//best wear the script when you use it. (Hud or in hand)

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
    {   string text="load_inworld_oar";
        llSetText(text,<1,1,1>,1);
        llSetObjectName(text);   
    }
    
    listen(integer channel, string name, key id, string message)
    {
        llListenRemove(gListener);
        llSay (0,name+" started loading oar "+message+".");
        integer res;
            
        res = osConsoleCommand("load oar "+message);
        if(res==FALSE)
            {
                llSay(0,"Unable to execute commnand 'load oar'"); 
            }
        else
            {
                llSay(0,"Done loading oar (hopefully)");
            }
    }
   
    touch_start(integer num)
    {
        if (llGetAttached()==FALSE)
         {llSay(0,"script only working attached.put it in a prim attached to avatar or to hud.");
         return;}
        integer channel = random_integer(-1000000,1000000);
        gListener = llListen( channel, "", "", "");     
        llTextBox(llDetectedKey(0), "Type the link to an oar file.
        e.g.:
        http://raw.githubusercontent.com/freddii/blank_oar/master/blank.oar", channel);
    }
}
