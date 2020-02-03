$import Modules.GuiTools.lslm();

// Quick Keys
key _ownerID;
key _villainID;

// Settings
integer rpMode = FALSE;
integer _RLV = FALSE;

// Stats
integer userExp = 0;
integer userStr = 1;
integer userDex = 1;
integer userInt = 1;
integer userLevel = 1;
list userSkills = [];

// Status Variables
string self;
integer _isArmsBound = FALSE;
integer _isLegsBound = FALSE;
integer _isGagged = FALSE;

// GUI screens
integer GUI_HOME = 0;
integer GUI_STATS = 10;
integer GUI_OPTIONS = 20;

string _resumeFunction;

init() {
	_ownerID = llGetOwner();
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
	llSetTimerEvent(guiTimeout);

	string btn10 = " ";	string btn11 = " ";			string btn12 = " ";
	string btn7 = " ";	string btn8 = " ";			string btn9 = " ";
	string btn4 = " ";	string btn5 = " ";			string btn6 = " ";
	string btn1 = " ";	string btn2 = "<<Done>>";	string btn3 = " ";
		
	guiText = " ";
		
	// GUI: Main
	if (prmScreen == GUI_HOME) {
		if (rpMode || (!_isArmsBound && !_isLegsBound && !_isGagged) || _villainID == _ownerID) {
			btn1 = "Options";
			btn4 = "Bind";
		}

		if (_isArmsBound || _isLegsBound || _isGagged) { btn5 = "Escape"; }
		btn3 = "Stats";
	}
	// GUI: Stats 
	else if (prmScreen == GUI_STATS) {
		guiText = "Level: " + (string)getUserLevel() + "\n";
		guiText += "Experience: " + (string)userExp + "/" + (string)getNextLevelExp() + "\n";
		guiText += "STR: " + (string)userStr + "\tDEX: " + (string)userDex + "\tINT: " + (string)userInt;

		if (canLevelUp()) {
			btn4 = "STR ↑";
			btn5 = "DEX ↑";
			btn6 = "INT ↑";
		}

		btn1 = "<<Back>>";
	}
	else if (prmScreen == GUI_OPTIONS) {
		guiText = "User Settings" + "\n";
		guiText = "Please reference the included README for details.";
		if (rpMode) { btn4 = "☑ RP Mode"; }
		else { btn4 = "☒ RP Mode"; }
		if (_RLV) { btn5 = "☑ RLV"; }
		else { btn5 = "☒ RLV"; }
		btn1 = "<<Back>>";
	}

	if (prmScreen != guiScreen) { guiScreenLast = guiScreen; }		
	guiScreen = prmScreen;

	guiButtons = [btn1, btn2, btn3];
	if (btn4+btn5+btn6 != "   ") { guiButtons += [btn4, btn5, btn6]; }
	if (btn7+btn8+btn9 != "   ") { guiButtons += [btn7, btn8, btn9]; }
	if (btn10+btn11+btn12 != "   ") { guiButtons += [btn10, btn11, btn12]; }

	llDialog(guiUserID, guiText, guiButtons, guiChannel);
}

// ===== Gets & Sets =====
setRestraints(string prmJson) {
	_isArmsBound = (integer)llJsonGetValue(prmJson, ["isArmBound"])
		&& !(integer)llJsonGetValue(prmJson, ["isArmBoundExternal"]);
	_isLegsBound = (integer)llJsonGetValue(prmJson, ["isLegBound"]);
	_isGagged = (integer)llJsonGetValue(prmJson, ["isGagged"]);
}

addExp(string prmValue) {
	integer addValue = (integer)prmValue;
	if (addValue > 0) { userExp += addValue; }
}

integer getUserLevel() { 
	return userStr + userDex + userInt - 2;
}

integer getNextLevelExp() {
	integer tmpLevel = getUserLevel();
	return ((tmpLevel) * 200) + ((tmpLevel-1)*100);
}

setStats(string stats) {
	userDex = (integer)llJsonGetValue(stats, ["dex"]);
	userInt = (integer)llJsonGetValue(stats, ["int"]);
	userStr = (integer)llJsonGetValue(stats, ["str"]);
	userExp = (integer)llJsonGetValue(stats, ["exp"]);
	userSkills = llJson2List(llJsonGetValue(stats, ["skills"]));
}

// ===== Main Functions =====
integer canLevelUp() {
	integer tmpLevel = getUserLevel();
	integer tmpRequired = getNextLevelExp();

	if (tmpLevel < 20 && userExp > tmpRequired) { return TRUE; }

	return FALSE;
}

// ===== Other Functions =====
debug(string output) {
	// TODO: global enable/disable?
	llOwnerSay(output);
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
	else if (prmFunction == "setVillainID") { _villainID = value; }
	else if (prmFunction == "addExp") { addExp(value); }
	else if (prmFunction == "setStats") { setStats(value); }
	else if (prmFunction == "setRestraints") { setRestraints(value); }
	else if (prmFunction == "resetGUI") {
		exit("");
	}
}
default {
	state_entry() {
		init();
	}

	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel = guiChannel) {
			if (prmText == "<<Done>>") { exit("done"); return; }
			else if (prmText == "<<Back>>") { gui(guiScreenLast); }
			else if (prmText == " ") { gui(guiScreen); }

			if (guiScreen == GUI_HOME) {
				if (prmText == "Bind") { guiRequest("gui_bind", FALSE, guiUserID, 0); return; }
				else if (prmText == "Escape") { guiRequest("gui_escape", FALSE, guiUserID, 0); return; }
				else if (prmText == "Stats") { gui(GUI_STATS); }
				else if (prmText == "Options") { gui(GUI_OPTIONS); }
			} else if (guiScreen == GUI_STATS) {
				if (prmText == "STR ↑") { userStr++; simpleRequest("addStr", "1"); }
				if (prmText == "DEX ↑") { userDex++; simpleRequest("addDex", "1"); }
				if (prmText == "INT ↑") { userInt++; simpleRequest("addInt", "1"); }
				gui(guiScreen);
			} else if (guiScreen == GUI_OPTIONS) {
				if (prmText == "☒ RP Mode") { rpMode = TRUE; simpleRequest("setRPMode", "1"); }
				else if (prmText == "☑ RP Mode") { rpMode = FALSE; simpleRequest("setRPMode", "0"); }
				else if (prmText == "☒ RLV") { _RLV = TRUE; simpleRequest("setRLV", "1"); }
				else if (prmText == "☑ RLV") { _RLV = FALSE; simpleRequest("setRLV", "0"); }
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

	timer() {
		exit("timeout");
	}
}
