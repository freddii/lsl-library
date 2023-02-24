// This script has been modified from the origional so as not to warn of oncoming sim borders 9/14/2017 : see line(s) 241 - 242 - 243 - 244 - 245 and uncomment them in order to reenable. Driver Sit Target edit line 6 {OSPBA 9/27/2017_JayR Cela}{added Auto Delete lines 192-196 2/19/2019 thanks to Modee.Parlez}   
integer DEBUG = FALSE;

//==== G L O B A L   V A R I A B L E   D E C L A R A T I O N ====
integer xlimit;
integer ylimit;
vector      gSitTarget_Pos = <1.15,0.65,0.66>;
key         gAgent;
integer     gRun;     //ENGINE RUNNING
string      gDrivingAnim = "drive forward - chris craft";
string      gReverseAnim = "drive reverse - chris craft";
string      gSitMessage = "Go Boating";
float       gVerticalThrust=10.0;
integer     gGear;
float       gGearPower;
float       gReversePower = -5;
float       gTurnMulti = 1;
float       gTurnRatio;
integer     numGears;
string      animation;
list gGearPowerList = [ 5, 15, 30, 45, 65, 90 ];
list gTurnRatioList = [ 1, 1, 1, 1, 1, 1 ];
//==== E N D   G L O B A L   V A R I A B L E   D E C L A R A T I O N ====

init_engine(){
    gRun = 0;
    numGears = llGetListLength( gGearPowerList );
//llOwnerSay( (string)numGears );
    llSetSitText(gSitMessage);
    vector gSitTarget_Rot = llRot2Euler( llGetRootRotation() ); // SIT TARGET IS BASED ON VEHICLE'S ROTATION.
    llSitTarget(gSitTarget_Pos, llEuler2Rot(DEG_TO_RAD * gSitTarget_Rot));
    llSetLinkPrimitiveParamsFast(LINK_ALL_CHILDREN, [PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_NONE]);
}

gearshift()
{
    gGearPower = llList2Float(gGearPowerList, gGear);  
    llSay(0, "Speed = " + (string)( gGear+1 ) );
}

init_followCam()
{
    llSetCameraParams([
                       CAMERA_ACTIVE, 1,                 // 0=INACTIVE  1=ACTIVE
                       CAMERA_BEHINDNESS_ANGLE, 2.5,     // (0 to 180) DEGREES
                       CAMERA_BEHINDNESS_LAG, 0.3,       // (0 to 3) SECONDS
                       CAMERA_DISTANCE, 10.0,             // ( 0.5 to 10) METERS
                       CAMERA_PITCH, 12.0,                // (-45 to 80) DEGREES
                       CAMERA_POSITION_LOCKED, FALSE,    // (TRUE or FALSE)
                       CAMERA_POSITION_LAG, 0.0,         // (0 to 3) SECONDS
                       CAMERA_POSITION_THRESHOLD, 0.0,   // (0 to 4) METERS
                       CAMERA_FOCUS_LOCKED, FALSE,       // (TRUE or FALSE)
                       CAMERA_FOCUS_LAG, 0.0,           // (0 to 3) SECONDS
                       CAMERA_FOCUS_THRESHOLD, 0.0,      // (0 to 4) METERS
                       CAMERA_FOCUS_OFFSET, <-5, 0, 0>   // <-10,-10,-10> to <10,10,10> METERS
                      ]);
    llForceMouselook(FALSE);
}

set_engine()
{
//    llSetVehicleType(VEHICLE_TYPE_AIRPLANE);
    llSetVehicleType(VEHICLE_TYPE_BOAT);
    
// default rotation of local frame
//llSetVehicleRotationParam( VEHICLE_REFERENCE_FRAME, <0, 0, 0, 1> );  // lsl default
    llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME, <0.00000, 0.00000, 0.00000, 0.00000>); // <0.00000, 0.00000, 0.00000, 0.00000>
    
// linear motor wins after about five seconds, decays after about a minute 
//llSetVehicleVectorParam( VEHICLE_LINEAR_MOTOR_DIRECTION, <0, 0, 0> );  // lsl default
//llSetVehicleFloatParam( VEHICLE_LINEAR_MOTOR_TIMESCALE, 5 );  // lsl default
//llSetVehicleFloatParam( VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 60 );  // lsl default
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, 0.90);  // 0.90)
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 1.0); //  0.10
    
// least for forward-back, most friction for up-down   ( matched lsl gives much slower control response )
//llSetVehicleVectorParam( VEHICLE_LINEAR_FRICTION_TIMESCALE, <10, 3, 2> );  // lsl default
    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <1.0,1.0,1.0> );  // <1.0,1.0,1.0>
    
// uniform angular friction (setting it as a scalar rather than a vector)  ( matched lsl gives a compile error )
//llSetVehicleFloatParam( VEHICLE_ANGULAR_FRICTION_TIMESCALE, 10 );  // 
    llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <1.0,1000.0,1000.0> );  // <1.0,1000.0,1000.0>

