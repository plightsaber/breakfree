$import Modules.ArmTools.lslm();
$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.UserLib.lslm();

// General Settings
string gender = "female";
integer _rpMode = FALSE;

string _villain;

// Status
string armsBound = "free";  // 0: FREE; 1: BOUND; 2: HELPLESS

// Colors
vector COLOR_BROWN = <0.5, 0.25, 0.0>;
vector COLOR_BLACK = <0.1, 0.1, 0.1>;
vector COLOR_BLUE = <0.0, 0.25, 0.5>;
vector COLOR_GREEN = <0.0, 0.4, 0.2>;
vector COLOR_WHITE = <1.0, 1.0, 1.0>;
vector COLOR_RED = <0.75, 0.0, 0.0>;
vector COLOR_PINK = <1.0, 0.5, 0.5>;
vector COLOR_YELLOW = <0.88, 0.68, 0.15>;
vector COLOR_PURPLE = <0.5, 0.0, 0.5>;
vector COLOR_SILVER = <0.5, 0.5, 0.5>;

vector color = COLOR_SILVER;
list colors = ["White", "Silver", "Black", "Purple", "Red", "Blue", "Green", "Pink", "Yellow", "Brown"];
list colorVals = [COLOR_WHITE, COLOR_SILVER, COLOR_BLACK, COLOR_PURPLE, COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_BROWN];

string _currentRestraints;
string _restraintLib;

string getSelf() {
	if (_self != "") return _self;

	_self = llJsonSetValue(_self, ["name"], "Tape");
	_self = llJsonSetValue(_self, ["part"], "arm");
	_self = llJsonSetValue(_self, ["hasColor"], "1");
	return _self;
}

