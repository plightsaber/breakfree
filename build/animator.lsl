

// Global Variables
string animation_arm_base;
string animation_arm_success;
string animation_arm_failure;

integer mouthOpen = FALSE;

list poses;
string pose;

string animation_mover_current;

init(){
  llRequestPermissions(llGetOwner(),PERMISSION_TRIGGER_ANIMATION);
  if (animation_arm_base) {
    llStartAnimation(animation_arm_base);
  }
  if ((llJsonGetValue(pose,["animBase"]) != JSON_INVALID)) {
    llStartAnimation(llJsonGetValue(pose,["animBase"]));
  }
  if (mouthOpen) {
    llStartAnimation("express_open_mouth");
    llStartAnimation("animOpenMouthBento");
    llSetTimerEvent(0.2);
  }
}

bindArms(string prmInfo){
  llRequestPermissions(llGetOwner(),PERMISSION_TRIGGER_ANIMATION);
  if (animation_arm_base) {
    llStopAnimation(animation_arm_base);
  }
  if (animation_arm_success) {
    llStopAnimation(animation_arm_success);
  }
  if (animation_arm_failure) {
    llStopAnimation(animation_arm_failure);
  }
  if ((prmInfo == "free")) {
    (animation_arm_base = "");
    return;
  }
  (animation_arm_base = llJsonGetValue(prmInfo,["animation_base"]));
  (animation_arm_success = llJsonGetValue(prmInfo,["animation_success"]));
  (animation_arm_failure = llJsonGetValue(prmInfo,["animation_failure"]));
  llStartAnimation(animation_arm_base);
}

bindLegs(string prmInfo){
  llRequestPermissions(llGetOwner(),(PERMISSION_TRIGGER_ANIMATION | PERMISSION_OVERRIDE_ANIMATIONS));
  if ((prmInfo == "free")) {
    string animation_leg_base = getAnimation("leg_base");
    if (animation_leg_base) {
      llStopAnimation(animation_leg_base);
    }
    (pose = "");
    llResetAnimationOverride("Walking");
    return;
  }
  (poses = llJson2List(llJsonGetValue(prmInfo,["poses"])));
  string poseName = llJsonGetValue(pose,["name"]);
  if ((poseName == JSON_INVALID)) {
    setPoseIndex(0);
  }
  else  {
    setPoseIndex(getPoseIndexFromName(poseName));
  }
}

bindGag(string prmInfo){
  llRequestPermissions(llGetOwner(),PERMISSION_TRIGGER_ANIMATION);
  (mouthOpen = (llJsonGetValue(prmInfo,["mouthOpen"]) == "1"));
  if (mouthOpen) {
    llStartAnimation("express_open_mouth");
    llStartAnimation("animOpenMouthBento");
    llSetTimerEvent(0.2);
  }
  else  {
    llSetTimerEvent(0.0);
    llStopAnimation("express_open_mouth");
    llStopAnimation("animOpenMouthBento");
  }
}

// ===== Main Functions =====
animate(string prmAnimation){
  llRequestPermissions(llGetOwner(),PERMISSION_TRIGGER_ANIMATION);
  string animation;
  if ((prmAnimation == "animation_arm_success")) {
    (animation = animation_arm_success);
  }
  else  if ((prmAnimation == "animation_arm_failure")) {
    (animation = animation_arm_failure);
  }
  else  if ((prmAnimation == "animation_leg_success")) {
    (animation = getAnimation("leg_success"));
  }
  else  if ((prmAnimation == "animation_leg_failure")) {
    (animation = getAnimation("leg_fail"));
  }
  if (animation) {
    llStartAnimation(animation);
  }
}

animate_mover(string prmAnimation){
  llRequestPermissions(llGetOwner(),(PERMISSION_TRIGGER_ANIMATION | PERMISSION_OVERRIDE_ANIMATIONS));
  if ((llGetAnimationOverride("Walking") != getAnimation("walk_forward"))) {
    llSetAnimationOverride("Walking",getAnimation("walk_forward"));
  }
  if (animation_mover_current) {
    llStopAnimation(animation_mover_current);
  }
  if ((prmAnimation == "animation_walk_forward")) {
    (animation_mover_current = getAnimation("walk_forward"));
  }
  else  {
    (animation_mover_current = "");
  }
  if (animation_mover_current) {
    llStartAnimation(animation_mover_current);
  }
}

string getAnimation(string prmAnimation){
  if ((prmAnimation == "leg_base")) {
    return llJsonGetValue(pose,["animBase"]);
  }
  else  if ((prmAnimation == "leg_fail")) {
    return llJsonGetValue(pose,["animFail"]);
  }
  else  if ((prmAnimation == "leg_success")) {
    return llJsonGetValue(pose,["animSuccess"]);
  }
  else  if ((prmAnimation == "walk_forward")) {
    return llJsonGetValue(pose,["animWalkFwd"]);
  }
  return "";
}

// Pose Functions
integer getPoseIndexFromName(string prmName){
  integer index;
  for ((index = 0); (index < llGetListLength(poses)); (index++)) {
    if ((llJsonGetValue(llList2String(poses,index),["name"]) == prmName)) {
      return index;
    }
  }
  return (-1);
}

setPoseIndex(integer prmIndex){
  string oldAnim = llJsonGetValue(pose,["animBase"]);
  (pose = llList2String(poses,prmIndex));
  string newAnim = llJsonGetValue(pose,["animBase"]);
  if ((oldAnim != newAnim)) {
    llRequestPermissions(llGetOwner(),PERMISSION_TRIGGER_ANIMATION);
    if ((oldAnim != JSON_INVALID)) llStopAnimation(oldAnim);
    if ((newAnim != JSON_INVALID)) llStartAnimation(newAnim);
  }
}

setPose(string prmPoseName){
  integer index = getPoseIndexFromName(prmPoseName);
  if ((index == (-1))) return;
  setPoseIndex(index);
}

// ===== Other Functions =====
debug(string output){
  llOwnerSay(output);
}


// ===== Event Controls =====

default {

  state_entry() {
    init();
  }

  on_rez(integer prmStart) {
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
      bindArms(value);
    }
    else  if ((function == "bindLegs")) {
      bindLegs(value);
    }
    else  if ((function == "bindGag")) {
      bindGag(value);
    }
    else  if ((function == "animate")) {
      animate(value);
    }
    else  if ((function == "animate_mover")) {
      animate_mover(value);
    }
    else  if ((function == "setPose")) {
      setPose(value);
    }
  }


  timer() {
    if (mouthOpen) {
      llRequestPermissions(llGetOwner(),PERMISSION_TRIGGER_ANIMATION);
      llStartAnimation("express_open_mouth");
    }
  }
}
