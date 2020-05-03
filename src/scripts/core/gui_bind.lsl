// src.scripts.core.gui_bind.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated

integer debugging = TRUE;
integer guiID;
integer multipageIndex = 0;
key guiUserID;
list guiButtons;
integer guiChannel;
integer guiScreen;
integer guiScreenLast;
string guiText;
integer guiTimeout = 30;

// General Settings
string gender = "female";

// Status
integer _armsBound = FALSE;
integer _legsBound = FALSE;

// Tether Variables
integer _armsTetherable;
integer _legsTetherable;

list availablePoses;

// Restaint Lists
list armRestraints;
list legRestraints;
list gagRestraints;

// Other
integer _armBoundExternal = FALSE;
key configQueryID;
string jsonSettings;

string _resumeFunction;
string _restraints;

debug(string output){
  if (debugging) llOwnerSay(output);
}

simple_request(string prmFunction,string prmValue){
  string request = "";
  (request = llJsonSetValue(request,["function"],prmFunction));
  (request = llJsonSetValue(request,["value"],prmValue));
  llMessageLinked(LINK_THIS,0,request,NULL_KEY);
}

exit(string prmReason){
  llListenRemove(guiID);
  llSetTimerEvent(0.0);
  if (prmReason) {
    simpleRequest("resetGUI",prmReason);
  }
}

guiRequest(string prmGUI,integer prmRestore,key prmUserID,integer prmScreen){
  string local0 = "";
  (local0 = llJsonSetValue(local0,["function"],prmGUI));
  (local0 = llJsonSetValue(local0,["restorescreen"],((string)prmRestore)));
  (local0 = llJsonSetValue(local0,["userkey"],((string)prmUserID)));
  (local0 = llJsonSetValue(local0,["value"],((string)prmScreen)));
  llMessageLinked(LINK_THIS,0,local0,NULL_KEY);
  exit("");
}

list multipageGui(list prmButtons,integer prmRows,integer prmPage){
  list mpGui = [];
  integer buttonCount = llGetListLength(prmButtons);
  integer multipage = FALSE;
  if ((buttonCount > (3 * prmRows))) {
    (multipage = TRUE);
    (mpGui += ["<< Previous"," ","Next >>"]);
    if ((((prmPage * prmRows) * 3) > buttonCount)) {
      (prmPage = 0);
    }
    else  if ((prmPage < 0)) {
      (prmPage = llFloor((buttonCount / ((3 * prmRows) - multipage))));
    }
    (multipageIndex = prmPage);
  }
  integer mpIndex = 0;
  for (mpIndex; (mpIndex < buttonCount); (mpIndex++)) {
    if ((mpIndex >= ((prmPage * prmRows) * (3 - multipage)))) {
      (mpGui += llList2String(prmButtons,mpIndex));
    }
    if ((llGetListLength(mpGui) == (prmRows * 3))) {
      (mpIndex = buttonCount);
    }
  }
  return mpGui;
}

simpleRequest(string prmFunction,string prmValue){
  string request = "";
  (request = llJsonSetValue(request,["function"],prmFunction));
  (request = llJsonSetValue(request,["value"],prmValue));
  llMessageLinked(LINK_THIS,0,request,NULL_KEY);
}

init(){
  (armRestraints = ["Unbound"]);
  (legRestraints = ["Unbound"]);
  (gagRestraints = ["Unbound"]);
  (configQueryID = llGetNotecardLine(".config",0));
  simpleRequest("getAvailableRestraints","all");
}

init_gui(key prmID,integer prmScreen){
  (guiUserID = prmID);
  simple_request("setVillainID",guiUserID);
  if (guiID) {
    llListenRemove(guiID);
  }
  (guiChannel = (((integer)llFrand((-9998))) - 1));
  (guiID = llListen(guiChannel,"",guiUserID,""));
  gui(prmScreen);
}

// ===== GUI =====
gui(integer prmScreen){
  llSetTimerEvent(guiTimeout);
  string btn10 = " ";
  string btn11 = " ";
  string btn12 = " ";
  string btn7 = " ";
  string btn8 = " ";
  string btn9 = " ";
  string btn4 = " ";
  string btn5 = " ";
  string btn6 = " ";
  string btn1 = " ";
  string btn2 = "<<Done>>";
  string btn3 = " ";
  if ((guiUserID == llGetOwner())) {
    (btn1 = "<<Back>>");
  }
  list mpButtons;
  (guiText = " ");
  if ((((integer)llJsonGetValue(jsonSettings,["gagOnly"])) && (prmScreen == 0))) {
    (prmScreen = 30);
  }
  if ((prmScreen != guiScreen)) {
    (guiScreenLast = guiScreen);
  }
  if (((btn1 == " ") && (prmScreen != 0))) {
    (btn1 = "<<Back>>");
  }
  
  if ((prmScreen == 0)) {
    (guiScreenLast = 0);
    if (_armsTetherable) {
      (btn7 = "Tether Arms");
    }
    if (_legsTetherable) {
      (btn7 = "Tether Legs");
    }
    if ((!_armBoundExternal)) {
      (btn4 = "Bind Arms");
    }
    (btn5 = "Bind Legs");
    (btn6 = "Gag");
    if ((llGetListLength(getAvailablePoses()) > 1)) {
      (btn3 = "Position");
    }
  }
  if ((prmScreen == 10)) {
    (guiText = (("What do you want to bind " + getName()) + "'s arms with?"));
    (mpButtons = multipageGui(armRestraints,3,multipageIndex));
  }
  if ((prmScreen == 20)) {
    (guiText = (("What do you want to bind " + getName()) + "'s legs with?"));
    (mpButtons = multipageGui(legRestraints,3,multipageIndex));
  }
  if ((prmScreen == 30)) {
    (guiText = (("What do you want to gag " + getName()) + " with?"));
    (mpButtons = multipageGui(gagRestraints,3,multipageIndex));
    if (((guiUserID != llGetOwner()) && ((integer)llJsonGetValue(jsonSettings,["gagOnly"])))) {
      (btn1 = " ");
    }
  }
  if ((prmScreen == 70)) {
    (guiText = (("How do you want to pose " + getName()) + "?"));
    (mpButtons = multipageGui(getAvailablePoses(),3,multipageIndex));
  }
  (guiScreen = prmScreen);
  (guiButtons = [btn1,btn2,btn3]);
  if ((((btn4 + btn5) + btn6) != "   ")) {
    (guiButtons += [btn4,btn5,btn6]);
  }
  if ((((btn7 + btn8) + btn9) != "   ")) {
    (guiButtons += [btn7,btn8,btn9]);
  }
  if ((((btn10 + btn11) + btn12) != "   ")) {
    (guiButtons += [btn10,btn11,btn12]);
  }
  if (llGetListLength(mpButtons)) {
    (guiButtons += mpButtons);
  }
  llDialog(guiUserID,guiText,guiButtons,guiChannel);
}

// ===== Main Functions =====
addAvailableRestraint(string prmInfo){
  string tmpName = llJsonGetValue(prmInfo,["name"]);
  string tmpPart = llJsonGetValue(prmInfo,["part"]);
  integer hasColor = (llJsonGetValue(prmInfo,["hasColor"]) == "1");
  if ((tmpPart == "arm")) {
    (armRestraints += tmpName);
  }
  else  if ((tmpPart == "leg")) {
    (legRestraints += tmpName);
  }
  else  if ((tmpPart == "gag")) {
    (gagRestraints += tmpName);
  }
}

// ===== Gets =====
string getName(){
  return llGetDisplayName(llGetOwner());
}

list getAvailablePoses(){
  return availablePoses;
}

// ===== Sets =====
setGender(string prmGender){
  (gender = prmGender);
}

set_available_poses(string prmPoses){
  (availablePoses = []);
  list tmpPoses = llJson2List(prmPoses);
  integer i;
  for ((i = 0); (i < llGetListLength(tmpPoses)); (i++)) {
    (availablePoses += llJsonGetValue(llList2String(tmpPoses,i),["name"]));
  }
}

set_restraints(string prmJson){
  (_restraints = prmJson);
  (_armsBound = ((integer)llJsonGetValue(prmJson,["isArmBound"])));
  (_armsTetherable = ((integer)llJsonGetValue(prmJson,["isArmTetherable"])));
  (_armBoundExternal = ((integer)llJsonGetValue(prmJson,["isArmBoundExternal"])));
  (_legsBound = ((integer)llJsonGetValue(prmJson,["isLegBound"])));
  (_legsTetherable = ((integer)llJsonGetValue(prmJson,["isLegTetherable"])));
  set_available_poses(llJsonGetValue(prmJson,["poses"]));
}

