//Link two boxes then put the script inside.

//By Chaser.Zaks.
//Feel free to redistribute and use in projects(even in sold products, just keep it open source).
//DO NOT CLOSE SOURCE OR SELL ALONE.

//Configuration:
integer MeasureNonParcelPrims=FALSE;
//Variables, these are dynamically set, don't bother with them.
string region;
string sim;
vector color;
integer avatars;
integer lastrestart;
integer days;
integer hours;
integer minutes;
integer seconds;
integer lastrestartedcalc;
list same_params=[PRIM_SLICE, <0.5, 1., 0.0>,PRIM_FULLBRIGHT,ALL_SIDES,TRUE,PRIM_TEXTURE,ALL_SIDES,TEXTURE_BLANK,ZERO_VECTOR,ZERO_VECTOR,0];
integer timercnt=0;
list ltimertime=[0.5,2,5];

default
{
    state_entry()
    {
        llSetObjectName("Lag Meter v12.4_os_betabad");
        llSetLinkPrimitiveParams(1,same_params+[PRIM_COLOR,ALL_SIDES,<0,0,0>,.4,PRIM_SIZE,<.5,.5,4>]);
        llSetLinkPrimitiveParams(2,same_params+[PRIM_COLOR,ALL_SIDES,<0,1,0>,1.,PRIM_SIZE,<.4,.4,3.8>,PRIM_POS_LOCAL,<0,0,.04>,PRIM_GLOW,ALL_SIDES,0.1]);
        llSetText("Initalizing...",<1,1,0>, 1.0);
        //First start, Set some stuff.
        lastrestart = llGetUnixTime();
        llSetTimerEvent(llList2Float(ltimertime,timercnt)); //One second is too much checking. Let's not be a resource hog.
    }
    
    on_rez(integer start_param) {
        llSetPos(llGetPos()+<0,0,-2.>);
    }
    
    changed(integer change)
    {
        if(change & CHANGED_REGION_START)
            lastrestart = llGetUnixTime();
    }
    
     touch_start(integer num_detected)
    {
        key    avatarKey  = llDetectedKey(0);
        if (avatarKey==llGetOwner())
        {
            timercnt++;
            if(timercnt>(llGetListLength(ltimertime)-1))
            {timercnt=-1;
            llSetTimerEvent(0);
            llSetLinkColor(2,<0.5,0.5,0.5>,ALL_SIDES);
            llSetText("deactivated.\nTouch to activate.",<1,0.5,0>, 1.0);}
            else
            {
                llSetLinkColor(2,<0,1,0>,ALL_SIDES);
                llSetTimerEvent(llList2Float(ltimertime,timercnt));
                llSay(0,"updating every "+(string)llList2Float(ltimertime,timercnt)+" seconds.");}
            
            }
    }
    
    timer(){
        region = llGetRegionName();
        avatars = llGetListLength(llGetAgentList(AGENT_LIST_REGION, []));
        //Restart time
            lastrestartedcalc = llGetUnixTime()-(integer)llGetEnv("region_start_time");//-lastrestart;
            days=0;
            hours=0;
            minutes=0;
            seconds=0;
            do{
                if(lastrestartedcalc>=86399){
                    days++;
                    lastrestartedcalc=lastrestartedcalc-86399;
                }else if(lastrestartedcalc>=3599){
                    hours++;
                    lastrestartedcalc=lastrestartedcalc-3599;
                }else if(lastrestartedcalc>=59){
                    minutes++;
                    lastrestartedcalc=lastrestartedcalc-59;
                }else{
                    seconds++;
                    lastrestartedcalc--;
                }
            }while(lastrestartedcalc>=0);
            float region_time_dilation=llGetRegionTimeDilation();
        if(region_time_dilation>=0.75)
            color=<0,1,0>;
        else if(region_time_dilation>=0.50)
            color=<1,1,0>;
        else 
            color=<1,0,0>;
        integer primsused=llGetParcelPrimCount(llGetPos(), PARCEL_COUNT_TOTAL, MeasureNonParcelPrims);
        integer maxprims=llGetParcelMaxPrims(llGetPos(), MeasureNonParcelPrims);
        string  sim_version=llGetEnv("sim_version");
        list lsim_version=llParseString2List(sim_version,[" "],[]);
        string sim_version_clean=llList2String(lsim_version,1)+" "+llList2String(lsim_version,12);//llDumpList2String(lsim_version,","); llList2String(lsim_version,0)+" "+
        llSetText(
        "Region: "+region+
        //"\nSimChan: "+llGetEnv("sim_channel")+
        "\nSimHostn: "+llGetEnv("simulator_hostname")+
        "\nSimVrsn: "+sim_version_clean+
        "\nPhysics: "+osGetPhysicsEngineName()+
//        "\nProdn: "+llGetEnv("region_product_name")+
        "\nAvatars: "+(string)avatars+"/"+llGetEnv("agent_limit")+
        "\nPrims left: "+(string)(maxprims-primsused)+" ("+(string)primsused+"/"+(string)maxprims+")"+
        "\nTemp on rez: "+(string)llGetParcelPrimCount(llGetPos(),PARCEL_COUNT_TEMP, FALSE)+
        "\nDilation: "+llGetSubString((string)((1.-region_time_dilation)*100.), 0, 3)+"%"+
        "\nFPS: "+llGetSubString((string)llGetRegionFPS(), 0, 5)+
        "\nLast restart:\n"+(string)days+" days, "+(string)hours+" hrs, "+(string)minutes+" min, and "+(string)seconds+" sec ago.",
        //"\nLast restart:\n"+(string)days+":"+(string)hours+":"+(string)minutes+":"+(string)seconds,
        color, 1.0);
        //llSetLinkPrimitiveParamsFast(2,[PRIM_SLICE,<0,(region_time_dilation),0>,PRIM_COLOR,ALL_SIDES,color,1]);
        llSetLinkPrimitiveParamsFast(2,[PRIM_SLICE, <0.5, 1., 0.0>,PRIM_SIZE,<0.4, 0.4, 3.80*region_time_dilation>,PRIM_COLOR,ALL_SIDES,color,1]);
    }
}