string getCurrentRestraints() {
	if (_currentRestraints) {
		return _currentRestraints;
	}

	_currentRestraints = llJsonSetValue(_currentRestraints, ["hand"], JSON_NULL);
	_currentRestraints = llJsonSetValue(_currentRestraints, ["wrist"], JSON_NULL);
	_currentRestraints = llJsonSetValue(_currentRestraints, ["elbow"], JSON_NULL);
	_currentRestraints = llJsonSetValue(_currentRestraints, ["torso"], JSON_NULL);
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

		if (isSet(llJsonGetValue(getCurrentRestraints(), ["wrist"]))
			|| isSet(llJsonGetValue(_currentRestraints, ["elbow"]))
			|| isSet(llJsonGetValue(_currentRestraints, ["torso"]))
		) {
			mpButtons += "Untie";
		}

		if (isSet(llJsonGetValue(_currentRestraints, ["hand"]))) { mpButtons += "Free Hands"; }

		if (!isSet(llJsonGetValue(_currentRestraints, ["wrist"])) && !isSet(llJsonGetValue(_currentRestraints, ["torso"]))) {
			if (!isSet(llJsonGetValue(_currentRestraints, ["elbow"]))) {
				mpButtons += "Front";
			}
			mpButtons += "Back";
		}

		if (!isSet(llJsonGetValue(_currentRestraints, ["elbow"]))
			&& !isSet(llJsonGetValue(_currentRestraints, ["torso"]))
			&& ("backTape" == llJsonGetValue(_currentRestraints, ["wrist"]) || "backRope" == llJsonGetValue(_currentRestraints, ["wrist"]))
		) {
			mpButtons += "Elbow";
		}

		if (!isSet(llJsonGetValue(_currentRestraints, ["torso"])) && !isSet(llJsonGetValue(_currentRestraints, ["elbow"])) && !isSet(llJsonGetValue(_currentRestraints, ["wrist"]))) {
			mpButtons += "Sides";
		} else if (!isSet(llJsonGetValue(_currentRestraints, ["torso"]))) {
			mpButtons += "Harness";
		}

		if ((hasFeat(_villain, "Anubis") || _rpMode)
			&& llJsonGetValue(_currentRestraints, ["elbow"]) == JSON_NULL
			&& llJsonGetValue(_currentRestraints, ["torso"]) == JSON_NULL
			&& llJsonGetValue(_currentRestraints, ["wrist"]) == JSON_NULL
		) {
			mpButtons += "Box";
		}

		if ((hasFeat(_villain, "Anubis++") || _rpMode)
			&& !isSet(llJsonGetValue(_currentRestraints, ["hand"]))
		) {
			mpButtons += "Mitten";
		}

		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}

	// GUI: Colorize
	else if (prmScreen == 100) {
		guiText = "Choose a color for the arm tape.";
		mpButtons = multipageGui(colors, 3, multipageIndex);
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

	// Type-specific values
	restraint = llJsonSetValue(restraint, ["name"], prmName);
	restraint = llJsonSetValue(_self, ["canCut"], "1");
	restraint = llJsonSetValue(restraint, ["canEscape"], "1");
	restraint = llJsonSetValue(restraint, ["canTether"], "0");
	restraint = llJsonSetValue(restraint, ["canUseItem"], "1");
	restraint = llJsonSetValue(restraint, ["type"], "tape");

	integer complexity = 1;
	integer integrity;
	integer tightness;

	if (prmName == "Sides") {
		integrity = 20;
		tightness = 5;

		restraint = llJsonSetValue(restraint, ["uid"], "sidesTape");
		restraint = llJsonSetValue(restraint, ["slot"], "torso");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["sides"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["armTape_sides"]));
	} else if (prmName == "Front") {
		integrity = 20;
		tightness = 4;

		restraint = llJsonSetValue(restraint, ["uid"], "frontTape");
		restraint = llJsonSetValue(restraint, ["slot"], "wrist");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["front"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["armTape_front_wrist"]));
	} else if (prmName == "Back") {
		integrity = 20;
		tightness = 4;

		string pose = "back";
		list liAttachments = ["armTape_back_wrist"];
		if (llJsonGetValue(getCurrentRestraints(), ["elbow"]) != JSON_NULL) {
			pose = "backTight";
			liAttachments = ["armTape_backTight_wrist"];
		}

		restraint = llJsonSetValue(restraint, ["uid"], "backTape");
		restraint = llJsonSetValue(restraint, ["slot"], "wrist");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, [pose]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, liAttachments));
	} else if (prmName == "Elbow") {
		integrity = 25;
		tightness = 8;

		restraint = llJsonSetValue(restraint, ["uid"], "elbowTape");
		restraint = llJsonSetValue(restraint, ["slot"], "elbow");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["backTight"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["armTape_backTight_elbow"]));
	} else if (prmName == "Harness") {
		integrity = 30;
		tightness = 6;

		list liAttachments;
		list liPoses;
		if (llJsonGetValue(getCurrentRestraints(), ["elbow"]) != JSON_NULL) {
			liAttachments += "armTape_backTight_harness";
			liPoses = ["backTight"];
		} else if (llJsonGetValue(getCurrentRestraints(), ["wrist"]) == "backRope" || llJsonGetValue(getCurrentRestraints(), ["wrist"]) == "backTape") {
			liAttachments += "armTape_back_harness";
			liPoses = ["back"];
		} else if (llJsonGetValue(getCurrentRestraints(), ["wrist"]) == "frontRope" || llJsonGetValue(getCurrentRestraints(), ["wrist"]) == "frontTape") {
			liAttachments += "armTape_front_harness";
			liPoses = ["back"];
		}
		restraint = llJsonSetValue(restraint, ["uid"], "harnessTape");
		restraint = llJsonSetValue(restraint, ["slot"], "torso");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, liPoses));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, liAttachments));
	} else if (prmName == "Box") {
		complexity = 2;
		integrity = 30;
		tightness = 15;

		restraint = llJsonSetValue(restraint, ["uid"], "boxTape");
		restraint = llJsonSetValue(restraint, ["slot"], "torso");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["box"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["armTape_box"]));
	} else if (prmName == "Mitten") {
		tightness = 5;
		integrity = 10;

		restraint = llJsonSetValue(restraint, ["uid"], "mittenTape");
		restraint = llJsonSetValue(restraint, ["slot"], "hand");
		restraint = llJsonSetValue(restraint, ["animations"], "animHand_fist");
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["armTape_mitten"]));
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

// Color Functions
setColorByName(string prmColorName) {
  integer tmpColorIndex = llListFindList(colors, [prmColorName]);
  setColor(llList2Vector(colorVals, tmpColorIndex));
}

setColor(vector prmColor) {
  color = prmColor;

  string tmpRequest = "";
  tmpRequest = llJsonSetValue(tmpRequest, ["color"], (string)color);
  tmpRequest = llJsonSetValue(tmpRequest, ["attachment"], "arm");
  tmpRequest = llJsonSetValue(tmpRequest, ["component"], "tape");
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

setArmsBound(string prmArmsBound) {
  armsBound = prmArmsBound;
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
	else if (prmFunction == "requestColor") {
	  if (llJsonGetValue(value, ["attachment"]) != llJsonGetValue(getSelf(), ["part"])) { return; }
	  if (llJsonGetValue(value, ["name"]) != "tape") { return; }
	  setColor(color);
	}
	else if (prmFunction == "gui_arm_tape") {
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
			} else if (prmText == "Free Hands") {
				simpleRequest("rmSlot", "hand");
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
