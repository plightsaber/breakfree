// src.scripts.core.gui_gag_tape.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated

integer debugging = TRUE;
integer _slot;
string _self;
string _restraints;
string _resumeFunction;
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

// ===== Variables =====
// General Settings
string gender = "female";

// Colors
vector COLOR_BROWN = <0.5,0.25,0.0>;
vector COLOR_BLACK = <0.1,0.1,0.1>;
vector COLOR_BLUE = <0.0,0.25,0.5>;
vector COLOR_GREEN = <0.0,0.4,0.2>;
vector COLOR_WHITE = <1.0,1.0,1.0>;
vector COLOR_RED = <0.75,0.0,0.0>;
vector COLOR_PINK = <1.0,0.5,0.5>;
vector COLOR_YELLOW = <0.8800000000000001,0.6799999999999999,0.15>;
vector COLOR_PURPLE = <0.5,0.0,0.5>;
vector COLOR_SILVER = <0.5,0.5,0.5>;

vector color = COLOR_SILVER;
list colors = ["White","Silver","Black","Purple","Red","Blue","Green","Pink","Yellow","Brown"];
list colorVals = [COLOR_WHITE,COLOR_SILVER,COLOR_BLACK,COLOR_PURPLE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_PINK,COLOR_YELLOW,COLOR_BROWN];

debug(string output){
  if (debugging) llOwnerSay(output);
}

simple_request(string prmFunction,string prmValue){
  string request = "";
  (request = llJsonSetValue(request,["function"],prmFunction));
  (request = llJsonSetValue(request,["value"],prmValue));
  llMessageLinked(LINK_THIS,0,request,NULL_KEY);
}

// ===== Main Functions =====
integer is_mouth_open(){
  integer index;
  list liGags = llJson2List(llJsonGetValue(_restraints,["gag"]));
  for ((index = 0); (index < llGetListLength(liGags)); (++index)) {
    if (("1" == llJsonGetValue(llList2String(liGags,index),["mouthOpen"]))) {
      return TRUE;
    }
  }
  return FALSE;
}

set_restraints(string prmJson){
  (_slot = 0);
  (_restraints = prmJson);
  string gags = llJsonGetValue(prmJson,["gag"]);
  if ((JSON_NULL == gags)) return;
  list liGags = llJson2List(gags);
  string gag = llList2String(liGags,(-1));
  (_slot = ((integer)llJsonGetValue(gag,["slot"])));
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

//list textures = ["Smooth", "Duct"];
//list textureVals = [TEXTURE_BLANK, "duct"];

string getSelf(){
  if ((_self != "")) return _self;
  (_self = llJsonSetValue(_self,["name"],"Tape"));
  (_self = llJsonSetValue(_self,["part"],"gag"));
  (_self = llJsonSetValue(_self,["hasColor"],"1"));
  return _self;
}



// ===== Initializer =====
initGUI(key prmID,integer prmScreen){
  (guiUserID = prmID);
  if (guiID) {
    llListenRemove(guiID);
  }
  (guiChannel = (((integer)llFrand((-9998))) - 1));
  (guiID = llListen(guiChannel,"",guiUserID,""));
  gui(prmScreen);
}

sendAvailabilityInfo(){
  simpleRequest("addAvailableRestraint",getSelf());
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
    (btn3 = "<<Style>>");
    if (_slot) {
      (mpButtons += "Ungag");
    }
    else  {
      (mpButtons += "Stuff");
    }
    if ((_slot < 2)) {
      (mpButtons += "Simple");
    }
    if ((_slot == 2)) {
      (mpButtons += "Heavy");
    }
    (mpButtons = multipageGui(mpButtons,2,multipageIndex));
  }
  else  if ((prmScreen == 100)) {
    (guiText = "Choose what you want to style.");
    (mpButtons = multipageGui(["Tape","Stuffing"],2,multipageIndex));
  }
  else  if ((prmScreen == 101)) {
    (guiText = "Choose a color for the tape.");
    (mpButtons = multipageGui(colors,3,multipageIndex));
  }
  else  if ((prmScreen == 102)) {
    (guiText = "Choose a color for the stuffing.");
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
addGag(string prmName){
  string gag;
  (gag = llJsonSetValue(gag,["name"],prmName));
  if ((prmName == "Stuff")) {
    (gag = llJsonSetValue(gag,["garble","garbled"],"1"));
    (gag = llJsonSetValue(gag,["slot"],"1"));
    (gag = llJsonSetValue(gag,["canCut"],"0"));
    (gag = llJsonSetValue(gag,["canEscape"],"1"));
    (gag = llJsonSetValue(gag,["mouthOpen"],"1"));
    (gag = llJsonSetValue(gag,["type"],"knot"));
    (gag = llJsonSetValue(gag,["difficulty"],"3"));
    (gag = llJsonSetValue(gag,["tightness"],"1"));
    (gag = llJsonSetValue(gag,["attachments",JSON_APPEND],"gStuff"));
  }
  else  if ((prmName == "Simple")) {
    (gag = llJsonSetValue(gag,["garble","sealed"],"1"));
    (gag = llJsonSetValue(gag,["slot"],"2"));
    (gag = llJsonSetValue(gag,["canCut"],"1"));
    (gag = llJsonSetValue(gag,["canEscape"],"1"));
    (gag = llJsonSetValue(gag,["type"],"tape"));
    (gag = llJsonSetValue(gag,["difficulty"],"9"));
    (gag = llJsonSetValue(gag,["tightness"],"3"));
    if (is_mouth_open()) {
      (gag = llJsonSetValue(gag,["attachments",JSON_APPEND],"gTapeStuffed"));
    }
    else  {
      (gag = llJsonSetValue(gag,["attachments",JSON_APPEND],"gTapeSimple"));
    }
  }
  else  if ((prmName == "Heavy")) {
    (gag = llJsonSetValue(gag,["garble","sealed"],"1"));
    (gag = llJsonSetValue(gag,["slot"],"3"));
    (gag = llJsonSetValue(gag,["canCut"],"1"));
    (gag = llJsonSetValue(gag,["canEscape"],"1"));
    (gag = llJsonSetValue(gag,["type"],"knot"));
    (gag = llJsonSetValue(gag,["difficulty"],"9"));
    (gag = llJsonSetValue(gag,["tightness"],"9"));
    (gag = llJsonSetValue(gag,["attachments",JSON_APPEND],"gTapeHeavy"));
    (gag = llJsonSetValue(gag,["preventAttach",JSON_APPEND],"gTapeSimple"));
    (gag = llJsonSetValue(gag,["preventAttach",JSON_APPEND],"gTapeStuffed"));
  }
  string restraint;
  (restraint = llJsonSetValue(restraint,["type"],"gag"));
  (restraint = llJsonSetValue(restraint,["restraint"],gag));
  simple_request("addRestraint",restraint);
}

// Color Functions
setColorByName(string prmColorName,string prmComponent){
  integer tmpColorIndex = llListFindList(colors,[prmColorName]);
  setColor(llList2Vector(colorVals,tmpColorIndex),prmComponent);
}

setColor(vector prmColor,string prmComponent){
  (color = prmColor);
  string tmpRequest = "";
  (tmpRequest = llJsonSetValue(tmpRequest,["color"],((string)color)));
  (tmpRequest = llJsonSetValue(tmpRequest,["attachment"],"gag"));
  (tmpRequest = llJsonSetValue(tmpRequest,["component"],prmComponent));
  (tmpRequest = llJsonSetValue(tmpRequest,["userKey"],((string)llGetOwner())));
  simpleAttachedRequest("setColor",tmpRequest);
  simpleRequest("setColor",tmpRequest);
}
/*
setTextureByName(string prmTextureName, string prmComponent) {
	integer tmpTextureIndex = llListFindList(textures, [prmTextureName]);
	setTexture(llList2String(textureVals, tmpTextureIndex), prmComponent);
}

setTexture(string prmTexture, string prmComponent) {
	string tmpRequest = "";
	tmpRequest = llJsonSetValue(tmpRequest, ["attachment"], "gag");
	tmpRequest = llJsonSetValue(tmpRequest, ["component"], prmComponent);
	tmpRequest = llJsonSetValue(tmpRequest, ["texture"], prmTexture);
	tmpRequest = llJsonSetValue(tmpRequest, ["userKey"], (string)llGetOwner());

	simpleAttachedRequest("setTexture", tmpRequest);
	simpleRequest("setTexture", tmpRequest);
}
*/

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
    if ((llJsonGetValue(prmJson,["attachment"]) != "gag")) {
      return;
    }
    if ((llJsonGetValue(prmJson,["name"]) != "tape")) {
      return;
    }
    string component = llJsonGetValue(prmJson,["component"]);
    if (("" == component)) {
      (component = "tape");
    }
    setColor(color,component);
  }
  else  if ((prmFunction == "gui_gag_tape")) {
    key userkey = ((key)llJsonGetValue(prmJson,["userkey"]));
    integer screen = 0;
    if ((((integer)llJsonGetValue(prmJson,["restorescreen"])) && guiScreenLast)) {
      (screen = guiScreenLast);
    }
    initGUI(userkey,screen);
  }
  else  if ((prmFunction == "resetGUI")) {
    exit("");
  }
}

// ===== Sets =====
setGender(string prmGender){
  (gender = prmGender);
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
        if ((guiScreen == 100)) {
          gui(0);
          return;
        }
        else  if ((guiScreen != 0)) {
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
      if ((prmText == "Ungag")) {
        simple_request("remRestraint","gag");
        (_resumeFunction = "setRestraints");
        return;
      }
      if ((guiScreen == 0)) {
        if ((prmText == "<<Style>>")) {
          gui(100);
        }
        else  {
          addGag(prmText);
          (_resumeFunction = "setRestraints");
          return;
        }
        return;
      }
      else  if ((guiScreen == 100)) {
        if (("Tape" == prmText)) {
          gui(101);
        }
        else  if (("Stuffing" == prmText)) {
          gui(102);
        }
      }
      else  if ((guiScreen == 101)) {
        setColorByName(prmText,"tape");
      }
      else  if ((guiScreen == 102)) {
        setColorByName(prmText,"stuffing");
      }
      gui(guiScreen);
      return;
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
      initGUI(guiUserID,guiScreen);
    }
  }


	timer() {
    exit("timeout");
  }
}
// src.scripts.core.gui_gag_tape.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated
