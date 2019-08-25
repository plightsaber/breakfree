// src.stats.lslp 
// 2019-08-25 10:50:40 - LSLForge (0.1.9.6) generated
// ===== Variables =====
integer dex = 1;
integer str = 1;
integer int = 1;

integer exp = 0;

list skills = [];

// ===== Initializer =====
init(){
  string stats;
  (stats = llJsonSetValue(stats,["dex"],((string)dex)));
  (stats = llJsonSetValue(stats,["str"],((string)str)));
  (stats = llJsonSetValue(stats,["int"],((string)int)));
  (stats = llJsonSetValue(stats,["exp"],((string)exp)));
  (stats = llJsonSetValue(stats,["skills"],llList2Json(JSON_ARRAY,skills)));
  simpleRequest("setStats",stats);
  return;
}


// ===== Primary Functions ====
// Adds
addDex(string prmValue){
  integer addValue = ((integer)prmValue);
  if ((addValue > 0)) {
    (dex += addValue);
  }
}
addInt(string prmValue){
  integer addValue = ((integer)prmValue);
  if ((addValue > 0)) {
    (int += addValue);
  }
}
addStr(string prmValue){
  integer addValue = ((integer)prmValue);
  if ((addValue > 0)) {
    (str += addValue);
  }
}
addExp(string prmValue){
  integer addValue = ((integer)prmValue);
  if ((addValue > 0)) {
    (exp += addValue);
  }
}
addSkill(string prmValue){
  if ((llListFindList(skills,[prmValue]) == (-1))) {
    (skills += [prmValue]);
  }
}

// Sets
setDex(string prmValue){
  integer setValue = ((integer)prmValue);
  if ((setValue > 0)) {
    (dex = setValue);
  }
}
setInt(string prmValue){
  integer setValue = ((integer)prmValue);
  if ((setValue > 0)) {
    (int = setValue);
  }
}
setStr(string prmValue){
  integer setValue = ((integer)prmValue);
  if ((setValue > 0)) {
    (str = setValue);
  }
}
setExp(string prmValue){
  integer setValue = ((integer)prmValue);
  if ((setValue > 0)) {
    (exp = setValue);
  }
}
setSkills(string prmValue){
  (skills = llJson2List(prmValue));
}

// ===== Helper Functions =====
debug(string prmString){
  llOwnerSay(prmString);
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
    if ((function == "addDex")) {
      addDex(value);
    }
    else  if ((function == "addStr")) {
      addStr(value);
    }
    else  if ((function == "addInt")) {
      addInt(value);
    }
    else  if ((function == "addSkill")) {
      addSkill(value);
    }
    else  if ((function == "addExp")) {
      addExp(value);
    }
    else  if ((function == "addSkill")) {
      addSkill(value);
    }
    else  if ((function == "setDex")) {
      setDex(value);
    }
    else  if ((function == "setStr")) {
      setStr(value);
    }
    else  if ((function == "setInt")) {
      setInt(value);
    }
    else  if ((function == "setExp")) {
      setExp(value);
    }
    else  if ((function == "setSkills")) {
      setSkills(value);
    }
  }
}
// src.stats.lslp 
// 2019-08-25 10:50:40 - LSLForge (0.1.9.6) generated
