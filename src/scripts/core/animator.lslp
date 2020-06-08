$import Modules.ContribLib.lslm();
$import Modules.GeneralTools.lslm();
$import Modules.RestraintTools.lslm();
$import Modules.PoseLib.lslm();

string _self;  // JSON object

// Global Variables
list _animations;	// Other animations set by restraints. (ie. mitten hands)
string _animation_arm_base;
string _animation_arm_success;
string _animation_arm_failure;

string _animation_leg_base;
string _animation_leg_success;
string _animation_leg_failure;
string _animation_leg_walk;

integer _mouthOpen = FALSE;

list _legPoses;
string _legPose;

string _animation_mover_current; // The mover should only be able to use one animation at a time.  The previous animation is always stopped first.

list _armPoses;		// A list of valid poses for the current restraint
string _armPose;	// The currently set arm pose

init() {
	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
	if (isSet(_animation_arm_base)) { llStartAnimation(_animation_arm_base); }
	if (isSet(_animation_leg_base)) { llStartAnimation(_animation_leg_base); }
	if (_mouthOpen) {
		llStartAnimation("express_open_mouth");
		llStartAnimation("animOpenMouthBento");
		llSetTimerEvent(0.2);
	}
}

setArmPose(string uid) {
 	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
	if (!isSet(uid)) {
		return;	// Just keep on truckin'
	}

	if (isSet(_animation_arm_base)) { llStopAnimation(_animation_arm_base); }

	if (uid == "free" || uid == "external") {
		_armPose = JSON_NULL;
		_animation_arm_base = JSON_NULL;
		return;
	}

	_armPose = uid;
	_animation_arm_base = llJsonGetValue(getPoses(), ["arm", uid, "base"]);
	//_animation_arm_success = llJsonGetValue(getPoses(), ["arm", "uid", "struggleSuccess"]);
	//_animation_arm_failure = llJsonGetValue(getPoses(), ["arm", "uid", "struggleFailure"]);
	_animation_arm_success = "animArm_struggle";
	_animation_arm_failure = "animArm_struggle";

	llStartAnimation(_animation_arm_base);
}

setLegPose(string uid) {
 	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_OVERRIDE_ANIMATIONS);
	if (!isSet(uid)) {
		return;	// Just keep on truckin'
	}

	string pose = llJsonGetValue(_poseLib, ["leg", _legPose]);

	if (isSet(_animation_leg_base)) { llStopAnimation(_animation_leg_base); }

	if (uid == "free" || uid == "external") {
		_legPose = JSON_NULL;
		_animation_leg_base = JSON_NULL;
		llResetAnimationOverride("ALL");
		return;
	}

	_legPose = uid;
	_animation_leg_base = llJsonGetValue(getPoses(), ["leg", uid, "base"]);
	_animation_leg_success = llJsonGetValue(getPoses(), ["leg", uid, "success"]);
	_animation_leg_failure = llJsonGetValue(getPoses(), ["leg", uid, "failure"]);
	_animation_leg_walk = llJsonGetValue(getPoses(), ["leg", uid, "walk"]);

	// Override walking animation
	if (isSet(_animation_leg_walk) && llGetAnimationOverride("Walking") != _animation_leg_walk) {
		llSetAnimationOverride("Walking", _animation_leg_walk);
	}

	if (isSet(_animation_leg_base)) { llStartAnimation(_animation_leg_base); }
}


setArmPoses(string prmPoses) {
	_armPoses = llJson2List(prmPoses);
	if (llListFindList(_armPoses, [_armPose]) == -1) {
		setArmPose(llList2String(_armPoses, 0));
	}
}

setLegPoses(string prmPoses) {
	_legPoses = llJson2List(prmPoses);
	if (llListFindList(_legPoses, [_legPose]) == -1) {
		setLegPose(llList2String(_legPoses, 0));
	}
}

setRestraints(string prmJson) {
	// Gag animation
	_mouthOpen = llJsonGetValue(prmJson, ["mouthOpen"]) == "1";
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

	// Other animations
	list newAnimations = llJson2List(llJsonGetValue(prmJson, ["animations"]));
	list startAnimations = ListXnotY(newAnimations, _animations);
	list stopAnimations = ListXnotY(_animations, newAnimations);
	integer index;

	// Start animations
	for (index = 0; index < llGetListLength(startAnimations); index++) {
		llStartAnimation(llList2String(startAnimations, index));
	}

	// Stop animations
	for (index = 0; index < llGetListLength(stopAnimations); index++) {
		llStopAnimation(llList2String(stopAnimations, index));
	}

	_animations = newAnimations;
}

// ===== Main Functions =====
animate(string prmAnimation) {
	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
	string animation;

	if (prmAnimation == "animation_arm_success") { animation = _animation_arm_success; }
	else if (prmAnimation == "animation_arm_failure") { animation = _animation_arm_failure; }
	else if (prmAnimation == "animation_leg_success") { animation = _animation_leg_success; }
	else if (prmAnimation == "animation_leg_failure") { animation = _animation_leg_failure; }

	if (isSet(animation)) { llStartAnimation(animation); }
}

animate_mover(string prmAnimation) {
	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_OVERRIDE_ANIMATIONS);

	if (isSet(_animation_mover_current)) { llStopAnimation(_animation_mover_current); }

	if (prmAnimation == "animation_walk_forward") {
		llResetAnimationOverride("ALL");
		_animation_mover_current = _animation_leg_walk;
	}
	else {
		// Set override ONLY when not already walking.  Needed for tether animation, but does bad things for slow movement speeds
		if (isSet(_animation_leg_walk) && llGetAnimationOverride("Walking") != _animation_leg_walk) {
			llSetAnimationOverride("Walking", _animation_leg_walk);
		}
		_animation_mover_current = JSON_NULL;
	}

	if (isSet(_animation_mover_current)) { llStartAnimation(_animation_mover_current); }
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

		if (function == "setArmPose") { setArmPose(value); }
		else if (function == "setArmPoses") { setArmPoses(value); }
		else if (function == "animate") { animate(value); }
		else if (function == "animate_mover") { animate_mover(value); }
		else if (function == "setLegPose") { setLegPose(value); }
		else if (function == "setLegPoses") { setLegPoses(value); }
		else if (function == "setRestraints") { setRestraints(value); }
  	}

  	timer() {
		if (_mouthOpen) {
		  	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
  			llStartAnimation("express_open_mouth");
		}
  	}
}
