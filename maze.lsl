// Maze Generator
// by Apotheus Silverman
//
// Adapted from txtmazea.bas and txtmazec.bas by Jonathan Dale Kirwan
// http://users.easystreet.com/jkirwan/new/zips+src/txtmazea.bas
// http://users.easystreet.com/jkirwan/TXTMAZEC.BAS
//
// ListReplaceList() from LSL Wiki
//
// SetBit(), ClearBit(), GetBit() by Huns Valen
//

integer mazeWidth = 6;
integer mazeHeight = 6;
float relativeZ = 0.0;
integer packBits = 32;
list westWalls;
list southWalls;


// Packs a vector into an integer with a precision of one meter
integer PackVector(vector vec) {
    return((integer)vec.x * 1000000 + (integer)vec.y * 1000 + (integer)vec.z);
}

// Rezzes a wall segment and sends it to the appropriate location
RezWall(integer mazeWidth, integer mazeHeight, integer x, integer y) {
    vector rezPos = <-mazeWidth + x - 2, -mazeHeight + y - 2, relativeZ> + llGetPos();
    integer packedRezPos = PackVector(rezPos);
    llRezObject("Wall", llGetPos() + <0,0,1>, ZERO_VECTOR, ZERO_ROTATION, packedRezPos);
}

// ListReplaceList() from LSL Wiki
// replaces item number _pos_ in list _dest_ with list _src_
// negative values for _pos_ means count from the end of
// the list instead, so a _pos_ of -1 means replace the last item in the list
list ListReplaceList(list dest, list src, integer pos) {
    if (pos > llGetListLength(dest)) {
        llSay(0, "Error: Index " + (string)pos + " is greater than list length " + (string)llGetListLength(dest));
        return(dest);
    }
    if (pos < 0) {
        pos = llGetListLength(dest) + pos;
    }
    return llListInsertList(llDeleteSubList(dest, pos, pos), src, pos);
}

// Sets a bit in an integer bitfield and returns the bitfield
integer SetBit(integer x, integer bit) {
    return(x | ((integer)llPow(2, (float)bit)));
}

// Clears a bit in an integer bitfield and returns the bitfield
integer ClearBit(integer x, integer bit) {
    return(x & (~(integer)llPow(2, (float)bit)));
}

// Reads a bit in an integer bitfield and returns the bit
integer GetBit(integer x, integer bit) {
    if(x & (integer)llPow(2, bit))
        return(TRUE);
    else
        return(FALSE);
}


// Spit out the "maze build" command usage.
Usage() {
    llSay(0, "Usage: maze build [XxY]");
    llSay(0, "maze build by itself will build a maze with the default size of " + (string)(mazeWidth * 2) + "x" + (string)(mazeHeight * 2) + ".");
    llSay(0, "maze build 10x10 will build a maze that is 10 meters on each side.");
}







