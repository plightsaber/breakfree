$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();

string self;	// JSON object

// General Settings
string gender = "female";

// Status
integer _armsBound = FALSE;
integer _legsBound = FALSE;
integer _gagBound = FALSE;

// Tether Variables
integer _armsTetherable;
integer _legsTetherable;

list _legPoses;

// Restaint Lists
list armRestraints;
list legRestraints;
list gagRestraints;

// Other
integer _armBoundExternal = FALSE;
key configQueryID;
string jsonSettings;

string _resumeFunction;
string _restraints;

init() {
	armRestraints = ["Unbound"];
	legRestraints = ["Unbound"];
	gagRestraints = ["Unbound"];

	configQueryID = llGetNotecardLine(".config",0);	// Load config.

	simpleRequest("getAvailableRestraints", "all");
}

init_gui(key prmID, integer prmScreen) {
	guiUserID = prmID;
	simpleRequest("setVillainKey", guiUserID);

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

	if (guiUserID == llGetOwner()) { btn1 = "<<Back>>"; }	// Allow users to bind selves and return to own menu

	list mpButtons;

	guiText = " ";

	// Handle Gag-only path
	if ((integer)llJsonGetValue(jsonSettings, ["gagOnly"]) && prmScreen == 0) {
		prmScreen = 30;
	}

	if (prmScreen != guiScreen) { guiScreenLast = guiScreen; }
	if (btn1 == " " && (prmScreen != 0)) { btn1 = "<<Back>>"; };

	// GUI: Main
	if (prmScreen == 0) {
		// reset previous screen
		guiScreenLast = 0;

		if (_armsTetherable) { btn7 = "Tether Arms"; }
		if (_legsTetherable) { btn7 = "Tether Legs"; }

		if (!_armBoundExternal) { btn4 = "Bind Arms"; }
		btn5 = "Bind Legs";
		btn6 = "Gag";
		if (llGetListLength(_legPoses) > 1) { btn3 = "Position"; }
	}

	// GUI: Bind Arms
	if (prmScreen == 10) {
		guiText = "What do you want to bind " + getName() + "'s arms with?";
		mpButtons = multipageGui(armRestraints, 3, multipageIndex);
	}

	// GUI: Bind Legs
	if (prmScreen == 20) {
		guiText = "What do you want to bind " + getName() + "'s legs with?";
		mpButtons = multipageGui(legRestraints, 3, multipageIndex);
	}

	// GUI: Bind Gag
	if (prmScreen == 30) {
		guiText = "What do you want to gag " + getName() + " with?";
		mpButtons = multipageGui(gagRestraints, 3, multipageIndex);

		// Unset <<BACK>> for gagOnly mode
		if (guiUserID != llGetOwner() && (integer)llJsonGetValue(jsonSettings, ["gagOnly"])) {
			btn1 = " ";
		}
	}

	// GUI: Position
	if (prmScreen == 70) {
		guiText = "How do you want to pose " + getName() + "?";
		mpButtons = multipageGui(_legPoses, 3, multipageIndex);
	}

	guiScreen = prmScreen;
	guiButtons = [btn1, btn2, btn3];

	if (btn4+btn5+btn6 != "   ") { guiButtons += [btn4, btn5, btn6]; }
	if (btn7+btn8+btn9 != "   ") { guiButtons += [btn7, btn8, btn9]; }
	if (btn10+btn11+btn12 != "   ") { guiButtons += [btn10, btn11, btn12]; }

	// Load MP Buttons - hopefully the lengths were configured correctly!
	if (llGetListLength(mpButtons)) { guiButtons += mpButtons; }

	llDialog(guiUserID, guiText, guiButtons, guiChannel);
}

// ===== Main Functions =====
addAvailableRestraint(string prmInfo) {
	string tmpName = llJsonGetValue(prmInfo, ["name"]);
	string tmpPart = llJsonGetValue(prmInfo, ["part"]);
	integer hasColor = llJsonGetValue(prmInfo, ["hasColor"]) == "1";

	if (tmpPart == "arm") {
		armRestraints += tmpName;
	} else if (tmpPart == "leg") {
		legRestraints += tmpName;
	} else if (tmpPart == "gag") {
		gagRestraints += tmpName;
	}
}

