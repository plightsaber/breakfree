$import Modules.ArmTools.lslm();
$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();

// General Settings
string gender = "female";

// Status
string armsBound = "free";  // 0: FREE; 1: BOUND; 2: HELPLESS

// Colors
vector COLOR_WHITE = <1.0, 1.0, 1.0>;
vector COLOR_BROWN = <0.824, 0.549, 0.353>;

vector color = COLOR_WHITE;
list colors = ["White", "Brown"];
list colorVals = [COLOR_WHITE, COLOR_BROWN];

string getSelf() {
	if (_self != "") return _self;

	_self = llJsonSetValue(_self, ["name"], "Rope");
	_self = llJsonSetValue(_self, ["part"], "arm");
	_self = llJsonSetValue(_self, ["hasColor"], "1");
	return _self;
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
		if (_slot) { mpButtons += "Untie"; }
		else {
			mpButtons += "Front";
			mpButtons += "F+Sides";
			mpButtons += "Back";
			mpButtons += "B+Sides";
		}
		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}
	
	// GUI: Colorize
	else if (prmScreen == 100) {
		guiText = "Choose a color for the arm ropes.";
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
add_restraint(string prmName) {
	string restraint;
	restraint = llJsonSetValue(restraint, ["name"], prmName);
	restraint = llJsonSetValue(_self, ["canCut"], "1");
	restraint = llJsonSetValue(restraint, ["canEscape"], "1");
	restraint = llJsonSetValue(restraint, ["canTether"], "1");
	restraint = llJsonSetValue(restraint, ["canUseItem"], "1");
	restraint = llJsonSetValue(restraint, ["type"], "knot");

	if (prmName == "Sides") {
		restraint = llJsonSetValue(restraint, ["slot"], "3");
		restraint = llJsonSetValue(restraint, ["difficulty"], "4");
		restraint = llJsonSetValue(restraint, ["tightness"], "15");

		restraint = llJsonSetValue(restraint, ["animation_base"], "animArmSides");
		restraint = llJsonSetValue(restraint, ["animation_success"], "animBaseWriggle");
		restraint = llJsonSetValue(restraint, ["animation_failure"], "animBaseThrash");

		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["arSides"]));
	} else if (prmName == "Front") {
		restraint = llJsonSetValue(restraint, ["slot"], "1");
		restraint = llJsonSetValue(restraint, ["difficulty"], "4");
		restraint = llJsonSetValue(restraint, ["tightness"], "20");

		restraint = llJsonSetValue(restraint, ["animation_base"], "animArmFront");
		restraint = llJsonSetValue(restraint, ["animation_success"], "animBaseWriggle");
		restraint = llJsonSetValue(restraint, ["animation_failure"], "animBaseThrash");

		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["arFront"]));
	} else if (prmName == "F+Sides") {
		restraint = llJsonSetValue(restraint, ["slot"], "3");
		restraint = llJsonSetValue(restraint, ["difficulty"], "6");
		restraint = llJsonSetValue(restraint, ["tightness"], "25");

		restraint = llJsonSetValue(restraint, ["animation_base"], "animArmFront");
		restraint = llJsonSetValue(restraint, ["animation_success"], "animBaseWriggle");
		restraint = llJsonSetValue(restraint, ["animation_failure"], "animBaseThrash");

		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["arFront", "arHarness", "arHarnessFront"]));
	} else if (prmName == "Back") {
		restraint = llJsonSetValue(restraint, ["slot"], "1");
		restraint = llJsonSetValue(restraint, ["difficulty"], "6");
		restraint = llJsonSetValue(restraint, ["tightness"], "20");

		restraint = llJsonSetValue(restraint, ["animation_base"], "animArmPoseXBack");
		restraint = llJsonSetValue(restraint, ["animation_success"], "animBaseWriggle");
		restraint = llJsonSetValue(restraint, ["animation_failure"], "animBaseThrash");

		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["arXBack"]));
	} else if (prmName == "B+Sides") {
		restraint = llJsonSetValue(restraint, ["slot"], "3");
		restraint = llJsonSetValue(restraint, ["difficulty"], "8");
		restraint = llJsonSetValue(restraint, ["tightness"], "25");

		restraint = llJsonSetValue(restraint, ["animation_base"], "animArmPoseXBack");
		restraint = llJsonSetValue(restraint, ["animation_success"], "animBaseWriggle");
		restraint = llJsonSetValue(restraint, ["animation_failure"], "animBaseThrash");

		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["arXBack", "arHarness", "arHarnessBack"]));
	}

	string restraintSet;
	restraintSet = llJsonSetValue(restraintSet, ["type"], "arm");
	restraintSet = llJsonSetValue(restraintSet, ["restraint"], restraint);
	simple_request("addRestraint", restraintSet);
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
    else if (prmFunction == "setRestraints") { set_restraints(value); }
    else if (prmFunction == "getAvailableRestraints") { sendAvailabilityInfo(); }
    else if (prmFunction == "requestColor") {
      if (llJsonGetValue(value, ["attachment"]) != "arm") { return; }
      if (llJsonGetValue(value, ["name"]) != "rope") { return; }
      setColor(color);
    }
    else if (prmFunction == "gui_arm_rope") {
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
				simple_request("remRestraint", "arm");
				_resumeFunction = "setRestraints";
				return;
			}

			if (guiScreen == 0) {
				if (prmText == "<<Color>>") {
					gui(100);
					return;
				} else {
					add_restraint(prmText);
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
