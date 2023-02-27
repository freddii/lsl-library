// Maze Wall
// by Apotheus Silverman
//
// SetPos() by Christopher Omega


// Unpacks a vector which was previously packed into an integer with a precision of one meter
vector UnpackVector(integer vectorInt) {
    integer x = vectorInt / 1000000;
    integer y = (vectorInt - (x * 1000000)) / 1000;
    integer z = vectorInt - (x * 1000000) - (y * 1000);
    return(<x,y,z>);
}

// SetPos() by Christopher Omega
// /15/a4/9900/1.html
SetPos(vector dest) {
    float dist = llVecDist(dest,llGetPos());
    vector prevPos;
    while(dist > 0) {
        prevPos = llGetPos();
        llSetPos(dest);
        if(llGetPos() == prevPos) {
            // Yipes! The object didnt move! Occurs with float error.
            //llSay(0,"Float error detected and recovered from.");
            return; // return from this function immediately.
        }
        dist = llVecDist(dest,llGetPos());
    }
}


default {
    state_entry() 
    {
    }

listen(integer channel, string name, key id, string message)
    {
        llDie();    
    }

    on_rez(integer startParam) {
        if (startParam == 0) {
            llDie();
        } else {llListen(0, "", llGetOwner(), "die");
            vector myPos = UnpackVector(startParam);
            //llSay(0, "Moving to " + (string)myPos);
            SetPos(myPos);
        }
    }
}