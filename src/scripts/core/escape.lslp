$import Modules.RestraintTools.lslm();

string activePart;

// Avi Settings
string gender = "female";
list SKILLS = [];
integer DEX = 1;
integer STR = 1;
integer INT = 1;

// Foreign Avi Settings
string helper_gender = "female";
integer helper_DEX = 1;
integer helper_STR = 1;
integer helper_INT = 1;

// GUI variables
key guiUserID;
list guiButtons;
integer guiChannel;
integer guiID;
integer guiScreen;
integer guiScreenLast;
string guiText;
integer guiTimeout = 30;

// Bindings
// Arm
integer arm_canEscape;
integer arm_canCut;
integer arm_difficulty;
integer arm_tightness;
string arm_type;
// TODO: Tensile strength?

/// Leg
integer leg_canEscape;
integer leg_canCut;
integer leg_difficulty;
integer leg_tightness;
string leg_type;
// TODO: Tensile strength?

// Gag
integer gag_canEscape;
integer gag_canCut;
integer gag_difficulty;
integer gag_tightness;
string gag_type;

// Escape Vars
list _struggle_puzzle;
integer _struggle_progress;
string _actionmsg;

// Other
integer _armBoundExternal = FALSE;
key configQueryID;
string jsonSettings;
integer _handsFree;
string _resumeFunction;

init_gui(key prmID, integer prmScreen) {
	guiUserID = prmID;

	if (guiID) { llListenRemove(guiID); }
	guiChannel = (integer)llFrand(-9998) - 1;
	guiID = llListen(guiChannel, "", guiUserID, "");
	gui(prmScreen);
}

// ===== Main Functions =====
integer assisted() { return guiUserID != llGetOwner(); }

loosen_restraint() {
	// Progress based on strength
	// TODO: and energy?
	integer tmpProgress = roll(1, llFloor(STR/2));
	if (!assisted()) {
		llOwnerSay("Your restraints have loosened.");

		// Earn experience!
		integer expEarned = 0;
		if (activePart == "arm") { expEarned = arm_difficulty; }
		if (activePart == "leg") { expEarned = leg_difficulty; }
		if (activePart == "gag") { expEarned = gag_difficulty; }
		if (!isArmsBound()) {
			expEarned = llFloor(expEarned/3);
		}
		simpleRequest("addExp", (string)gag_difficulty);
	}

	_struggle_puzzle = newPuzzle(activePart);

	if (activePart == "arm") { arm_tightness -= tmpProgress; }
	else if (activePart == "leg") { leg_tightness -= tmpProgress; }
	else if (activePart == "gag") { gag_tightness -= tmpProgress; }
}

update_progress() {
	_actionmsg ="You think you've made some progress.";

	_struggle_progress += 1;
	if (assisted()) { _struggle_progress += 1; }	// TODO: Do this better?

	if (_handsFree || _struggle_progress >= llGetListLength(_struggle_puzzle)) {
		loosen_restraint();
	}
}

escape_action(string prmVerb) {
	string tmpAction;
	string tmpMessage = "";

	if (prmVerb == "Twist") { tmpAction = "1"; }
	else if (prmVerb == "Squirm") { tmpAction = "2"; }
	else if (prmVerb == "Struggle") { tmpAction = "3"; }
	else if (prmVerb == "Thrash") { tmpAction = "4"; }

	else if (prmVerb == "Pick") { tmpAction = "1";}
	else if (prmVerb == "Pluck") { tmpAction = "2";}
	else if (prmVerb == "Pull") { tmpAction = "3";}
	else if (prmVerb == "Yank") { tmpAction = "4";}

	// Execute action
	integer success = (tmpAction == llList2String(_struggle_puzzle, _struggle_progress));
	if (success) {
		update_progress();
	} else {
		_actionmsg = "Your " + prmVerb + " didn't help.";
		if (!assisted() && _struggle_progress > 0) { _struggle_progress--; }
	}

	// Animate
	if (!assisted()) {
		if (success) { simpleRequest("animate", "animation_" + activePart + "_success"); }
		else { simpleRequest("animate", "animation_" + activePart + "_failure"); }
	}

	if (restraintFreed()) {
		return;
	}

	gui(guiScreen);
}

integer restraintFreed() {
	if (activePart == "arm" && arm_tightness <= 0) {
		llWhisper(0, getOwnerName() + " is freed from " + getOwnerPronoun("her") +"	arm restraints.");
		simpleRequest("remRestraint", "arm");
		_resumeFunction = "setRestraints";
		return TRUE;
	}

	else if (activePart == "leg" && leg_tightness <= 0) {
		llWhisper(0, getOwnerName() + " is freed from " + getOwnerPronoun("her") +"	leg restraints.");
		simpleRequest("remRestraint", "leg");
		_resumeFunction = "setRestraints";
		return TRUE;
	}

	else if (activePart == "gag" && gag_tightness <= 0) {
		llWhisper(0, getOwnerName() + " is freed from " + getOwnerPronoun("her") +" gag.");
		simpleRequest("remRestraint", "gag");
		_resumeFunction = "setRestraints";
		return TRUE;
	}
	return FALSE;
}

list newPuzzle(string prmRestraint) {
	integer tmpDifficulty;
	_struggle_progress = 0;
	if (prmRestraint == "arm") { tmpDifficulty = arm_difficulty; }
	if (prmRestraint == "leg") { tmpDifficulty = leg_difficulty; }
	if (prmRestraint == "gag") { tmpDifficulty = gag_difficulty; }

	// Modify difficulty based on DEX
	if (assisted()) {
		// TODO: assisted difficulty
	} else {
		integer tmpDifficultyReduction = llFloor(DEX/2);
		if (tmpDifficultyReduction > (tmpDifficulty/2)) { tmpDifficultyReduction = llFloor(tmpDifficulty/2); }
		tmpDifficulty -= tmpDifficultyReduction;
	}
	// TODO: Energy?

	list tmpPuzzle = [];
	integer tmpIndex;
	for (tmpIndex = 0; tmpIndex < tmpDifficulty; tmpIndex++) {
		integer tmpDie = roll(1, 4);
		if (tmpDie == 1)		 tmpPuzzle += "1";
		else if (tmpDie == 2)	tmpPuzzle += "2";
		else if (tmpDie == 3)	tmpPuzzle += "3";
		else if (tmpDie == 4)	tmpPuzzle += "4";
	}

	return tmpPuzzle;
}

string displayTightness(string prmRestraint) {
	integer tmpIndex;
	integer tmpTightness;
	string tmpDisplay;
	string tmpChar = " ";

	if (prmRestraint == "arm") { tmpTightness = arm_tightness; }
	if (prmRestraint == "leg") { tmpTightness = leg_tightness; }
	if (prmRestraint == "gag") { tmpTightness = gag_tightness; }

	if (tmpTightness > 30) {
		tmpChar = "=";
		tmpTightness -= 30;
		for (tmpIndex = 0; tmpIndex < tmpTightness; tmpIndex ++) { tmpDisplay += "#"; }
	} else if (tmpTightness > 20) {
		tmpChar = "~";
		tmpTightness -= 20;
		for (tmpIndex = 0; tmpIndex < tmpTightness; tmpIndex ++) { tmpDisplay += "="; }
	} else if (tmpTightness > 10) {
		tmpChar = "-";
		tmpTightness -= 10;
		for (tmpIndex = 0; tmpIndex < tmpTightness; tmpIndex ++) { tmpDisplay += "~"; }
	} else {
		tmpChar = " ";
		for (tmpIndex = 0; tmpIndex < tmpTightness; tmpIndex ++) { tmpDisplay += "-"; }
	}

	while (tmpIndex < 10) {
		tmpDisplay += tmpChar;
		tmpIndex++;
	}
	return tmpDisplay;
}

// ===== GUI =====
get_gui(string prmPart) {
	string tmpType;
	activePart = prmPart;
	_actionmsg = "";

	if (activePart == "arm") { tmpType = arm_type; }
	else if (activePart == "leg") { tmpType = leg_type; }
	else if (activePart == "gag") { tmpType = gag_type; }

	_struggle_puzzle = newPuzzle(activePart);

	if (guiUserID == llGetOwner() && isArmsBound()) {
		_handsFree = FALSE;
		gui(10);
		return;
	} else {
		_handsFree = TRUE;
		gui(20);
		return;
	}
}

