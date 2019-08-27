
integer guiID;
integer multipageIndex = 0;

string self;
//string restraint;  // JSON object

integer CHANNEL_ATTACHMENT = -9999277;

// General Settings
string gender = "female";

// Status
string armsBound = "free";

// Colors
vector COLOR_WHITE = <1.0,1.0,1.0>;
vector COLOR_BROWN = <0.8240000000000001,0.549,0.35300000000000004>;

vector color = COLOR_WHITE;
list colors = ["White","Brown"];
list colorVals = [COLOR_WHITE,COLOR_BROWN];

// GUI variables
key guiUserID;
list guiButtons;
integer guiChannel;
integer guiScreen;
integer guiScreenLast;
string guiText;
integer guiTimeout = 30;

exit(string prmReason){
  llListenRemove(guiID);
  llSetTimerEvent(0.0);
  if (prmReason) {
    simpleRequest("resetGUI",prmReason);
  }
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

string getSelf(){
  if ((self != "")) return self;
  (self = llJsonSetValue(self,["name"],"Rope"));
  (self = llJsonSetValue(self,["part"],"arm"));
  (self = llJsonSetValue(self,["hasColor"],"1"));
  return self;
}

initGui(key prmID,integer prmScreen){
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
    if ((armsBound != "free")) {
      (btn4 = "Untie");
    }
    (btn11 = "Front");
    (btn12 = "F+Sides");
    (btn7 = "Back");
    (btn9 = "B+Sides");
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
bindArms(string prmType,integer prmSend){
  string restraint;
  if ((prmType == "free")) {
    setArmsBound("free");
    if (prmSend) {
      simpleRequest("bindArms","free");
    }
  }
  else  {
    setArmsBound("bound");
    (restraint = llJsonSetValue(self,["canCut"],"1"));
    (restraint = llJsonSetValue(restraint,["canEscape"],"1"));
    (restraint = llJsonSetValue(restraint,["canTether"],"1"));
    (restraint = llJsonSetValue(restraint,["canUseItem"],"1"));
    (restraint = llJsonSetValue(restraint,["type"],"knot"));
    if ((prmType == "Sides")) {
      (restraint = llJsonSetValue(restraint,["difficulty"],"4"));
      (restraint = llJsonSetValue(restraint,["tightness"],"15"));
      (restraint = llJsonSetValue(restraint,["animation_base"],"animArmSides"));
      (restraint = llJsonSetValue(restraint,["animation_success"],"animBaseWriggle"));
      (restraint = llJsonSetValue(restraint,["animation_failure"],"animBaseThrash"));
      (restraint = llJsonSetValue(restraint,["attachments"],llList2Json(JSON_ARRAY,["arSides"])));
    }
    else  if ((prmType == "Front")) {
      (restraint = llJsonSetValue(restraint,["difficulty"],"4"));
      (restraint = llJsonSetValue(restraint,["tightness"],"20"));
      (restraint = llJsonSetValue(restraint,["animation_base"],"animArmFront"));
      (restraint = llJsonSetValue(restraint,["animation_success"],"animBaseWriggle"));
      (restraint = llJsonSetValue(restraint,["animation_failure"],"animBaseThrash"));
      (restraint = llJsonSetValue(restraint,["attachments"],llList2Json(JSON_ARRAY,["arFront"])));
    }
    else  if ((prmType == "F+Sides")) {
      (restraint = llJsonSetValue(restraint,["difficulty"],"6"));
      (restraint = llJsonSetValue(restraint,["tightness"],"25"));
      (restraint = llJsonSetValue(restraint,["animation_base"],"animArmFront"));
      (restraint = llJsonSetValue(restraint,["animation_success"],"animBaseWriggle"));
      (restraint = llJsonSetValue(restraint,["animation_failure"],"animBaseThrash"));
      (restraint = llJsonSetValue(restraint,["attachments"],llList2Json(JSON_ARRAY,["arFront","arHarness","arHarnessFront"])));
    }
    else  if ((prmType == "Back")) {
      (restraint = llJsonSetValue(restraint,["difficulty"],"6"));
      (restraint = llJsonSetValue(restraint,["tightness"],"20"));
      (restraint = llJsonSetValue(restraint,["animation_base"],"animArmPoseXBack"));
      (restraint = llJsonSetValue(restraint,["animation_success"],"animBaseWriggle"));
      (restraint = llJsonSetValue(restraint,["animation_failure"],"animBaseThrash"));
      (restraint = llJsonSetValue(restraint,["attachments"],llList2Json(JSON_ARRAY,["arXBack"])));
    }
    else  if ((prmType == "B+Sides")) {
      (restraint = llJsonSetValue(restraint,["difficulty"],"8"));
      (restraint = llJsonSetValue(restraint,["tightness"],"25"));
      (restraint = llJsonSetValue(restraint,["animation_base"],"animArmPoseXBack"));
      (restraint = llJsonSetValue(restraint,["animation_success"],"animBaseWriggle"));
      (restraint = llJsonSetValue(restraint,["animation_failure"],"animBaseThrash"));
      (restraint = llJsonSetValue(restraint,["attachments"],llList2Json(JSON_ARRAY,["arXBack","arHarness","arHarnessBack"])));
    }
    if (prmSend) {
      simpleRequest("bindArms",restraint);
    }
  }
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

setArmsBound(string prmArmsBound){
  (armsBound = prmArmsBound);
}

// ===== Other Functions =====
debug(string output){
  llOwnerSay(output);
}

guiRequest(string prmGUI,integer prmRestore,key prmUserID,integer prmScreen){
  string guiRequest = "";
  (guiRequest = llJsonSetValue(guiRequest,["function"],prmGUI));
  (guiRequest = llJsonSetValue(guiRequest,["restorescreen"],((string)prmRestore)));
  (guiRequest = llJsonSetValue(guiRequest,["userkey"],((string)prmUserID)));
  (guiRequest = llJsonSetValue(guiRequest,["value"],((string)prmScreen)));
  llMessageLinked(LINK_THIS,0,guiRequest,NULL_KEY);
  exit("");
}

simpleAttachedRequest(string prmFunction,string prmValue){
  string request = "";
  (request = llJsonSetValue(request,["function"],prmFunction));
  (request = llJsonSetValue(request,["value"],prmValue));
  llRegionSayTo(llGetOwner(),CHANNEL_ATTACHMENT,request);
}

// ===== Event Controls =====

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
      if ((prmText == "Untie")) {
        bindArms("free",TRUE);
        gui(guiScreen);
        return;
      }
      if ((guiScreen == 0)) {
        if ((prmText == "<<Color>>")) {
          gui(100);
          return;
        }
        else  {
          bindArms(prmText,TRUE);
          gui(guiScreen);
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
    (value = llJsonGetValue(prmText,["value"]));
    if ((function == "setGender")) {
      setGender(value);
    }
    else  if ((function == "bindArms")) {
      bindArms(value,FALSE);
    }
    else  if ((function == "getAvailableRestraints")) {
      sendAvailabilityInfo();
    }
    else  if ((function == "requestColor")) {
      if ((llJsonGetValue(value,["attachment"]) != "arm")) {
        return;
      }
      if ((llJsonGetValue(value,["name"]) != "rope")) {
        return;
      }
      setColor(color);
    }
    else  if ((function == "gui_arm_rope")) {
      key userkey = ((key)llJsonGetValue(prmText,["userkey"]));
      integer screen = 0;
      if ((((integer)llJsonGetValue(prmText,["restorescreen"])) && guiScreenLast)) {
        (screen = guiScreenLast);
      }
      initGui(userkey,screen);
    }
    else  if ((function == "resetGUI")) {
      exit("");
    }
  }


  timer() {
    exit("timeout");
  }
}