// ===== Gets =====
string getName() {
	return llGetDisplayName(llGetOwner());
}

// ===== Sets =====
setGender(string prmGender) {
	gender = prmGender;
}

setAvailablePoses(string prmPoses) {
	_legPoses = llJson2List(prmPoses);
}

set_restraints(string prmJson) {
	_restraints = prmJson;
	_armsBound = (integer)llJsonGetValue(prmJson, ["armBound"]);
	_armsTetherable = (integer)llJsonGetValue(prmJson, ["isArmTetherable"]);
	_armBoundExternal = (integer)llJsonGetValue(prmJson, ["armBoundExternal"]);
	_legsBound = (integer)llJsonGetValue(prmJson, ["legBound"]);
	_legsTetherable = (integer)llJsonGetValue(prmJson, ["isLegTetherable"]);
}

// ===== Event Controls =====
execute_function(string prmFunction, string prmJson) {
	string value = llJsonGetValue(prmJson, ["value"]);
	if (JSON_INVALID == value) {
		//return;		// TODO: Rewrite all linked calls to send in JSON
	}
	if (prmFunction == "setGender") { setGender(value); }
	else if (prmFunction == "setRestraints") { set_restraints(value); }
	else if (prmFunction == "setLegPoses") { setAvailablePoses(value); }
	else if (prmFunction == "addAvailableRestraint") { addAvailableRestraint(value); }
	else if (prmFunction == "gui_bind") {
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
		init();
	}

	on_rez(integer prmStart) {
		init();
	}

	dataserver(key queryID, string configData) {
		if (queryID == configQueryID) {
			jsonSettings = configData;
		}
	}

	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel = guiChannel) {
			if (prmText == "<<Done>>") { exit("done"); return; }
			else if (prmText == " ") { gui(guiScreen); }
			else if (prmText == "<<Back>>"
				&& guiScreen == 30
				&& (integer)llJsonGetValue(jsonSettings, ["gagOnly"])
			) {
				guiRequest("gui_owner", FALSE, guiUserID, 0);
				return;
			}
			else if (guiScreen !=0 && prmText == "<<Back>>") { gui(guiScreenLast); return; }

			else if (prmText == "Next >>") { multipageIndex ++; gui(guiScreen); return; }
			else if (prmText == "<< Previous") { multipageIndex --; gui(guiScreen); return; }

			if (guiScreen == 0) {
				if (prmText == "Bind Arms") { gui(10); }
				else if (prmText == "Bind Legs") { gui(20); }
				else if (prmText == "Gag") { gui(30); }
				else if (prmText == "Position") { gui(70); }
				else if (prmText == "Tether Arms") { guiRequest("gui_tether_arm", FALSE, guiUserID, 0); return; }
				else if (prmText == "Tether Legs") { guiRequest("gui_tether_leg", FALSE, guiUserID, 0); return; }
				else if (prmText == "<<Back>>") {
					guiRequest("gui_owner", FALSE, guiUserID, 0);
					return;
				}
			}
			else if (guiScreen == 10) {
				if (prmText == "Unbound") {
					simpleRequest("releaseRestraint", "arm");
					gui(guiScreen);
					return;
				}
				guiRequest("gui_arm_" + llToLower(prmText), FALSE, guiUserID, 0);
				return;
			} else if (guiScreen == 20) {
				if (prmText == "Unbound") {
					simpleRequest("releaseRestraint", "leg");
					gui(guiScreen);
					return;
				}
				guiRequest("gui_leg_" + llToLower(prmText), FALSE, guiUserID, 0);
				return;
			} else if (guiScreen == 30) {
				if (prmText == "Unbound") {
					simpleRequest("releaseRestraint", "gag");
					gui(guiScreen);
					return;
				}
				guiRequest("gui_gag_" + llToLower(prmText), FALSE, guiUserID, 0);
				return;
			} else if (guiScreen == 70) {
				simpleRequest("setLegPose", prmText);
				gui(guiScreen);
				return;
			}
		}
	}

	link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
		string function = llJsonGetValue(prmText, ["function"]);
		if (JSON_INVALID == function) {
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