gui(integer prmScreen) {
	// Reset Busy Clock
	llSetTimerEvent(guiTimeout);

	string btn10 = " ";	string btn11 = " ";			string btn12 = " ";
	string btn7 = " ";	string btn8 = " ";			string btn9 = " ";
	string btn4 = " ";	string btn5 = " ";			string btn6 = " ";
	string btn1 = " ";	string btn2 = "<<Done>>";	string btn3 = " ";

	guiText = " ";

	if (prmScreen == 0 && ((integer)llJsonGetValue(jsonSettings, ["gagOnly"]))) {
		get_gui("gag");
		return;
	}

	if (prmScreen != guiScreen) { guiScreenLast = guiScreen; }
	if (btn1 == " " && (prmScreen != 0)) { btn1 = "<<Back>>"; };

	// GUI: Main
	if (prmScreen == 0) {
		if (guiUserID == llGetOwner()) { btn1 = "<<Back>>"; }

		// reset previous screen
		guiScreenLast = 0;

		if (arm_tightness > 0) { btn4 = "Free Arms"; }
		if (leg_tightness > 0) { btn5 = "Free Legs"; }
		if (gag_tightness > 0) { btn6 = "Free Gag"; }

		// TODO: Get quick release options
	}

	// GUI: Self Escape
	else if (prmScreen == 10) {
		btn4 = "Twist";
		btn5 = "Squirm";
		btn6 = "Struggle";
		btn8 = "Thrash";

		guiText = "Restraint: " + ToTitle(activePart);	// TODO: Get full name of restraint
		guiText += "\nTightness: " + displayTightness(activePart);
		// TODO: Show suggestion based on INT
		if (_actionmsg) { guiText += "\n" + _actionmsg; }
	}

	// GUI Assisted Escape
	else if (prmScreen == 20) {
		btn4 = "Pick";
		btn5 = "Pluck";
		btn6 = "Pull";
		btn8 = "Yank";

		guiText = "Restraint: " + ToTitle(activePart);	// TODO: Get full name of restraint
		guiText += "\nTightness: " + displayTightness(activePart);
		// TODO: Show suggestion based on INT
		if (_actionmsg) { guiText += "\n" + _actionmsg; }
		
		if (guiUserID != llGetOwner() && (integer)llJsonGetValue(jsonSettings, ["gagOnly"])) {
			btn1 = " ";
		}
	}

	guiScreen = prmScreen;
	guiButtons = [btn1, btn2, btn3];

	if (btn4+btn5+btn6 != "	 ") { guiButtons += [btn4, btn5, btn6]; }
	if (btn7+btn8+btn9 != "	 ") { guiButtons += [btn7, btn8, btn9]; }
	if (btn10+btn11+btn12 != "	 ") { guiButtons += [btn10, btn11, btn12]; }
	llDialog(guiUserID, guiText, guiButtons, guiChannel);
}

exit(string prmReason) {
	llListenRemove(guiID);
	llSetTimerEvent(0.0);

	if (prmReason) { simpleRequest("resetGUI", prmReason); }
}

// ===== Gets =====
string getOwnerName() {
	return llGetDisplayName(llGetOwner());
}

string getOwnerPronoun(string prmPlaceholder) {
	// TODO: Get gender
	string gender = "female";
	if (gender == "female") { return prmPlaceholder; }
	else {
	}

	return "";
}

integer isArmsBound() {
	return _armBoundExternal || (arm_tightness > 0);
}

integer is_bound() {
	return (arm_tightness + leg_tightness + gag_tightness) > 0;
}

// ===== Sets =====
setRestraints(string prmInfo) {
	_restraints = prmInfo;

	_armBoundExternal = FALSE;
	string armJson = get_top_restraint("arm");
	if (JSON_NULL == armJson || JSON_INVALID == armJson) {
		arm_tightness = 0;
	} else if (llJsonGetValue(armJson, ["type"]) == "external") {
		_armBoundExternal = TRUE;
		arm_canEscape = FALSE;
		arm_canCut = FALSE;
	} else {
		arm_canCut = (integer)llJsonGetValue(armJson, ["canCut"]);
		arm_canEscape = (integer)llJsonGetValue(armJson, ["canEscape"]);
		arm_difficulty = (integer)llJsonGetValue(armJson, ["difficulty"]);
		arm_tightness = (integer)llJsonGetValue(armJson, ["tightness"]);
		arm_type = llJsonGetValue(armJson, ["type"]);
	}

	string legJson = get_top_restraint("leg");
	if (JSON_NULL == legJson || JSON_INVALID == legJson) {
		leg_tightness = 0;
	} else {
		leg_canCut = (integer)llJsonGetValue(legJson, ["canCut"]);
		leg_canEscape = (integer)llJsonGetValue(legJson, ["canEscape"]);
		leg_difficulty = (integer)llJsonGetValue(legJson, ["difficulty"]);
		leg_tightness = (integer)llJsonGetValue(legJson, ["tightness"]);
		leg_type = llJsonGetValue(legJson, ["type"]);
	}

	string gagJson = get_top_restraint("gag");
	if (JSON_NULL == gagJson || JSON_INVALID == gagJson) {
		gag_tightness = 0;
	} else {
		gag_canCut = (integer)llJsonGetValue(gagJson, ["canCut"]);
		gag_canEscape = (integer)llJsonGetValue(gagJson, ["canEscape"]);
		gag_difficulty = (integer)llJsonGetValue(gagJson, ["difficulty"]);
		gag_tightness = (integer)llJsonGetValue(gagJson, ["tightness"]);
		gag_type = llJsonGetValue(gagJson, ["type"]);
	}
}

