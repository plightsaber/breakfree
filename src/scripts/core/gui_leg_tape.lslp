$import Modules.LegTools.lslm();
$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.TapeColor.lslm();
$import Modules.UserLib.lslm();

// General Settings
string gender = "female";
integer _rpMode = FALSE;

// GUI Screens
integer GUI_HOME = 0;
integer GUI_STYLE = 100;
//integer GUI_TEXTURE = 101;
integer GUI_COLOR = 100;	// Only one option menu - share with STYLE

string _villain;

// Status
string legsBound = "free";  // 0: FREE; 1: BOUND; 2: HELPLESS

string _currentRestraints;
string _restraintLib;

string getSelf() {
	if (_self != "") return _self;

	_self = llJsonSetValue(_self, ["name"], "Tape");
	_self = llJsonSetValue(_self, ["part"], "leg");
	_self = llJsonSetValue(_self, ["hasColor"], "1");
	return _self;
}

string getCurrentRestraints() {
	if (_currentRestraints) {
		return _currentRestraints;
	}

	_currentRestraints = llJsonSetValue(_currentRestraints, ["ankle"], JSON_NULL);
	_currentRestraints = llJsonSetValue(_currentRestraints, ["knee"], JSON_NULL);
	_currentRestraints = llJsonSetValue(_currentRestraints, ["immobilizer"], JSON_NULL);
	return _currentRestraints;
}

// ===== Initializers =====
init() {
	if (!isSet(_currentColors)) {
		_currentColors = llJsonSetValue(_currentColors, ["tape"], (string)COLOR_SILVER);
	}
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

	string btn10 = " ";			string btn11 = " ";			string btn12 = " ";
	string btn7 = " ";			string btn8 = " ";			string btn9 = " ";
	string btn4 = " ";			string btn5 = " ";			string btn6 = " ";
	string btn1 = "<<Back>>";	string btn2 = "<<Done>>";	string btn3 = " ";

	list mpButtons;
	guiText = " ";

	// GUI: Main
	if (prmScreen == GUI_HOME) {
		btn3 = "<<Style>>";

		if (!isSet(llJsonGetValue(_currentRestraints, ["ankle"])) && !isSet(llJsonGetValue(_currentRestraints, ["immobilizer"]))) {
			mpButtons += "Ankle";
		} else if (!isSet(llJsonGetValue(_currentRestraints, ["immobilizer"])) && isSet(llJsonGetValue(_currentRestraints, ["ankle"]))) {
			mpButtons += "Free Ankle";
		}

		if (!isSet(llJsonGetValue(_currentRestraints, ["knee"])) && !isSet(llJsonGetValue(_currentRestraints, ["immobilizer"]))) {
			mpButtons += "Knee";
		} else if (!isSet(llJsonGetValue(_currentRestraints, ["immobilizer"])) && isSet(llJsonGetValue(_currentRestraints, ["knee"]))) {
			mpButtons += "Free Knee";
		}

		if (llJsonGetValue(_currentRestraints, ["immobilizer"]) == JSON_NULL) {
			mpButtons += "Kneel";
		}

		if ((hasFeat(_villain, "Anubis+") || _rpMode)
			&& !isSet(llJsonGetValue(_currentRestraints, ["immobilizer"]))
		) {
			mpButtons += "Ball";
		}

		if (isSet(llJsonGetValue(_currentRestraints, ["immobilizer"]))) {
			mpButtons += "Untie";
		}

		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}

	// GUI: Colorize
	else if (prmScreen == GUI_COLOR) {
		guiText = "Choose a color for the leg tape.";
		mpButtons = multipageGui(_colors, 3, multipageIndex);
	}

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
	string restraint;
	list liPoseStandard = ["stand", "kneel", "sit", "sitLeft", "sitRight", "groundFront", "groundLeft", "groundRight", "groundBack"];

	// Type-specific values
	restraint = llJsonSetValue(restraint, ["name"], prmName);
	restraint = llJsonSetValue(restraint, ["canCut"], "1");
	restraint = llJsonSetValue(restraint, ["canEscape"], "1");
	restraint = llJsonSetValue(restraint, ["canTether"], "0");
	restraint = llJsonSetValue(restraint, ["canUseItem"], "1");
	restraint = llJsonSetValue(restraint, ["type"], "tape");

	integer complexity = 1;
	integer integrity;
	integer tightness;

	if (prmName == "Ankle") {
		integrity = 25;
		tightness = 6;

		restraint = llJsonSetValue(restraint, ["uid"], "ankleTape");
		restraint = llJsonSetValue(restraint, ["slot"], "ankle");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, liPoseStandard));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["legTape_ankle"]));
	} else if (prmName == "Knee") {
		integrity = 25;
		tightness = 6;

		restraint = llJsonSetValue(restraint, ["uid"], "kneeTape");
		restraint = llJsonSetValue(restraint, ["slot"], "knee");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, liPoseStandard));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["legTape_knee"]));
	} else if (prmName == "Kneel") {
		integrity = 15;
		tightness = 10;

		restraint = llJsonSetValue(restraint, ["uid"], "kneelTape");
		restraint = llJsonSetValue(restraint, ["slot"], "immobilizer");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["hogKneel", "hogFront", "hogLeft", "hogRight"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["legTape_kneel"]));
	} else if (prmName == "Ball") {
		complexity = 1;
		integrity = 15;
		tightness = 15;

		restraint = llJsonSetValue(restraint, ["uid"], "ballTape");
		restraint = llJsonSetValue(restraint, ["slot"], "immobilizer");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["ballLeft", "ballRight"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["legTape_ball"]));
		//restraint = llJsonSetValue(restraint, ["preventAttach", JSON_APPEND], "legRope_knee"); // TODO: Add this to special bind rules?
	}

	if (hasFeat(_villain, "Anubis")) { tightness = tightness + 2; }
	if (hasFeat(_villain, "Anubis+")) { tightness = tightness + 2; }

	restraint = llJsonSetValue(restraint, ["complexity"], (string)complexity);
	restraint = llJsonSetValue(restraint, ["integrity"], (string)integrity);
	restraint = llJsonSetValue(restraint, ["tightness"], (string)tightness);

	return restraint;
}

