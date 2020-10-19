$import Modules.ContribLib.lslm();
$import Modules.GuiTools.lslm();
$import Modules.PoseLib.lslm();
$import Modules.UserLib.lslm();

// Quick Keys
key _ownerID;
key _villainID;

// Settings
integer rpMode = FALSE;
integer _lockable = TRUE;
integer _RLV = FALSE;

// Stats
string _owner;	// User object
integer _ownerExp = 0;
list _ownerFeats = [];

key _statsQueryID;

// Status Variables
integer _isArmsBound = FALSE;
integer _isLegsBound = FALSE;
integer _isGagged = FALSE;
integer _isHandBound = FALSE;
integer _isOtherBound = FALSE;

list _legPoses;

// GUI screens
integer GUI_HOME = 0;
integer GUI_STATS = 10;
integer GUI_OPTIONS = 20;
integer GUI_POSE = 70;

string _resumeFunction;

list _feats = [
	"Athletic",
	"Athletic+",
	"Eidetic",
	"Intuitive",
	"Endurant",
	"Endurant+",
	"Flexible",
	"Flexible+",
	"Resolute",
	"Resolute+",
	"Steadfast",
	"Anubis",
	"Anubis+",
	"Anubis++",
	"Rigger",
	"Rigger+",
	"Gag Snob",
	"Gag Snob+",
	"Sadist"
];

init() {
	_ownerID = llGetOwner();

	// Reset owner if mismatched.
	if (llJsonGetValue(_owner, ["key"]) != _ownerID) {
		_owner = "";
	}

	if (_owner == "" && llGetInventoryKey(".stats") != NULL_KEY) {
		_statsQueryID = llGetNotecardLine(".stats",0);	// Load config.
	}

	_owner = llJsonSetValue(_owner, ["key"], llGetOwner());
	_owner = llJsonSetValue(_owner, ["name"], llGetDisplayName(llGetOwner()));
	_owner = llJsonSetValue(_owner, ["gender"], getGender(llGetOwner()));

	_owner = llJsonSetValue(_owner, ["feats"], llList2Json(JSON_ARRAY, _ownerFeats));
	_owner = llJsonSetValue(_owner, ["exp"], (string)_ownerExp);
	_owner = llJsonSetValue(_owner, ["armBound"], (string)_isArmsBound);
	_owner = llJsonSetValue(_owner, ["handBound"], (string)_isHandBound);
	_owner = llJsonSetValue(_owner, ["blade"], JSON_NULL);
}

init_gui(key prmID, integer prmScreen) {
	guiUserID = prmID;

	if (guiID) { llListenRemove(guiID); }
	guiChannel = (integer)llFrand(-9998) - 1;
	guiID = llListen(guiChannel, "", guiUserID, "");
	gui(prmScreen);
}

// ===== GUI =====
gui(integer prmScreen) {
	// Reset Busy Clock
	simpleRequest("resetGuiTimer", "1");

	string btn10 = " ";	string btn11 = " ";			string btn12 = " ";
	string btn7 = " ";	string btn8 = " ";			string btn9 = " ";
	string btn4 = " ";	string btn5 = " ";			string btn6 = " ";
	string btn1 = " ";	string btn2 = "<<Done>>";	string btn3 = " ";

	guiText = " ";
	list mpButtons;

	// GUI: Main
	if (prmScreen == GUI_HOME) {
		guiText = "v4.1.3";

		if (rpMode || (!_isArmsBound && !_isLegsBound && !_isGagged) || _villainID == _ownerID) {
			btn1 = "Options";
			btn4 = "Bind";
		}

		if (_isLegsBound) {
			btn6 = "Pose";
		}

		if (_isArmsBound || _isLegsBound || _isGagged || _isOtherBound) { btn5 = "Escape"; }
		btn3 = "Stats";
	}
	// GUI: Stats
	else if (prmScreen == GUI_STATS) {
		guiText = "Level: " + (string)getUserLevel() + "\n";
		guiText += "Experience: " + (string)_ownerExp + "/" + (string)getNextLevelExp() + "\n";
		guiText += "Feats: " + llDumpList2String(_ownerFeats, ", ");

		if (canLevelUp()) {
			mpButtons = getAvailableFeats();
		}
		mpButtons = multipageGui(mpButtons, 3, multipageIndex);

		btn1 = "<<Back>>";
		btn3 = "Export";
	}
	else if (prmScreen == GUI_OPTIONS) {
		guiText = "User Settings" + "\n";
		guiText += "Please reference the included README for details.";

		if (rpMode) { mpButtons += "☑ RP Mode"; }
		else { mpButtons += "☒ RP Mode"; }

		if (_RLV) { mpButtons += "☑ RLV"; }
		else { mpButtons += "☒ RLV"; }

		if (_lockable) { mpButtons += "☑ Lockable"; }
		else { mpButtons += "☒ Lockable"; }

		btn1 = "<<Back>>";
	}
	else if (prmScreen == GUI_POSE) {
		guiText = "How do you want to pose?";
		mpButtons = multipageGui(_legPoses, 3, multipageIndex);
	}

	if (prmScreen != guiScreen) { guiScreenLast = guiScreen; }
	guiScreen = prmScreen;

	guiButtons = [btn1, btn2, btn3];
	if (btn4+btn5+btn6 != "   ") { guiButtons += [btn4, btn5, btn6]; }
	if (btn7+btn8+btn9 != "   ") { guiButtons += [btn7, btn8, btn9]; }
	if (btn10+btn11+btn12 != "   ") { guiButtons += [btn10, btn11, btn12]; }

	if (llGetListLength(mpButtons)) { guiButtons += mpButtons; }
	llDialog(guiUserID, guiText, guiButtons, guiChannel);
}

// ===== Gets & Sets =====
list getAvailableFeats() {

	// Remove any feats we already have
	list feats = ListXnotY(_feats, _ownerFeats);

	// Remove any feats that have unmet prerequisites
	feats = requirePrerequisiteFeat(feats, "Athletic+", "Athletic");
	feats = requirePrerequisiteFeat(feats, "Endurant+", "Endurant");
	feats = requirePrerequisiteFeat(feats, "Flexible+", "Flexible");
	feats = requirePrerequisiteFeat(feats, "Resolute+", "Resolute");
	feats = requirePrerequisiteFeat(feats, "Sadist", "Rigger+");
	feats = requirePrerequisiteFeat(feats, "Rigger+", "Rigger");
	feats = requirePrerequisiteFeat(feats, "Anubis++", "Anubis+");
	feats = requirePrerequisiteFeat(feats, "Anubis+", "Anubis");
	feats = requirePrerequisiteFeat(feats, "Gag Snob+", "Gag Snob");

	return feats;
}

setRestraints(string prmJson) {
	_isArmsBound = (integer)llJsonGetValue(prmJson, ["armBound"])
		&& !(integer)llJsonGetValue(prmJson, ["armBoundExternal"]);
	_isLegsBound = (integer)llJsonGetValue(prmJson, ["legBound"]);
	_isGagged = (integer)llJsonGetValue(prmJson, ["gagged"]);
	_isHandBound = isSet(llJsonGetValue(prmJson, ["slots", "hand"]));
	_isOtherBound = isSet(llJsonGetValue(prmJson, ["slots", "crotch"])) || isSet(llJsonGetValue(prmJson, ["slots", "hand"]));

	_owner = llJsonSetValue(_owner, ["armBound"], (string)_isArmsBound);
	_owner = llJsonSetValue(_owner, ["handBound"], (string)_isHandBound);
}

integer getNextLevelExp() {
	integer tmpLevel = getUserLevel();
	if (tmpLevel == 0) {
		return 0;
	}

	return (integer)(tmpLevel * 50 + llPow(tmpLevel,3));
}

integer getUserLevel() {
	return llGetListLength(_ownerFeats);
}

setAvailablePoses(string prmPoses) {
	_legPoses = llJson2List(prmPoses);
	_legPoses += getPoseBallPoseList();
}

setExp(integer exp) {
	_ownerExp = exp;
	_owner = llJsonSetValue(_owner, ["exp"], (string)exp);
}

setFeats(list feats) {
	_ownerFeats = llListSort(feats, 1, TRUE);
	_owner = llJsonSetValue(_owner, ["feats"], llList2Json(JSON_ARRAY, feats));
	simpleRequest("setOwner", _owner);
	simpleRequest("setOwnerFeats", llList2Json(JSON_ARRAY, feats));
}

// ===== Main Functions =====
addExp(string prmValue) {
	//debug("Earned Experience! " + prmValue);
	integer experience = _ownerExp;
	integer addValue = (integer)prmValue;
	if (addValue > 0) { experience += addValue; }
	setExp(experience);
}

addFeat(string feat) {
	_ownerFeats += feat;
	setFeats(_ownerFeats);
}