setGender(string prmGender) {
	gender = prmGender;
}

setStats(string stats) {
	DEX = (integer)llJsonGetValue(stats, ["dex"]);
	INT = (integer)llJsonGetValue(stats, ["int"]);
	STR = (integer)llJsonGetValue(stats, ["str"]);
	SKILLS = llJson2List(llJsonGetValue(stats, ["skills"]));
}

// ===== Other Functions =====
debug(string output) {
	// TODO: global enable/disable?
	llOwnerSay(output);
}

guiRequest(string prmGUI, integer prmRestore, key prmUserID, integer prmScreen) {
	string guiRequest = "";
	guiRequest = llJsonSetValue(guiRequest, ["function"], prmGUI);
	guiRequest = llJsonSetValue(guiRequest, ["restorescreen"], (string)prmRestore);
	guiRequest = llJsonSetValue(guiRequest, ["userkey"], (string)prmUserID);
	guiRequest = llJsonSetValue(guiRequest, ["value"], (string)prmScreen);
	llMessageLinked(LINK_THIS, 0, guiRequest, NULL_KEY);
	exit("");
}

simpleRequest(string prmFunction, string prmValue) {
	string request = "";
	request = llJsonSetValue(request, ["function"], prmFunction);
	request = llJsonSetValue(request, ["value"], prmValue);
	llMessageLinked(LINK_THIS, 0, request, NULL_KEY);
}

integer roll(integer dice, integer sides) {
	integer result = 1;
	integer i;
	for (i = 0; i < dice; i++) {
		result += llCeil(llFrand(sides));
	}
	return result;
}

// ===== Contrib Functions =====
string ToTitle(string src) {
	list words = llParseString2List(llToLower(src), [], [".",";","?","!","\""," ","\n"]);
	integer ll = llGetListLength(words);
	integer lc = -1;
	string word = "";
	while((++lc) < ll)
	{
		string cap = llToUpper(llGetSubString((word = llList2String(words, lc)), 0, 0));
		words = llListReplaceList(words, [(cap + llDeleteSubString(word, 0, 0))], lc, lc);
	}
	return llDumpList2String(words, "");
}


// ===== Event Controls =====
execute_function(string prmFunction, string prmJson) {
	string value = llJsonGetValue(prmJson, ["value"]);
	if (JSON_INVALID == value) {
		//return;		// TODO: Rewrite all linked calls to send in JSON
	}

	if (prmFunction == "setGender") { setGender(value); }
	else if (prmFunction == "setStats") { setStats(value); }
	else if (prmFunction == "setRestraints") { setRestraints(value); }
	else if (prmFunction == "gui_escape") {
		key userkey = (key)llJsonGetValue(prmJson, ["userkey"]);
		integer screen = 0;
		if ((integer)llJsonGetValue(prmJson, ["restorescreen"]) && guiScreen) { screen = guiScreen;}
		init_gui(userkey, screen);
	} else if (prmFunction == "resetGUI") {
		exit("");
	}
}

default {
	state_entry() {
		configQueryID = llGetNotecardLine(".config", 0);	// Load config.
	}

	on_rez(integer prmStart) {
		configQueryID = llGetNotecardLine(".config", 0);	// Load config.
	}

	dataserver(key queryID, string configData) {
		if (queryID == configQueryID) {
			jsonSettings = configData;
		}
	}

	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel = guiChannel) {
			if (prmText == "<<Done>>") { exit("done"); return; }
			else if (prmText == " ") { gui(guiScreen); return; }
			else if (prmText == "<<Back>>"
				&& guiScreen != 0
				&& (integer)llJsonGetValue(jsonSettings, ["gagOnly"])
			) {
				guiRequest("gui_owner", FALSE, guiUserID, 0);
				return;
			}
			else if (guiScreen !=0 && prmText == "<<Back>>") { gui(guiScreenLast); return; }

			if (guiScreen == 0) {
					 if (prmText == "Free Arms") { get_gui("arm"); }
				else if (prmText == "Free Legs") { get_gui("leg"); }
				else if (prmText == "Free Gag") { get_gui("gag"); }
				else if (prmText == "<<Back>>") {
					guiRequest("gui_owner", TRUE, guiUserID, 0);
					return;
				}
			}
			else if (guiScreen == 10) {
				escape_action(prmText);
			} else if (guiScreen == 20) {
				escape_action(prmText);
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
			if (!is_bound()) {
				return;
			}
			init_gui(guiUserID, 0);
		}
	}

	timer() {
		exit("timeout");
	}
}
