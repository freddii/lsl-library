default
{
    state_entry()
    {   string text="Your_IP_is";
        llSetText(text,<1,1,1>,1);
        llSetObjectName(text);   
    }
    touch_start(integer total_number)
    {
        llRegionSayTo (llDetectedKey(0),0,osGetAgentIP(llDetectedKey(0)));
    }
}