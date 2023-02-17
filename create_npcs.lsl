list bots = ["barkeeper", "slave", "monkey"];
 
default
{
state_entry()
{
string text="create_npcs";
llSetText(text,<1,1,1>,1);
llSetObjectName(text);   
}    

touch_start(integer number)
{
vector npcPos = llGetPos() + <1,0,0>;
osAgentSaveAppearance(llDetectedKey(0), "appearance");
integer x;
integer length = llGetListLength(bots);
key npc;
 
for (x = 0; x < length; x++)
{
 
npc = osNpcCreate(llList2String(bots, x), "Resident", npcPos, "appearance");
}
}
}