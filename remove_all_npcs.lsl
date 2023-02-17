default
{
state_entry()
{
string text="remove_all_npcs";
llSetText(text,<1,1,1>,1);
llSetObjectName(text);   
}    

touch_start(integer number)
{
list avatars = llList2ListStrided(osGetAvatarList(), 0, -1, 3);
integer i;
llSay(0,"NPC Removal: No avatars will be harmed or removed in this process!");
for (i=0; i<llGetListLength(avatars); i++)
{
string target = llList2String(avatars, i);
osNpcRemove(target);
llSay(0,"NPC Removal: Target "+target);
}
}
}