//   This routine accepts a width and height for a maze and calculates a
//   random maze into two arrays designed to hold the west and south walls
//   of each room or cell in the maze grid.  These can then be used to print
//   or use the maze, as desired (such as a random labyrinth for a game.)
GenerateMaze (integer mazeWidth, integer mazeHeight) {
    integer i;
    integer j;
    integer k;
    integer exitCount;
    integer selection;
    integer unvisitedRoomCount;
    integer currentRoom;
    integer count;
    integer element;
    list visited;
    list exits;
    list paths;

    for (i = 0; i < 4; i++) {
        exits += 0;
    }

    // This code redimensions the west and south wall arrays, as needed.
    // These arrays must be redimensionable, or an error will result.
    // As an important side effect I'm depending on, redimensioning
    // these arrays causes their element values to be initialized to 0.
    for (i = 0; i < (integer)((((mazeWidth + 2) * (mazeHeight + 2)) + 15) / packBits); i++) {
        westWalls += [0];
        southWalls += [0];
        visited += [0];
        paths += [0];
    }

    // Set up our local copy of the visitation status array.  Since the
    // grid uses a perimeter around the maze itself, we need to mark the
    // rooms in the perimeter as having been used, so that the intervening
    // walls are not removed (since those walls are the maze's boundary.)
    j = (mazeWidth + 2) * (mazeHeight + 1) - 1;
    for (i = 0; i <= mazeWidth + 2; i++) {
        element = i / packBits;
        visited = ListReplaceList(visited, [SetBit(llList2Integer(visited, element), i % packBits)], element);
        element = (i + j) / packBits;
        visited = ListReplaceList(visited, [SetBit(llList2Integer(visited, element), (i + j) % packBits)], element);
    }
    j = mazeWidth + mazeWidth + 3;
    for (i = 1; i <= mazeHeight; i++) {
        element = j / packBits;
        visited = ListReplaceList(visited, [SetBit(llList2Integer(visited, element), j % packBits)], element);
        element = (j + 1) / packBits;
        visited = ListReplaceList(visited, [SetBit(llList2Integer(visited, element), (j + 1) % packBits)], element);
        j += mazeWidth + 2;
    }

    // Arrays are set up, the perimeter is initialized, we're ready to go.
    // Compute the maze!  (See the discussion on the web site for details.)
    unvisitedRoomCount = mazeWidth * mazeHeight;
    j = (integer)llFrand(unvisitedRoomCount);
    currentRoom = (1 + i / mazeWidth) * (mazeWidth + 2) + (i % mazeWidth) + 1;


    while (unvisitedRoomCount > 1) {
        unvisitedRoomCount -= 1;
        element = currentRoom / packBits;
        visited = ListReplaceList(visited, [SetBit(llList2Integer(visited, element), currentRoom % packBits)], element);

        while (TRUE) {
            exitCount = 0;
            element = (currentRoom - mazeWidth - 2) / packBits;
            if (!GetBit(llList2Integer(visited, element), (currentRoom - mazeWidth - 2) % packBits)) {
                exits = ListReplaceList(exits, [1], exitCount);
                exitCount += 1;
            }
            element = (currentRoom + mazeWidth + 2) / packBits;
            if (!GetBit(llList2Integer(visited, element), (currentRoom + mazeWidth + 2) % packBits)) {
                exits = ListReplaceList(exits, [2], exitCount);
                exitCount += 1;
            }
            element = (currentRoom - 1) / packBits;
            if (!GetBit(llList2Integer(visited, element), (currentRoom - 1) % packBits)) {
                exits = ListReplaceList(exits, [3], exitCount);
                exitCount += 1;
            }
            element = (currentRoom + 1) / packBits;
            if (!GetBit(llList2Integer(visited, element), (currentRoom + 1) % packBits)) {
                exits = ListReplaceList(exits, [4], exitCount);
                exitCount += 1;
            }
            if (exitCount >= 1) {
                jump endLoop;
            }
            j = (integer)llFrand(mazeWidth * mazeHeight);
            k = ((1 + j / mazeWidth) * (mazeWidth + 2) + (j % mazeWidth) + 1) / packBits;
            while (!llList2Integer(paths, k)) {
                k -= 1;
                if (k < 0) {
                    k = ((mazeWidth + 2) * (mazeHeight + 2) - 1) / packBits;
                }
            }
            for (i = 0; i < packBits; i++) {
                if (GetBit(llList2Integer(paths, k), i)) {
                    jump endFor;
                }
            }
            @endFor;
            paths = ListReplaceList(paths, [ClearBit(llList2Integer(paths, k), i)], k);
            currentRoom = k * packBits + i;
        }
        @endLoop;

        if (exitCount > 1) {
            element = currentRoom / packBits;
            paths = ListReplaceList(paths, [SetBit(llList2Integer(paths, element), currentRoom % packBits)], element);
        }
        selection = (integer)llFrand(exitCount);
        if (llList2Integer(exits, selection) == 1) {
            currentRoom -= mazeWidth + 2;
            element = currentRoom / packBits;
            southWalls = ListReplaceList(southWalls, [SetBit(llList2Integer(southWalls, element), currentRoom % packBits)], element);
        } else if (llList2Integer(exits, selection) == 2) {
            element = currentRoom / packBits;
            southWalls = ListReplaceList(southWalls, [SetBit(llList2Integer(southWalls, element), currentRoom % packBits)], element);
            currentRoom += mazeWidth + 2;
        } else if (llList2Integer(exits, selection) == 3) {
            element = currentRoom / packBits;
            westWalls = ListReplaceList(westWalls, [SetBit(llList2Integer(westWalls, element), currentRoom % packBits)], element);
            currentRoom -= 1;
        } else if (llList2Integer(exits, selection) == 4) {
            currentRoom += 1;
            element = currentRoom / packBits;
            westWalls = ListReplaceList(westWalls, [SetBit(llList2Integer(westWalls, element), currentRoom % packBits)], element);
        }
    }

    // Add an entrance and exit to the maze.  These could be placed
    // anywhere around the perimeter, if we wanted to.  For now, it's
    // hard-coded at the upper-left corner and the lower-right corner.
    southWalls = ListReplaceList(southWalls, [SetBit(llList2Integer(southWalls, 0), 1)], 0);
    j = (mazeHeight + 1) * (mazeWidth + 2) - 2;
    element = j / packBits;
    southWalls = ListReplaceList(southWalls, [SetBit(llList2Integer(southWalls, element), j % packBits)], element);
}


