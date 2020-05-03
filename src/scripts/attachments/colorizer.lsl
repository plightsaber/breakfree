// src.scripts.attachments.colorizer.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated
// ===== Variables =====
integer CHANNEL_API = -9999274;

integer CHANNEL_ATTACHMENT = -9999277;
string RESTRAINT_ATTACHMENT = "";
string RESTRAINT_COMPONENT = "";
string RESTRAINT_NAME = "";

vector color = <0.0,0.0,0.0>;
string texture = TEXTURE_BLANK;

key configQueryID;
integer listenerID;


// ===== Initializer =====
init(){
  (configQueryID = llGetNotecardLine(".config",0));
  if (listenerID) {
    llListenRemove(listenerID);
  }
  (listenerID = llListen(CHANNEL_ATTACHMENT,"",NULL_KEY,""));
}

// ===== Main Functions =====
setColor(string prmInfo){
  if ((validateTarget(prmInfo) == FALSE)) {
    return;
  }
  (color = ((vector)llJsonGetValue(prmInfo,["color"])));
  llSetLinkColor(LINK_SET,color,ALL_SIDES);
  simpleRequest("setColor",((string)color));
}

setTexture(string prmInfo){
  if ((validateTarget(prmInfo) == FALSE)) {
    return;
  }
  (texture = llJsonGetValue(prmInfo,["texture"]));
  llSetTexture(texture,ALL_SIDES);
  simpleRequest("setTexture",texture);
}

integer validateTarget(string prmInfo){
  if ((llJsonGetValue(prmInfo,["attachment"]) != RESTRAINT_ATTACHMENT)) {
    return FALSE;
  }
  if ((llJsonGetValue(prmInfo,["component"]) != RESTRAINT_COMPONENT)) {
    return FALSE;
  }
  if ((llJsonGetValue(prmInfo,["userKey"]) != ((string)llGetOwner()))) {
    return FALSE;
  }
  return TRUE;
}


// ===== Other Functions =====
debug(string output){
  llOwnerSay(output);
}

apiCall(key prmTargetID,string prmFunction,string prmJson){
  (prmJson = llJsonSetValue(prmJson,["function"],prmFunction));
  (prmJson = llJsonSetValue(prmJson,["userKey"],llGetOwner()));
  (prmJson = llJsonSetValue(prmJson,["apiTargetID"],((string)prmTargetID)));
  llRegionSayTo(prmTargetID,CHANNEL_API,prmJson);
}

simpleRequest(string prmFunction,string prmValue){
  string request = "";
  (request = llJsonSetValue(request,["function"],prmFunction));
  (request = llJsonSetValue(request,["value"],prmValue));
  llMessageLinked(LINK_THIS,0,request,NULL_KEY);
}

// ===== Event Controls =====
default {

	on_rez(integer prmStart) {
    init();
  }

	state_entry() {
    init();
  }

	dataserver(key queryID,string configData) {
    if ((queryID == configQueryID)) {
      (RESTRAINT_ATTACHMENT = llJsonGetValue(configData,["attachment"]));
      (RESTRAINT_COMPONENT = llJsonGetValue(configData,["component"]));
      (RESTRAINT_NAME = llJsonGetValue(configData,["type"]));
      string tmpRequest = "";
      (tmpRequest = llJsonSetValue(tmpRequest,["attachment"],RESTRAINT_ATTACHMENT));
      (tmpRequest = llJsonSetValue(tmpRequest,["component"],RESTRAINT_COMPONENT));
      (tmpRequest = llJsonSetValue(tmpRequest,["name"],RESTRAINT_NAME));
      apiCall(llGetOwner(),"requestColor",tmpRequest);
    }
  }


	listen(integer prmChannel,string prmName,key prmID,string prmText) {
    if ((prmChannel == CHANNEL_ATTACHMENT)) {
      string function;
      string value;
      if (((function = llJsonGetValue(prmText,["function"])) == JSON_INVALID)) {
        debug(prmText);
        return;
      }
      (value = llJsonGetValue(prmText,["value"]));
      if ((function == "setColor")) {
        setColor(value);
      }
      else  if ((function == "setTexture")) {
        setTexture(value);
      }
    }
  }
}
// src.scripts.attachments.colorizer.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated
