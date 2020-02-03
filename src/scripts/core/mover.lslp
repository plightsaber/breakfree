string self;  // JSON object
list _poses;
string _pose;

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
	if (!(integer)llJsonGetValue(prmJson, ["isArmBound"])) {
		armTetherID = NULL_KEY;
	}
	
	if (!(integer)llJsonGetValue(prmJson, ["isLegBound"])) {
		llReleaseControls();
		_pose = "";
		legTetherID = NULL_KEY;
		return;
	}
	
	init();
	llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_RIGHT | CONTROL_LEFT | CONTROL_UP | CONTROL_DOWN, TRUE, FALSE);
}

set_poses(string prmJson) {
	_poses = llJson2List(prmJson);
	string poseName = llJsonGetValue(_pose, ["name"]);
	if (poseName == JSON_INVALID) { setPoseIndex(0, FALSE); }
	else { setPoseIndex(getPoseIndexFromName(poseName), FALSE); }
}

// ===== Main Functions =====
setPoseIndex(integer prmIndex, integer prmSend) {
  _pose = llList2String(_poses, prmIndex);
  if (prmSend) {
    simpleRequest("setPose", get_poseName());
  }
}

setPose(string prmPoseName, integer prmSend) {
  integer index = getPoseIndexFromName(prmPoseName);
  if (index == -1) {
    debug("INVALID POSE: " + prmPoseName);
    return;
  }

  setPoseIndex(index, prmSend);
}

string get_poseName() {
  return llJsonGetValue(_pose, ["name"]);
}

float get_speedBack() {
  return (float)llJsonGetValue(_pose, ["speedBack"])/10;
}
float get_speedFwd() {
  return (float)llJsonGetValue(_pose, ["speedFwd"])/10;
}

integer getPoseIndexFromName(string prmName) {
  integer index;
  for (index = 0; index < llGetListLength(_poses); index++) {
    if (llJsonGetValue(llList2String(_poses, index), ["name"]) == prmName) {
      return index;
    }
  }
  return -1;
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
execute_function(string prmFunction, string prmJson) {
	string value = llJsonGetValue(prmJson, ["value"]);
	if (JSON_INVALID == value) {
		//return;		// TODO: Rewrite all linked calls to send in JSON
	}
	
	if (prmFunction == "setRestraints") { set_restraints(value); }
	else if (prmFunction == "tetherTo") { tetherTo(value); }
	else if (prmFunction == "setPose") { setPose(value, FALSE); }
	else if (prmFunction == "setPoses") { set_poses(value); }
}

default {
  control(key prmAviID, integer prmLevel, integer prmEdge) {
    integer press   = prmLevel & prmEdge;
    integer release = ~prmLevel & prmEdge;
    integer hold  = prmLevel & ~prmEdge;

    // General Movement
    if (hold == CONTROL_FWD) {
      llSetVelocity(<get_speedFwd(),0,0>, TRUE);
    }

    // Position Changes
    integer poseIndex = -1;
    if (press == CONTROL_UP) {
      poseIndex = getPoseIndexFromName(llJsonGetValue(_pose, ["poseUp"]));
      if (poseIndex != -1) {
        setPoseIndex(poseIndex, TRUE);
      }
    }
    if (press == CONTROL_DOWN) {
      poseIndex = getPoseIndexFromName(llJsonGetValue(_pose, ["poseDown"]));
      if (poseIndex != -1) {
        setPoseIndex(poseIndex, TRUE);
      }
    }
    if (press == CONTROL_RIGHT) {
      poseIndex = getPoseIndexFromName(llJsonGetValue(_pose, ["poseRight"]));
      if (poseIndex != -1) {
        setPoseIndex(poseIndex, TRUE);
      }
    }
    if (press == CONTROL_LEFT) {
      poseIndex = getPoseIndexFromName(llJsonGetValue(_pose, ["poseLeft"]));
      if (poseIndex != -1) {
        setPoseIndex(poseIndex, TRUE);
      }
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
		execute_function(function, prmText);
	}

  sensor(integer prmCount) {
    updateAviTetherPos();
  }
  no_sensor() {
    updateAviTetherPos();
  }
}
