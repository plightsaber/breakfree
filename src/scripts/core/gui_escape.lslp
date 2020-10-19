$import Modules.ContribLib.lslm();
$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.RestraintTools.lslm();
$import Modules.UserLib.lslm();

string  CONFIG;

integer GUI_HOME = 0;
integer GUI_ESCAPE = 100;
integer GUI_RESCUE = 101;

key     _configQueryID;

integer _lockable = TRUE;

integer _distraction;
integer _stamina;
integer _maxStamina = 100;

string  _activePart;
string  _escapeProgress;
string  _owner;
string  _guiUser;
string  _puzzles;
string  _security;

string  _actionMsg;
string  _resumeFunction;

// ===== Initializers =====
init()
{
	_configQueryID = llGetNotecardLine(".config", 0);
	_stamina = _maxStamina;
}

init_gui(key userKey, integer screen)
{
	_actionMsg = "";
	guiUserID = userKey;
	if (guiID) { llListenRemove(guiID); }

	guiChannel = (integer)llFrand(-9998) - 1;
	guiID = llListen(guiChannel, "", guiUserID, "");
	gui(screen);
}

// ===== GUI =====
gui(integer prmScreen)
{
	// Exit menu if exhausted
	if (_stamina <= 0) {
		llOwnerSay("You are too tired to struggle anymore.");
		exit("Exhausted");
		return;
	}

	simpleRequest("resetGuiTimer", "1");

	// Stop or slow recovery timer while deciding on struggle.
	if (llGetOwner() == guiUserID) {
		if (hasFeat(_guiUser, "Steadfast")) {
			simpleRequest("startRecoveryTimer", "Steadfast");
		} else {
			simpleRequest("stopRecoveryTimer", "0");
		}
	}

	string btn10 = " ";	string btn11 = " ";			string btn12 = " ";
	string btn7 = " ";	string btn8 = " ";			string btn9 = " ";
	string btn4 = " ";	string btn5 = " ";			string btn6 = " ";
	string btn1 = " ";	string btn2 = "<<Done>>";	string btn3 = " ";

	guiText = " ";

	if (prmScreen == 0 && ((integer)llJsonGetValue(CONFIG, ["gagOnly"]))) {
		if (!isSet(llJsonGetValue(_restraints, ["gagged"]))) {
			return;
		}

		getGui("gag");
		return;
	}

	if (prmScreen != guiScreen) { guiScreenLast = guiScreen; }
	if (btn1 == " " && (prmScreen != 0)) { btn1 = "<<Back>>"; };

	if (prmScreen == GUI_HOME) {
		if (guiUserID == llGetOwner()) { btn1 = "<<Back>>"; }

		// Reset previous screen
		guiScreenLast = 0;

		if (isSet(llJsonGetValue(_security, ["arm", "tightness"]))) { btn4 = "Free Arms"; }
		if (isSet(llJsonGetValue(_security, ["leg", "tightness"]))) { btn5 = "Free Legs"; }
		if (isSet(llJsonGetValue(_security, ["gag", "tightness"]))) { btn6 = "Free Gag"; }
		if (isSet(llJsonGetValue(_restraints, ["slots", "hand"]))) { btn7 = "Free Hands"; }
		if (isSet(llJsonGetValue(_restraints, ["slots", "crotch"]))) { btn8 = "Free Crotch"; }

	} else if (prmScreen == GUI_ESCAPE) {
		btn4 = "Twist";
		btn5 = "Struggle";
		btn6 = "Thrash";

		if (!isSet(llJsonGetValue(_restraints, ["slots", "hand"]))) { btn7 = "Pick"; }
		btn8 = "Tug";
		btn9 = "Yank";

		// Lockpick Verb overrides
		if (isPicking() && !isSet(llJsonGetValue(_restraints, ["slots", "hand"]))) {
			btn7 = "Poke";
			btn8 = "Sweep";
			btn9 = "Turn";
		}

		// Blade / Cropper Verb overrides
		if (isCutting() && !isSet(llJsonGetValue(_restraints, ["slots", "hand"]))) {
			btn7 = "Slice";
			btn8 = "Dice";
			btn9 = "Rend";
		}

		guiText = "Restraint: " + ToTitle(_activePart);	// TODO: Get full name of restraint
		guiText += "\nSecurity: " + displaySecurity(_activePart);
		if (_actionMsg) { guiText += "\n" + _actionMsg; }
		guiText += "\n" + getSuggestedAction();
	} else if (prmScreen == GUI_RESCUE) {
		if (!isSet(llJsonGetValue(_guiUser, ["handBound"]))) { btn4 = "Pick"; }
		btn5 = "Tug";
		btn6 = "Yank";

		// Lockpick Verb overrides
		if (isPicking() && !isSet(llJsonGetValue(_restraints, ["slots", "hand"]))) {
			btn4 = "Poke";
			btn5 = "Sweep";
			btn6 = "Turn";
		}

		// Blade / Cropper Verb overrides
		if (isCutting() && !isSet(llJsonGetValue(_restraints, ["slots", "hand"]))) {
			btn7 = "Slice";
			btn8 = "Dice";
			btn9 = "Rend";
		}

		guiText = "Restraint: " + ToTitle(_activePart);	// TODO: Get full name of restraint
		guiText += "\nSecurity: " + displaySecurity(_activePart);
		guiText += "\n" + getSuggestedAction();
		// TODO: Suggested action for feats?
		if (_actionMsg) { guiText += "\n" + _actionMsg; }

		if (guiUserID != llGetOwner() && (integer)llJsonGetValue(CONFIG, ["gagOnly"])) {
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

string displaySecurity(string restraint)
{
	integer index;

	integer tightness = (integer)llJsonGetValue(_security, [restraint, "tightness"]);
	integer integrity = (integer)llJsonGetValue(_security, [restraint, "integrity"]) - (integer)llJsonGetValue(_escapeProgress, ["integrity", "progress"]);
	integer complexity = (integer)llJsonGetValue(_security, [restraint, "complexity"]) - (integer)llJsonGetValue(_escapeProgress, ["complexity", "progress"]);
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

string getSuggestedAction()
{
	integer eidetic = hasFeat(_guiUser, "Eidetic");
	integer intuitive = hasFeat(_guiUser, "Intuitive");

	// Check tightness vs integrity suggestion
	string puzzleType = "tightness";
	integer progress = (integer)llJsonGetValue(_escapeProgress, ["tightness", "progress"]);
	integer tightness = (integer)llJsonGetValue(_security, [_activePart, "tightness"]);
	integer maxProgress = (integer)llJsonGetValue(_escapeProgress, ["tightness", "maxProgress"]);

	if (ignoreTightness() || progress >= tightness) {
		puzzleType = "integrity";
		progress = (integer)llJsonGetValue(_escapeProgress, ["integrity", "progress"]);
		tightness = (integer)llJsonGetValue(_security, [_activePart, "integrity"]);
		maxProgress = (integer)llJsonGetValue(_escapeProgress, ["integrity", "maxProgress"]);
	}

	if ("integrity" == puzzleType && !intuitive && !isPicking()) {
		return "You think it is time to break free!";
	} else if (isPicking() && "integrity" == puzzleType && !intuitive) {
		return "You think it is time to pick the lock!";
	} else if (maxProgress > progress && eidetic) {
		return "You think you should try to " + action2String((integer)llJsonGetValue(_puzzles, [puzzleType, progress]), puzzleType);
	} else if (intuitive) {
		integer action1 = (integer)llJsonGetValue(_puzzles, [puzzleType, progress]);
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

// ===== Methods =====
string action2String(integer action, string puzzleType)
{

	// Cause a distraction ...
	if (roll(_distraction, 5) >= 20) { return "???"; }

	if (puzzleType == "tightness") {
		if (action == 1) { return "Twist"; }
		else if (action == 2) { return "Struggle"; }
		else if (action == 3) { return "Thrash"; }
	} else if (puzzleType == "integrity") {
		if (isPicking()) {
			if (action == 1) { return "Poke"; }
			else if (action == 2) { return "Sweep"; }
			else if (action == 3) { return "Turn"; }
		}

		if (isCutting()) {
			if (action == 1) { return "Slice"; }
			else if (action == 2) { return "Dice"; }
			else if (action == 3) { return "Rend"; }
		}

		if (action == 3) { return "Pick"; }
		else if (action == 2) { return "Tug"; }
		else if (action == 1) { return "Yank"; }
	}

	return "ERROR: UNKNOWN ACTION:" + (string)(action);
}

integer canEscape()
{
	return !_lockable
		|| isSet(llJsonGetValue(_security, [_activePart, "canEscape"]))
		|| (isPicking() && isSet(llJsonGetValue(_security, [_activePart, "canPick"])));
}

integer checkComplexity()
{
	integer complexityProgress = (integer)llJsonGetValue(_escapeProgress, ["complexity", "progress"]);
	integer complexity = (integer)llJsonGetValue(_security, [_activePart, "complexity"]);

	if (complexityProgress >= complexity) {
		_escapeProgress = JSON_NULL;
		_puzzles = JSON_NULL;

		llWhisper(0, getOwnerName() + " is freed from " + getOwnerPronoun("her") + " " + _activePart + " restraints.");
		simpleRequest("remRestraint", _activePart);
		guiScreen = GUI_HOME;	// Exit the current screen when restraint level is removed
		_resumeFunction = "setSecurity";
		return TRUE;
	}

	return FALSE;
}

integer checkIntegrity()
{
	integer integrityProgress = (integer)llJsonGetValue(_escapeProgress, ["integrity", "progress"]);
	integer integrity = (integer)llJsonGetValue(_security, [_activePart, "integrity"]);
	integer tightness = (integer)llJsonGetValue(_security, [_activePart, "tightness"]);

	if (integrityProgress >= integrity) {
		_actionMsg = "Your restraint suddenly feels looser!";
		float adjustment = 1;
		if (ignoreTightness() && ignoreIntegrity()) {
			adjustment = 0.3;
		} else if (ignoreTightness() || ignoreIntegrity()) {
			adjustment = 0.75;
		}
		integer expEarned = (integer)(tightness*adjustment);

		if (isAssisted()) {
			apiRequest(llJsonGetValue(_guiUser, ["key"]), llGetOwner(), "addExp", (string)expEarned);
		} else {
			// Earn experience in escapology!
			simpleRequest("addExp", (string)expEarned);
		}

		// Reset puzzles
		refreshPuzzle("tightness");
		refreshPuzzle("integrity");

		// Update complexity.
		integer cProgress = (integer)llJsonGetValue(_escapeProgress, ["complexity", "progress"]) + 1;
		updateProgress("complexity", cProgress);
		return TRUE;
	}

	return FALSE;
}

integer checkThrash()
{
	integer dieSides = 100;
	if (hasFeat(_owner, "Athletic+")) {
		dieSides = 100;
	} else if (hasFeat(_owner, "Athletic")) {
		dieSides = 75;
	}

	return roll(1, dieSides) == dieSides;
}

escapeAction(string prmVerb)
{
	string  action;
	integer stamina;
	integer exertion;
	string  puzzleType;

	integer isCutting = 0;
	integer isPicking = 0;

	// TODO: Central definition?
	if (prmVerb == "Twist") { action = "1"; exertion = 3; puzzleType = "tightness"; }
	else if (prmVerb == "Struggle") { action = "2"; exertion = 4; puzzleType = "tightness"; }
	else if (prmVerb == "Thrash") {	action = "3"; exertion = 7; puzzleType = "tightness"; }

	else if (prmVerb == "Pick") { action = "3"; exertion = 2; puzzleType = "integrity";}
	else if (prmVerb == "Tug") { action = "2"; exertion = 5; puzzleType = "integrity";}
	else if (prmVerb == "Yank") { action = "1"; exertion = 5; puzzleType = "integrity";}

	else if ("Poke" == prmVerb) { action = "1"; exertion = 2; puzzleType = "integrity"; isPicking = TRUE;}
	else if ("Sweep" == prmVerb) { action = "2"; exertion = 2; puzzleType = "integrity"; isPicking = TRUE;}
	else if ("Turn" == prmVerb) { action = "3"; exertion = 2; puzzleType = "integrity"; isPicking = TRUE;}

	else if ("Slice" == prmVerb) { action = "1"; exertion = 2; puzzleType = "integrity"; isCutting = TRUE;}
	else if ("Dice" == prmVerb) { action = "2"; exertion = 2; puzzleType = "integrity"; isCutting = TRUE;}
	else if ("Rend" == prmVerb) { action = "3"; exertion = 2; puzzleType = "integrity"; isCutting = TRUE;}

	integer maxProgress = (integer)llJsonGetValue(_escapeProgress, [puzzleType, "maxProgress"]);
	integer progress = (integer)llJsonGetValue(_escapeProgress, [puzzleType, "progress"]);
	integer tightness = (integer)llJsonGetValue(_security, [_activePart, "tightness"]);

	if (!isAssisted() && isArmBound()) {
		stamina = _stamina - exertion;
		updateStamina(stamina);
	}

	// Execute action
	//debug("CORRECT ACTION: " + llJsonGetValue(_puzzles, [puzzleType, progress]));
	integer success = (action == llJsonGetValue(_puzzles, [puzzleType, progress]));
	if (success && puzzleType == "integrity" && !ignoreTightness()) {
		// Tightness failure
		integer tightnessProgress = (integer)llJsonGetValue(_escapeProgress, ["tightness", "progress"]);
		if (llFrand(1.0) > ((float)(tightnessProgress-(tightness-tightnessProgress))/(float)tightness)) {
			success = FALSE;
		}

		// Escapability
		if (!canEscape() && !isPicking && !isCutting) {
			success = FALSE;
		}
	}

	// Set escape progress
	if (prmVerb == "Thrash"
		&& canEscape()
		&& checkThrash()
	) {
		_actionMsg = "You think you've made some unexpected progress.";
		puzzleType = "integrity";
		maxProgress = (integer)llJsonGetValue(_escapeProgress, [puzzleType, "maxProgress"]);
		progress = (integer)llJsonGetValue(_escapeProgress, [puzzleType, "progress"]);
		if (maxProgress < progress) {
			maxProgress = progress;
			_escapeProgress = llJsonSetValue(_escapeProgress, [puzzleType, "maxProgress"], (string)maxProgress);
		}
	} else if (success) {
		_actionMsg = "You think you've made some progress.";
		progress++;
		if (maxProgress < progress) {
			maxProgress = progress;
			_escapeProgress = llJsonSetValue(_escapeProgress, [puzzleType, "maxProgress"], (string)maxProgress);
		}
	} else {
		_actionMsg = "Your " + prmVerb + " didn't help.";
		if (!isAssisted() && progress > 0 && puzzleType == "tightness") {
			progress = loseProgress(progress);
		}

		if ("integrity" == puzzleType && isPicking) {
			progress = 0;
		}
	}
	updateProgress(puzzleType, progress);

	// Animate
	if (!isAssisted() && puzzleType == "tightness") {
		if (success) { simpleRequest("animate", "animation_" + _activePart + "_success"); }
		else { simpleRequest("animate", "animation_" + _activePart + "_failure"); }
	}

	// Adjust distraction
	if (!isAssisted() && !success && isSet(llJsonGetValue(_restraints, ["slots", "crotch"]))) {
		updateDistraction(_distraction + 1);
	}

	// Check if anything should be escaped from
	if (success && puzzleType == "integrity") {
		// If being rescued by an unbound avi, every success reduces complexity
		if (ignoreIntegrity()) {
			_escapeProgress = llJsonSetValue(_escapeProgress, ["integrity", "progress"], "9999");
		}

		if (checkIntegrity()) {
			if (checkComplexity()) {
				return;	// GUI will resume after getting restraints call
			}
		}
	}
	gui(guiScreen);
}

getGui(string part)
{
	string tmpType;
	_activePart = part;
	_actionMsg = "";

	guiScreen = GUI_RESCUE;
	if (guiUserID == llGetOwner()) {
		guiScreen = GUI_ESCAPE;
	}

	_resumeFunction = "setActiveEscapeData";
	simpleRequest("getEscapeData", _activePart);
}

string getOwnerName() {
	return llGetDisplayName(llGetOwner());
}

string getOwnerPronoun(string prmPlaceholder) {
	string gender = llJsonGetValue(_owner, ["gender"]);
	if (gender == "female") { return prmPlaceholder; }
	else {
		if ("her" == prmPlaceholder) { return "his"; }
	}

	return "";
}

integer ignoreIntegrity()
{
	return (isAssisted() && !(integer)llJsonGetValue(_guiUser, ["armBound"])) && !isSet(llJsonGetValue(_guiUser, ["handBound"]))
		|| (!isAssisted() && !isArmBound())
		|| (isSet(llJsonGetValue(_guiUser, ["blade"])) && isSet(llJsonGetValue(_security, [_activePart, "canCut"])))
		|| (isSet(llJsonGetValue(_guiUser, ["cropper"])) && isSet(llJsonGetValue(_security, [_activePart, "canCrop"])))
	;
}

integer ignoreTightness()
{
	return isAssisted() || !isArmBound();
}

integer isAssisted()
{
	return guiUserID != llGetOwner();
}

integer isCutting()
{
	if (isSet(llJsonGetValue(_security, [_activePart, "canCut"])) && isSet(llJsonGetValue(_guiUser, ["blade"]))) {
		return TRUE;
	}

	if (isSet(llJsonGetValue(_security, [_activePart, "canCrop"])) && isSet(llJsonGetValue(_guiUser, ["cropper"]))) {
		return TRUE;
	}
	return FALSE;
}

integer isPicking()
{
	return isSet(llJsonGetValue(_security, [_activePart, "canPick"]))
		&& isSet(llJsonGetValue(_guiUser, ["pick"]));
}

integer loseProgress(integer progress) {
	if (hasFeat(_owner, "Flexible+")) {
		return progress;
	} else if (hasFeat(_owner, "Flexible")) {
		progress--;
	} else {
		progress = progress - 2;
	}


	if (progress < 0) {
		return 0;
	}

	return progress;
}

setActiveEscapeData(string json)
{
	_puzzles = llJsonGetValue(json, ["puzzles"]);
	_escapeProgress = llJsonGetValue(json, ["progress"]);

	if (!isSet(_puzzles) || !isSet(_escapeProgress)) {
		refreshPuzzle("tightness");
		refreshPuzzle("integrity");
		refreshPuzzle("complexity");
	}
}

setOwner(string user)
{
	_owner = user;
	_maxStamina = 100;

	if (hasFeat(_owner, "Endurant+")) { _maxStamina = 150; }
	else if (hasFeat(_owner, "Endurant")) { _maxStamina = 125; }
}

setRestraints(string restraints)
{
	_restraints = restraints;
}

setSecurity(string security)
{
	_security = security;
}

updateDistraction(integer distraction)
{
	_distraction = distraction;
	if (_distraction > 20) {
		_distraction = 20;
	}
	simpleRequest("setEscapeDistraction", (string)_distraction);
}

updateProgress(string type, integer progress)
{
	_escapeProgress = llJsonSetValue(_escapeProgress, [type, "progress"], (string)progress);

	string request;
	request = llJsonSetValue(request, ["restraint"], _activePart);
	request = llJsonSetValue(request, ["progress"], _escapeProgress);
	simpleRequest("setProgress", request);
}

updateStamina(integer stamina)
{
	_stamina = stamina;
	if (_stamina < 0) {
		_stamina = 0;
	}
	simpleRequest("setEscapeStamina", (string)_stamina);
}

// ===== Puzzle Methods =====
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

refreshPuzzle(string puzzleType) {
	string restraint = _activePart;

	_escapeProgress = llJsonSetValue(_escapeProgress, [puzzleType, "maxProgress"], "0");
	updateProgress(puzzleType, 0);

	string securityLevel = llJsonGetValue(_security, [restraint, puzzleType]);
	if (!isSet(securityLevel)) {
		_puzzles = llJsonSetValue(_puzzles, [puzzleType], JSON_NULL);
		return;
	}

	list puzzle = generatePuzzle((integer)securityLevel);
	_puzzles = llJsonSetValue(_puzzles, [puzzleType], llList2Json(JSON_ARRAY, puzzle));

	string request;
	request = llJsonSetValue(request, ["restraint"], _activePart);
	request = llJsonSetValue(request, ["puzzles"], _puzzles);
	simpleRequest("setPuzzles", request);
}

// ===== Events =====
executeFunction(string function, string json)
{
	string value = llJsonGetValue(json, ["value"]);

	if (function == "setOwner") { setOwner(value); }
	else if (function  == "setActiveEscapeData") {
		setActiveEscapeData(value);
		return;
	}
	else if (function == "setEscapeDistraction") { _distraction = (integer)value; }
	else if (function == "setEscapeStamina") { _stamina = (integer)value; }
	else if (function == "setLockable") { _lockable = (integer)value; }
	else if (function == "setRestraints") { setRestraints(value); }
	else if (function == "setSecurity") { setSecurity(value); }
	else if (function == "setToucher") { _guiUser = value; }
	else if (function == "gui_escape") {
		integer screen = 0;
		key     userkey = (key)llJsonGetValue(json, ["userkey"]);

		if ((integer)llJsonGetValue(json, ["restorescreen"]) && guiScreen) { screen = guiScreen;}
		init_gui(userkey, screen);
	} else if (function == "resetGUI") {
		exit("");
	}
}

default
{
  	state_entry()
  	{
  		init();
  	}

  	dataserver(key queryID, string configData)
  	{
		if (queryID == _configQueryID) {
			CONFIG = configData;
		}
	}

	link_message(integer sender_num, integer num, string str, key id)
	{
		string function;
		string value;

		if ((function = llJsonGetValue(str, ["function"])) == JSON_INVALID) {
			debug(str);
			return;
		}
		executeFunction(function, str);

		if (function == _resumeFunction) {
			_resumeFunction = "";
			init_gui(guiUserID, guiScreen);
		}
	}

	listen(integer channel, string name, key id, string message)
	{
		if (channel != guiChannel) { return; }

		if (message == "<<Done>>") { exit("done"); return; }
		else if (message == " ") { gui(guiScreen); return; }
		else if (message == "<<Back>>"
			&& guiScreen != 0
			&& (integer)llJsonGetValue(CONFIG, ["gagOnly"])
		) {
			guiRequest("gui_owner", FALSE, guiUserID, 0);
			return;
		}
		else if (guiScreen != GUI_HOME && message == "<<Back>>") { gui(guiScreenLast); return; }

		if (guiScreen == GUI_HOME) {
				 if (message == "Free Arms") { getGui("arm"); return; }
			else if (message == "Free Legs") { getGui("leg"); return; }
			else if (message == "Free Gag") { getGui("gag"); return; }
			else if (message == "Free Hands") { getGui("hand"); return; }
			else if (message == "Free Crotch") { getGui("crotch"); return; }
			else if (message == "<<Back>>") {
				guiRequest("gui_owner", TRUE, guiUserID, 0);
				return;
			}
		}
		else if (guiScreen == GUI_ESCAPE) {
			escapeAction(message);
			return;
		} else if (guiScreen == GUI_RESCUE) {
			escapeAction(message);
			return;
		}
	}

	timer()
	{
		exit("timeout");
	}
}
