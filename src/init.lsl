// src.init.lslp 
// 2019-08-25 10:50:40 - LSLForge (0.1.9.6) generated
integer CHANNEL_API = -9999274;
integer TOUCH_MAX_DISTANCE = 1;
integer TOUCH_TIMEOUT = 3;

key ownerID;
key villainID;

key toucherID;

key activeUser = NULL_KEY;

// Status
integer armsBound = FALSE;
integer legsBound = FALSE;
integer gagBound = FALSE;

string DEFAULT_USER(key prmID){
  string user = "";
  (user = llJsonSetValue(user,["userID"],prmID));
  (user = llJsonSetValue(user,["name"],llGetDisplayName(prmID)));
  (user = llJsonSetValue(user,["gender"],getGender(prmID)));
  (user = llJsonSetValue(user,["str"],"1"));
  (user = llJsonSetValue(user,["dex"],"1"));
  (user = llJsonSetValue(user,["int"],"1"));
  list skills;
  (user = llJsonSetValue(user,["skills"],llList2Json(JSON_ARRAY,skills)));
  (user = llJsonSetValue(user,["armRestraints"],"free"));
  return user;
}

// ==== Initializer =====

init(key prmID){
  (ownerID = llGetOwner());
  if ((activeUser != NULL_KEY)) {
    if ((activeUser == prmID)) {
      return;
    }
    if ((prmID != ownerID)) {
      if ((activeUser == villainID)) {
        llRegionSayTo(prmID,0,(((("You cannot do anything because " + llGetDisplayName(ownerID)) + " is being controlled by ") + llGetDisplayName(activeUser)) + "."));
        return;
      }
    }
    else  if ((prmID != villainID)) {
      llRegionSayTo(prmID,0,(("You cannot do anything because you are being controlled by " + llGetDisplayName(activeUser)) + "."));
      return;
    }
  }
  if ((prmID == ownerID)) {
    simpleRequest("resetGUI","override");
    (activeUser = prmID);
    guiRequest("gui_owner",FALSE,activeUser,0);
  }
  else  {
    (toucherID = prmID);
    string request_toucher = "";
    (request_toucher = llJsonSetValue(request_toucher,["function"],"getTouchInfo"));
    (request_toucher = llJsonSetValue(request_toucher,["userID"],ownerID));
    (request_toucher = llJsonSetValue(request_toucher,["apiTargetID"],toucherID));
    llRegionSayTo(prmID,CHANNEL_API,request_toucher);
    llSetTimerEvent(TOUCH_TIMEOUT);
  }
}

// ===== Main Functions =====

touchUser(string prmUserObj){
  llSetTimerEvent(0.0);
  (toucherID = ((key)llJsonGetValue(prmUserObj,["userID"])));
  vector toucherPos = llList2Vector(llGetObjectDetails(toucherID,[OBJECT_POS]),0);
  string toucherName = llJsonGetValue(prmUserObj,["name"]);
  integer toucherDistance = llAbs(llFloor(llVecDist(toucherPos,llGetPos())));
  integer toucherBound = (llJsonGetValue(prmUserObj,["armRestraints"]) != "free");
  if ((toucherDistance > TOUCH_MAX_DISTANCE)) {
    llRegionSayTo(toucherID,0,(llGetDisplayName(ownerID) + " is too far away."));
    return;
  }
  if ((toucherBound && (!isBound()))) {
    llRegionSayTo(toucherID,0,"You can't do that while bound.");
    return;
  }
  simpleRequest("resetGUI","override");
  (activeUser = toucherID);
  if (isBound()) {
    if (((!toucherBound) && (toucherID == villainID))) {
      guiRequest("gui_bind",FALSE,activeUser,0);
    }
    else  {
      guiRequest("gui_escape",FALSE,activeUser,0);
    }
  }
  else  {
    llOwnerSay((toucherName + " is eyeing you suspiciously."));
    guiRequest("gui_bind",FALSE,activeUser,0);
  }
}

bindArms(string prmInfo){
  (armsBound = (prmInfo != "free"));
}
bindLegs(string prmInfo){
  (legsBound = (prmInfo != "free"));
}
bindGag(string prmInfo){
  (gagBound = (prmInfo != "free"));
}

integer isBound(){
  return ((armsBound || legsBound) || gagBound);
}

// ===== Helper Functions =====
debug(string prmString){
  llOwnerSay(prmString);
}

string getGender(key prmUserID){
  list details = llGetObjectDetails(prmUserID,[OBJECT_BODY_SHAPE_TYPE]);
  if ((details == [])) return "female";
  float gender = llList2Float(details,0);
  if ((gender < 0.0)) return "object";
  if ((gender > 0.5)) return "male";
  return "female";
}

guiRequest(string prmGUI,integer prmRestore,key prmUserID,integer prmScreen){
  string guiRequest = "";
  (guiRequest = llJsonSetValue(guiRequest,["function"],prmGUI));
  (guiRequest = llJsonSetValue(guiRequest,["restorescreen"],((string)prmRestore)));
  (guiRequest = llJsonSetValue(guiRequest,["userkey"],((string)prmUserID)));
  (guiRequest = llJsonSetValue(guiRequest,["value"],((string)prmScreen)));
  llMessageLinked(LINK_THIS,0,guiRequest,NULL_KEY);
}

simpleRequest(string prmFunction,string prmValue){
  string request = "";
  (request = llJsonSetValue(request,["function"],prmFunction));
  (request = llJsonSetValue(request,["value"],prmValue));
  llMessageLinked(LINK_THIS,0,request,NULL_KEY);
}

// ===== Event Controls =====

default {

    touch_start(integer prmCount) {
    key toucherID = llDetectedKey(0);
    init(toucherID);
  }


    link_message(integer prmLink,integer prmValue,string prmText,key prmID) {
    string function;
    string value;
    if (((function = llJsonGetValue(prmText,["function"])) == JSON_INVALID)) {
      debug(prmText);
      return;
    }
    (value = llJsonGetValue(prmText,["value"]));
    if ((function == "touch")) {
      key toucherID = ((key)llJsonGetValue(value,["userID"]));
      init(toucherID);
    }
    else  if ((function == "touchUser")) {
      touchUser(value);
    }
    else  if ((function == "bindArms")) {
      bindArms(value);
    }
    else  if ((function == "bindLegs")) {
      bindLegs(value);
    }
    else  if ((function == "bindGag")) {
      bindGag(value);
    }
    else  if ((function == "setVillainID")) {
      (villainID = value);
    }
    else  if ((function == "resetGUI")) {
      if ((value == "timeout")) {
        llRegionSayTo(activeUser,0,(llGetDisplayName(ownerID) + "'s menu has timed out."));
        (activeUser = NULL_KEY);
      }
      else  if ((value != "override")) {
        (activeUser = NULL_KEY);
      }
      if ((!isBound())) {
        (villainID = NULL_KEY);
      }
    }
  }

    
    timer() {
    touchUser(DEFAULT_USER(toucherID));
  }
}
// src.init.lslp 
// 2019-08-25 10:50:40 - LSLForge (0.1.9.6) generated
