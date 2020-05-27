$import Modules.GeneralTools.lslm();
$import Modules.RestraintTools.lslm();

string _slots;
string _metadata;

init() {
	_slots = llJsonSetValue(_slots, ["wrist"], JSON_NULL);
	_slots = llJsonSetValue(_slots, ["elbow"], JSON_NULL);
	_slots = llJsonSetValue(_slots, ["torso"], JSON_NULL);
	_slots = llJsonSetValue(_slots, ["ankle"], JSON_NULL);
	_slots = llJsonSetValue(_slots, ["knee"], JSON_NULL);
	_slots = llJsonSetValue(_slots, ["immobilizer"], JSON_NULL);
	_slots = llJsonSetValue(_slots, ["gag1"], JSON_NULL);
	_slots = llJsonSetValue(_slots, ["gag2"], JSON_NULL);
	_slots = llJsonSetValue(_slots, ["gag3"], JSON_NULL);
	_slots = llJsonSetValue(_slots, ["gag4"], JSON_NULL);
	override_restraint(_restraints);
}

addRestraint(string prmJson) {
	string type = llJsonGetValue(prmJson, ["type"]);
	string restraint = llJsonGetValue(prmJson, ["restraint"]);

	_restraints = llJsonSetValue(_restraints, [type, JSON_APPEND], restraint);
	_slots = llJsonSetValue(_slots, [llJsonGetValue(restraint, ["slot"])], llJsonGetValue(restraint, ["uid"]));
	rebuild_metadata();

	if (type == "arm") {
		string armPoses = llJsonGetValue(restraint, ["poses"]);
		if (armPoses != JSON_NULL && armPoses != JSON_INVALID) {
			simpleRequest("setArmPoses", armPoses);
		}
	} else if (type == "leg") {
		string legPoses = llJsonGetValue(restraint, ["poses"]);
		if (legPoses != JSON_NULL && legPoses != JSON_INVALID) {
			simpleRequest("setLegPoses", legPoses);
		}
	}
	simpleRequest("setRestraints", _metadata);
}

override_restraint(string prmJson) {
	string type = llJsonGetValue(prmJson, ["type"]);
	string restraint = llJsonGetValue(prmJson, ["restraint"]);

	_restraints = llJsonSetValue(_restraints, [type], JSON_NULL);
	_restraints = llJsonSetValue(_restraints, [type, JSON_APPEND], restraint);
	rebuild_metadata();
	simpleRequest("setRestraints", _metadata);
}

rem_restraint(string prmType) {
	string restraints = llJsonGetValue(_restraints, [prmType]);
	if (JSON_NULL == restraints) {
		debug("No restraints to remove.");
		return;
	}

	list liRestraints = llJson2List(restraints);
	string restraint = llList2String(liRestraints, -1);
	liRestraints = llDeleteSubList(liRestraints, -1, -1);

	_slots = llJsonSetValue(_slots, [llJsonGetValue(restraint, ["slot"])], JSON_NULL);

	if (llGetListLength(liRestraints) == 0) {
		_restraints = llJsonSetValue(_restraints, [prmType], JSON_NULL);
	} else {
		_restraints = llJsonSetValue(_restraints, [prmType], llList2Json(JSON_ARRAY, liRestraints));
	}

	if (prmType == "arm") {
		string armPoses = llJsonGetValue(llList2String(liRestraints, -1), ["poses"]);
		if (armPoses == JSON_INVALID) { armPoses = llJsonSetValue(armPoses, [JSON_APPEND], "free"); }
		simpleRequest("setArmPoses", armPoses);
	} else if (prmType == "leg") {
		string legPoses = llJsonGetValue(llList2String(liRestraints, -1), ["poses"]);
		if (legPoses == JSON_INVALID) { legPoses = llJsonSetValue(legPoses, [JSON_APPEND], "free"); }
		simpleRequest("setLegPoses", legPoses);
	}

	rebuild_metadata();
	simpleRequest("setRestraints", _metadata);
}

release_restraint(string prmType) {
	_restraints = llJsonSetValue(_restraints, [prmType], JSON_NULL);
	if (prmType == "arm") {
		_slots = llJsonSetValue(_slots, ["wrist"], JSON_NULL);
		_slots = llJsonSetValue(_slots, ["elbow"], JSON_NULL);
		_slots = llJsonSetValue(_slots, ["torso"], JSON_NULL);
		simpleRequest("setArmPose", "free");
	} else if (prmType == "leg") {
		_slots = llJsonSetValue(_slots, ["ankle"], JSON_NULL);
		_slots = llJsonSetValue(_slots, ["knee"], JSON_NULL);
		_slots = llJsonSetValue(_slots, ["immobilizer"], JSON_NULL);
		simpleRequest("setLegPose", "free");
	}

	rebuild_metadata();
	simpleRequest("setRestraints", _metadata);
}

