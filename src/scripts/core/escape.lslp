$import Modules.GeneralTools.lslm();
$import Modules.RestraintTools.lslm();

/*
JSON structures

_escapeProgress: {
	"arm": {
		"integrity": {
			"progress",
			"maxProgress"
		}
		"tightness": {
			"progress",
			"maxProgress"
		}
	},
	...
}

_puzzles: {
 	"arm": {
		"integrity",
		"tightness"
	},
	...
}
 */

string _activePart;

// Avi Settings
string _gender = "female";
integer _maxStamina = 100;
list _ownerFeats = [];

// GUI variables
string _guiUser;

key guiUserID;
list guiButtons;
integer guiChannel;
integer guiID;
integer guiScreen;
integer guiScreenLast;
string guiText;
integer guiTimeout = 30;

string _actionmsg;

integer GUI_MAIN = 0;
integer GUI_ESCAPE = 10;
integer GUI_RESCUE = 20;

// Escape Vars
integer REST_TIMER = 60;
integer _distraction;
integer _stamina;
string _puzzles;
string _escapeProgress;

// Other
key configQueryID;
string jsonSettings;
string _resumeFunction;

init_gui(key prmID, integer prmScreen) {
	guiUserID = prmID;

	if (guiID) { llListenRemove(guiID); }
	guiChannel = (integer)llFrand(-9998) - 1;
	guiID = llListen(guiChannel, "", guiUserID, "");
	gui(prmScreen);
}

