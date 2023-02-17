//***** Backups the clicked users inventory to IAR ********
//   - Current script may be activated by the prim owner 
//   - Requires OSSL functions treat level set to "Severe"

//file destination of the iar file to save
string INV_FILE_PATH_NAME="/*";
//  Objects

//file extension of the IAR file 
string IAR_FILE_EXT= ".iar";

// FALSE will generate unique archive name ( based on the current time:  [username][datetime].[IAR_FILE_EXT])
// TRUE will overwrite the last arhcive (filename: [username].[IAR_FILE_EXT]
integer OVERWRITE_OLD_IARS = FALSE;

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

string str_replace(string src, string from, string to)
{//replaces all occurrences of 'from' with 'to' in 'src'.
    integer len = (~-(llStringLength(from)));
    if(~len)
    {
        string  buffer = src;
        integer b_pos = -1;
        integer to_len = (~-(llStringLength(to)));
        @loop;//instead of a while loop, saves 5 bytes (and runs faster).
        integer to_pos = ~llSubStringIndex(buffer, from);
        if(to_pos)
        {
            b_pos -= to_pos;
            src = llInsertString(llDeleteSubString(src, b_pos, b_pos + len), b_pos, to);
            b_pos += to_len;
            buffer = llGetSubString(src, (-~(b_pos)), 0x8000);
            jump loop;
        }
    }
    return src;
}

default
{
    state_entry()
    {   string text="backup_user_iar";
        llSetText(text,<1,1,1>,1);
        llSetObjectName(text);   
    }
    
    listen(integer channel, string name, key id, string message)
    {
        
    if (message =="Exit")
    {llListenRemove(gListener);
     path=FALSE;
     llSetText("backup_user_iar",<1,1,1>,1);}

    else if (message =="inv_path")
    {path=TRUE;
    llTextBox(ukey, "Type the inventory_path to your file or folder you want to save below.\n Current setup:\n "+INV_FILE_PATH_NAME +"\n ( whole inventory is: /*  only object folder is: Objects", channel);
     say ("waiting for inv_path input.");
     }
     
    else if (message =="save_iar")
    {path=FALSE;
     llTextBox(ukey, "Type your account password below to save the iar file '"+INV_FILE_PATH_NAME+"' into your inventory.", channel);
     say ("waiting for password input.");}
 
 
    else if (path==TRUE)
    {llListenRemove(gListener);
         INV_FILE_PATH_NAME=message;
         say ("changed INV_FILE_PATH_NAME to: "+INV_FILE_PATH_NAME+" (click the box again and choose save)");}
    
       else if (path==FALSE)
    {  
        llListenRemove(gListener);
        string username=name;
        string username_fix=llDumpList2String(llParseString2List(username, [" "], []), "_"); 
        say ("Saving iar for "+username);
          
        string iarName = username_fix+IAR_FILE_EXT;
        if(OVERWRITE_OLD_IARS==FALSE)         
            {
                string time = llGetTimestamp();
                list l = llParseString2List(time,":","");
                if (INV_FILE_PATH_NAME=="/*")
                {
                iarName=username_fix+llList2String(l,0)+llList2String(l,1)+IAR_FILE_EXT;
                }
                else 
                {llSay(0,"test"+str_replace(INV_FILE_PATH_NAME, "/", "_"));
                iarName=username_fix+llList2String(l,0)+llList2String(l,1)+str_replace(INV_FILE_PATH_NAME, "/", "_")+IAR_FILE_EXT;
                }   
            }
        integer res = osConsoleCommand("save iar "+username+" "+INV_FILE_PATH_NAME+" "+message+" "+iarName);
        if(res==FALSE)
            {
               say ("Unable to execute commnand 'save iar "+username+" "+INV_FILE_PATH_NAME+" "+"****"+" "+iarName+"'");
            }
        else 
            {
                llSay(0,"'Done saving iar' successfull (hopefully, check your wifi console for errors http://YOUR_SERVER_IP:9000/wifi )");
            }
    }
    }
   
    touch_start(integer num)
    {
        integer channel = random_integer(-1000000,1000000);
        gListener = llListen( channel, "", "", "");
        ukey=llDetectedKey(0); 
        llDialog(ukey, "current inventory_path: "+INV_FILE_PATH_NAME,
                ["inv_path", "save_iar",["Exit"]], channel);

    }
}