// This routine accepts a width and height and rezzes the wall segments
// appropriately to create the maze.
BuildMaze(integer mazeWidth, integer mazeHeight) {
    integer i;
    integer j;
    integer p;
    integer element;

    for (i = 1; i <= mazeWidth; i++) {
        RezWall(mazeWidth, mazeHeight, i * 2, 1);
        element = i / packBits;
        if (!GetBit(llList2Integer(southWalls, element), i % packBits)) {
            RezWall(mazeWidth, mazeHeight, (i * 2) + 1, 1);
        }
    }
    RezWall(mazeWidth, mazeHeight, (mazeWidth * 2) + 2, 1);

    p = 0;
    for (i = 1; i <= mazeHeight; i++) {
        p += mazeWidth + 2;
        for (j = 1; j <= mazeWidth; j++) {
            element = (p + j) / packBits;
            if (!GetBit(llList2Integer(westWalls, element), (p + j) % packBits)) {
                RezWall(mazeWidth, mazeHeight, j * 2, i * 2);
            }
        }
        element = (p + mazeWidth + 1) / packBits;
        if (!GetBit(llList2Integer(westWalls, element), (p + mazeWidth + 1) % packBits)) {
            RezWall(mazeWidth, mazeHeight, (mazeWidth * 2) + 2, i * 2);
        }
        for (j = 1; j <= mazeWidth; j++) {
            RezWall(mazeWidth, mazeHeight, j * 2, (i * 2) + 1);
            element = (p + j) / packBits;
            if (!GetBit(llList2Integer(southWalls, element), (p + j) % packBits)) {
                RezWall(mazeWidth, mazeHeight, (j * 2) + 1, (i * 2) + 1);
            }
        }
        RezWall(mazeWidth, mazeHeight, (mazeWidth * 2) + 2, (i * 2) + 1);
    }
}

integer BOOT_TIME;

default {
    state_entry() {
        llSetText("", <1,1,1>, 1.0);
        llListen(0, "", llGetOwner(), "");
    }

    on_rez(integer start_param) {
        Usage();
    llResetScript();
    }

    listen(integer channel, string name, key id, string message) {
        string myMessage = llToLower(message);
        if (myMessage == "maze reset") {
            llResetScript();
        } else if (llGetSubString(myMessage, 0, 9) == "maze build") {
            integer myMazeWidth = mazeWidth * 2;
            integer myMazeHeight = mazeHeight * 2;
             BOOT_TIME = llGetUnixTime(); 
            // This entire validation block could be handled with a single regexp test.
            if (llStringLength(myMessage) > 13) {
                if (llGetSubString(myMessage, 10, 10) == " " && llSubStringIndex(myMessage, "x") > -1) {
                    list dimensions = llParseString2List(llGetSubString(myMessage, 11, -1), ["x"], []);
                    if (llGetListLength(dimensions) == 2) {
                        myMazeWidth = llList2Integer(dimensions, 0);
                        myMazeHeight = llList2Integer(dimensions, 1);
                    } else {
                        myMazeWidth = 0;
                    }
                } else {
                    myMazeWidth = 0;
                }
            }

            if (myMazeWidth == 0 || myMazeHeight == 0) {
                llSay(0, "Invalid parameter " + llGetSubString(myMessage, 11, -1));
                Usage();
            } else {
                llSay(0, "Generating " + (string)myMazeWidth + " x " + (string)myMazeHeight + " maze. Please wait...");
                GenerateMaze(myMazeWidth / 2, myMazeHeight / 2);
                //llSay(0, "Maze generated. Building...");
                //llSay(0, llDumpList2String(southWalls, ""));
                //llSay(0, llDumpList2String(westWalls, ""));
                BuildMaze(myMazeWidth / 2, myMazeHeight / 2);
                llSay(0,(string)(llGetUnixTime() - BOOT_TIME) + " Seconds for maze building.");

                llResetScript();
            }
        }
    }
}