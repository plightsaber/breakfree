$import Modules.RestraintTools.lslm();

string self;	// JSON object

// Global Variables
list _attachedFolders = [];

addRestraint(string prmJson) {
	string type = llJsonGetValue(prmJson, ["type"]);
	string restraint = llJsonGetValue(prmJson, ["restraint"]);
	
	_restraints = llJsonSetValue(_restraints, [type, JSON_APPEND], restraint);
	setRestraints(_restraints);
}

remRestraint(string prmType) {
	string restraints = llJsonGetValue(_restraints, [prmType]);
	if (JSON_NULL == restraints) {
		debug("No restraints to remove.");
		return;
	}

	list liRestraints = llJson2List(restraints);
	string restraint = llList2String(liRestraints, -1);
	liRestraints = llDeleteSubList(liRestraints, -1, -1);

	if (llGetListLength(liRestraints) == 0) {
		_restraints = llJsonSetValue(_restraints, [prmType], JSON_NULL);
	} else {
		_restraints = llJsonSetValue(_restraints, [prmType], llList2Json(JSON_ARRAY, liRestraints));
	}
	
	setRestraints(_restraints);
}

releaseRestraint(string prmType) {
	_restraints = llJsonSetValue(_restraints, [prmType], JSON_NULL);
	setRestraints(_restraints);
}

setRestraints(string prmJson) {
	list bindFolders = [];
	list preventFolders = [];
	string restraint;
	integer index;

	// Arm loop.
	restraint = llJsonGetValue(prmJson, ["arm"]);
	if (restraint != JSON_INVALID) { 
		bindFolders += get_restraint_list(restraint, "attachments");
		preventFolders += get_restraint_list(restraint, "preventAttach");
	}
	
	// Leg Loop.
	restraint = llJsonGetValue(prmJson, ["leg"]);
	if (restraint != JSON_INVALID) { 
		bindFolders += get_restraint_list(restraint, "attachments");
		preventFolders += get_restraint_list(restraint, "preventAttach");
	}
	
	// Gag Loop.
	restraint = llJsonGetValue(prmJson, ["gag"]);
	if (restraint != JSON_INVALID) { 
		bindFolders += get_restraint_list(restraint, "attachments");
		preventFolders += get_restraint_list(restraint, "preventAttach");
	}
	
	bindFolders = ListXnotY(bindFolders, preventFolders);
	list addFolders = ListXnotY(bindFolders, _attachedFolders);
	list remFolders = ListXnotY(_attachedFolders, bindFolders);
	
	// Add Folders.
	debug((string)addFolders);
	for (index = 0; index < llGetListLength(addFolders); index++) {
		llOwnerSay("@attachover:BreakFree/bf_" + llList2String(addFolders, index) + "=force");
	}

	// Detatch Folders.
	for (index = 0; index < llGetListLength(remFolders); index++) {
		llOwnerSay("@detachall:BreakFree/bf_" + llList2String(remFolders, index) + "=force");
	}
	
	// Save setting
	_attachedFolders = bindFolders;
}

// ===== User-Defined Functions ======
list ListXnotY(list lx, list ly) {// return elements in X list that are not in Y list
	list lz = [];
	integer i = llGetListLength(lx);
	while(i--)
	if ( !~llListFindList(ly,llList2List(lx,i,i)) )
			lz += llList2List(lx,i,i);
	return lz;
}

// ===== Other Functions =====
debug(string output) {
	// TODO: global enable/disable?
	llOwnerSay(output);
}

// ===== Event Controls =====

default {
	link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
		string function;
		string value;

		if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
			debug(prmText);
			return;
		}
		value = llJsonGetValue(prmText, ["value"]);

		if ("addRestraint" == function) addRestraint(value);
		else if ("remRestraint" == function) remRestraint(value);
		else if ("releaseRestraint" == function) releaseRestraint(value);
		else if ("overrideRestraint" == function) setRestraints(value);
	}
}
