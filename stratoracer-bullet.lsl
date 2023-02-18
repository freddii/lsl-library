//Arcadia's Stratoracer, this is a modification by Aaack Aardvark from Littlefield Grid of the OSGrid Scooter v1.0.
//Old credits as follows:

//*************************************************
//Final code and animations and sounds by Christy Lock OSGRID 4/23/2014
//Maegan OMally standalone alt may be listed also

//Special Thanks to Robert Adams and all those who worked on BulletSim!
//BulletSim Required for this to work
//Thanks to Cory and ANdrew Linden as their work and instructions contributed to this code

//EVERYTHING in the scooter is opensource free to use as you like
//*************************************************

key agent;

//key sittingAlready;//this is needed to stop the passenger from shuting down the scooter in the changed event
// Nope, this doesn't work, so instead I check if someone's sitting on the passenger sit (llAvatarOnLinkSitTarget) and if the engine is running
integer level; //this is to make the dialog come back unless you explicitly close it
key passenger;
integer engine = FALSE; //A third verification for if the passenger stands while driving
integer handle;
integer fono; //the dialog channel number, it uses the root UUID to generate an unique channel per object.
integer tflag = FALSE; //False uses to timeout the dialog, True uses to timeout the autoclosing of the car.

float forward_power = 35.0; //Power used to go forward 
float reverse_power = -25.0; //Power ued to go reverse
float turn_rate = 15.0;//rotation (twist) around angular.z 

string sit_message = "Board"; //Sit message

vector linear;
vector angular;

float xfactor = 28.0;//Normal velocity all three axis
float yfactor = 8.0;
float zfactor = 20.0;

dialog(key user)  //Improved dialog with more options
{
    handle = llListen(fono,"",user,"");
    llDialog(user,"Options",["Canopy Open", "Canopy Close", "Dismiss", "Lights ON", "Lights OFF", "-", "Fast","Normal", "Slow"],fono);
}
camfixed()
{
    //actual camera used....Camera_Position_Lag should be 0.0  0.1 makes the cam bump a little
    //and look like the physics engine is on off on off - same for Camera_behindness_lag        
    llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 10.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.3, // (0 to 3) seconds
        CAMERA_DISTANCE, 15.0, // ( 0.5 to 10) meters
        //CAMERA_FOCUS, <0,0,5>, // region relative position
        CAMERA_FOCUS_LAG, 0.1 , // (0 to 3) seconds
        CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_PITCH, 35.0, // (-45 to 80) degrees
        //CAMERA_POSITION, <0,0,0>, // region relative position
        CAMERA_POSITION_LAG, 0.1, // (0 to 3) seconds
        CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_POSITION_THRESHOLD, 1.0, // (0 to 4) meters
        CAMERA_FOCUS_OFFSET, <0.0,0.0,0.0> // <-10,-10,-10> to <10,10,10> meters        
    ]);    
}

init()
{
        llPreloadSound("Arcadia's Stratoracer Start"); 
        llPreloadSound("Arcadia's Stratoracer Loop");   
        llPreloadSound("Arcadia's Stratoracer End");    
        llSetVehicleType(VEHICLE_TYPE_AIRPLANE);    
        llRemoveVehicleFlags
        (
            VEHICLE_FLAG_NO_DEFLECTION_UP |
            VEHICLE_FLAG_HOVER_WATER_ONLY |
            VEHICLE_FLAG_HOVER_TERRAIN_ONLY |
            VEHICLE_FLAG_HOVER_UP_ONLY |
            VEHICLE_FLAG_LIMIT_MOTOR_UP |
            VEHICLE_FLAG_LIMIT_ROLL_ONLY
        );
        rotation rot =llEuler2Rot(<0, 0, 0>);
        // linear friction
        llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <100.0, 100.0, 100.0>);
        // uniform angular friction
        llSetVehicleFloatParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, 1.0);
        // linear motor
        llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <0.0, 0.0, 0.0>);
        llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, 1.0);
        llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 1.0);
        // angular motor
        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <0.0, 0.0, 0.0>);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 1.0);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 5.0);
        // hover
        llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, 0.0);
        llSetVehicleFloatParam(VEHICLE_HOVER_EFFICIENCY, 0.0);
        llSetVehicleFloatParam(VEHICLE_HOVER_TIMESCALE, 360.0);
        llSetVehicleFloatParam(VEHICLE_BUOYANCY, 0);
        // linear deflection
        llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0.5);
        llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 10.0);
        // angular deflection
        llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0.25);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 100.0);
        // vertical attractor
        llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.4);
        llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 5.0);
        // banking
        llSetVehicleFloatParam(VEHICLE_BANKING_EFFICIENCY, 1.0);
        llSetVehicleFloatParam(VEHICLE_BANKING_MIX, 1.0);
        llSetVehicleFloatParam(VEHICLE_BANKING_TIMESCALE, 100.0);
        // default rotation of local frame
        llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME, <0.0, 0.0, 0.0, 1.0>);
        llSetVehicleFlags
        (
            VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT
        );
        
        //** 1.0 floats and turn on physics **
        llSetVehicleFloatParam(VEHICLE_BUOYANCY, 0.0);//0.9    
        llSetStatus(STATUS_PHYSICS, TRUE);
   
}

