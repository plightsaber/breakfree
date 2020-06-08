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

	_slots = llJsonSetValue(_slots, ["crotch"], JSON_NULL);

	override_restraint(_restraints);
}

addRestraint(string prmJson) {
	string type = llJsonGetValue(prmJson, ["type"]);
	string restraint = llJsonGetValue(prmJson, ["restraint"]);
	string slot = llJsonGetValue(restraint, ["slot"]);

	_restraints = llJsonSetValue(_restraints, [slot], restraint);
	_slots = llJsonSetValue(_slots, [slot], llJsonGetValue(restraint, ["uid"]));

	deployRestraints();
}

deployRestraints() {
	resetPoses();
	simpleRequest("setAttachments", llList2Json(JSON_ARRAY, getAttachments()));

	rebuild_metadata();
	simpleRequest("setRestraints", _metadata);
}

list getAttachments() {
	list bindFolders = getRestraintList(_restraints, "attachments");
	list preventFolders = getRestraintList(_restraints, "preventAttach");

	// Odd rules so complicated they need to be here. <_<
	if (llJsonGetValue(_restraints, ["immobilizer", "uid"]) == "hogRope") {
		if (isSet(llJsonGetValue(_restraints, ["elbow"]))) { bindFolders += ["legRope_hogBackTight"]; }
		else if (llJsonGetValue(_restraints, ["torso", "uid"]) == "boxRope") { bindFolders += ["legRope_hogBox"]; }
		else { bindFolders += ["legRope_hogBack"]; }
	} else if ("ballRope" == llJsonGetValue(_restraints, ["immobilizer", "uid"]) || "ballTape" == llJsonGetValue(_restraints, ["immobilizer", "uid"])) {
		debug(llJsonGetValue(_restraints, ["knee", "uid"]));
		if ("kneeRope" == llJsonGetValue(_restraints, ["knee", "uid"])) {
			preventFolders += "legRope_knee";
		} else if ("kneeTape" == llJsonGetValue(_restraints, ["knee", "uid"])) {
			bindFolders += "legTape_kneeBent";
			preventFolders += "legTape_knee";
		}
	}

	if (isSet(llJsonGetValue(_restraints, ["elbow"]))) {
		// Update wrist restraints to alternate mesh for pose
		string wrist = llJsonGetValue(_restraints, ["wrist", "uid"]);
		if (wrist == "backRope") {
			bindFolders += "armRope_backTight_wrist";
			preventFolders += "armRope_back_wrist";
		} else if (wrist == "backTape") {
			bindFolders += "armTape_backTight_wrist";
			preventFolders += "armTape_back_wrist";
		}
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

	// Remove hogRope if connecting arm restraint removed
	if (llJsonGetValue(_slots, ["immobilizer"]) == "hogRope"
		&& (slot == "wrist" || llJsonGetValue(restraint, ["uid"]) == "boxRope")
	) {
		rmSlot("immobilizer");
	}
}

remRestraint(string prmType) {
	string removedRestraint = getTopRestraint(prmType);
	if (JSON_NULL == removedRestraint) {
		debug("No restraints to remove.");
		return;
	}

	string slot = llJsonGetValue(removedRestraint, ["slot"]);

	// Removal rules are about to get complicated.  This is a problem for future Myshel!
	integer isEscape = FALSE;	// TODO: Only apply alternate order for escapes.
	if (isEscape && prmType == "leg") {
		if (isSet(llJsonGetValue(_restraints, ["immobilizer"]))) { slot = "immobilizer"; }
		else if (isSet(llJsonGetValue(_restraints, ["ankle"]))) { slot = "ankle"; }
		else if (isSet(llJsonGetValue(_restraints, ["knee"]))) { slot = "knee"; }
	}

	rmSlot(slot);
	deployRestraints();
}

resetPoses() {
	string poses;
	string topRestraint;

	// Arm poses
	topRestraint = getTopRestraint("arm");
	poses = llJsonGetValue(topRestraint, ["poses"]);
	if (!isSet(poses)) {
		poses = llJsonSetValue(poses, [JSON_APPEND], "free");
	}
	debug(poses);
	simpleRequest("setArmPoses", poses);

	// Leg poses
	topRestraint = getTopRestraint("leg");
	poses = llJsonGetValue(topRestraint, ["poses"]);
	if (!isSet(poses)) {
		poses = llJsonSetValue(poses, [JSON_APPEND], "free");
	}
	simpleRequest("setLegPoses", poses);
}

releaseRestraint(string prmType) {
	if (prmType == "arm") {
		rmSlot("torso");
		rmSlot("elbow");
		rmSlot("wrist");
		rmSlot("hand");
	} else if (prmType == "leg") {
		rmSlot("immobilizer");
		rmSlot("knee");
		rmSlot("ankle");
		rmSlot("crotch");
	} else if (prmType == "gag") {
		rmSlot("gag1");
		rmSlot("gag2");
		rmSlot("gag3");
		rmSlot("gag4");
	}

	deployRestraints();
}

rebuild_metadata() {
	_metadata = llJsonSetValue(_metadata, ["slots"], _slots);

	integer isArmsBound = isSet(llJsonGetValue(_restraints, ["wrist"]))
		|| isSet(llJsonGetValue(_restraints, ["elbow"]))
		|| isSet(llJsonGetValue(_restraints, ["torso"]));
	_metadata = llJsonSetValue(_metadata, ["armBound"], (string)isArmsBound);

	integer isLegsBound = isSet(llJsonGetValue(_restraints, ["ankle"]))
		|| isSet(llJsonGetValue(_restraints, ["knee"]))
		|| isSet(llJsonGetValue(_restraints, ["immobilizer"]));
	_metadata = llJsonSetValue(_metadata, ["legBound"], (string)isLegsBound);

	integer isGagged = isSet(llJsonGetValue(_restraints, ["gag1"]))
		|| isSet(llJsonGetValue(_restraints, ["gag2"]))
		|| isSet(llJsonGetValue(_restraints, ["gag3"]))
		|| isSet(llJsonGetValue(_restraints, ["gag4"]));
	_metadata = llJsonSetValue(_metadata, ["gagged"], (string)isGagged);

	_metadata = llJsonSetValue(_metadata, ["mouthOpen"], (string)searchRestraint("gag", "mouthOpen", "1"));
	_metadata = llJsonSetValue(_metadata, ["speechGarbled"], (string)searchRestraint("gag", "speechGarbled", "1"));
	_metadata = llJsonSetValue(_metadata, ["speechMuffled"], (string)searchRestraint("gag", "speechMuffled", "1"));
	_metadata = llJsonSetValue(_metadata, ["speechSealed"], (string)searchRestraint("gag", "speechSealed", "1"));

	_metadata = llJsonSetValue(_metadata, ["armTetherable"], (string)searchRestraint("arm", "canTether", "1"));
	_metadata = llJsonSetValue(_metadata, ["legTetherable"], (string)searchRestraint("leg", "canTether", "1"));

	_metadata = llJsonSetValue(_metadata, ["armBoundExternal"], (string)searchRestraint("arm", "type", "external"));
	_metadata = llJsonSetValue(_metadata, ["animations"], llList2Json(JSON_ARRAY, getRestraintList(_restraints, "animations")));

	_metadata = llJsonSetValue(_metadata, ["security", "arm"], getSecurityDetails("arm"));
	_metadata = llJsonSetValue(_metadata, ["security", "leg"], getSecurityDetails("leg"));
	_metadata = llJsonSetValue(_metadata, ["security", "gag"], getSecurityDetails("gag"));
	_metadata = llJsonSetValue(_metadata, ["security", "crotch"], getSecurityDetails("crotch"));
	_metadata = llJsonSetValue(_metadata, ["security", "hand"], getSecurityDetails("hand"));
}

string getSecurityDetails(string prmType) {
	string details = "{'complexity':0,'integrity':0,'tightness':0}";

	// Tightness: Add all restraint totals for tightness
	// Complexity: Get just the top level
	// Integrity: Get just the top level.

	list liSlots = getSearchSlots(prmType);

	// Get details from top restraint
	string topRestraint = getTopRestraint(prmType);
	details = llJsonSetValue(details, ["complexity"], llJsonGetValue(topRestraint, ["complexity"]));
	details = llJsonSetValue(details, ["integrity"], llJsonGetValue(topRestraint, ["integrity"]));

	// Get cumulative details
	list slots = getSearchSlots(prmType);

	integer index;
	integer tightness;
	for (index = 0; index < llGetListLength(slots); index++) {
		string slot = llList2String(slots, index);
		tightness += (integer)llJsonGetValue(_restraints, [slot, "tightness"]);
	}
	details = llJsonSetValue(details, ["tightness"], (string)tightness);

	// Other properties
	details = llJsonSetValue(details, ["canCut"], llJsonGetValue(topRestraint, ["canCut"]));
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
		else if ("rmSlot" == function) { rmSlot(value); deployRestraints(); return; }
		else if ("releaseRestraint" == function) releaseRestraint(value);
		else if ("overrideRestraint" == function) override_restraint(value);
	}
}