sendAvailabilityInfo () {
	simpleRequest("addAvailableRestraint", getSelf());
}

// ===== Color Functions =====
setColorByName(string prmColorName, string prmComponent) {
	integer tmpColorIndex = llListFindList(_colors, [prmColorName]);
	setColor(llList2Vector(_colorVals, tmpColorIndex), prmComponent);
}

setColor(vector color, string component) {
	_currentColors = llJsonSetValue(_currentColors, [component], (string)color);

	string request = "";
	request = llJsonSetValue(request, ["color"], (string)color);
	request = llJsonSetValue(request, ["attachment"], llJsonGetValue(getSelf(), ["part"]));
	request = llJsonSetValue(request, ["component"], component);
	request = llJsonSetValue(request, ["userKey"], (string)llGetOwner());

	simpleAttachedRequest("setColor", request);
	simpleRequest("setColor", request);
}

setTextureByName(string prmTextureName, string prmComponent) {
	integer tmpTextureIndex = llListFindList(_textures, [prmTextureName]);
	setTexture(llList2String(_textureVals, tmpTextureIndex), prmComponent);
}

setTexture(string texture, string component) {
	_currentTextures = llJsonSetValue(_currentTextures, [component], texture);

	string request = "";
	request = llJsonSetValue(request, ["attachment"], llJsonGetValue(getSelf(), ["part"]));
	request = llJsonSetValue(request, ["component"], component);
	request = llJsonSetValue(request, ["texture"], texture);
	request = llJsonSetValue(request, ["userKey"], (string)llGetOwner());

	simpleAttachedRequest("setTexture", request);
	simpleRequest("setTexture", request);
}

// ===== Gets =====
string getName() {
  return llGetDisplayName(llGetOwner());
}

// ===== Sets =====
setGender(string prmGender) {
  gender = prmGender;
}

setLegsBound(string prmBound) {
  legsBound = prmBound;
}

// ===== Event Controls =====
execute_function(string prmFunction, string prmJson) {
	string value = llJsonGetValue(prmJson, ["value"]);
	if (JSON_INVALID == value) {
		//return;		// TODO: Rewrite all linked calls to send in JSON
	}

	if (prmFunction == "setGender") { setGender(value); }
	else if (prmFunction == "setRestraints") {
		_currentRestraints = llJsonGetValue(value, ["slots"]);
		set_restraints(value);
	}
	else if (prmFunction == "getAvailableRestraints") { sendAvailabilityInfo(); }
	else if (prmFunction == "setRPMode") { _rpMode = (integer)value; }
	else if (prmFunction == "setVillain") { _villain = value; }
	else if (prmFunction == "requestStyle") {
	  	if (llJsonGetValue(value, ["attachment"]) != llJsonGetValue(getSelf(), ["part"])) { return; }
	  	if (llJsonGetValue(value, ["name"]) != "tape") { return; }
		string component = llJsonGetValue(value, ["component"]);
		if ("" == component) { component = "tape"; }

		setColor((vector)llJsonGetValue(_currentColors, [component]), component);
		//setTexture(llJsonGetValue(_currentTextures, [component]), component);
	}
	else if (prmFunction == "gui_leg_tape") {
	  key userkey = (key)llJsonGetValue(prmJson, ["userkey"]);
	  integer screen = 0;
	  if ((integer)llJsonGetValue(prmJson, ["restorescreen"]) && guiScreenLast) { screen = guiScreenLast;}
	  init_gui(userkey, screen);
	} else if (prmFunction == "resetGUI") {
	  exit("");
	}
}

default {
	state_entry() { init(); }

	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel = guiChannel) {
			if (prmText == "<<Done>>") { exit("done"); return; }
			else if (prmText == " ") { gui(guiScreen); return; }
			else if (prmText == "<<Back>>") {
				if (guiScreen != 0) { gui(guiScreenLast); return;}
				guiRequest("gui_bind", TRUE, guiUserID, 0);
				return;
			}
			else if (prmText == "Next >>") { multipageIndex ++; gui(guiScreen); return; }
			else if (prmText == "<< Previous") { multipageIndex --; gui(guiScreen); return; }

			if (prmText == "Untie") {
				simpleRequest("remRestraint", llJsonGetValue(getSelf(), ["part"]));
				_resumeFunction = "setRestraints";
				return;
			} else if (prmText == "Free Ankle") {
				simpleRequest("rmSlot", "ankle");
				_resumeFunction = "setRestraints";
				return;
			} else if (prmText == "Free Knee") {
				simpleRequest("rmSlot", "knee");
				_resumeFunction = "setRestraints";
				return;
			}

			if (guiScreen == GUI_HOME) {
				if (prmText == "<<Style>>") {
					gui(GUI_STYLE);
					return;
				} else {
					string restraintSet;
					restraintSet = llJsonSetValue(restraintSet, ["type"], llJsonGetValue(getSelf(), ["part"]));
					restraintSet = llJsonSetValue(restraintSet, ["restraint"], defineRestraint(prmText));
					simpleRequest("addRestraint", restraintSet);
					_resumeFunction = "setRestraints";
					return;
				}
			} else if (guiScreen == GUI_COLOR) {
				setColorByName(prmText, "tape");
				gui(guiScreen);
				return;
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
