//best wear the script when you use it. (Hud or in hand)

//   - Current script may be activated by the prim owner 
//   - Requires OSSL functions treat level set to "Severe"

integer gListener;
 
integer random_integer(integer min, integer max)
{
    return min + (integer)(llFrand(max - min + 1));
}

default
{
    state_entry()
    {   string text="terrain_fill";
        llSetText(text,<1,1,1>,1);
        llSetObjectName(text);   
    }
    
    listen(integer channel, string name, key id, string message)
    {
        llListenRemove(gListener);
        llSay (0,name+" started filling terrain "+message+".");
        integer res;
            
        res = osConsoleCommand("terrain fill "+message);
        if(res==FALSE)
            {
                llSay(0,"Unable to execute commnand 'terrain fill'"); 
            }
        else
            {
                llSay(0,"Done filling terrain (hopefully)");
            }
    }
   
    touch_start(integer num)
    {
        if (llGetAttached()==FALSE)
         {llSay(0,"script only working attached.put it in a prim attached to avatar or to hud.");
         return;}
        integer channel = random_integer(-1000000,1000000);
        gListener = llListen( channel, "", "", "");     
        llTextBox(llDetectedKey(0), "Type the numeric value of the height you wish to set your region to.
        e.g.:
        22", channel);
    }
}
