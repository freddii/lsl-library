//*****************************************************************
// 
//           Carscript for ubODE & Bullet Physics
// 
//          written by My.Admin@3d-sim.spdns.eu:8002
//
//                       (April. 2019)
// 
//*****************************************************************


//#################### Set your Parameters here ###################

// ---- usual ----
integer private = 0; // 1 = private / 0 = public
string gDrivingAnim = "drive"; // Name of the Driver Sitanimation
vector sitpos = <1.10, 0.40, 1.10>; // Sitposition of the Driver

// ---- Physics ----
integer phys = 0; // 0 = ubODE Physics / 1 = Bullet Physics
float angle = 0.75; // 0.75 for ubODE Physics / 1.5 for Bullet Physics

// ---- Maximum Speed ----
integer gGearMax = 10; // example: gGearMax = 12 results 120 Km/h Maximum Speed 

// ---- Sounds ----
string SoundHorn = "Car-Horn_01";
string SoundStartup = "Ente-start";
string SoundRun = "Ente-run";
string SoundIdle = "Ente-idle";
string SoundAlarm = "zw-lala";
string SoundStop = "Ente-stop";

// ---- driving Camera ----
float camDist = 7.8;   // Camera Distance to Driver (Meters)
float camPitch = 11.0;  // Camera Pitch to Driver (Degrees)

//#################################################################

// **************** Car spezifical Parameters *********************

// ---- Wheel turn/spin Parameters ----

// turn left Frontwheel
vector wltl = <0.0, 0.0, 115.0>;
vector wltr = <0.0, 0.0, 65.0>;
vector wltn = <0.0, 0.0, 90.0>;
// turn right Frontwheel
vector wrtl = <0.0, 0.0, -65.0>;
vector wrtr = <0.0, 0.0, -115.0>;
vector wrtn = <0.0, 0.0, -90.0>;

// spin left Frontwheel
vector sfwl = <1.0, 0.0, 0.0>;
// spin right Frontwheel
vector sfwr = <-1.0, 0.0, 0.0>;
// spin right Rearwheel
vector srwr = <-1.0, 0.0, 0.0>;
// spin left Rearwheel
vector srwl = <1.0, 0.0, 0.0>;

// ---- PrimNumbers ----
integer csh =  29;   // Carshaddow
integer fwl =  44;   // Frontwheel left
integer fwr =  43;   // Frontwheel right
integer rwr =  32;   // Rearwheel right
integer rwl =   5;   // Rearwheel left

// ****************************************************************

// ---- global Variable Section ----
key gAgent;
integer gRun;
integer gMoving;
integer sit = 0;
float spinfact = 200.0;
float spinBurst;
float Timer = 0.33;
string SpeedText;
string NmsgSpin;
string msgSpin;
string NmsgTurn;
string msgTurn;
float gGearPower = 5;
integer gGear = 1;
float gGearFactor = 0.8;
float tr = 10.0;
float delay = 0.1;
string Sound;
integer TogSnd = 1;

// ---- Subroutine Section -----

showdata(string s)
{
    llSetText("Gear: "+(string)gGear+"\n\n-\n"+s+"\n.\n.\n.\n.", <1.0, 1.0, 0.6>, 1.0);
}

preload_sounds()
{
 llPreloadSound(SoundHorn);
 llPreloadSound(SoundStartup);
 llPreloadSound(SoundRun);
 llPreloadSound(SoundIdle);
 llPreloadSound(SoundAlarm);
 llPreloadSound(SoundStop);
}

init_camera()
{
    llSetCameraParams([
                       CAMERA_ACTIVE, 1,                  // 0=INACTIVE  1=ACTIVE
                       CAMERA_BEHINDNESS_ANGLE, 15.0,     // (0 to 180) DEGREES
                       CAMERA_BEHINDNESS_LAG, 0.3,        // (0 to 3) SECONDS
                       CAMERA_DISTANCE, camDist,          // ( 0.5 to 10) METERS
                       CAMERA_PITCH, camPitch,            // (-45 to 80) DEGREES
                       CAMERA_POSITION_LOCKED, FALSE,     // (TRUE or FALSE)
                       CAMERA_POSITION_LAG, 0.0,          // (0 to 3) SECONDS
                       CAMERA_POSITION_THRESHOLD, 0.0,    // (0 to 4) METERS
                       CAMERA_FOCUS_LOCKED, FALSE,        // (TRUE or FALSE)
                       CAMERA_FOCUS_LAG, 0.0,             // (0 to 3) SECONDS
                       CAMERA_FOCUS_THRESHOLD, 0.0,       // (0 to 4) METERS
                       CAMERA_FOCUS_OFFSET, <0.0,0,0>     // <-10,-10,-10> to                                                                <10,10,10> METERS
                      ]);
}

