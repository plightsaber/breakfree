// src.scripts.core.rlv.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated
// ===== Variables =====
integer _armBound;
integer _legBound;
integer _gagBound;

integer _RLV;
string _restraints;

// ==== Main Functions =====
init(){
  set_restraints(_restraints);
}

detachCheck(){
  if (((_armBound || _legBound) || _gagBound)) {
    llOwnerSay("@detach=n");
  }
  else  {
    llOwnerSay("@detach=y");
  }
}

set_restraints(string prmJson){
  (_restraints = prmJson);
  if ((!_RLV)) {
    return;
  }
  if (((integer)llJsonGetValue(prmJson,["isArmBound"]))) {
    (_armBound = TRUE);
    llOwnerSay("@touchfar=n");
  }
  else  {
    (_armBound = FALSE);
    llOwnerSay("@touchfar=y");
  }
  (_legBound = ((integer)llJsonGetValue(prmJson,["isLegBound"])));
  (_gagBound = ((integer)llJsonGetValue(prmJson,["isGagged"])));
  detachCheck();
}

// ===== Other Functions =====
debug(string output){
  llOwnerSay(output);
}

// ===== Events =====

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
    if ((function == "setRestraints")) {
      set_restraints(value);
    }
    else  if ((function == "setRLV")) {
      (_RLV = ((integer)value));
    }
  }
}
// src.scripts.core.rlv.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated
