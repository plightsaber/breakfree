// src.scripts.core.gui_arm_rope.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated

integer _slot;
string _self;
string _restraints;
string _resumeFunction;
integer debugging = TRUE;
integer CHANNEL_ATTACHMENT = -9999277;
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

// Colors
vector COLOR_WHITE = <1.0,1.0,1.0>;
vector COLOR_BROWN = <0.8240000000000001,0.549,0.35300000000000004>;

vector color = COLOR_WHITE;
list colors = ["White","Brown"];
list colorVals = [COLOR_WHITE,COLOR_BROWN];

// ===== Main Functions =====
set_restraints(string prmJson){
  (_slot = 0);
  (_restraints = prmJson);
  string armRestraints = llJsonGetValue(prmJson,["arm"]);
  if ((JSON_NULL == armRestraints)) return;
  list liArmRestraints = llJson2List(armRestraints);
  string armRestraint = llList2String(liArmRestraints,(-1));
  (_slot = ((integer)llJsonGetValue(armRestraint,["slot"])));
}

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

simpleAttachedRequest(string prmFunction,string prmValue){
  string request = "";
  (request = llJsonSetValue(request,["function"],prmFunction));
  (request = llJsonSetValue(request,["value"],prmValue));
  llRegionSayTo(llGetOwner(),CHANNEL_ATTACHMENT,request);
}

simpleRequest(string prmFunction,string prmValue){
  string request = "";
  (request = llJsonSetValue(request,["function"],prmFunction));
  (request = llJsonSetValue(request,["value"],prmValue));
  llMessageLinked(LINK_THIS,0,request,NULL_KEY);
}

string getSelf(){
  if ((_self != "")) return _self;
  (_self = llJsonSetValue(_self,["name"],"Rope"));
  (_self = llJsonSetValue(_self,["part"],"arm"));
  (_self = llJsonSetValue(_self,["hasColor"],"1"));
  return _self;
}