rebuild_metadata() {
	_metadata = llJsonSetValue(_metadata, ["slots"], _slots);

	integer isArmsBound = FALSE;
	string armJson = llJsonGetValue(_restraints, ["arm"]);
	if (JSON_NULL != armJson && JSON_INVALID != armJson) {
		isArmsBound = llGetListLength(llJson2List(armJson));
	}
	_metadata = llJsonSetValue(_metadata, ["armBound"], (string)isArmsBound);

	integer isLegsBound = FALSE;
	string legJson = llJsonGetValue(_restraints, ["leg"]);
	if (JSON_NULL != legJson && JSON_INVALID != legJson) {
		isLegsBound = llGetListLength(llJson2List(legJson));
	}
	_metadata = llJsonSetValue(_metadata, ["legBound"], (string)isLegsBound);

	integer isGagged = FALSE;
	string gagJson = llJsonGetValue(_restraints, ["gag"]);
	if (JSON_NULL != gagJson && JSON_INVALID != gagJson) {
		isGagged = llGetListLength(llJson2List(gagJson));
	}
	_metadata = llJsonSetValue(_metadata, ["gagged"], (string)isGagged);
	_metadata = llJsonSetValue(_metadata, ["mouthOpen"], (string)searchRestraint("gag", "mouthOpen", "1"));
	_metadata = llJsonSetValue(_metadata, ["speechGarbled"], (string)searchRestraint("gag", "speechGarbled", "1"));
	_metadata = llJsonSetValue(_metadata, ["speechMuffled"], (string)searchRestraint("gag", "speechMuffled", "1"));
	_metadata = llJsonSetValue(_metadata, ["speechSealed"], (string)searchRestraint("gag", "speechSealed", "1"));

	_metadata = llJsonSetValue(_metadata, ["armTetherable"], (string)searchRestraint("arm", "canTether", "1"));
	_metadata = llJsonSetValue(_metadata, ["legTetherable"], (string)searchRestraint("leg", "canTether", "1"));

	_metadata = llJsonSetValue(_metadata, ["armBoundExternal"], (string)searchRestraint("arm", "type", "external"));
	_metadata = llJsonSetValue(_metadata, ["poses"], llList2Json(JSON_ARRAY, getRestraintList("leg", "poses")));

	_metadata = llJsonSetValue(_metadata, ["security", "arm"], getSecurityDetails("arm"));
	_metadata = llJsonSetValue(_metadata, ["security", "leg"], getSecurityDetails("leg"));
	_metadata = llJsonSetValue(_metadata, ["security", "gag"], getSecurityDetails("gag"));
}

string getSecurityDetails(string prmType) {
	string details;

	// Tightness: Add all restraint totals for tightness
	// Complexity: Get just the top level
	// Integrity: Get just the top level.

	// If not restrained, return nothing
	string restraintDetails = llJsonGetValue(_restraints, [prmType]);
	if (restraintDetails == JSON_NULL || restraintDetails == JSON_INVALID) {
		return "{'complexity':0,'integrity':0,'tightness':0}";
	}

	// Get details from top restraint
	list liRestraints = llJson2List(restraintDetails);
	string topRestraint = llList2String(liRestraints, -1);

	details = llJsonSetValue(details, ["complexity"], llJsonGetValue(topRestraint, ["complexity"]));
	details = llJsonSetValue(details, ["integrity"], llJsonGetValue(topRestraint, ["integrity"]));

	// Get cumulative details
	integer index;
	integer tightness;
	for (index = 0; index < llGetListLength(liRestraints); index++) {
		string restraint = llList2String(liRestraints, index);
		tightness += (integer)llJsonGetValue(restraint, ["tightness"]);
	}
	details = llJsonSetValue(details, ["tightness"], (string)tightness);

	// Other properties
	details = llJsonSetValue(details, ["canEscape"], llJsonGetValue(topRestraint, ["canEscape"]));

	return details;
}


integer isMouthOpen() {
	integer index;
	list liGags = llJson2List(llJsonGetValue(_restraints,["gag"]));
	for (index = 0; index < llGetListLength(liGags); ++index) {
		if ("1" == llJsonGetValue(llList2String(liGags, index), ["mouthOpen"])) {
			return TRUE;
		}
	}
	return FALSE;
}

default {
	state_entry() {
		init();
	}

	link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
		string function = llJsonGetValue(prmText, ["function"]);
		if (JSON_INVALID == function) {
			return;
		}

		string value = llJsonGetValue(prmText, ["value"]);
		if (JSON_INVALID == value) {
			return;
		}

		if ("addRestraint" == function) addRestraint(value);
		else if ("remRestraint" == function) rem_restraint(value);
		else if ("releaseRestraint" == function) release_restraint(value);
		else if ("overrideRestraint" == function) override_restraint(value);
	}
}
