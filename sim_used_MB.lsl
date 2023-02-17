// Simple formatted Output
// shows either MB or GB as applicable
//
//based on: http://opensimulator.org/wiki/OsGetSimulatorMemory
//
// ==== GET Memory Integer and Format for Display ====
GenStats()
{
 // Get Memory and format it
 string TotalMem;
 string TotMemUsed;
 string TxtTail =" used by OpenSim";
 
 TotMemUsed = (string)osGetSimulatorMemory();
 integer Len = llStringLength(TotMemUsed);
 
 if(Len == 8) // ##.### MB
 {
 string Mem1 = llGetSubString(TotMemUsed,0,1);
 string Mem2 = llGetSubString(TotMemUsed,2,4);
 TotalMem = Mem1 + "." + Mem2 + "\nMb"+TxtTail;
 }
 else if(Len == 9) //###.### MB
 {
 string Mem1 = llGetSubString(TotMemUsed,0,2);
 string Mem2 = llGetSubString(TotMemUsed,3,5);
 TotalMem = Mem1 + "." + Mem2 + "\nMb"+TxtTail;
 }
 else if(Len == 10) //#.### GB
 {
 string Mem1 = llGetSubString(TotMemUsed,0,0);
 string Mem2 = llGetSubString(TotMemUsed,1,3);
 TotalMem = Mem1 + "." + Mem2 + "\nGb"+TxtTail;
 }
 else if(Len == 11) //##.### GB
 {
 string Mem1 = llGetSubString(TotMemUsed,0,1);
 string Mem2 = llGetSubString(TotMemUsed,2,4);
 TotalMem = Mem1 + "." + Mem2 + "\nGb"+TxtTail;
 }
 
 llSetText(TotalMem, <0.0,1.0,0.0>, 1.0 );
}
 
default
{
 state_entry() // display @ start
 {
 GenStats();
 string text="sim_used_MB";
 llSetText(text,<1,1,1>,1);
 llSetObjectName(text); 
 }
 touch(integer num) // refresh on touch
 {
 GenStats();
 }
}
