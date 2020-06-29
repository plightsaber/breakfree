$import Modules.ContribLib.lslm();
$import Modules.GeneralTools.lslm();
$import Modules.RestraintTools.lslm();

string _slots;		// List of UIDs ONLY for currently applied restraints
string _villain;

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
	string restraint = llJsonGetValue(prmJson, ["restraint"]);
	string slot = llJsonGetValue(restraint, ["slot"]);

	_restraints = llJsonSetValue(_restraints, [slot], restraint);
	_slots = llJsonSetValue(_slots, [slot], llJsonGetValue(restraint, ["uid"]));

	// You don't get experience for tying yourself up.
	if (llGetOwner() != llJsonGetValue(_villain, ["key"])) {
		string request;

		integer tightness = (integer)llJsonGetValue(restraint, ["tightness"]);
		integer integrity = (integer)llJsonGetValue(restraint, ["integrity"]);
		integer complexity = (integer)llJsonGetValue(restraint, ["complexity"]);
		integer expEarned = ((tightness+integrity)*complexity/2);

		apiRequest(llJsonGetValue(_villain, ["key"]), llGetOwner(), "addExp", (string)expEarned);
	}
	deployRestraints();
}

deployRestraints() {
	resetPoses();
	simpleRequest("setAttachments", llList2Json(JSON_ARRAY, getAttachments()));
	rebuild_metadata();
	rebuild_security();
}