SetPhys()
{
if (phys == 1)
 {
  llSetLinkPrimitiveParamsFast(LINK_ALL_CHILDREN, [PRIM_PHYSICS_SHAPE_TYPE,PRIM_PHYSICS_SHAPE_NONE]);
 }
if (phys == 0)
 {
  llSetLinkPrimitiveParamsFast(LINK_ALL_CHILDREN, [PRIM_PHYSICS_SHAPE_TYPE,  PRIM_PHYSICS_SHAPE_PRIM]);
  llSetLinkPrimitiveParamsFast
  (csh, [PRIM_PHYSICS_SHAPE_TYPE,PRIM_PHYSICS_SHAPE_NONE]);
  llSetLinkPrimitiveParamsFast
  (fwl, [PRIM_PHYSICS_SHAPE_TYPE,PRIM_PHYSICS_SHAPE_NONE]);
  llSetLinkPrimitiveParamsFast
  (fwr, [PRIM_PHYSICS_SHAPE_TYPE,PRIM_PHYSICS_SHAPE_NONE]);
  llSetLinkPrimitiveParamsFast
  (rwr, [PRIM_PHYSICS_SHAPE_TYPE,PRIM_PHYSICS_SHAPE_NONE]);
  llSetLinkPrimitiveParamsFast
  (rwl, [PRIM_PHYSICS_SHAPE_TYPE,PRIM_PHYSICS_SHAPE_NONE]);
 }
}

set_engine()
{
    llSetVehicleType(VEHICLE_TYPE_CAR);
    llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME, <0.00000, 0.00000, 0.00000, 0.00000>);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0.10);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 0.10);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0.20);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 0.10);
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.50);
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 2.0);
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0.80);
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 0.10);
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, 0.6);
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 0.10);
    llSetVehicleFloatParam(VEHICLE_HOVER_EFFICIENCY, 0.0 );
    llSetVehicleFloatParam(VEHICLE_HOVER_TIMESCALE, 0.0 );
    llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, 0.0 );
    llSetVehicleFloatParam(VEHICLE_BUOYANCY, 0.0 );
    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <5.0, 0.5, 1000.0> );
    llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <0.10, 0.10, 0.20> );
    llRemoveVehicleFlags(VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT | VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT | VEHICLE_FLAG_HOVER_WATER_ONLY);
    llSetVehicleFlags(VEHICLE_FLAG_NO_DEFLECTION_UP | VEHICLE_FLAG_LIMIT_ROLL_ONLY | VEHICLE_FLAG_LIMIT_MOTOR_UP |
                      VEHICLE_FLAG_HOVER_UP_ONLY | VEHICLE_FLAG_HOVER_TERRAIN_ONLY);
}

//---- Main Section ----
default
{
    state_entry()
    {if(llGetSubString(osGetPhysicsEngineName(), 0, 8)=="BulletSim")
      {phys = 1;}
     gRun = 0;
     llSetSitText("DRIVE");
     llSitTarget(sitpos, <0.000000, -0.034899, 0.000000, -0.999391>);
     state Ground;
    }
    
}

