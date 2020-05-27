$import Modules.LegTools.lslm();
$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.RopeColor.lslm();

// General Settings
string gender = "female";

// Status
string legsBound = "free";  // 0: FREE; 1: BOUND; 2: HELPLESS

string _currentRestraints;
string _restraintLib;

string getSelf() {
	if (_self != "") return _self;

	_self = llJsonSetValue(_self, ["name"], "Rope");
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
	if (prmScreen == 0) {
		btn3 = "<<Color>>";

		if (llJsonGetValue(getCurrentRestraints(), ["ankle"]) != JSON_NULL
			|| llJsonGetValue(_currentRestraints, ["knee"]) != JSON_NULL
			|| llJsonGetValue(_currentRestraints, ["immobilizer"]) != JSON_NULL
		) {
			mpButtons += "Untie";
		}

		if (llJsonGetValue(_currentRestraints, ["ankle"]) == JSON_NULL && llJsonGetValue(_currentRestraints, ["immobilizer"]) == JSON_NULL) {
			mpButtons += "Ankle";
		}

		if (llJsonGetValue(_currentRestraints, ["knee"]) == JSON_NULL && llJsonGetValue(_currentRestraints, ["immobilizer"]) == JSON_NULL) {
			mpButtons += "Knee";
		}

		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}

	// GUI: Colorize
	else if (prmScreen == 100) {
		guiText = "Choose a color for the leg rope.";
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
	restraint = llJsonSetValue(_self, ["canCut"], "1");
	restraint = llJsonSetValue(restraint, ["canEscape"], "1");
	restraint = llJsonSetValue(restraint, ["canTether"], "1");
	restraint = llJsonSetValue(restraint, ["canUseItem"], "1");
	restraint = llJsonSetValue(restraint, ["type"], "rope");

	if (prmName == "Ankle") {
		restraint = llJsonSetValue(restraint, ["uid"], "ankle");
		restraint = llJsonSetValue(restraint, ["slot"], "ankle");
		restraint = llJsonSetValue(restraint, ["complexity"], "3");
		restraint = llJsonSetValue(restraint, ["integrity"], "5");
		restraint = llJsonSetValue(restraint, ["tightness"], "6");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, liPoseStandard));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["legRope_ankle"]));
	} else if (prmName == "Knee") {
		restraint = llJsonSetValue(restraint, ["uid"], "knee");
		restraint = llJsonSetValue(restraint, ["slot"], "knee");
		restraint = llJsonSetValue(restraint, ["complexity"], "3");
		restraint = llJsonSetValue(restraint, ["integrity"], "5");
		restraint = llJsonSetValue(restraint, ["tightness"], "6");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, liPoseStandard));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["legRope_knee"]));
	}

	return restraint;
}

sendAvailabilityInfo () {
	simpleRequest("addAvailableRestraint", getSelf());
}

// Color Functions
setColorByName(string prmColorName) {
  integer tmpColorIndex = llListFindList(_colors, [prmColorName]);
  setColor(llList2Vector(_colorVals, tmpColorIndex));
}
setColor(vector prmColor) {
  _color = prmColor;

  string tmpRequest = "";
  tmpRequest = llJsonSetValue(tmpRequest, ["color"], (string)_color);
  tmpRequest = llJsonSetValue(tmpRequest, ["attachment"], llJsonGetValue(_self, ["part"]));
  tmpRequest = llJsonSetValue(tmpRequest, ["component"], "rope");
  tmpRequest = llJsonSetValue(tmpRequest, ["userKey"], (string)llGetOwner());

  simpleAttachedRequest("setColor", tmpRequest);
  simpleRequest("setColor", tmpRequest);
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
    else if (prmFunction == "requestColor") {
      if (llJsonGetValue(value, ["attachment"]) != llJsonGetValue(getSelf(), ["part"])) { return; }
      if (llJsonGetValue(value, ["name"]) != "rope") { return; }
      setColor(_color);
    }
    else if (prmFunction == "gui_leg_rope") {
      key userkey = (key)llJsonGetValue(prmJson, ["userkey"]);
      integer screen = 0;
      if ((integer)llJsonGetValue(prmJson, ["restorescreen"]) && guiScreenLast) { screen = guiScreenLast;}
      init_gui(userkey, screen);
    } else if (prmFunction == "resetGUI") {
      exit("");
    }
}

default {
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
			}

			if (guiScreen == 0) {
				if (prmText == "<<Color>>") {
					gui(100);
					return;
				} else {
					string restraintSet;
					restraintSet = llJsonSetValue(restraintSet, ["type"], llJsonGetValue(getSelf(), ["part"]));
					restraintSet = llJsonSetValue(restraintSet, ["restraint"], defineRestraint(prmText));
					simpleRequest("addRestraint", restraintSet);
					_resumeFunction = "setRestraints";
					return;
				}
			} else if (guiScreen == 100) {
				setColorByName(prmText);
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