integer canLevelUp() {
	return getNextLevelExp() <= _ownerExp
		&& getUserLevel() < llGetListLength(_feats);
}

list requirePrerequisiteFeat(list feats, string feat, string prerequisite) {
	integer featIndex = llListFindList(feats, [feat]);
	integer preIndex = llListFindList(feats, [prerequisite]);
	if (preIndex != -1 && featIndex != -1) {
		feats = llDeleteSubList(feats, featIndex, featIndex);
	}
	return feats;
}

// ===== Event Controls =====
execute_function(string prmFunction, string prmJson) {
	string value = llJsonGetValue(prmJson, ["value"]);
	if (JSON_INVALID == value) {
		debug("Invalid value in JSON: " + prmJson);
		return;
	}

	if (prmFunction == "gui_owner") {
		key userkey = (key)llJsonGetValue(prmJson, ["userkey"]);
		init_gui(userkey, (integer)value);
	}
	else if (prmFunction == "setVillainKey") { _villainID = value; }
	else if (prmFunction == "setPoses") { setAvailablePoses(llJsonGetValue(value, ["leg"])); }
	else if (prmFunction == "addExp") { addExp(value); }
	else if (prmFunction == "getOwnerFeats") { setFeats(_ownerFeats); }
	else if (prmFunction == "setRestraints") { setRestraints(value); }
	else if (prmFunction == "resetGUI") {
		exit("");
	}
}

default {
	state_entry() {	init();	}
	on_rez(integer start_param) { init(); }

	dataserver(key queryID, string data) {
		if (queryID == _statsQueryID) {
			string exp = llJsonGetValue(data, ["exp"]);
			string feats = llJsonGetValue(data, ["feats"]);
			if (isSet(exp)) { setExp((integer)exp); }
			if (isSet(feats)) { setFeats(llJson2List(feats)); }
		}
	}

	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel = guiChannel) {
			if (prmText == "<<Done>>") { exit("done"); return; }
			else if (prmText == "<<Back>>") { multipageIndex = 0; gui(guiScreenLast); return;}
			else if (prmText == "Next >>") { multipageIndex ++; gui(guiScreen); return; }
			else if (prmText == "<< Previous") { multipageIndex --; gui(guiScreen); return; }
			else if (prmText == " ") { gui(guiScreen); }

			if (guiScreen == GUI_HOME) {
				if (prmText == "Bind") {
					simpleRequest("setVillain", _owner);
					guiRequest("gui_bind", FALSE, guiUserID, 0);
					return;
				}
				else if (prmText == "Escape") { guiRequest("gui_escape", FALSE, guiUserID, 0); return; }
				else if (prmText == "Stats") { gui(GUI_STATS); }
				else if (prmText == "Options") { gui(GUI_OPTIONS); }
				else if (prmText == "Pose") { gui(GUI_POSE); }
			} else if (guiScreen == GUI_STATS) {
				if (prmText == "Export") {
					string export;
					export = llJsonSetValue(export, ["exp"], (string)_ownerExp);
					export = llJsonSetValue(export, ["feats"], llList2Json(JSON_ARRAY, _ownerFeats));
					llOwnerSay(export);
				} else {
					addFeat(prmText);
				}
				gui(guiScreen);
			} else if (guiScreen == GUI_OPTIONS) {
				if (prmText == "☒ RP Mode") { rpMode = TRUE; simpleRequest("setRPMode", "1"); }
				else if (prmText == "☑ RP Mode") { rpMode = FALSE; simpleRequest("setRPMode", "0"); }
				else if (prmText == "☒ RLV") { _RLV = TRUE; simpleRequest("setRLV", "1"); }
				else if (prmText == "☑ RLV") { _RLV = FALSE; simpleRequest("setRLV", "0"); }
				else if (prmText == "☒ Lockable") { _lockable = TRUE; simpleRequest("setLockable", "1"); }
				else if (prmText == "☑ Lockable") { _lockable = FALSE; simpleRequest("setLockable", "0"); }
				gui(guiScreen);
			} else if (guiScreen == GUI_POSE) {
				simpleRequest("setLegPose", prmText);
				gui(guiScreen);
			}
		}
	}

	link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
		string function;
		string value;

		if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
			debug(prmText);
			return;
		}
		execute_function(function, prmText);

		if (function == _resumeFunction) {
			_resumeFunction = "";
			init_gui(guiUserID, guiScreen);
		}
	}
}
