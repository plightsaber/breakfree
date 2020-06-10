$import Modules.GeneralTools.lslm();
$import Modules.GagTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.TapeColor.lslm();
$import Modules.UserLib.lslm();

// ===== Variables =====
// General Settings
string gender = "female";
integer _rpMode = FALSE;

integer GUI_HOME = 0;
integer GUI_STYLE = 100;
integer GUI_COLOR_STUFF = 101;
integer GUI_COLOR_TAPE = 102;
integer GUI_TEXTURE = 111;

string _villain;

string getSelf() {
	if (_self != "") return _self;

	_self = llJsonSetValue(_self, ["name"], "Tape");
	_self = llJsonSetValue(_self, ["part"], "gag");
	_self = llJsonSetValue(_self, ["hasColor"], "1");
	return _self;
}



// ===== Initializer =====
initGUI(key prmID, integer prmScreen) {
	guiUserID = prmID;

	if (guiID) { llListenRemove(guiID); }
	guiChannel = (integer)llFrand(-9998) - 1;
	guiID = llListen(guiChannel, "", guiUserID, "");
	gui(prmScreen);
}

sendAvailabilityInfo () {
	simpleRequest("addAvailableRestraint", getSelf());
}

// ===== GUI =====
gui(integer prmScreen) {
	// Reset Busy Clock
	llSetTimerEvent(guiTimeout);

	string btn10 = " ";			string btn11 = " ";			string btn12 = " ";
	string btn7 = " ";			string btn8 = " ";			string btn9 = " ";
	string btn4 = " ";			string btn5 = " ";			string btn6 = " ";
	string btn1 = "<<Back>>";	string btn2 = "<<Done>>";	string btn3 = " ";

	list mpButtons;
	guiText = " ";

	// GUI: Main
	if (prmScreen == GUI_HOME) {
		getCurrentRestraints();
		btn3 = "<<Style>>";
		if (llJsonGetValue(_currentRestraints, ["gag1"]) != JSON_NULL
			|| llJsonGetValue(_currentRestraints, ["gag2"]) != JSON_NULL
			|| llJsonGetValue(_currentRestraints, ["gag3"]) != JSON_NULL
			|| llJsonGetValue(_currentRestraints, ["gag4"]) != JSON_NULL
		) {
			mpButtons += "Ungag";
		}

		if (llJsonGetValue(_currentRestraints, ["gag1"]) == JSON_NULL
			&& llJsonGetValue(_currentRestraints, ["gag2"]) == JSON_NULL
			&& llJsonGetValue(_currentRestraints, ["gag3"]) == JSON_NULL
			&& llJsonGetValue(_currentRestraints, ["gag4"]) == JSON_NULL
		) {
			mpButtons += "Stuff";
		}

		if (llJsonGetValue(_currentRestraints, ["gag2"]) == JSON_NULL
			&& llJsonGetValue(_currentRestraints, ["gag3"]) == JSON_NULL
			&& llJsonGetValue(_currentRestraints, ["gag4"]) == JSON_NULL
		) {
			mpButtons += "Simple";
		}

		if (llJsonGetValue(_currentRestraints, ["gag2"]) != JSON_NULL
			&& llJsonGetValue(_currentRestraints, ["gag3"]) == JSON_NULL
			&& llJsonGetValue(_currentRestraints, ["gag4"]) == JSON_NULL
		) {
			mpButtons += "Heavy";
		}

		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}
	// GUI: Colorize
	else if (prmScreen == GUI_STYLE) {
		guiText = "Choose what you want to style.";
		mpButtons = multipageGui(["Tape", "Stuffing"], 2, multipageIndex);
	}
	else if (prmScreen == GUI_COLOR_TAPE) {
		guiText = "Choose a color for the tape.";
		mpButtons = multipageGui(_colors, 3, multipageIndex);
	}
	else if (prmScreen == GUI_COLOR_STUFF) {
		guiText = "Choose a color for the stuffing.";
		mpButtons = multipageGui(_colors, 3, multipageIndex);
	}
	/*
	else if (prmScreen == 111) {
		guiText = "Choose a texture for the gag.";
		mpButtons = multipageGui(textures, 3, multipageIndex);
	}
	*/

	if (prmScreen != guiScreen) { guiScreenLast = guiScreen; }
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
string defineRestraint(string prmName) {
	string gag;

	// Type-specific values
	gag = llJsonSetValue(gag, ["name"], prmName);
	gag = llJsonSetValue(gag, ["type"], "tape");
	gag = llJsonSetValue(gag, ["canEscape"], "1");
	gag = llJsonSetValue(gag, ["canCut"], "1");

	integer complexity;
	integer integrity;
	integer tightness;

	if (prmName == "Stuff") {
		complexity = 1;
		integrity = 2;
		tightness = 3;

		gag = llJsonSetValue(gag, ["uid"], "stuff");
		gag = llJsonSetValue(gag, ["slot"], "gag1");
		gag = llJsonSetValue(gag, ["canCut"], "0");
		gag = llJsonSetValue(gag, ["mouthOpen"], "1");
		gag = llJsonSetValue(gag, ["attachments", JSON_APPEND], "gStuff");
	} else if (prmName == "Simple") {
		complexity = 1;
		integrity = 10;
		tightness = 5;

		gag = llJsonSetValue(gag, ["uid"], "tapeSimple");
		gag = llJsonSetValue(gag, ["speechSealed"], "1");
		gag = llJsonSetValue(gag, ["slot"], "gag2");
		if (_mouthOpen) { gag = llJsonSetValue(gag, ["attachments", JSON_APPEND], "gTapeStuffed"); }
		else { gag = llJsonSetValue(gag, ["attachments", JSON_APPEND], "gTapeSimple"); }
	} else if (prmName == "Heavy") {
		complexity = 2;
		integrity = 10;
		tightness = 5;

		gag = llJsonSetValue(gag, ["uid"], "tapeHeavy");
		gag = llJsonSetValue(gag, ["speechSealed"], "1");
		gag = llJsonSetValue(gag, ["slot"], "gag3");
		gag = llJsonSetValue(gag, ["complexity"], "2");
		gag = llJsonSetValue(gag, ["integrity"], "10");
		gag = llJsonSetValue(gag, ["tightness"], "5");
		gag = llJsonSetValue(gag, ["attachments", JSON_APPEND], "gTapeHeavy");
		gag = llJsonSetValue(gag, ["preventAttach", JSON_APPEND], "gTapeSimple");
		gag = llJsonSetValue(gag, ["preventAttach", JSON_APPEND], "gTapeStuffed");
	}

	if (hasFeat(_villain, "Anubis")) { tightness = tightness + 2; }
	if (hasFeat(_villain, "Anubis+")) { tightness = tightness + 2; }
	if (hasFeat(_villain, "Gag Snob")) { integrity = integrity + 5; }
	if (hasFeat(_villain, "Gag Snob+")) { complexity++; }

	gag = llJsonSetValue(gag, ["complexity"], (string)complexity);
	gag = llJsonSetValue(gag, ["integrity"], (string)integrity);
	gag = llJsonSetValue(gag, ["tightness"], (string)tightness);

	return gag;
}

// Color Functions
setColorByName(string prmColorName, string prmComponent) {
	integer tmpColorIndex = llListFindList(_colors, [prmColorName]);
	setColor(llList2Vector(_colorVals, tmpColorIndex), prmComponent);
}

setColor(vector prmColor, string prmComponent) {
	_currentColors = llJsonSetValue(_currentColors, [prmComponent], (string)prmColor);

	string tmpRequest = "";
	tmpRequest = llJsonSetValue(tmpRequest, ["color"], (string)prmColor);
	tmpRequest = llJsonSetValue(tmpRequest, ["attachment"], "gag");
	tmpRequest = llJsonSetValue(tmpRequest, ["component"], prmComponent);
	tmpRequest = llJsonSetValue(tmpRequest, ["userKey"], (string)llGetOwner());

	simpleAttachedRequest("setColor", tmpRequest);
	simpleRequest("setColor", tmpRequest);
}

execute_function(string prmFunction, string prmJson) {
	string value = llJsonGetValue(prmJson, ["value"]);
	if (JSON_INVALID == value) {
		//return;		// TODO: Rewrite all linked calls to send in JSON
	}

	if (prmFunction == "setGender") { setGender(value); }
	else if (prmFunction == "setRestraints") {
		_currentRestraints = llJsonGetValue(value, ["slots"]);
		_mouthOpen = llJsonGetValue(value, ["mouthOpen"]) == "1";
	}
	else if (prmFunction == "getAvailableRestraints") { sendAvailabilityInfo(); }
	else if (prmFunction == "setRPMode") { _rpMode = (integer)value; }
	else if (prmFunction == "setVillain") { _villain = value; }
	else if (prmFunction == "requestStyle") {
		if (llJsonGetValue(prmJson, ["attachment"]) != "gag") { return; }
		if (llJsonGetValue(prmJson, ["name"]) != "tape") { return; }
		string component = llJsonGetValue(prmJson, ["component"]);
		if ("" == component) { component = "tape"; }
		setColor((vector)llJsonGetValue(_currentColors, [component]), component);
	}
	else if (prmFunction == "setColor") {
		if (llJsonGetValue(value, ["attachment"]) != "gag") { return; }
		if (!isSet(llJsonGetValue(value, ["component"]))) { return; }
		_currentColors = llJsonSetValue(_currentColors, [llJsonGetValue(value, ["component"])], llJsonGetValue(value, ["color"]));
	}
	else if (prmFunction == "gui_gag_tape") {
		key userkey = (key)llJsonGetValue(prmJson, ["userkey"]);
		integer screen = 0;
		if ((integer)llJsonGetValue(prmJson, ["restorescreen"]) && guiScreenLast) { screen = guiScreenLast;}
		initGUI(userkey, screen);
	} else if (prmFunction == "resetGUI") {
		exit("");
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

// ===== Event Controls =====
default {
	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel = guiChannel) {
			if (prmText == "<<Done>>") { exit("done"); return; }
			else if (prmText == " ") { gui(guiScreen); return; }
			else if (prmText == "<<Back>>") {
				if (guiScreen == 100) { gui(0); return; }
				else if (guiScreen != 0) { gui(guiScreenLast); return;}
				guiRequest("gui_bind", TRUE, guiUserID, 0);
				return;
			}
			else if (prmText == "Next >>") { multipageIndex ++; gui(guiScreen); return; }
			else if (prmText == "<< Previous") { multipageIndex --; gui(guiScreen); return; }

			if (prmText == "Ungag") {
				simpleRequest("remRestraint", "gag");
				_resumeFunction = "setRestraints";
				return;
			}

			if (guiScreen == GUI_HOME) {
				if (prmText == "<<Style>>") {
					gui(100);
				} else {
					string restraint;
					restraint = llJsonSetValue(restraint, ["type"], llJsonGetValue(getSelf(), ["part"]));
					restraint = llJsonSetValue(restraint, ["restraint"], defineRestraint(prmText));
					simpleRequest("addRestraint", restraint);
					_resumeFunction = "setRestraints";
				}
				return;
			} else if (guiScreen == GUI_STYLE) {
				if ("Tape" == prmText) { gui(GUI_COLOR_TAPE); }
				else if ("Stuffing" == prmText) { gui(GUI_COLOR_STUFF); }
			} else if (guiScreen == GUI_COLOR_TAPE) {
				setColorByName(prmText, "tape");
			} else if (guiScreen == GUI_COLOR_STUFF) {
				setColorByName(prmText, "stuff");
			}
			gui(guiScreen);
			return;
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
			initGUI(guiUserID, guiScreen);
		}
	}

	timer() {
		exit("timeout");
	}
}