// ===== Initializers =====
init_gui(key prmID,integer prmScreen){
  (guiUserID = prmID);
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
  string btn1 = "<<Back>>";
  string btn2 = "<<Done>>";
  string btn3 = " ";
  list mpButtons;
  (guiText = " ");
  if ((prmScreen == 0)) {
    (btn3 = "<<Color>>");
    if (_slot) {
      (mpButtons += "Untie");
    }
    else  {
      (mpButtons += "Front");
      (mpButtons += "F+Sides");
      (mpButtons += "Back");
      (mpButtons += "B+Sides");
    }
    (mpButtons = multipageGui(mpButtons,2,multipageIndex));
  }
  else  if ((prmScreen == 100)) {
    (guiText = "Choose a color for the arm ropes.");
    (mpButtons = multipageGui(colors,3,multipageIndex));
  }
  if ((prmScreen != guiScreen)) {
    (guiScreenLast = guiScreen);
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
add_restraint(string prmName){
  string restraint;
  (restraint = llJsonSetValue(restraint,["name"],prmName));
  (restraint = llJsonSetValue(_self,["canCut"],"1"));
  (restraint = llJsonSetValue(restraint,["canEscape"],"1"));
  (restraint = llJsonSetValue(restraint,["canTether"],"1"));
  (restraint = llJsonSetValue(restraint,["canUseItem"],"1"));
  (restraint = llJsonSetValue(restraint,["type"],"knot"));
  if ((prmName == "Sides")) {
    (restraint = llJsonSetValue(restraint,["slot"],"3"));
    (restraint = llJsonSetValue(restraint,["difficulty"],"4"));
    (restraint = llJsonSetValue(restraint,["tightness"],"15"));
    (restraint = llJsonSetValue(restraint,["animation_base"],"animArmSides"));
    (restraint = llJsonSetValue(restraint,["animation_success"],"animBaseWriggle"));
    (restraint = llJsonSetValue(restraint,["animation_failure"],"animBaseThrash"));
    (restraint = llJsonSetValue(restraint,["attachments"],llList2Json(JSON_ARRAY,["arSides"])));
  }
  else  if ((prmName == "Front")) {
    (restraint = llJsonSetValue(restraint,["slot"],"1"));
    (restraint = llJsonSetValue(restraint,["difficulty"],"4"));
    (restraint = llJsonSetValue(restraint,["tightness"],"20"));
    (restraint = llJsonSetValue(restraint,["animation_base"],"animArmFront"));
    (restraint = llJsonSetValue(restraint,["animation_success"],"animBaseWriggle"));
    (restraint = llJsonSetValue(restraint,["animation_failure"],"animBaseThrash"));
    (restraint = llJsonSetValue(restraint,["attachments"],llList2Json(JSON_ARRAY,["arFront"])));
  }
  else  if ((prmName == "F+Sides")) {
    (restraint = llJsonSetValue(restraint,["slot"],"3"));
    (restraint = llJsonSetValue(restraint,["difficulty"],"6"));
    (restraint = llJsonSetValue(restraint,["tightness"],"25"));
    (restraint = llJsonSetValue(restraint,["animation_base"],"animArmFront"));
    (restraint = llJsonSetValue(restraint,["animation_success"],"animBaseWriggle"));
    (restraint = llJsonSetValue(restraint,["animation_failure"],"animBaseThrash"));
    (restraint = llJsonSetValue(restraint,["attachments"],llList2Json(JSON_ARRAY,["arFront","arHarness","arHarnessFront"])));
  }
  else  if ((prmName == "Back")) {
    (restraint = llJsonSetValue(restraint,["slot"],"1"));
    (restraint = llJsonSetValue(restraint,["difficulty"],"6"));
    (restraint = llJsonSetValue(restraint,["tightness"],"20"));
    (restraint = llJsonSetValue(restraint,["animation_base"],"animArmPoseXBack"));
    (restraint = llJsonSetValue(restraint,["animation_success"],"animBaseWriggle"));
    (restraint = llJsonSetValue(restraint,["animation_failure"],"animBaseThrash"));
    (restraint = llJsonSetValue(restraint,["attachments"],llList2Json(JSON_ARRAY,["arXBack"])));
  }
  else  if ((prmName == "B+Sides")) {
    (restraint = llJsonSetValue(restraint,["slot"],"3"));
    (restraint = llJsonSetValue(restraint,["difficulty"],"8"));
    (restraint = llJsonSetValue(restraint,["tightness"],"25"));
    (restraint = llJsonSetValue(restraint,["animation_base"],"animArmPoseXBack"));
    (restraint = llJsonSetValue(restraint,["animation_success"],"animBaseWriggle"));
    (restraint = llJsonSetValue(restraint,["animation_failure"],"animBaseThrash"));
    (restraint = llJsonSetValue(restraint,["attachments"],llList2Json(JSON_ARRAY,["arXBack","arHarness","arHarnessBack"])));
  }
  string restraintSet;
  (restraintSet = llJsonSetValue(restraintSet,["type"],"arm"));
  (restraintSet = llJsonSetValue(restraintSet,["restraint"],restraint));
  simple_request("addRestraint",restraintSet);
}

sendAvailabilityInfo(){
  simpleRequest("addAvailableRestraint",getSelf());
}

// Color Functions
setColorByName(string prmColorName){
  integer tmpColorIndex = llListFindList(colors,[prmColorName]);
  setColor(llList2Vector(colorVals,tmpColorIndex));
}
setColor(vector prmColor){
  (color = prmColor);
  string tmpRequest = "";
  (tmpRequest = llJsonSetValue(tmpRequest,["color"],((string)color)));
  (tmpRequest = llJsonSetValue(tmpRequest,["attachment"],"arm"));
  (tmpRequest = llJsonSetValue(tmpRequest,["userKey"],((string)llGetOwner())));
  simpleAttachedRequest("setColor",tmpRequest);
  simpleRequest("setColor",tmpRequest);
}

// ===== Sets =====
setGender(string prmGender){
  (gender = prmGender);
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
  else  if ((prmFunction == "getAvailableRestraints")) {
    sendAvailabilityInfo();
  }
  else  if ((prmFunction == "requestColor")) {
    if ((llJsonGetValue(value,["attachment"]) != "arm")) {
      return;
    }
    if ((llJsonGetValue(value,["name"]) != "rope")) {
      return;
    }
    setColor(color);
  }
  else  if ((prmFunction == "gui_arm_rope")) {
    key userkey = ((key)llJsonGetValue(prmJson,["userkey"]));
    integer screen = 0;
    if ((((integer)llJsonGetValue(prmJson,["restorescreen"])) && guiScreenLast)) {
      (screen = guiScreenLast);
    }
    init_gui(userkey,screen);
  }
  else  if ((prmFunction == "resetGUI")) {
    exit("");
  }
}

default {

	listen(integer prmChannel,string prmName,key prmID,string prmText) {
    if ((prmChannel = guiChannel)) {
      if ((prmText == "<<Done>>")) {
        exit("done");
        return;
      }
      else  if ((prmText == " ")) {
        gui(guiScreen);
        return;
      }
      else  if ((prmText == "<<Back>>")) {
        if ((guiScreen != 0)) {
          gui(guiScreenLast);
          return;
        }
        guiRequest("gui_bind",TRUE,guiUserID,0);
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
      if ((prmText == "Untie")) {
        simple_request("remRestraint","arm");
        (_resumeFunction = "setRestraints");
        return;
      }
      if ((guiScreen == 0)) {
        if ((prmText == "<<Color>>")) {
          gui(100);
          return;
        }
        else  {
          add_restraint(prmText);
          (_resumeFunction = "setRestraints");
          return;
        }
      }
      else  if ((guiScreen == 100)) {
        setColorByName(prmText);
        gui(guiScreen);
        return;
      }
    }
  }


	link_message(integer prmLink,integer prmValue,string prmText,key prmID) {
    string function;
    string value;
    if (((function = llJsonGetValue(prmText,["function"])) == JSON_INVALID)) {
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
// src.scripts.core.gui_arm_rope.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated
