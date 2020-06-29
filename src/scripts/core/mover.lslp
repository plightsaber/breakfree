$import Modules.GeneralTools.lslm();
$import Modules.PoseLib.lslm();

string self;  // JSON object
list _legPoses;
string _legPose;

// Tether Variables
key _armTetherID;
key _legTetherID;

float _armTetherLength;
float _legTetherLength;

// Global Variables
init() {
	llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS | PERMISSION_TRACK_CAMERA);
}

setRestraints(string prmJson) {
	if (!isSet(llJsonGetValue(prmJson, ["armBound"]))) {
		_armTetherID = NULL_KEY;
	}

	if (!isSet(llJsonGetValue(prmJson, ["legBound"]))) {
		_legTetherID = NULL_KEY;
	}

	refreshSensors();
}

setLegPose(string uid, integer sendUpdate) {
	 llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_OVERRIDE_ANIMATIONS);
	if (!isSet(uid)) {
		return;	// Just keep on truckin'
	}

	if (uid == "free" || uid == "external") {
		_legPose = "";
		llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS | PERMISSION_TRACK_CAMERA);
		llReleaseControls();
		return;
	}

	string pose = llJsonGetValue(getPoses(), ["leg", uid]);
	if (!isSet(pose)) {
		return;
	}

	llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS | PERMISSION_TRACK_CAMERA);
	llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_RIGHT | CONTROL_LEFT | CONTROL_UP | CONTROL_DOWN, TRUE, FALSE);
	_legPose = uid;

	if (sendUpdate) {
		simpleRequest("setLegPose", _legPose);
	}
}

setLegPoses(string prmPoses) {
	_legPoses = llJson2List(prmPoses);
	if (llListFindList(_legPoses, [_legPose]) == -1) {
		setLegPose(llList2String(_legPoses, 0), FALSE);
	}
}

// ===== Main Functions =====
float get_speedBack() {
	return (float)llJsonGetValue(getPoses(), ["leg", _legPose, "speedBack"])/10;
}

float get_speedFwd() {
	return (float)llJsonGetValue(getPoses(), ["leg", _legPose, "speedFwd"])/10;
}

refreshSensors() {
	if (isSet(_armTetherID)) {
		llSensorRepeat("", _armTetherID, AGENT|SCRIPTED, _armTetherLength, PI, 0.5);
	} else if (isSet(_legTetherID)) {
		llSensorRepeat("", _legTetherID, AGENT|SCRIPTED, _legTetherLength, PI, 0.5);
	} else {
		llStopMoveToTarget();
		llSensorRemove();
	}
}

tetherTo(string prmJson) {
	if (llJsonGetValue(prmJson, ["attachment"]) == "arm") {
		_armTetherID = (key)llJsonGetValue(prmJson, ["targetID"]);
		_armTetherLength = (integer)llJsonGetValue(prmJson, ["length"]);
	} else if (llJsonGetValue(prmJson, ["attachment"]) == "leg") {
		_legTetherID = (key)llJsonGetValue(prmJson, ["targetID"]);
		_legTetherLength = (integer)llJsonGetValue(prmJson, ["length"]);
	}

	refreshSensors();
}

updateAviTetherPos(integer force) {
	if (isSet(_armTetherID)) {
		vector armTetherPos = llList2Vector(llGetObjectDetails(_armTetherID, [OBJECT_POS]), 0);
		integer armTetherDistance = llAbs(llFloor(llVecDist(armTetherPos, llGetPos())));
		if (force || armTetherDistance > _armTetherLength) {
			llMoveToTarget(armTetherPos, 0.5);
		}
		else { llStopMoveToTarget(); }
	} else if (isSet(_legTetherID)) {
		vector legTetherPos = llList2Vector(llGetObjectDetails(_legTetherID, [OBJECT_POS]), 0);
		integer legTetherDistance = llAbs(llFloor(llVecDist(legTetherPos, llGetPos())));
		if (force || legTetherDistance > _legTetherLength) {
			llMoveToTarget(legTetherPos, 0.5);
		}
		else { llStopMoveToTarget(); }
	}
}

// ===== Event Controls =====
executeFunction(string function, string prmJson) {
	string value = llJsonGetValue(prmJson, ["value"]);

	if (function == "setLegPose") { setLegPose(value, FALSE); }
	else if (function == "setRestraints") { setRestraints(prmJson); }
	else if (function == "setPoses") { setLegPoses(llJsonGetValue(value, ["leg"])); }
	else if (function == "tetherTo") { tetherTo(value); }
	else if (function == "tetherPull") { updateAviTetherPos(TRUE); }
}

default {
	control(key prmAviID, integer prmLevel, integer prmEdge) {
		integer press = prmLevel & prmEdge;
		integer release = ~prmLevel & prmEdge;
		integer hold = prmLevel & ~prmEdge;

		// General Movement
		if (hold == CONTROL_FWD) {
			llSetVelocity(<get_speedFwd(),0,0>, TRUE);
		}

		// Position Changes
		if (press == CONTROL_UP) {
			setLegPose(llJsonGetValue(getPoses(), ["leg", _legPose, "poseUp"]), TRUE);
		}
		if (press == CONTROL_DOWN) {
			setLegPose(llJsonGetValue(getPoses(), ["leg", _legPose, "poseDown"]), TRUE);
		}
		if (press == CONTROL_RIGHT) {
			setLegPose(llJsonGetValue(getPoses(), ["leg", _legPose, "poseRight"]), TRUE);
		}
		if (press == CONTROL_LEFT) {
			setLegPose(llJsonGetValue(getPoses(), ["leg", _legPose, "poseLeft"]), TRUE);
		}

		// Animations
		if (press == CONTROL_FWD) { simpleRequest("animate_mover", "animation_walk_forward"); }

		if (release) { simpleRequest("animate_mover", "stop"); }
	}

	link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
		string function;
		string value;

		if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
			debug(prmText);
			return;
		}
		executeFunction(function, prmText);
	}

	sensor(integer prmCount) {
		//updateAviTetherPos();
	}

	no_sensor() {
		updateAviTetherPos(FALSE);
	}
}
