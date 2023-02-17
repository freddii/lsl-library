# lsl-library
opensimulator lsl library for scripts with OSSL functions. scripts work only in opensim

to run this scripts you need to change some settings:  
first get from the console the ID of the user that wants to test the scripts:  
Region (My Opensim Server) # show account Test User  
Name:    Test User  
ID:      YOUR_LONG_ID  


Replace YOUR_LONG_ID with your own ID in the following code, then run it:  

YOUR_LONG_ID="a2e76fcd-9360-4f6d-a924-000000000003"  
PathToDir="$HOME"  
  
##for diva distro  
echo "[XEngine]" | sudo tee -a  $PathToDir/diva-r*/bin/config-include/MyWorld.ini  
echo "    AllowOSFunctions = true" | sudo tee -a  $PathToDir/diva-r*/bin/config-include/MyWorld.ini  
echo "    Allow_osConsoleCommand = $YOUR_LONG_ID" | sudo tee -a  $PathToDir/diva-r*/bin/config-include/MyWorld.ini  
echo "[NPC]" | sudo tee -a  $PathToDir/diva-r*/bin/config-include/MyWorld.ini  
echo "Enabled = true" | sudo tee -a  $PathToDir/diva-r*/bin/config-include/MyWorld.ini  
  
##for opensim 0.9.0  
echo "[XEngine]" | sudo tee -a  $PathToDir/opensim-0.9*/bin/config-include/StandaloneCommon.ini  
echo "    AllowOSFunctions = true" | sudo tee -a  $PathToDir/opensim-0.9*/bin/config-include/StandaloneCommon.ini  
echo "    Allow_osConsoleCommand = $YOUR_LONG_ID" | sudo tee -a  $PathToDir/opensim-0.9*/bin/config-include/StandaloneCommon.ini  
echo "[NPC]" | sudo tee -a  $PathToDir/opensim-0.9*/bin/config-include/StandaloneCommon.ini  
echo "Enabled = true" | sudo tee -a  $PathToDir/opensim-0.9*/bin/config-include/StandaloneCommon.ini  

##for opensim 0.9.1  
echo "[OSSL]" | sudo tee -a  $PathToDir/opensim-0.9*/bin/config-include/StandaloneCommon.ini  
echo "    AllowOSFunctions = true" | sudo tee -a  $PathToDir/opensim-0.9*/bin/config-include/StandaloneCommon.ini  
echo "    Allow_osConsoleCommand = $YOUR_LONG_ID" | sudo tee -a  $PathToDir/opensim-0.9*/bin/config-include/StandaloneCommon.ini  
echo "[NPC]" | sudo tee -a  $PathToDir/opensim-0.9*/bin/config-include/StandaloneCommon.ini  
echo "Enabled = true" | sudo tee -a  $PathToDir/opensim-0.9*/bin/config-include/StandaloneCommon.ini 