state Ground
{
    state_entry()
    {
    }
    
    on_rez(integer param)
    {
        llResetScript();
        preload_sounds();
    }
    
    changed(integer change)
    {
        if ((change & CHANGED_LINK) == CHANGED_LINK)
        {
        gAgent = llAvatarOnLinkSitTarget(1);
        if ((gAgent != NULL_KEY) & ((gAgent == llGetOwner()) | (1 - private)))
            {
                SetPhys();
                llSetStatus(STATUS_PHYSICS, TRUE);
                set_engine();
                llSetTimerEvent(Timer);
                llRequestPermissions(gAgent, PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
                gRun = 1; spinBurst = spinfact;
                if (sit == 0)
                {
                 init_camera();
                 llStartAnimation(gDrivingAnim);
                 llTriggerSound(SoundStartup,0.7);
                 llMessageLinked(LINK_SET, 0, "sit", NULL_KEY);
                 llSleep(1.5);
                 llLoopSound(SoundIdle,1.0); Sound = SoundIdle;
                }
                 sit = 1;
            }
            
            else
            {
            if( ((gAgent != NULL_KEY) & (gAgent != llGetOwner())) && (private == 1))
              {
               llSay(0, "Sorry, Vehicle is locked");
               llMessageLinked(LINK_SET, 0, "unsit", NULL_KEY);
               llUnSit(gAgent);
               llPlaySound(SoundAlarm,1.0);
               llPushObject(gAgent, <0,0,20>, ZERO_VECTOR, FALSE);
               }

               llSetStatus(STATUS_PHYSICS, FALSE);
               llSetTimerEvent(0);
               llStopAnimation(gDrivingAnim);
               llSetTimerEvent(0.0);
               if (gRun == 1) {llTriggerSound(SoundStop,1);}
               llStopSound();
               llReleaseControls();
               llClearCameraParams();
               llMessageLinked(LINK_SET, 0, "unsit", NULL_KEY);
               Sound = "";
               gRun = 0; sit = 0;
               llSetText("",<0,0,0>,1.0);
            }
        }
    }
    
    run_time_permissions(integer perm)
    {
        if (perm)
        {
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_DOWN | CONTROL_UP | CONTROL_RIGHT | CONTROL_LEFT | CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT, TRUE, FALSE);
        }
    }
        
    control(key id, integer held, integer change)
    {
        if(gRun == 0)
        {
            return;
        }
        integer reverse=1; gMoving = 0;
        
        if (held & CONTROL_FWD)
        {
            NmsgSpin = "ForwardSpin";
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <gGearPower * gGear * gGearFactor,0,0>);
            spinBurst = gGear * spinfact;
            gMoving = 1;
            reverse = 1;
        }
        
        if (held & CONTROL_BACK)
        {
            gGear = 1;
            NmsgSpin = "BackwardSpin";
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <-gGearPower * gGear * gGearFactor,0,0>);
            spinBurst = gGear * spinfact;
            gMoving = 1;
            reverse = -1;
        }
        
        if (~held & change & CONTROL_FWD)
        {
            NmsgSpin = "NoSpin";
        }
        
        if (~held & change & CONTROL_BACK)
        {
            NmsgSpin = "NoSpin";
        }

        vector AngularMotor;
        if (held & CONTROL_LEFT)
        {
            NmsgTurn = "LeftTurn";
            if (reverse == 1)
            {
                AngularMotor.z += angle + angle * gGear/tr;
            }
            else
            {
                AngularMotor.z -= angle + angle * gGear/tr;
            }
        }
        
        if (held & CONTROL_RIGHT)
        {
            NmsgTurn = "RightTurn";
            if (reverse == 1)
            {
                AngularMotor.z -= angle + angle * gGear/tr;
            }
            else
            {
                AngularMotor.z += angle + angle * gGear/tr;
            }
        }
        
        if (held & CONTROL_ROT_LEFT)
        {
            NmsgTurn = "LeftTurn";
            if (reverse == 1)
            {
                AngularMotor.z += angle;
            }
            else
            {
                AngularMotor.z -= angle;
            }
        }
        
        if (held & CONTROL_ROT_RIGHT)
        {
            NmsgTurn = "RightTurn";
            if (reverse == 1)
            {
                AngularMotor.z -= angle;
            }
            else
            {
                AngularMotor.z += angle;
            }
        }

        if (~held & change & (CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT
                              | CONTROL_RIGHT | CONTROL_LEFT))
        {
            NmsgTurn = "NoTurn";
        }
        
        if ((held & change & CONTROL_UP) || ((gGear >= gGearMax) && (held & CONTROL_UP)))
          {
            gGear=gGear + 1;
            if (gGear < 1) gGear = 1;
            if (gGear > gGearMax) gGear = gGearMax;
            llMessageLinked(LINK_SET, 0, NmsgSpin, NULL_KEY);
           }
           
        if ((held & change & CONTROL_DOWN) || ((gGear >= gGearMax) && (held & CONTROL_DOWN))){
            gGear=gGear - 1;
            if (gGear < 1) gGear = 1;
            if (gGear > gGearMax) gGear = gGearMax;
            llMessageLinked(LINK_SET, 0, NmsgSpin, NULL_KEY);
        }
        
        if ((NmsgSpin != msgSpin))
        {
         llMessageLinked(LINK_SET, 0, "NoTurn", NULL_KEY); llSleep(delay);
         llMessageLinked(LINK_SET, 0, NmsgSpin, NULL_KEY);
         msgSpin = NmsgSpin; llSleep(delay);
         llMessageLinked(LINK_SET, 0, msgTurn, NULL_KEY);
        }
        
        if (gMoving == 0)
        {
         llMessageLinked(LINK_SET, 0, "NoTurn", NULL_KEY);
         llMessageLinked(LINK_SET, 0, "NoSpin", NULL_KEY);
        }
 
        
        if ((NmsgTurn != msgTurn) & (gMoving == 1))
        {
         llMessageLinked(LINK_SET, 0, "NoSpin", NULL_KEY); llSleep(delay);
         llMessageLinked(LINK_SET, 0, NmsgTurn, NULL_KEY);
         msgTurn = NmsgTurn; llSleep(delay);
         llMessageLinked(LINK_SET, 0, msgSpin, NULL_KEY);
        }
        
        if ((gMoving == 1) & (TogSnd == 1))
         {
          llStopSound(); TogSnd = 0;
          llLoopSound(SoundRun, 1.0); Sound = SoundRun; 
         }
         if ((gMoving == 0) & (TogSnd == 0))
         {
          llStopSound(); TogSnd = 1;
          llLoopSound(SoundIdle, 1.0); Sound = SoundIdle;
         }
                
        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, AngularMotor);
    }