string getEscapeProgress() {
	if (_escapeProgress) { return _escapeProgress; }

	_stamina = _maxStamina;

	_escapeProgress = llJsonSetValue(_escapeProgress, ["arm", "complexity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["arm", "integrity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["arm", "tightness"], "0");

	_escapeProgress = llJsonSetValue(_escapeProgress, ["leg", "complexity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["leg", "integrity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["leg", "tightness"], "0");

	_escapeProgress = llJsonSetValue(_escapeProgress, ["gag", "complexity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["gag", "integrity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["gag", "tightness"], "0");

	return _escapeProgress;
}

// ===== Main Functions =====
integer isAssisted() { return guiUserID != llGetOwner(); }

string action2String(integer action, string puzzleType) {

	// Cause a distraction ...
	if (roll(_distraction, 5) >= 20) { return "???"; }

	if (puzzleType == "tightness") {
		if (action == 1) { return "Twist"; }
		else if (action == 2) { return "Struggle"; }
		else if (action == 3) { return "Thrash"; }
	} else if (puzzleType == "integrity") {
		if (action == 3) { return "Pick"; }
		else if (action == 2) { return "Tug"; }
		else if (action == 1) { return "Yank"; }
	}

	return "ERROR: UNKNOWN ACTION:" + (string)(action);
}

string getSuggestedAction() {
	getEscapeProgress();

	if (isAssisted()) {
		return "";
	}

	integer eidetic = llListFindList(_ownerFeats, ["Eidetic"]) > -1;
	integer intuitive = llListFindList(_ownerFeats, ["Intuitive"]) > -1;

	integer progress = (integer)llJsonGetValue(_escapeProgress, [_activePart, "tightness", "progress"]);
	integer tightness = (integer)llJsonGetValue(_restraints, ["security", _activePart, "tightness"]);
	integer maxProgress = (integer)llJsonGetValue(_escapeProgress, [_activePart, "tightness", "maxProgress"]);

	if ((progress >= tightness || ignoreTightness()) && !intuitive) {
		return "You think it is time to break free!";
	} else if (maxProgress > progress && eidetic && !ignoreTightness()) {
		return "You think you should try to " + action2String((integer)llJsonGetValue(_puzzles, [_activePart, "tightness", progress]), "tightness");
	} else if (intuitive) {
		string puzzleType = "tightness";
		if (progress >= tightness || ignoreTightness()) {
			puzzleType = "integrity";
		}

		integer action1 = (integer)llJsonGetValue(_puzzles, [_activePart, puzzleType, progress]);
		integer action2;
		do {
			action2 = roll(1,3);
		} while (action2 == action1);
		list actions = [action1, action2];
		actions = llListSort(actions, 1, TRUE);

		return "You think should " + action2String(llList2Integer(actions, 0), puzzleType) + " or " + action2String(llList2Integer(actions, 1), puzzleType) + ".";
	}
	return "You are not sure how to escape.";
}

escapeAction(string prmVerb) {
	string action;
	integer stamina;
	integer exertion;
	string puzzleType;

	getEscapeProgress();

	// TODO: Central definition?
	if (prmVerb == "Twist") { action = "1"; exertion = 3; puzzleType = "tightness"; }
	else if (prmVerb == "Struggle") { action = "2"; exertion = 4; puzzleType = "tightness"; }
	else if (prmVerb == "Thrash") {	action = "3"; exertion = 7; puzzleType = "tightness"; }

	else if (prmVerb == "Pick") { action = "3"; exertion = 2; puzzleType = "integrity";}
	else if (prmVerb == "Tug") { action = "2"; exertion = 5; puzzleType = "integrity";}
	else if (prmVerb == "Yank") { action = "1"; exertion = 5; puzzleType = "integrity";}

	integer maxProgress = (integer)llJsonGetValue(_escapeProgress, [_activePart, puzzleType, "maxProgress"]);
	integer progress = (integer)llJsonGetValue(_escapeProgress, [_activePart, puzzleType, "progress"]);
	integer tightness = (integer)llJsonGetValue(_restraints, ["security", _activePart, "tightness"]);

	if (!isAssisted() && isArmBound()) {
		_stamina = _stamina - exertion;
		if (_stamina < 0) {
			_stamina = 0;
		}
	}

	// Execute action
	debug("CORRECT ACTION: " + llJsonGetValue(_puzzles, [_activePart, puzzleType, progress]));
	integer success = (action == llJsonGetValue(_puzzles, [_activePart, puzzleType, progress]));
	if (success && puzzleType == "integrity" && !ignoreTightness()) {
		// Tightness failure
		integer tightnessProgress = (integer)llJsonGetValue(_escapeProgress, [_activePart, "tightness", "progress"]);
		if (llFrand(1.0) > ((float)(tightnessProgress-(tightness-tightnessProgress))/(float)tightness)) {
			success = FALSE;
		}

		// Escapability
		if (!(integer)llJsonGetValue(_restraints, ["security", _activePart, "canEscape"])) {
			success = FALSE;
		}
	}

	// Set escape progress
	if (prmVerb == "Thrash"
		&& (integer)llJsonGetValue(_restraints, ["security", _activePart, "canEscape"])
		&& checkThrash()
	) {
		_actionmsg = "You think you've made some unexpected progress.";
		puzzleType = "integrity";
		maxProgress = (integer)llJsonGetValue(_escapeProgress, [_activePart, puzzleType, "maxProgress"]);
		progress = (integer)llJsonGetValue(_escapeProgress, [_activePart, puzzleType, "progress"]);
		if (maxProgress < progress) {
			maxProgress = progress;
			_escapeProgress = llJsonSetValue(_escapeProgress, [_activePart, puzzleType, "maxProgress"], (string)maxProgress);
		}
	} else if (success) {
		_actionmsg = "You think you've made some progress.";
		progress++;
		if (maxProgress < progress) {
			maxProgress = progress;
			_escapeProgress = llJsonSetValue(_escapeProgress, [_activePart, puzzleType, "maxProgress"], (string)maxProgress);
		}
	} else {
		_actionmsg = "Your " + prmVerb + " didn't help.";
		if (!isAssisted() && progress > 0 && puzzleType == "tightness") {
			progress = loseProgress(progress);
		}
	}
	_escapeProgress = llJsonSetValue(_escapeProgress, [_activePart, puzzleType, "progress"], (string)progress);

	// Animate
	if (!isAssisted() && puzzleType == "tightness") {
		if (success) { simpleRequest("animate", "animation_" + _activePart + "_success"); }
		else { simpleRequest("animate", "animation_" + _activePart + "_failure"); }
	}

	// Adjust arousal
	if (!isAssisted() && !success && isSet(llJsonGetValue(_restraints, ["slots", "crotch"]))) {
		_distraction++;
	}

	// Check if anything should be escaped from
	if (success && puzzleType == "integrity") {
		// If being rescued by an unbound avi, every success reduces complexity
		if (ignoreIntegrity()) {
			_escapeProgress = llJsonSetValue(_escapeProgress, [_activePart, "integrity", "progress"], "9999");
		}

		if (checkIntegrity(_activePart)) {
			if (checkComplexity(_activePart)) {
				return;	// GUI will resume after getting restraints call
			}
		}
	}
	gui(guiScreen);
}

integer checkThrash() {
	integer dieSides = 100;
	if (llListFindList(_ownerFeats, ["Athletic+"]) > -1) {
		dieSides = 100;
	} else if (llListFindList(_ownerFeats, ["Athletic"]) > -1) {
		dieSides = 75;
	}

	return roll(1, dieSides) == dieSides;
}

integer checkIntegrity(string restraint) {
	getEscapeProgress();

	integer integrityProgress = (integer)llJsonGetValue(_escapeProgress, [restraint, "integrity", "progress"]);
	integer integrity = (integer)llJsonGetValue(_restraints, ["security", restraint, "integrity"]);

	if (integrityProgress >= integrity) {
		_actionmsg = "Your restraint suddenly feels looser!";
		if (!isAssisted()) {
			simpleRequest("addExp", llJsonGetValue(_restraints, ["security", restraint, "tightness"]));
		}

		// Reset puzzles
		refreshPuzzle(restraint, "tightness");
		refreshPuzzle(restraint, "integrity");

		// Update complexity.
		integer cProgress = (integer)llJsonGetValue(_escapeProgress, [restraint, "complexity", "progress"]) + 1;
		_escapeProgress = llJsonSetValue(_escapeProgress, [restraint, "complexity", "progress"], (string)cProgress);
		return TRUE;
	}

	return FALSE;
}

integer checkComplexity(string restraint) {
	getEscapeProgress();

	integer complexityProgress = (integer)llJsonGetValue(_escapeProgress, [restraint, "complexity", "progress"]);
	integer complexity = (integer)llJsonGetValue(_restraints, ["security", restraint, "complexity"]);

	if (complexityProgress >= complexity) {
		llWhisper(0, getOwnerName() + " is freed from " + getOwnerPronoun("her") + " " + restraint + " restraints.");
		simpleRequest("remRestraint", restraint);
		_resumeFunction = "setRestraints";
		return TRUE;
	}

	return FALSE;
}

list generatePuzzle(integer length) {
	list puzzle = [];
	integer index;
	for (index = 0; index < length; index++) {
		integer result = roll(1, 20);
		if (result <= 7) { puzzle += "1"; }			// 35%
		else if (result <= 16) { puzzle += "2"; }	// 45%
		else { puzzle += "3"; }						// 20%
	}

	return puzzle;
}

refreshPuzzle(string restraint, string puzzleType) {
	getEscapeProgress();

	list puzzle = generatePuzzle((integer)llJsonGetValue(_restraints, ["security", restraint, puzzleType]));
	_escapeProgress = llJsonSetValue(_escapeProgress, [restraint, puzzleType, "progress"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, [restraint, puzzleType, "maxProgress"], "0");
	_puzzles = llJsonSetValue(_puzzles, [restraint, puzzleType], llList2Json(JSON_ARRAY, puzzle));
}

string displaySecurity(string restraint) {
	integer index;

	integer tightness = (integer)llJsonGetValue(_restraints, ["security", restraint, "tightness"]);
	integer integrity = (integer)llJsonGetValue(_restraints, ["security", restraint, "integrity"]) - (integer)llJsonGetValue(_escapeProgress, [restraint, "integrity", "progress"]);
	integer complexity = (integer)llJsonGetValue(_restraints, ["security", restraint, "complexity"]) - (integer)llJsonGetValue(_escapeProgress, [restraint, "complexity", "progress"]);
	integer security = ((tightness + integrity) * complexity)/3;

	string output;
	string char = " ";

	if (security > 60) {
		char = "#";
		security -= 60;
		for (index = 0; index < security; index ++) { output += "!"; }
	} else if (security > 50) {
		char = "=";
		security -= 50;
		for (index = 0; index < security; index ++) { output += "#"; }
	} else if (security > 40) {
		char = "+";
		security -= 40;
		for (index = 0; index < security; index ++) { output += "="; }
	} else if (tightness > 30) {
		char = ":";
		security -= 30;
		for (index = 0; index < security; index ++) { output += "+"; }
	} else if (tightness > 20) {
		char = "-";
		security -= 20;
		for (index = 0; index < security; index ++) { output += ":"; }
	} else if (tightness > 10) {
		char = ".";
		security -= 10;
		for (index = 0; index < security; index ++) { output += "-"; }
	} else {
		char = " ";
		for (index = 0; index < security; index ++) { output += "."; }
	}

	while (index < 10) {
		output += char;
		index++;
	}
	return "[" + output + "]";
}

integer ignoreIntegrity() {
	return (isAssisted() && !(integer)llJsonGetValue(_guiUser, ["armBound"])) && !isSet(llJsonGetValue(_guiUser, ["handBound"]))
		|| (!isAssisted() && !isArmBound())
		|| isSet(llJsonGetValue(_guiUser, ["blade"]))
	;
}

integer ignoreTightness() {
	return isAssisted() || !isArmBound();
}

integer loseProgress(integer progress) {
	if (llListFindList(_ownerFeats, ["Flexible+"]) > -1) {
		return progress;
	} else if (llListFindList(_ownerFeats, ["Flexible"]) > -1) {
		progress--;
	} else {
		progress = progress - 2;
	}


	if (progress < 0) {
		return 0;
	}

	return progress;
}

// ===== GUI =====
getGui(string prmPart) {
	string tmpType;
	_activePart = prmPart;
	_actionmsg = "";

	if (guiUserID == llGetOwner()) {
		gui(GUI_ESCAPE);
		return;
	} else {
		gui(GUI_RESCUE);
		return;
	}
}

gui(integer prmScreen) {
	getEscapeProgress();

	if (_stamina <= 0) {
		llOwnerSay("You are too tired to struggle anymore.");
		_escapeProgress = llJsonSetValue(_escapeProgress, [_activePart, "tightness", "progress"], "0");
		exit("Exhausted");
		return;
	}

	// Reset Busy Clock
	llSetTimerEvent(REST_TIMER);

	string btn10 = " ";	string btn11 = " ";			string btn12 = " ";
	string btn7 = " ";	string btn8 = " ";			string btn9 = " ";
	string btn4 = " ";	string btn5 = " ";			string btn6 = " ";
	string btn1 = " ";	string btn2 = "<<Done>>";	string btn3 = " ";

	guiText = " ";

	if (prmScreen == 0 && ((integer)llJsonGetValue(jsonSettings, ["gagOnly"]))) {
		getGui("gag");
		return;
	}

	if (prmScreen != guiScreen) { guiScreenLast = guiScreen; }
	if (btn1 == " " && (prmScreen != 0)) { btn1 = "<<Back>>"; };

	if (prmScreen == GUI_MAIN) {
		if (guiUserID == llGetOwner()) { btn1 = "<<Back>>"; }

		// reset previous screen
		guiScreenLast = 0;

		if ((integer)llJsonGetValue(_restraints, ["security", "arm", "tightness"]) > 0) { btn4 = "Free Arms"; }
		if ((integer)llJsonGetValue(_restraints, ["security", "leg", "tightness"]) > 0) { btn5 = "Free Legs"; }
		if ((integer)llJsonGetValue(_restraints, ["security", "gag", "tightness"]) > 0) { btn6 = "Free Gag"; }
		if (isSet(llJsonGetValue(_restraints, ["slots", "hand"]))) { btn7 = "Free Hands"; }
		if (isSet(llJsonGetValue(_restraints, ["slots", "crotch"]))) { btn8 = "Free Crotch"; }

		// TODO: Get quick release options
	} else if (prmScreen == GUI_ESCAPE) {
		btn4 = "Twist";
		btn5 = "Struggle";
		btn6 = "Thrash";
		if (!isSet(llJsonGetValue(_restraints, ["slots", "hand"]))) { btn7 = "Pick"; }
		btn8 = "Tug";
		btn9 = "Yank";

		guiText = "Restraint: " + ToTitle(_activePart);	// TODO: Get full name of restraint
		guiText += "\nSecurity: " + displaySecurity(_activePart);
		if (_actionmsg) { guiText += "\n" + _actionmsg; }
		guiText += "\n" + getSuggestedAction();
	} else if (prmScreen == GUI_RESCUE) {
		if (!isSet(llJsonGetValue(_guiUser, ["handBound"]))) { btn4 = "Pick"; }
		btn5 = "Tug";
		btn6 = "Yank";

		guiText = "Restraint: " + ToTitle(_activePart);	// TODO: Get full name of restraint
		guiText += "\nTightness: " + displaySecurity(_activePart);
		// TODO: Suggested action for feats?
		if (_actionmsg) { guiText += "\n" + _actionmsg; }

		if (guiUserID != llGetOwner() && (integer)llJsonGetValue(jsonSettings, ["gagOnly"])) {
			btn1 = " ";
		}
	}

	guiScreen = prmScreen;
	guiButtons = [btn1, btn2, btn3];

	if (btn4+btn5+btn6 != "   ") { guiButtons += [btn4, btn5, btn6]; }
	if (btn7+btn8+btn9 != "   ") { guiButtons += [btn7, btn8, btn9]; }
	if (btn10+btn11+btn12 != "   ") { guiButtons += [btn10, btn11, btn12]; }
	llDialog(guiUserID, guiText, guiButtons, guiChannel);
}

exit(string prmReason) {
	llListenRemove(guiID);
	//llSetTimerEvent(0.0);

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

// ===== Sets =====
setRestraints(string prmInfo) {
	_restraints = prmInfo;
	getEscapeProgress();

	// TODO: Only reset progress on restraint level change?
	_escapeProgress = llJsonSetValue(_escapeProgress, ["escape", "arm", "complexity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["escape", "arm", "integrity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["escape", "arm", "tightness"], "0");

	_escapeProgress = llJsonSetValue(_escapeProgress, ["escape", "leg", "complexity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["escape", "leg", "integrity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["escape", "leg", "tightness"], "0");

	_escapeProgress = llJsonSetValue(_escapeProgress, ["escape", "gag", "complexity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["escape", "gag", "integrity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["escape", "gag", "tightness"], "0");

	_escapeProgress = llJsonSetValue(_escapeProgress, ["escape", "crotch", "complexity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["escape", "crotch", "integrity"], "0");
	_escapeProgress = llJsonSetValue(_escapeProgress, ["escape", "crotch", "tightness"], "0");

	_armBoundExternal = FALSE;
	refreshPuzzle("arm", "integrity");
	refreshPuzzle("arm", "tightness");

	refreshPuzzle("leg", "integrity");
	refreshPuzzle("leg", "tightness");

	refreshPuzzle("gag", "integrity");
	refreshPuzzle("gag", "tightness");

	refreshPuzzle("crotch", "integrity");
	refreshPuzzle("crotch", "tightness");
}

setGender(string prmGender) {
	_gender = prmGender;
}

setOwnerFeats(string feats) {
	_ownerFeats = llJson2List(feats);

	// Set maxStamina based on feats
	if (llListFindList(_ownerFeats, ["Endurant+"]) > -1) {
		_maxStamina = 150;
	} else if (llListFindList(_ownerFeats, ["Endurant"]) > -1) {
		_maxStamina = 125;
	} else {
		_maxStamina = 100;
	}
}

// ===== Other Functions =====
guiRequest(string prmGUI, integer prmRestore, key prmUserID, integer prmScreen) {
	string guiRequest = "";
	guiRequest = llJsonSetValue(guiRequest, ["function"], prmGUI);
	guiRequest = llJsonSetValue(guiRequest, ["restorescreen"], (string)prmRestore);
	guiRequest = llJsonSetValue(guiRequest, ["userkey"], (string)prmUserID);
	guiRequest = llJsonSetValue(guiRequest, ["value"], (string)prmScreen);
	llMessageLinked(LINK_THIS, 0, guiRequest, NULL_KEY);
	exit("");
}

integer roll(integer dice, integer sides) {
	integer result = 0;
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
	else if (prmFunction == "setOwnerFeats") { setOwnerFeats(value); }
	else if (prmFunction == "setRestraints") { setRestraints(value); }
	else if (prmFunction == "setToucher") { _guiUser = value; }
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
			else if (guiScreen != GUI_MAIN && prmText == "<<Back>>") { gui(guiScreenLast); return; }

			if (guiScreen == GUI_MAIN) {
					 if (prmText == "Free Arms") { getGui("arm"); }
				else if (prmText == "Free Legs") { getGui("leg"); }
				else if (prmText == "Free Gag") { getGui("gag"); }
				else if (prmText == "Free Hands") { getGui("hand"); }
				else if (prmText == "Free Crotch") { getGui("crotch"); }
				else if (prmText == "<<Back>>") {
					guiRequest("gui_owner", TRUE, guiUserID, 0);
					return;
				}
			}
			else if (guiScreen == 10) {
				escapeAction(prmText);
			} else if (guiScreen == 20) {
				escapeAction(prmText);
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
			if (!isBound()) {
				return;
			}
			init_gui(guiUserID, 0);
		}
	}

	timer() {
		if (!isBound()) {
			// Oops, shouldn't be here.  Just clean up
			llSetTimerEvent(0.0);
			return;
		}

		// Decrease arousal
		if (_distraction > 0) {
			_distraction -= 20/4;

			if (_distraction <= 0) {
				_distraction = 0;
				llOwnerSay("You are feeling less distracted.");
			}
		}

		if (_stamina == _maxStamina) {
			return;
		}

		// Reset struggle progress (if resting, assumed stop)
		_escapeProgress = llJsonSetValue(_escapeProgress, ["arm", "tightness", "progress"], "0");
		_escapeProgress = llJsonSetValue(_escapeProgress, ["leg", "tightness", "progress"], "0");
		_escapeProgress = llJsonSetValue(_escapeProgress, ["gag", "tightness", "progress"], "0");
		_escapeProgress = llJsonSetValue(_escapeProgress, ["crotch", "tightness", "progress"], "0");

		// Refresh stamina
		integer denominator = 4;
		if (llListFindList(_ownerFeats, ["Resolute+"]) > -1) {
			denominator = 1;
		} else if (llListFindList(_ownerFeats, ["Resolute"]) > -1) {
			denominator = 2;
		}

		_stamina += _maxStamina/denominator;
		if (_stamina >= _maxStamina) {
			_stamina = _maxStamina;
			llOwnerSay("You are feeling fully rested.");
		}

	}
}
