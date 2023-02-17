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
    {   string text="terrain_save";
        llSetText(text,<1,1,1>,1);
        llSetObjectName(text);   
    }
    
    listen(integer channel, string name, key id, string message)
    {
        llListenRemove(gListener);
        llSay (0,name+" started saving terrain "+message+".");
        integer res;
            
        res = osConsoleCommand("terrain save "+message);
        if(res==FALSE)
            {
                llSay(0,"Unable to execute commnand 'terrain save'"); 
            }
        else
            {
                llSay(0,"Done saving terrain (hopefully)");
            }
    }
   
    touch_start(integer num)
    {
        integer channel = random_integer(-1000000,1000000);
        gListener = llListen( channel, "", "", "");     
        llTextBox(llDetectedKey(0), "Type the destination filename for your heightmap.\n (it will be saved in your /opensim/bin folder)
        e.g.:
        myterrain.raw", channel);
    }
}
