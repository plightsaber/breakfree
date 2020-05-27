$import Modules.PoseLib.lslm();

string self;  // JSON object
list _legPoses;
string _legPose;

// Tether Variables
key armTetherID;
key legTetherID;

integer armTetherLength;
integer legTetherLength;

string _restraints;

// Global Variables
init() {
  llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS | PERMISSION_TRACK_CAMERA);
}

set_restraints(string prmJson) {
	_restraints = prmJson;
	if (!(integer)llJsonGetValue(prmJson, ["armBound"])) {
		armTetherID = NULL_KEY;
	}

	if (!(integer)llJsonGetValue(prmJson, ["legBound"])) {
		llReleaseControls();
		_legPose = "";
		legTetherID = NULL_KEY;
		return;
	}

	init();
	llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_RIGHT | CONTROL_LEFT | CONTROL_UP | CONTROL_DOWN, TRUE, FALSE);
}

setLegPose(string uid, integer sendUpdate) {
 	llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_OVERRIDE_ANIMATIONS);
	if (uid == JSON_NULL || uid == JSON_INVALID) {
		return;	// Just keep on truckin'
	}

	if (uid == "free" || uid == "external") {
		_legPose = "";
		llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS | PERMISSION_TRACK_CAMERA);
		llReleaseControls();
		return;
	}

	string pose = llJsonGetValue(getPoses(), ["leg", uid]);
	if (pose == JSON_INVALID) {
		debug("INVALID POSE: " + uid);
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

tetherTo(string prmJson) {
  if (llJsonGetValue(prmJson, ["attachment"]) == "arm") {
    armTetherID = (key)llJsonGetValue(prmJson, ["targetID"]);
    armTetherLength = (integer)llJsonGetValue(prmJson, ["length"]);
  } else if (llJsonGetValue(prmJson, ["attachment"]) == "leg") {
    legTetherID = (key)llJsonGetValue(prmJson, ["targetID"]);
    legTetherLength = (integer)llJsonGetValue(prmJson, ["length"]);
  }

  if (armTetherID != NULL_KEY) {
    llSensorRepeat("", armTetherID, AGENT|SCRIPTED, armTetherLength, PI, 0.5);
  } else if (legTetherID != NULL_KEY) {
    llSensorRepeat("", legTetherID, AGENT|SCRIPTED, legTetherLength, PI, 0.5);
  } else {
    llSensorRemove();
  }
}

updateAviTetherPos() {
  if (armTetherID != NULL_KEY) {
    vector armTetherPos = llList2Vector(llGetObjectDetails(armTetherID, [OBJECT_POS]), 0);
    integer armTetherDistance = llAbs(llFloor(llVecDist(armTetherPos, llGetPos())));
    if (armTetherDistance > armTetherLength) {
      llMoveToTarget(armTetherPos, 0.5);
    }
    else { llStopMoveToTarget(); }
  }
}

// ===== Other Functions =====
debug(string output) {
  // TODO: global enable/disable?
  llOwnerSay(output);
}

simpleRequest(string prmFunction, string prmValue) {
  string request = "";
  request = llJsonSetValue(request, ["function"], prmFunction);
  request = llJsonSetValue(request, ["value"], prmValue);
  llMessageLinked(LINK_THIS, 0, request, NULL_KEY);
}

// ===== Event Controls =====
executeFunction(string function, string prmJson) {
	string value = llJsonGetValue(prmJson, ["value"]);
	if (JSON_INVALID == value) {
		//return;		// TODO: Rewrite all linked calls to send in JSON
	}

	if (function == "setLegPose") { setLegPose(value, FALSE); }
    else if (function == "setLegPoses") { setLegPoses(value); }
	else if (function == "tetherTo") { tetherTo(value); }
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
		updateAviTetherPos();
	}

  	no_sensor() {
		updateAviTetherPos();
  	}
}