// ===== Event Controls =====
execute_function(string prmFunction,string prmJson){
  string value = llJsonGetValue(prmJson,["value"]);
  if ((JSON_INVALID == value)) {
  }
  if ((prmFunction == "setGender")) {
    setGender(value);
  }
  else  if ((prmFunction == "setRestraints")) {
    set_restraints(value);
  }
  else  if ((prmFunction == "addAvailableRestraint")) {
    addAvailableRestraint(value);
  }
  else  if ((prmFunction == "gui_bind")) {
    key userkey = ((key)llJsonGetValue(prmJson,["userkey"]));
    integer screen = 0;
    if ((((integer)llJsonGetValue(prmJson,["restorescreen"])) && guiScreen)) {
      (screen = guiScreen);
    }
    init_gui(userkey,screen);
  }
  else  if ((prmFunction == "resetGUI")) {
    exit("");
  }
}
	

default {

	state_entry() {
    init();
  }


	on_rez(integer prmStart) {
    init();
  }


	dataserver(key queryID,string configData) {
    if ((queryID == configQueryID)) {
      (jsonSettings = configData);
    }
  }


	listen(integer prmChannel,string prmName,key prmID,string prmText) {
    if ((prmChannel = guiChannel)) {
      if ((prmText == "<<Done>>")) {
        exit("done");
        return;
      }
      else  if ((prmText == " ")) {
        gui(guiScreen);
      }
      else  if ((((prmText == "<<Back>>") && (guiScreen == 30)) && ((integer)llJsonGetValue(jsonSettings,["gagOnly"])))) {
        guiRequest("gui_owner",FALSE,guiUserID,0);
        return;
      }
      else  if (((guiScreen != 0) && (prmText == "<<Back>>"))) {
        gui(guiScreenLast);
        return;
      }
      else  if ((prmText == "Next >>")) {
        (multipageIndex++);
        gui(guiScreen);
        return;
      }
      else  if ((prmText == "<< Previous")) {
        (multipageIndex--);
        gui(guiScreen);
        return;
      }
      if ((guiScreen == 0)) {
        if ((prmText == "Bind Arms")) {
          gui(10);
        }
        else  if ((prmText == "Bind Legs")) {
          gui(20);
        }
        else  if ((prmText == "Gag")) {
          gui(30);
        }
        else  if ((prmText == "Position")) {
          gui(70);
        }
        else  if ((prmText == "Tether Arms")) {
          guiRequest("gui_tether_arm",FALSE,guiUserID,0);
          return;
        }
        else  if ((prmText == "Tether Legs")) {
          guiRequest("gui_tether_leg",FALSE,guiUserID,0);
          return;
        }
        else  if ((prmText == "<<Back>>")) {
          guiRequest("gui_owner",FALSE,guiUserID,0);
          return;
        }
      }
      else  if ((guiScreen == 10)) {
        if ((prmText == "Unbound")) {
          simpleRequest("releaseRestraint","arm");
          gui(guiScreen);
          return;
        }
        guiRequest(("gui_arm_" + llToLower(prmText)),FALSE,guiUserID,0);
        return;
      }
      else  if ((guiScreen == 20)) {
        if ((prmText == "Unbound")) {
          simpleRequest("releaseRestraint","leg");
          gui(guiScreen);
          return;
        }
        guiRequest(("gui_leg_" + llToLower(prmText)),FALSE,guiUserID,0);
        return;
      }
      else  if ((guiScreen == 30)) {
        if ((prmText == "Unbound")) {
          simpleRequest("releaseRestraint","gag");
          gui(guiScreen);
          return;
        }
        guiRequest(("gui_gag_" + llToLower(prmText)),FALSE,guiUserID,0);
        return;
      }
      else  if ((guiScreen == 70)) {
        simpleRequest("setPose",prmText);
        gui(guiScreen);
        return;
      }
    }
  }


	link_message(integer prmLink,integer prmValue,string prmText,key prmID) {
    string function = llJsonGetValue(prmText,["function"]);
    if ((JSON_INVALID == function)) {
      debug(prmText);
      return;
    }
    execute_function(function,prmText);
    if ((function == _resumeFunction)) {
      (_resumeFunction = "");
      init_gui(guiUserID,guiScreen);
    }
  }


	timer() {
    exit("timeout");
  }
}
// src.scripts.core.gui_bind.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated
