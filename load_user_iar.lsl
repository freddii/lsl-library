//***** Load an IAR to the inventory of the clicked user ********
//   - Current script may be activated by the prim owner 
//   - Requires OSSL functions treat level set to "Severe"
//file destination of the iar file to load
string IAR_FILE_PATH_NAME="http://raw.githubusercontent.com/freddii/lsl-library/master/lsl-library.iar";
//  http://nebadon2025.com/iars/OKC_Racer_Kit_v0.186X.iar
//  http://files.zadaroo.com/iars/furry-avatars.iar
//  /home/pi/YOUR_IAR_FILE.iar

integer gListener;
integer path=FALSE;
key ukey;

integer random_integer(integer min, integer max)
{
    return min + (integer)(llFrand(max - min + 1));
}

say (string status_msg)
{
        llSay (0,status_msg);
        llSetText(status_msg,<1,1,1>,1);
}

default
{
    state_entry()
    {   string text="load_user_iar";
        llSetText(text,<1,1,1>,1);
        llSetObjectName(text);   
    }
    
    listen(integer channel, string name, key id, string message)
    {
    if (message =="Exit")
    {llListenRemove(gListener);
     path=FALSE;
     llSetText("load_user_iar",<1,1,1>,1);}
    else if (message =="iar_path")
    {path=TRUE;
    llTextBox(ukey, "Type the path to your iar file you want to load into inventory below.\n Current setup:\n "+IAR_FILE_PATH_NAME, channel);
     say ("waiting for iar_path input.");
     }

    else if (message =="load_iar")
    {path=FALSE;
     llTextBox(ukey, "Type your account password below to load the iar file '"+IAR_FILE_PATH_NAME+"' into your inventory.", channel);
     say ("waiting for password input.");}

    else if (path==TRUE)
    {llListenRemove(gListener);
         IAR_FILE_PATH_NAME=message;
         say ("changed IAR_FILE_PATH_NAME to: "+IAR_FILE_PATH_NAME);}

    else if (path==FALSE)
    {
      llListenRemove(gListener);
          say ("Loading archive '"+IAR_FILE_PATH_NAME+"'  to inventory path / for "+name+".");
          integer res;
          res = osConsoleCommand("load iar "+name+" / "+message+" " +IAR_FILE_PATH_NAME);
          if(res==FALSE)
            {
                say ("Unable to execute command '"+"load iar "+name+" / "+message+" " +IAR_FILE_PATH_NAME+"'"); 
            }
          else
            {
                say("Done loading iar (hopefully, check your wifi console for errors http://YOUR_SERVER_IP:9000/wifi )");
            }
    }
    }
   
    touch_start(integer num)
    {
        integer channel = random_integer(-1000000,1000000);
        gListener = llListen( channel, "", "", "");
        ukey=llDetectedKey(0);
        llDialog(ukey, "current iar_path: "+IAR_FILE_PATH_NAME,
                ["iar_path", "load_iar",["Exit"]], channel);
    }
}
