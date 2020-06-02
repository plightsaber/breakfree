$import Modules.ContribLib.lslm();
$import Modules.GeneralTools.lslm();
$import Modules.RestraintTools.lslm();

string _slots;		// List of UIDs ONLY for currently applied restraints
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
	string slot = llJsonGetValue(restraint, ["slot"]);

	_restraints = llJsonSetValue(_restraints, [slot], restraint);
	_slots = llJsonSetValue(_slots, [slot], llJsonGetValue(restraint, ["uid"]));

	resetPoses(type);
	deployRestraints();
}

deployRestraints() {
	simpleRequest("setAttachments", llList2Json(JSON_ARRAY, getAttachments()));

	rebuild_metadata();
	simpleRequest("setRestraints", _metadata);
}

list getAttachments() {
	list bindFolders;
	list preventFolders;
	string restraint;

	// Arm loop.
	restraint = llJsonGetValue(_restraints, ["arm"]);
	if (restraint != JSON_INVALID) {
		bindFolders += getRestraintList(restraint, "attachments");
		preventFolders += getRestraintList(restraint, "preventAttach");
	}

	// Leg Loop.
	restraint = llJsonGetValue(_restraints, ["leg"]);
	if (restraint != JSON_INVALID) {
		bindFolders += getRestraintList(restraint, "attachments");
		preventFolders += getRestraintList(restraint, "preventAttach");

		// Rope Hog tie rules are so complicated they need to be here. <_<
		if (llJsonGetValue(_restraints, ["immobilizer"]) == "ropeHog") {
			if (isSet(llJsonGetValue(_restraints, ["elbow"]))) { bindFolders += ["legRope_hogBackTight"]; }
			else if (llJsonGetValue(_restraints, ["wrist"]) == "ropeBox") { bindFolders += ["legRope_hogBox"]; }
			else { bindFolders += ["legRope_hogBack"]; }
		}
	}

	// Gag Loop.
	restraint = llJsonGetValue(_restraints, ["gag"]);
	if (restraint != JSON_INVALID) {
		bindFolders += getRestraintList(restraint, "attachments");
		preventFolders += getRestraintList(restraint, "preventAttach");
	}

	return ListXnotY(bindFolders, preventFolders);
}

override_restraint(string prmJson) {
	_restraints = prmJson;
	deployRestraints();
}

rmSlot(string slot) {
	string restraint = llJsonGetValue(_restraints, [slot]);

	_restraints = llJsonSetValue(_restraints, [slot], JSON_NULL);
	_slots = llJsonSetValue(_slots, [slot], JSON_NULL);

	// Remove ropeHog if connecting arm restraint removed
	if (llJsonGetValue(_slots, ["immobilizer"]) == "ropeHog"
		&& (slot == "wrist" || llJsonGetValue(restraint, ["uid"]) == "ropeBox")
	) {
		rmSlot("immobilizer");
	}
}

remRestraint(string prmType) {
	string restraints = llJsonGetValue(_restraints, [prmType]);
	if (JSON_NULL == restraints) {
		debug("No restraints to remove.");
		return;
	}

	string removedRestraint = getTopRestraint(prmType);
	string slot = llJsonGetValue(removedRestraint, ["slot"]);

	// Removal rules are about to get complicated.  This is a problem for future Myshel!
	integer isEscape = FALSE;	// TODO: Only apply alternate order for escapes.
	if (isEscape && prmType == "leg") {
		if (isSet(llJsonGetValue(_restraints, ["immobilizer"]))) { slot = "immobilizer"; }
		else if (isSet(llJsonGetValue(_restraints, ["ankle"]))) { slot = "ankle"; }
		else if (isSet(llJsonGetValue(_restraints, ["knee"]))) { slot = "knee"; }
	}

	rmSlot(slot);

	resetPoses(prmType);
	deployRestraints();
}

resetPoses(string prmType) {
	string method;
	if (prmType == "arm") { method = "setArmPoses"; }
	else if (prmType == "leg") { method = "setLegPoses"; }
	else { return; }


	string topRestraint = getTopRestraint(prmType);
	string poses = llJsonGetValue(topRestraint, ["poses"]);

	if (!isSet(poses)) {
		simpleRequest(method, llJsonSetValue(poses, [JSON_APPEND], "free"));
		return;
	}

	simpleRequest(method, poses);
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
		else if ("remRestraint" == function) remRestraint(value);
		else if ("releaseRestraint" == function) release_restraint(value);
		else if ("overrideRestraint" == function) override_restraint(value);
	}
}