release_camera_control()
{
    llSetCameraParams([CAMERA_ACTIVE, 0]); // 1 is active, 0 is inactive  
}

default
{
    state_entry()
    {
        fono = (integer)("0x" + llGetSubString((string)llGetKey(),-1,-8));
        llSetSitText(sit_message);
        llSitTarget(<0.097514,0.007036,-0.476859>, <0.001863,0.079794,-0.000128,-0.996810>);
        llSetStatus(STATUS_PHYSICS, FALSE);
        llStopSound();
    }
    touch_start(integer touched)
    {
        agent = llAvatarOnSitTarget();
        key avatar = llDetectedKey(0);
        if (avatar == agent || engine == FALSE) //if the hover is empty or if the engine is off show the dialog to whoever clicks on it  otherwise it will respond only to the pilot
        {
            dialog(avatar);
        }
    } 
    listen(integer chan,string name,key id , string msg)
    {
        if (level == 0)
        {
            if ( msg == "Fast")
            {
                tflag = FALSE;
                llSetTimerEvent(45);
                llSay( 0, "Fast speed");
                turn_rate = 20;
                xfactor = 60.0;
                yfactor = 15.0;
                zfactor = 30.0;
                dialog(id);
            }
            if ( msg == "Normal")
            {
                tflag = FALSE;
                llSetTimerEvent(45);
                llSay( 0, "Normal speed");
                turn_rate = 15.0;
                xfactor = 28.0;
                yfactor = 8.0;
                zfactor = 12.0;
                dialog(id);
            }
            else if ( msg == "Slow")
            {
                tflag = FALSE;
                llSetTimerEvent(45);
                llSay( 0, "Slow speed");
                turn_rate = 10;
                xfactor = 10.0;
                yfactor = 4.0;
                zfactor = 8.0;
                dialog(id);
            }
            else if ( msg == "Lights ON")
            {
                tflag = FALSE;
                llSetTimerEvent(45);
                llSetLinkPrimitiveParams
                    (LINK_ALL_OTHERS, [
                        PRIM_LINK_TARGET, 6,
                        PRIM_FULLBRIGHT, 5, TRUE,
                        PRIM_GLOW, 5, 0.7,
                        PRIM_LINK_TARGET, 4,
                        PRIM_ROT_LOCAL, llEuler2Rot(<0, 270, 270> * DEG_TO_RAD),
                        PRIM_POINT_LIGHT, TRUE, <1.000, 0.910, 0.506>, 1.0, 10.0, 0.75,
                        PRIM_FULLBRIGHT, 2, TRUE,
                        PRIM_GLOW, 2, 0.05,
                        PRIM_LINK_TARGET, 5,
                        PRIM_ROT_LOCAL, llEuler2Rot(<0, 270, 270> * DEG_TO_RAD),
                        PRIM_POINT_LIGHT, TRUE, <1.000, 0.910, 0.506>, 1.0, 10.0, 0.75,
                        PRIM_FULLBRIGHT, 2, TRUE,
                        PRIM_GLOW, 2, 0.05
                    ]);
                dialog(id);
            }
            else if ( msg == "Lights OFF")
            {
                tflag = FALSE;
                llSetTimerEvent(45);
                llSetLinkPrimitiveParams
                    (LINK_ALL_OTHERS, [
                        PRIM_LINK_TARGET, 6,
                        PRIM_FULLBRIGHT, 5, FALSE,
                        PRIM_GLOW, 5, 0.0,
                        PRIM_LINK_TARGET, 4,
                        PRIM_ROT_LOCAL, llEuler2Rot(<0, 90, 90> * DEG_TO_RAD),
                        PRIM_POINT_LIGHT, FALSE, <1.000, 0.910, 0.506>, 1.0, 10.0, 0.75,
                        PRIM_FULLBRIGHT, 2, FALSE,
                        PRIM_GLOW, 2, 0.0,
                        PRIM_LINK_TARGET, 5,
                        PRIM_ROT_LOCAL, llEuler2Rot(<0, 90, 90> * DEG_TO_RAD),
                        PRIM_POINT_LIGHT, FALSE, <1.000, 0.910, 0.506>, 1.0, 10.0, 0.75,
                        PRIM_FULLBRIGHT, 2, FALSE,
                        PRIM_GLOW, 2, 0.0
                    ]);
                dialog(id);
            }
            else if ( msg == "Canopy Open" )
            {
                tflag = FALSE;
                llSetTimerEvent(45);
                 llSetLinkPrimitiveParams
                    (LINK_ALL_OTHERS, [
                        PRIM_LINK_TARGET, 3,
                        PRIM_ROT_LOCAL, llEuler2Rot(<0, 292, 90> * DEG_TO_RAD)
                    ]);
                dialog(id);
            }
            else if ( msg == "Canopy Close")
            {
                tflag = FALSE;
                llSetTimerEvent(45);
                llSetLinkPrimitiveParams
                    (LINK_ALL_OTHERS, [
                        PRIM_LINK_TARGET, 3,
                        PRIM_ROT_LOCAL, llEuler2Rot(<0, 0, 90> * DEG_TO_RAD)
                    ]);
                dialog(id);
            }
            else if ( msg == "-")
            {
                tflag = FALSE;
                llSetTimerEvent(45);
                dialog(id);
            }
            else if ( msg == "Dismiss")
            {
                tflag = FALSE;
                llSetTimerEvent(0);
                llListenRemove(handle);
            }
        }
    }
    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            camfixed(); //Trying to solve the cam reset if the passenger stands in midflight         
            agent = llAvatarOnSitTarget();
            //Pilot and copilot sat
            if (agent != NULL_KEY && llAvatarOnLinkSitTarget(2) != "00000000-0000-0000-0000-000000000000" && engine == FALSE)
            {
                engine = TRUE;
                llRequestPermissions(agent, PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
                llStopAnimation("Sit");
                llStartAnimation("Arcadia's Stratoracer Pilot");
                llTriggerSound("Arcadia's Stratoracer Start",1.0);
                llLoopSound("Arcadia's Stratoracer Loop",1.0);
                init();
                camfixed();
            }
            //Pilot sat alone
            else if (agent != NULL_KEY && llAvatarOnLinkSitTarget(2) == "00000000-0000-0000-0000-000000000000" && engine == FALSE)
            {
                engine = TRUE;
                llRequestPermissions(agent, PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
                llStopAnimation("Sit");
                llStartAnimation("Arcadia's Stratoracer Pilot");
                llTriggerSound("Arcadia's Stratoracer Start",1.0);
                llLoopSound("Arcadia's Stratoracer Loop",1.0);
                init();
                camfixed();
            }
            //Copilot sat alone, this wont make the hover start
            else if (agent == NULL_KEY && llAvatarOnLinkSitTarget(2) != "00000000-0000-0000-0000-000000000000" && engine == TRUE)
            {
                engine = FALSE;
                llTriggerSound("Arcadia's Stratoracer End",1.0);
                llSleep(0.2);
                release_camera_control();
                llStopAnimation("Arcadia's Stratoracer Pilot");
                llReleaseControls();
                llSetLinkPrimitiveParams
                    (LINK_ALL_OTHERS, [
                        PRIM_LINK_TARGET, 3,
                        PRIM_ROT_LOCAL, llEuler2Rot(<0, 0, 90> * DEG_TO_RAD),
                        PRIM_LINK_TARGET, 6,
                        PRIM_FULLBRIGHT, 5, FALSE,
                        PRIM_GLOW, 5, 0.0,
                        PRIM_LINK_TARGET, 4,
                        PRIM_ROT_LOCAL, llEuler2Rot(<0, 90, 90> * DEG_TO_RAD),
                        PRIM_POINT_LIGHT, FALSE, <1.000, 0.910, 0.506>, 1.0, 10.0, 0.75,
                        PRIM_FULLBRIGHT, 2, FALSE,
                        PRIM_GLOW, 2, 0.0,
                        PRIM_LINK_TARGET, 5,
                        PRIM_ROT_LOCAL, llEuler2Rot(<0, 90, 90> * DEG_TO_RAD),
                        PRIM_POINT_LIGHT, FALSE, <1.000, 0.910, 0.506>, 1.0, 10.0, 0.75,
                        PRIM_FULLBRIGHT, 2, FALSE,
                        PRIM_GLOW, 2, 0.0
                    ]);
                    vector hererot = llRot2Euler(llGetRot()) * RAD_TO_DEG;
                    llSetRot(llEuler2Rot (<0, 0, hererot.z> * DEG_TO_RAD));
                    llSleep(0.1);
                    llResetScript();
            }
            //No one sat, this will turn off the hover
            else if (agent == NULL_KEY && llAvatarOnLinkSitTarget(2) == "00000000-0000-0000-0000-000000000000" && engine == TRUE)
            {
                engine = FALSE;
                llStopSound();
                llTriggerSound("Arcadia's Stratoracer End",1.0);
                llSleep(0.2);
                release_camera_control();
                llStopAnimation("Arcadia's Stratoracer Pilot");
                llReleaseControls();
                tflag = TRUE;
                llSetTimerEvent(3);
            }
        }
    }
    run_time_permissions(integer perm)
    {
        if (perm)
        {
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_RIGHT | CONTROL_LEFT | CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT | CONTROL_UP | CONTROL_DOWN, TRUE, FALSE);
            
        }
    }
 
    control(key name, integer levels, integer edges)
    {
        if ((edges & levels & CONTROL_UP)) 
        {
            linear.z += zfactor;
        } 
        else if ((edges & ~levels & CONTROL_UP)) 
        {
            linear.z -= zfactor;
        }
        if ((edges & levels & CONTROL_DOWN)) 
        {          
            linear.z -= zfactor;
        } 
        else if ((edges & ~levels & CONTROL_DOWN)) 
        {
            linear.z += zfactor;
        }        
        if ((edges & levels & CONTROL_FWD)) 
        {          
            linear.x += xfactor;
        } 
        else if ((edges & ~levels & CONTROL_FWD)) 
        {
            linear.x -= xfactor;
        }
        if ((edges & levels & CONTROL_BACK)) 
        {           
            linear.x -= xfactor;
        } 
        else if ((edges & ~levels & CONTROL_BACK)) 
        {
            linear.x += xfactor;
        }
        
        if ((edges & levels & CONTROL_LEFT)) 
        {        
            linear.y += yfactor;                    
        }
        else if ((edges & ~levels & CONTROL_LEFT)) 
        {
            linear.y -= yfactor;            
        }
        if ((edges & levels & CONTROL_RIGHT)) 
        {          
            linear.y -= yfactor;           
        } 
        else if ((edges & ~levels & CONTROL_RIGHT)) 
        {
            linear.y += yfactor;
        }     
        if ((edges & levels & CONTROL_ROT_LEFT)) 
        {              
            angular.z += turn_rate;        
            angular.x -= PI * 4;
            llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 30);
        } 
        else if ((edges & ~levels & CONTROL_ROT_LEFT))
        {           
            angular.z -= turn_rate;               
            angular.x += PI * 4;
            llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 5);
        } 
        if ((edges & levels & CONTROL_ROT_RIGHT))
        {         
            angular.z -= turn_rate;
            angular.x += PI * 4;
            llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 30);
        } 
        else if ((edges & ~levels & CONTROL_ROT_RIGHT)) 
        {
            angular.z += turn_rate;
            angular.x -= PI * 4;
            llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 5);
        }
        llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, linear);
        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular);
    }
    timer()
    {
        if (tflag == FALSE)
        {
            llSetTimerEvent(0);
            llListenRemove(handle);
        }
        else
        {
            llSetLinkPrimitiveParams
                    (LINK_ALL_OTHERS, [
                        PRIM_LINK_TARGET, 3,
                        PRIM_ROT_LOCAL, llEuler2Rot(<0, 0, 90> * DEG_TO_RAD),
                        PRIM_LINK_TARGET, 6,
                        PRIM_FULLBRIGHT, 5, FALSE,
                        PRIM_GLOW, 5, 0.0,
                        PRIM_LINK_TARGET, 4,
                        PRIM_ROT_LOCAL, llEuler2Rot(<0, 90, 90> * DEG_TO_RAD),
                        PRIM_POINT_LIGHT, FALSE, <1.000, 0.910, 0.506>, 1.0, 10.0, 0.75,
                        PRIM_FULLBRIGHT, 2, FALSE,
                        PRIM_GLOW, 2, 0.0,
                        PRIM_LINK_TARGET, 5,
                        PRIM_ROT_LOCAL, llEuler2Rot(<0, 90, 90> * DEG_TO_RAD),
                        PRIM_POINT_LIGHT, FALSE, <1.000, 0.910, 0.506>, 1.0, 10.0, 0.75,
                        PRIM_FULLBRIGHT, 2, FALSE,
                        PRIM_GLOW, 2, 0.0
                    ]);
            llSetTimerEvent(0);
            llListenRemove(handle);
            vector zerorot = llRot2Euler(llGetRot());
            llSetRot(llEuler2Rot(<0, 0, zerorot.z>));
            llResetScript();
        }
    }
} 