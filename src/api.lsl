// src.api.lslp 
// 2019-08-26 23:56:38 - LSLForge (0.1.9.6) generated
// Objects
string self;

// Listener Vars
integer CHANNEL_API = -9999274;
integer listenID;

string DEFAULT_USER(key prmID){
  string user = "";
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

// ===== Initializer =====
init(){
  if (listenID) {
    llListenRemove(listenID);
  }
  llListen(CHANNEL_API,"",NULL_KEY,"");
  if ((self == "")) {
    (self = DEFAULT_USER(llGetOwner()));
  }
}


// ===== Primary Functions ====
api(string prmJson){
  string function = llJsonGetValue(prmJson,["function"]);
  key apiTargetID = ((key)llJsonGetValue(prmJson,["apiTargetID"]));
  key senderID = ((key)llJsonGetValue(prmJson,["userID"]));
  if ((apiTargetID != llGetOwner())) {
    return;
  }
  if ((function == "touch")) {
    simpleRequest("touch",prmJson);
  }
  else  if ((function == "touchUser")) {
    simpleRequest("touchUser",prmJson);
  }
  else  if ((function == "getTouchInfo")) {
    send(senderID,"touchUser",self);
  }
  else  if ((function == "touchUser")) {
    simpleRequest("touchUser",prmJson);
  }
  else  if ((function == "requestColor")) {
    simpleRequest("requestColor",prmJson);
  }
}

send(key prmTargetID,string prmFunction,string prmJson){
  (prmJson = llJsonSetValue(prmJson,["function"],prmFunction));
  (prmJson = llJsonSetValue(prmJson,["userID"],((string)llGetOwner())));
  (prmJson = llJsonSetValue(prmJson,["apiTargetID"],((string)prmTargetID)));
  llRegionSayTo(prmTargetID,CHANNEL_API,prmJson);
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

    
     link_message(integer prmLink,integer prmValue,string prmText,key prmID) {
    string function;
    string value;
    if (((function = llJsonGetValue(prmText,["function"])) == JSON_INVALID)) {
      debug(prmText);
      return;
    }
    (value = llJsonGetValue(prmText,["value"]));
    if ((function == "bindArms")) {
      (self = llJsonSetValue(self,["armRestraints"],value));
    }
    else  if ((function == "bindLegs")) {
      (self = llJsonSetValue(self,["legRestraints"],value));
    }
    else  if ((function == "bindGag")) {
      (self = llJsonSetValue(self,["gagRestraints"],value));
    }
  }

    
    listen(integer prmChannel,string prmName,key prmID,string prmText) {
    api(prmText);
  }
}
// src.api.lslp 
// 2019-08-26 23:56:38 - LSLForge (0.1.9.6) generated