// agular motor wins after four seconds, decays in same amount of time   ( matched lsl turning almost non existent )
//llSetVehicleVectorParam( VEHICLE_ANGULAR_MOTOR_DIRECTION, <0, 0, 0> );  // lsl default
//llSetVehicleFloatParam( VEHICLE_ANGULAR_MOTOR_TIMESCALE, 4 );  // lsl default
//llSetVehicleFloatParam( VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 4 );
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0.20);  // 0.20
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 0.10);  // 0.10
    
// halfway linear deflection with timescale of 3 seconds  ( matched lsl turning is slower )
//llSetVehicleFloatParam( VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0.5 );  // lsl default
//llSetVehicleFloatParam( VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 3 );  // lsl default
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0.10);  // 0.10
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 10.00);  // 10.00
    
// angular deflection ( matched lsl without any visable change )
//llSetVehicleFloatParam( VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0.5 );  // lsl default
//llSetVehicleFloatParam( VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 5 );  // lsl default
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0.10); // 0.10
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 10.00); // 10.00
    
// somewhat bounscy vertical attractor ( changing gives very bad results )
//llSetVehicleFloatParam( VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.5 );  // lsl default
//llSetVehicleFloatParam( VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 5 );  // lsl default
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.5);  // 3.00
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 2.00);  // 2.00
    
// hover ( matched lsl without any visable change )
//llSetVehicleFloatParam( VEHICLE_HOVER_HEIGHT, 0 );  // lsl default
//llSetVehicleFloatParam( VEHICLE_HOVER_EFFICIENCY, 0.5 );  // lsl default
//llSetVehicleFloatParam( VEHICLE_HOVER_TIMESCALE, 2.0 );  // lsl default
//llSetVehicleFloatParam( VEHICLE_BUOYANCY, 1 );  // lsl default
    llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, 0.1 );  // 0.0 
    llSetVehicleFloatParam(VEHICLE_HOVER_EFFICIENCY, 0.5 );  // 0.0
    llSetVehicleFloatParam(VEHICLE_HOVER_TIMESCALE, 250.0 );  // 0.0
    llSetVehicleFloatParam(VEHICLE_BUOYANCY, 1.0 );  // 1.0
    
// weak negative damped banking  ( matched lsl without any visable change )
//llSetVehicleFloatParam( VEHICLE_BANKING_EFFICIENCY, -0.3 );  // lsl default
//llSetVehicleFloatParam( VEHICLE_BANKING_MIX, 0.8 );  // lsl default
//llSetVehicleFloatParam( VEHICLE_BANKING_TIMESCALE, 1 );  // lsl default
    llSetVehicleFloatParam( VEHICLE_BANKING_EFFICIENCY, 1.0 );  // 1.0
    llSetVehicleFloatParam( VEHICLE_BANKING_MIX, 1.0 );  // 1.0
    llSetVehicleFloatParam( VEHICLE_BANKING_TIMESCALE, 0.5 );  // 0.5
// remove these flags
    llRemoveVehicleFlags( VEHICLE_FLAG_HOVER_TERRAIN_ONLY
        | VEHICLE_FLAG_LIMIT_ROLL_ONLY
        | VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT);
// set these flags
    llSetVehicleFlags( VEHICLE_FLAG_NO_DEFLECTION_UP
        | VEHICLE_FLAG_HOVER_WATER_ONLY
        | VEHICLE_FLAG_HOVER_UP_ONLY
        | VEHICLE_FLAG_LIMIT_MOTOR_UP );
}

default {
    state_entry()
    {
        vector vTarget = llGetPos();
        vTarget.z = llGround( ZERO_VECTOR );
        float fWaterLevel = llWater( ZERO_VECTOR );
        if( vTarget.z < fWaterLevel )
        {
            vTarget.z = fWaterLevel;
//            llSay(0,"Ready to go!");
        }
        else
        {
//            llSay(0,"You must rezz me in water!");
        }
        llSetRegionPos(vTarget + <0,0,0.1>);
        init_engine();
        state Ground;
    }
}
 
state Ground{
 
    state_entry(){
    }
    on_rez(integer param) {
        llResetScript();
    }
    
    changed(integer change){
        if ((change & CHANGED_LINK) == CHANGED_LINK){
            gAgent = llAvatarOnSitTarget();
            if (gAgent != NULL_KEY){ // we have a driver
                llSetStatus(STATUS_PHYSICS, TRUE);
                llSetStatus(STATUS_ROTATE_Y,TRUE);
                llSetStatus(STATUS_ROTATE_Z,TRUE);
                set_engine();
                vector regionsize = osGetRegionSize();
//                vector regionsize = <256, 256, 256>;
                xlimit = (integer)regionsize.x - 15;
                ylimit = (integer)regionsize.y - 15;
                llRequestPermissions(gAgent, PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA | PERMISSION_TRACK_CAMERA);
                gRun = 1; // set running
            }
            else { // driver got off
                llSetStatus(STATUS_PHYSICS, FALSE); //SHOULD THIS BE THE LAST THING YOU SET??
                gRun = 0; // turn off running
                init_engine();
                llStopAnimation( animation );
                llPushObject(gAgent, <3,3,21>, ZERO_VECTOR, FALSE);
                llReleaseControls();
                llClearCameraParams();
                llSetCameraParams([CAMERA_ACTIVE, 0]);
                llSetText("",<0,0,0>,1.0);
                llMessageLinked(LINK_SET, 0, "aboard", NULL_KEY);     // driver got off
                
//////////////////////////////// added by modee               
//                 llSleep(15);
//                llDie();
                
//////////////////////////////////////////////////////////////////////              
            }
        }
    }
    run_time_permissions(integer perm){
        if (perm) {
            gGear = 0;
            gearshift(); 
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_DOWN | CONTROL_UP | CONTROL_RIGHT | CONTROL_LEFT | CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT, TRUE, FALSE);
            init_followCam();
            llStopAnimation("sit");
            llStartAnimation(gDrivingAnim);
            animation = gDrivingAnim;
            llMessageLinked(LINK_SET, 1, "aboard", NULL_KEY);     // driver aboard
            llSleep(1.5);
        }
    }
 
    control(key id, integer held, integer change){
        if(gRun == 0){
            return;
        }
        integer reverse = 1;
        gTurnRatio = llList2Float(gTurnRatioList, gGear);  
        vector vel = llGetVel();
        float gSpeed = llVecMag(vel);
        vector speedvec = llGetVel() / llGetRot();
        vector AngularMotor;
        vector pos = llGetPos();
        vector newPos = pos;

        if( (held & change & CONTROL_UP) || ((gGear >= 11) && (held & CONTROL_UP)) ||
            (held & change & CONTROL_RIGHT) || ((gGear >= 11) && (held & CONTROL_RIGHT)) )
        {
            gGear=gGear+1;
            if (gGear > numGears-1) gGear = numGears-1;
            gearshift();
        }
        
        if( (held & change & CONTROL_DOWN) || ((gGear >= 11) && (held & CONTROL_DOWN)) ||
            (held & change & CONTROL_LEFT) || ((gGear >= 11) && (held & CONTROL_LEFT)) )
        {
            gGear=gGear-1;
            if (gGear < 0) gGear = 0;
            gearshift();
        }
        
        if (held & CONTROL_FWD)
        {
//            llSay(0,"held & CONTROL_FWD");
            reverse = 1;
            // if near region edge, slow down, and veer to the right
 //           if (newPos.x > xlimit || newPos.x < 0.1 || newPos.y > ylimit || newPos.y < 15.0) 
   //         {
     //           llWhisper(0, "Approaching sim edge, turn away...");
       //     }
            if( !DEBUG ) llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <gGearPower,0,0>);
            llMessageLinked(LINK_SET, (integer)gSpeed, "ForwardSpin", NULL_KEY);
            if( animation == gReverseAnim )
            {
                llStopAnimation( animation );
                animation = gDrivingAnim;
            }
        }
 
        if (held & CONTROL_BACK)
        {
//            llSay(0,"held & CONTROL_BACK");
            if( !DEBUG ) llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <gReversePower, 0, 0>);
            llSetCameraParams([CAMERA_BEHINDNESS_ANGLE,-45.0]);
            llSetCameraParams([CAMERA_DISTANCE,8.0]);
            gTurnRatio = -1.0;
            reverse = -1;
            llMessageLinked(LINK_SET, (integer)gSpeed, "BackwardSpin", NULL_KEY);
            if( animation == gDrivingAnim )
            {
                animation = gReverseAnim;
                llStartAnimation( animation );
            }
        }

        if (~held & change & CONTROL_FWD)
        {
            llMessageLinked(LINK_SET, (integer)gSpeed, "NoSpin", NULL_KEY);             
        }
        
        if (~held & change & CONTROL_BACK)
        {
            llMessageLinked(LINK_SET, (integer)gSpeed, "NoSpin", NULL_KEY);             
        }
        
//        vector AngularMotor;
//        AngularMotor.y = 0;  
        if (held & (CONTROL_ROT_RIGHT))
        {
//            llSay(0,"held & (CONTROL_ROT_RIGHT)");
            if( reverse == 1 )
            {
                AngularMotor.x += ( gTurnRatio * 0.3 );  //1
                AngularMotor.y -= ( gTurnRatio * 0.3 );  //0.3
            }
            AngularMotor.z -= ( gTurnRatio * 1 );
//            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <gGearPower,0,gGearPower>);
        }
 
        if (held & (CONTROL_ROT_LEFT))
        {
//            llSay(0,"held & (CONTROL_ROT_LEFT)");
            if( reverse == 1 )
            {
                AngularMotor.x -= ( gTurnRatio * 0.3 );
                AngularMotor.y -= ( gTurnRatio * 0.3 );
            }
            AngularMotor.z += ( gTurnRatio * 1);
//            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <gGearPower,0,gGearPower>);
         }
         if( !DEBUG ) llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, AngularMotor);
//        llSay(0, "gGear= " + gGear + "\n");
//        llSay(0, "gGearPower= " + (string)gGearPower + "\n");
//        llSay(0, "AngularMotor= " + (string)AngularMotor + "\n");
    }
}