touch_start(integer total_number)
{
 llStopSound(); llPlaySound(SoundHorn, 1.0);
 llSleep(0.25); llLoopSound(Sound, 1.0);
}    

// ---- Wheel spin/turn ----  
link_message(integer sender, integer num, string str, key id)
{
spinBurst = gGear * spinfact;
integer i = fwl;        
rotation rootRot = llGetRootRotation();
vector rootPos = llGetRootPosition();
                
list params = llGetLinkPrimitiveParams(i,[PRIM_POSITION,PRIM_ROT_LOCAL,PRIM_SIZE]);
rotation childRot = llList2Rot(params,1);
vector childPos = (llList2Vector(params,0)-rootPos)/rootRot;
vector childSize = llList2Vector(params,2);
 
if(str == "ForwardSpin")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_OMEGA, sfwl*DEG_TO_RAD*childRot, spinBurst, 1.0]);
}
else if (str == "BackwardSpin")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_OMEGA, sfwl*DEG_TO_RAD*childRot, -spinBurst, 1.0]);
}
else if (str == "NoSpin")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_OMEGA, <0.0, 0.0, 0.0>*DEG_TO_RAD*childRot, 0, spinBurst]);
}
else if (str == "LeftTurn")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_ROT_LOCAL, llEuler2Rot(DEG_TO_RAD * wltl)]);
}
else if (str == "RightTurn")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_ROT_LOCAL, llEuler2Rot(DEG_TO_RAD * wltr)]);
}
else if (str == "NoTurn")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_ROT_LOCAL, llEuler2Rot(DEG_TO_RAD * wltn)]);
}

i = fwr;
                
params = llGetLinkPrimitiveParams(i,[PRIM_POSITION,PRIM_ROT_LOCAL,PRIM_SIZE]);
childRot = llList2Rot(params,1);
childPos = (llList2Vector(params,0)-rootPos)/rootRot;
childSize = llList2Vector(params,2);
 
if(str == "ForwardSpin")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_OMEGA, sfwr*DEG_TO_RAD*childRot,  spinBurst, 1.0]);
}
else if (str == "BackwardSpin")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_OMEGA, sfwr*DEG_TO_RAD*childRot, -spinBurst, 1.0]);
}
else if (str == "NoSpin")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_OMEGA, <0.0, 0.0, 0.0>*DEG_TO_RAD*childRot, 0, 1.0]);
}
else if (str == "LeftTurn")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_ROT_LOCAL, llEuler2Rot(DEG_TO_RAD * wrtl)]);
}
else if (str == "RightTurn")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_ROT_LOCAL, llEuler2Rot(DEG_TO_RAD * wrtr)]);
}
else if (str == "NoTurn")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_ROT_LOCAL, llEuler2Rot(DEG_TO_RAD * wrtn)]);
}

i = rwr;
                
params = llGetLinkPrimitiveParams(i,[PRIM_POSITION,PRIM_ROT_LOCAL,PRIM_SIZE]);
childRot = llList2Rot(params,1);
childPos = (llList2Vector(params,0)-rootPos)/rootRot;
childSize = llList2Vector(params,2);
 
if(str == "ForwardSpin")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_OMEGA, srwr*DEG_TO_RAD*childRot,  spinBurst, 1.0]);
}
else if (str == "BackwardSpin")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_OMEGA, srwr*DEG_TO_RAD*childRot, -spinBurst, 1.0]);
}
else if (str == "NoSpin")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_OMEGA, <0.0, 0.0, 0.0>*DEG_TO_RAD*childRot, 0, 1.0]);
}

i = rwl;
                
params = llGetLinkPrimitiveParams(i,[PRIM_POSITION,PRIM_ROT_LOCAL,PRIM_SIZE]);
childRot = llList2Rot(params,1);
childPos = (llList2Vector(params,0)-rootPos)/rootRot;
childSize = llList2Vector(params,2);
 
if(str == "ForwardSpin")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_OMEGA, srwl*DEG_TO_RAD*childRot,  spinBurst, 1.0]);
}
else if (str == "BackwardSpin")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_OMEGA, srwl*DEG_TO_RAD*childRot,  -spinBurst, 1.0]);
}
else if (str == "NoSpin")
{
llSetLinkPrimitiveParamsFast(i, [PRIM_OMEGA, <0.0, 0.0, 0.0>*DEG_TO_RAD*childRot, 0, 1.0]);
}
        
}

// ---- Speedmetering ----
timer()
{
    if(gRun == 1)
    {
     float SPEED = llVecMag(llGetVel());
     SpeedText = ((string)llRound(SPEED * 2.95) + " Km/h");
     showdata("Speed: " + SpeedText);     

    }  
}

}