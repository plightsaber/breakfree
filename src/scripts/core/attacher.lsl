// src.scripts.core.attacher.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated


// Global Variables
list _attachedFolders = [];

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

setRestraints(string prmJson){
  list bindFolders = [];
  list preventFolders = [];
  string restraint;
  integer index;
  (restraint = llJsonGetValue(prmJson,["arm"]));
  if ((restraint != JSON_INVALID)) {
    (bindFolders += get_restraint_list(restraint,"attachments"));
    (preventFolders += get_restraint_list(restraint,"preventAttach"));
  }
  (restraint = llJsonGetValue(prmJson,["leg"]));
  if ((restraint != JSON_INVALID)) {
    (bindFolders += get_restraint_list(restraint,"attachments"));
    (preventFolders += get_restraint_list(restraint,"preventAttach"));
  }
  (restraint = llJsonGetValue(prmJson,["gag"]));
  if ((restraint != JSON_INVALID)) {
    (bindFolders += get_restraint_list(restraint,"attachments"));
    (preventFolders += get_restraint_list(restraint,"preventAttach"));
  }
  (bindFolders = ListXnotY(bindFolders,preventFolders));
  list addFolders = ListXnotY(bindFolders,_attachedFolders);
  list remFolders = ListXnotY(_attachedFolders,bindFolders);
  for ((index = 0); (index < llGetListLength(addFolders)); (index++)) {
    llOwnerSay((("@attachover:BreakFree/bf_" + llList2String(addFolders,index)) + "=force"));
  }
  for ((index = 0); (index < llGetListLength(remFolders)); (index++)) {
    llOwnerSay((("@detachall:BreakFree/bf_" + llList2String(remFolders,index)) + "=force"));
  }
  (_attachedFolders = bindFolders);
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
    if ((function == "setRestraints")) {
      setRestraints(value);
    }
  }
}
// src.scripts.core.attacher.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated
