$import Modules.GeneralTools.lslm();
$import Modules.RestraintTools.lslm();

string _self;  // JSON object

// Global Variables
string _animation_arm_base;
string _animation_arm_success;
string _animation_arm_failure;

integer _mouthOpen = FALSE;

list _poses;
string _pose;

string _animation_mover_current; // The mover should only be able to use one animation at a time.  The previous animation is always stopped first.

init() {
	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
	if (_animation_arm_base) { llStartAnimation(_animation_arm_base); }
	if (llJsonGetValue(_pose, ["animBase"]) != JSON_INVALID) { llStartAnimation(llJsonGetValue(_pose, ["animBase"])); }
	if (_mouthOpen) {
		llStartAnimation("express_open_mouth");
		llStartAnimation("animOpenMouthBento");
		llSetTimerEvent(0.2);
	}
}

setRestraints(string prmJson) {
	_restraints = prmJson;

	string armJson = llJsonGetValue(prmJson, ["arm"]);
	if (JSON_INVALID == armJson || (integer)llJsonGetValue(prmJson, ["isArmBoundExternal"])) {
		bindArms("free");
	} else {
		bindArms(armJson);
	}

	string legJson = llJsonGetValue(prmJson, ["leg"]);
	if (JSON_INVALID == legJson) {
		bindLegs("free");
	} else {
		bindLegs(legJson);
	}

	string gagJson = llJsonGetValue(prmJson, ["gag"]);
	if (JSON_INVALID == gagJson) {
		bindGag("free");
	} else {
		bindGag(gagJson);
	}
}

bindArms(string prmJson) {
	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);

	if (_animation_arm_base) { llStopAnimation(_animation_arm_base); }
	if (_animation_arm_success) { llStopAnimation(_animation_arm_success); }
	if (_animation_arm_failure) { llStopAnimation(_animation_arm_failure); }

	if (prmJson == "free" || prmJson == "external") {
		_animation_arm_base = "";
		return;
	}

	string restraint = get_top_restraint("arm");

	_animation_arm_base = llJsonGetValue(restraint, ["animation_base"]);
	_animation_arm_success = llJsonGetValue(restraint, ["animation_success"]);
	_animation_arm_failure = llJsonGetValue(restraint, ["animation_failure"]);

	llStartAnimation(_animation_arm_base);
}

setPoses(string prmPoses) {
	_poses = llJson2List(prmPoses);
	string poseName = llJsonGetValue(_pose, ["name"]);
	if (poseName == JSON_INVALID) { setPoseIndex(0); }
	else {setPoseIndex(getPoseIndexFromName(poseName)); }
}

bindLegs(string prmJson) {
	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_OVERRIDE_ANIMATIONS);
	if (prmJson == "free") {
		string animation_leg_base = getAnimation("leg_base");
		if (animation_leg_base != "" && JSON_INVALID != animation_leg_base) {
			llStopAnimation(animation_leg_base);
		}
		_pose = "";

		// Stop animations?
		llResetAnimationOverride("Walking");
		return;
	}

}

bindGag(string prmInfo) {
	_mouthOpen = FALSE;
	if (prmInfo != "free") {
		_mouthOpen = search_restraint("gag", "mouthOpen", "1");
	}
	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);

	if (_mouthOpen) {
		llStartAnimation("express_open_mouth");
		llStartAnimation("animOpenMouthBento");
		llSetTimerEvent(0.2);
	} else {
		llSetTimerEvent(0.0);
		llStopAnimation("express_open_mouth");
		llStopAnimation("animOpenMouthBento");
	}
}

// ===== Main Functions =====
animate(string prmAnimation) {
	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
	string animation;

	if (prmAnimation == "animation_arm_success") { animation = _animation_arm_success; }
	else if (prmAnimation == "animation_arm_failure") { animation = _animation_arm_failure; }
	else if (prmAnimation == "animation_leg_success") { animation = getAnimation("leg_success"); }
	else if (prmAnimation == "animation_leg_failure") { animation = getAnimation("leg_fail"); }

	if (animation) { llStartAnimation(animation); }
}

animate_mover(string prmAnimation) {
	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_OVERRIDE_ANIMATIONS);

	// Override walking animation
	if (llGetAnimationOverride("Walking") != getAnimation("walk_forward")) {
		llSetAnimationOverride("Walking", getAnimation("walk_forward"));
	}

	if (_animation_mover_current) { llStopAnimation(_animation_mover_current); }

	if (prmAnimation == "animation_walk_forward") { _animation_mover_current = getAnimation("walk_forward"); }
	else { _animation_mover_current = ""; }

	if (_animation_mover_current) { llStartAnimation(_animation_mover_current); }
}

string getAnimation(string prmAnimation) {
	if (prmAnimation == "leg_base") { return llJsonGetValue(_pose, ["animBase"]); }
	else if (prmAnimation == "leg_fail") { return llJsonGetValue(_pose, ["animFail"]); }
	else if (prmAnimation == "leg_success") { return llJsonGetValue(_pose, ["animSuccess"]); }
	else if (prmAnimation == "walk_forward") { return llJsonGetValue(_pose, ["animWalkFwd"]); }

	return "";
}

// Pose Functions
integer getPoseIndexFromName(string prmName) {
	integer index;
	for (index = 0; index < llGetListLength(_poses); index++) {
		if (llJsonGetValue(llList2String(_poses, index), ["name"]) == prmName) {
			return index;
		}
	}
	return -1;
}

setPoseIndex(integer prmIndex) {
	string oldAnim = llJsonGetValue(_pose, ["animBase"]);
	_pose = llList2String(_poses, prmIndex);
	string newAnim = llJsonGetValue(_pose, ["animBase"]);

	if (oldAnim != newAnim) {
		llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
		if (oldAnim != JSON_INVALID) { llStopAnimation(oldAnim); }
		if (newAnim != JSON_INVALID) { llStartAnimation(newAnim); }
	}
}

setPose(string prmPoseName) {
	integer index = getPoseIndexFromName(prmPoseName);
	if (index == -1) {
		return;
	}

	setPoseIndex(index);
}

// ===== Event Controls =====

default {
  state_entry() { init(); }
  on_rez(integer prmStart) { init(); }
  link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
    string function;
    string value;

    if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
      debug(prmText);
      return;
    }
    value = llJsonGetValue(prmText, ["value"]);

	if (function == "setRestraints") { setRestraints(value); }
    else if (function == "animate") { animate(value); }
    else if (function == "animate_mover") { animate_mover(value); }
    else if (function == "setPose") { setPose(value); }
    else if (function == "setPoses") { setPoses(value); }
  }

  timer() {
    if (_mouthOpen) {
      llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
      llStartAnimation("express_open_mouth");
    }
  }
}