list getAttachments() {
	list bindFolders = getRestraintList(_restraints, "attachments");
	list preventFolders = getRestraintList(_restraints, "preventAttach");

	// Use bent knee restraints for certain positions
	string kneeRestraint = llJsonGetValue(_restraints, ["knee"]);
	string immobilizer = llJsonGetValue(_restraints, ["immobilizer", "uid"]);
	if (isSet(kneeRestraint) && isSet(immobilizer) &&
		(llSubStringIndex(immobilizer, "hog") != -1 || llSubStringIndex(immobilizer, "ball") != -1 || llSubStringIndex(immobilizer, "kneel") != -1)
	) {
		// Add/Remove attachment by pattern.  You hopefully named everything to proper convention!
		string attachName = "leg_" + llJsonGetValue(kneeRestraint, ["type"]) + "_knee";
		preventFolders += attachName;
		bindFolders += attachName + "Bent";
	}

	// Hogtie connectors
	if ("hog_rope" == immobilizer) {
		if (isSet(llJsonGetValue(_restraints, ["elbow"]))) { bindFolders += ["leg_rope_hogBackTight"]; }
		else if (llJsonGetValue(_restraints, ["torso", "uid"]) == "box_rope") { bindFolders += ["leg_rope_hogBox"]; }
		else { bindFolders += ["leg_rope_hogBack"]; }
	}

	// Change meshes for back => backTight pose
	if (isSet(llJsonGetValue(_restraints, ["elbow"]))) {
		string wrist = llJsonGetValue(_restraints, ["wrist", "uid"]);
		if (wrist == "back_rope") {
			bindFolders += "arm_rope_backTight_wrist";
			preventFolders += "arm_rope_back_wrist";
		} else if (wrist == "back_tape") {
			bindFolders += "arm_tape_backTight_wrist";
			preventFolders += "arm_tape_back_wrist";
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

	// Remove hog_rope if connecting arm restraint removed
	if (llJsonGetValue(_slots, ["immobilizer"]) == "hog_rope"
		&& (slot == "wrist" || llJsonGetValue(restraint, ["uid"]) == "box_rope")
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
	string poseRequest;

	// Arm poses
	poses = llJsonGetValue(getTopRestraint("arm"), ["poses"]);
	if (!isSet(poses)) {
		poses = llJsonSetValue(poses, [JSON_APPEND], "free");
	}
	poseRequest = llJsonSetValue(poseRequest, ["arm"], poses);

	// Leg poses
	poses = llJsonGetValue(getTopRestraint("leg"), ["poses"]);
	if (!isSet(poses)) {
		poses = llJsonSetValue(poses, [JSON_APPEND], "free");
	}
	poseRequest = llJsonSetValue(poseRequest, ["leg"], poses);

	simpleRequest("setPoses", poseRequest);
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

rebuild_security()
{
	string security;
	security = llJsonSetValue(security, ["security", "arm"], getSecurityDetails("arm"));
	security = llJsonSetValue(security, ["security", "leg"], getSecurityDetails("leg"));
	security = llJsonSetValue(security, ["security", "gag"], getSecurityDetails("gag"));
	security = llJsonSetValue(security, ["security", "crotch"], getSecurityDetails("crotch"));
	security = llJsonSetValue(security, ["security", "hand"], getSecurityDetails("hand"));

	simpleRequest("setSecurity", security);
}

rebuild_metadata() {
	string metadata;
	metadata = llJsonSetValue(metadata, ["slots"], _slots);

	integer isArmsBound = isSet(llJsonGetValue(_restraints, ["wrist"]))
		|| isSet(llJsonGetValue(_restraints, ["elbow"]))
		|| isSet(llJsonGetValue(_restraints, ["torso"]));
	metadata = llJsonSetValue(metadata, ["armBound"], (string)isArmsBound);

	integer isLegsBound = isSet(llJsonGetValue(_restraints, ["ankle"]))
		|| isSet(llJsonGetValue(_restraints, ["knee"]))
		|| isSet(llJsonGetValue(_restraints, ["immobilizer"]));
	metadata = llJsonSetValue(metadata, ["legBound"], (string)isLegsBound);

	integer isGagged = isSet(llJsonGetValue(_restraints, ["gag1"]))
		|| isSet(llJsonGetValue(_restraints, ["gag2"]))
		|| isSet(llJsonGetValue(_restraints, ["gag3"]))
		|| isSet(llJsonGetValue(_restraints, ["gag4"]));
	metadata = llJsonSetValue(metadata, ["gagged"], (string)isGagged);

	if (isGagged) {
		metadata = llJsonSetValue(metadata, ["mouthOpen"], (string)searchRestraint("gag", "mouthOpen", "1"));
		metadata = llJsonSetValue(metadata, ["speechGarbled"], (string)searchRestraint("gag", "speechGarbled", "1"));
		metadata = llJsonSetValue(metadata, ["speechMuffled"], (string)searchRestraint("gag", "speechMuffled", "1"));
		metadata = llJsonSetValue(metadata, ["speechSealed"], (string)searchRestraint("gag", "speechSealed", "1"));
	} else {
		metadata = llJsonSetValue(metadata, ["mouthOpen"], "0");
		metadata = llJsonSetValue(metadata, ["speechGarbled"], "0");
		metadata = llJsonSetValue(metadata, ["speechMuffled"], "0");
		metadata = llJsonSetValue(metadata, ["speechSealed"], "0");
	}

	metadata = llJsonSetValue(metadata, ["armTetherable"], (string)searchRestraint("arm", "canTether", "1"));
	metadata = llJsonSetValue(metadata, ["legTetherable"], (string)searchRestraint("leg", "canTether", "1"));

	metadata = llJsonSetValue(metadata, ["armBoundExternal"], (string)searchRestraint("arm", "type", "external"));
	metadata = llJsonSetValue(metadata, ["animations"], llList2Json(JSON_ARRAY, getRestraintList(_restraints, "animations")));

	simpleRequest("setRestraints", metadata);
}

string getSecurityDetails(string prmType) {
	string details = "{'complexity':0,'integrity':0,'tightness':0}";

	// Tightness: Add all restraint totals for tightness
	// Complexity: Get just the top level
	// Integrity: Get just the top level.

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
	details = llJsonSetValue(details, ["canCrop"], llJsonGetValue(topRestraint, ["canCrop"]));
	details = llJsonSetValue(details, ["canCut"], llJsonGetValue(topRestraint, ["canCut"]));
	details = llJsonSetValue(details, ["canEscape"], llJsonGetValue(topRestraint, ["canEscape"]));
	details = llJsonSetValue(details, ["canPick"], llJsonGetValue(topRestraint, ["canPick"]));

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
		else if ("setVillain" == function) { _villain = value; }
	}
}
