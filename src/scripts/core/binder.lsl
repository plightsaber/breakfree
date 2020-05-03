// src.scripts.core.binder.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated

integer debugging = TRUE;
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

list get_restraint_list(string prmRestraint,string prmList){
  list liValues = [];
  list slots = llJson2List(prmRestraint);
  integer index = 0;
  for ((index = 0); (index < llGetListLength(slots)); (++index)) {
    string attachments = llJsonGetValue(llList2String(slots,index),[prmList]);
    if ((JSON_INVALID != attachments)) {
      list restraintAttachments = llJson2List(attachments);
      (liValues += restraintAttachments);
    }
  }
  return liValues;
}

integer search_restraint(string prmType,string prmParameter,string prmValue){
  list liRestraints = llJson2List(llJsonGetValue(_restraints,[prmType]));
  integer index;
  for ((index = 0); (index < llGetListLength(liRestraints)); (++index)) {
    if ((llJsonGetValue(llList2String(liRestraints,index),[prmParameter]) == prmValue)) {
      return TRUE;
    }
  }
  return FALSE;
}

add_restraint(string prmJson){
  string type = llJsonGetValue(prmJson,["type"]);
  string restraint = llJsonGetValue(prmJson,["restraint"]);
  (_restraints = llJsonSetValue(_restraints,[type,JSON_APPEND],restraint));
  rebuild_metadata();
  simple_request("setRestraints",_restraints);
}

override_restraint(string prmJson){
  string type = llJsonGetValue(prmJson,["type"]);
  string restraint = llJsonGetValue(prmJson,["restraint"]);
  (_restraints = llJsonSetValue(_restraints,[type],JSON_NULL));
  (_restraints = llJsonSetValue(_restraints,[type,JSON_APPEND],restraint));
  rebuild_metadata();
  simple_request("setRestraints",_restraints);
}

rem_restraint(string prmType){
  string restraints = llJsonGetValue(_restraints,[prmType]);
  if ((JSON_NULL == restraints)) {
    debug("No restraints to remove.");
    return;
  }
  list liRestraints = llJson2List(restraints);
  (liRestraints = llDeleteSubList(liRestraints,(-1),(-1)));
  if ((llGetListLength(liRestraints) == 0)) {
    (_restraints = llJsonSetValue(_restraints,[prmType],JSON_NULL));
  }
  else  {
    (_restraints = llJsonSetValue(_restraints,[prmType],llList2Json(JSON_ARRAY,liRestraints)));
  }
  rebuild_metadata();
  simple_request("setRestraints",_restraints);
}

release_restraint(string prmType){
  (_restraints = llJsonSetValue(_restraints,[prmType],JSON_NULL));
  rebuild_metadata();
  simple_request("setRestraints",_restraints);
}

rebuild_metadata(){
  integer isArmsBound = FALSE;
  string armJson = llJsonGetValue(_restraints,["arm"]);
  if (((JSON_NULL != armJson) && (JSON_INVALID != armJson))) {
    (isArmsBound = llGetListLength(llJson2List(armJson)));
  }
  (_restraints = llJsonSetValue(_restraints,["isArmBound"],((string)isArmsBound)));
  integer isLegsBound = FALSE;
  string legJson = llJsonGetValue(_restraints,["leg"]);
  if (((JSON_NULL != legJson) && (JSON_INVALID != legJson))) {
    (isLegsBound = llGetListLength(llJson2List(legJson)));
  }
  (_restraints = llJsonSetValue(_restraints,["isLegBound"],((string)isLegsBound)));
  integer isGagged = FALSE;
  string gagJson = llJsonGetValue(_restraints,["gag"]);
  if (((JSON_NULL != gagJson) && (JSON_INVALID != gagJson))) {
    (isGagged = llGetListLength(llJson2List(gagJson)));
  }
  (_restraints = llJsonSetValue(_restraints,["isGagged"],((string)isGagged)));
  (_restraints = llJsonSetValue(_restraints,["isArmTetherable"],((string)search_restraint("arm","canTether","1"))));
  (_restraints = llJsonSetValue(_restraints,["isLegTetherable"],((string)search_restraint("leg","canTether","1"))));
  (_restraints = llJsonSetValue(_restraints,["isArmBoundExternal"],((string)search_restraint("arm","type","external"))));
  (_restraints = llJsonSetValue(_restraints,["poses"],llList2Json(JSON_ARRAY,get_restraint_list("leg","poses"))));
}

default {

	link_message(integer prmLink,integer prmValue,string prmText,key prmID) {
    string function = llJsonGetValue(prmText,["function"]);
    if ((JSON_INVALID == function)) {
      return;
    }
    string value = llJsonGetValue(prmText,["value"]);
    if ((JSON_INVALID == value)) {
      return;
    }
    if (("addRestraint" == function)) add_restraint(value);
    else  if (("remRestraint" == function)) rem_restraint(value);
    else  if (("releaseRestraint" == function)) release_restraint(value);
    else  if (("overrideRestraint" == function)) override_restraint(value);
  }
}
// src.scripts.core.binder.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated
