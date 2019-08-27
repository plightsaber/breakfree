

// Global Variables
list armfolders = [];
list legfolders = [];
list gagfolders = [];

bindArms(string prmInfo){
  list bindfolders = [];
  string attachments = llJsonGetValue(prmInfo,["attachments"]);
  if ((attachments != JSON_INVALID)) {
    (bindfolders = llJson2List(attachments));
  }
  list addfolders = ListXnotY(bindfolders,armfolders);
  list remfolders = ListXnotY(armfolders,bindfolders);
  integer index;
  for ((index = 0); (index < llGetListLength(addfolders)); (index++)) {
    llOwnerSay((("@attachover:BreakFree/bf_" + llList2String(addfolders,index)) + "=force"));
  }
  for ((index = 0); (index < llGetListLength(remfolders)); (index++)) {
    llOwnerSay((("@detachall:BreakFree/bf_" + llList2String(remfolders,index)) + "=force"));
  }
  (armfolders = bindfolders);
}

bindLegs(string prmInfo){
  list bindfolders = [];
  string attachments = llJsonGetValue(prmInfo,["attachments"]);
  if ((attachments != JSON_INVALID)) {
    (bindfolders = llJson2List(attachments));
  }
  list addfolders = ListXnotY(bindfolders,legfolders);
  list remfolders = ListXnotY(legfolders,bindfolders);
  integer index;
  for ((index = 0); (index < llGetListLength(addfolders)); (index++)) {
    llOwnerSay((("@attachover:BreakFree/bf_" + llList2String(addfolders,index)) + "=force"));
  }
  for ((index = 0); (index < llGetListLength(remfolders)); (index++)) {
    llOwnerSay((("@detachall:BreakFree/bf_" + llList2String(remfolders,index)) + "=force"));
  }
  (legfolders = bindfolders);
}

bindGag(string prmInfo){
  list bindfolders = [];
  string attachments = llJsonGetValue(prmInfo,["attachments"]);
  if ((attachments != JSON_INVALID)) {
    (bindfolders = llJson2List(attachments));
  }
  list addfolders = ListXnotY(bindfolders,gagfolders);
  list remfolders = ListXnotY(gagfolders,bindfolders);
  integer index;
  for ((index = 0); (index < llGetListLength(addfolders)); (index++)) {
    llOwnerSay((("@attachover:BreakFree/bf_" + llList2String(addfolders,index)) + "=force"));
  }
  for ((index = 0); (index < llGetListLength(remfolders)); (index++)) {
    llOwnerSay((("@detachall:BreakFree/bf_" + llList2String(remfolders,index)) + "=force"));
  }
  (gagfolders = bindfolders);
}

// ===== User-Defined Functions ======
list ListXnotY(list lx,list ly){
  list lz = [];
  integer i = llGetListLength(lx);
  while ((i--)) if ((!(~llListFindList(ly,llList2List(lx,i,i))))) (lz += llList2List(lx,i,i));
  return lz;
}

// ===== Other Functions =====
debug(string output){
  llOwnerSay(output);
}

// ===== Event Controls =====

default {

  link_message(integer prmLink,integer prmValue,string prmText,key prmID) {
    string function;
    string value;
    if (((function = llJsonGetValue(prmText,["function"])) == JSON_INVALID)) {
      debug(prmText);
      return;
    }
    (value = llJsonGetValue(prmText,["value"]));
    if ((function == "bindArms")) {
      bindArms(value);
    }
    else  if ((function == "bindLegs")) {
      bindLegs(value);
    }
    else  if ((function == "bindGag")) {
      bindGag(value);
    }
  }
}
