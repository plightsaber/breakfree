$import Modules.LegTools.lslm();
$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();

// ===== Variables =====
// General Settings
string gender = "female";

// Status
string _legsBound = "free";	// 0: FREE; 1: BOUND; 2: HELPLESS

// Colors
vector COLOR_WHITE = <1.0, 1.0, 1.0>;
vector COLOR_BROWN = <0.824, 0.549, 0.353>;

vector _color = COLOR_WHITE;
list _colors = ["White", "Brown"];
list _colorVals = [COLOR_WHITE, COLOR_BROWN];

string getSelf() {
	if (_self != "") return _self;

	_self = llJsonSetValue(_self, ["name"], "Rope");
	_self = llJsonSetValue(_self, ["part"], "leg");
	_self = llJsonSetValue(_self, ["hasColor"], "1");
	return _self;
}

// ===== POSES =====
string POSE_STAND() {
	string object = "";
	object = llJsonSetValue(object, ["animBase"], "animLegPose_stand");
	object = llJsonSetValue(object, ["animFail"], "animLegStruggle_stand");
	object = llJsonSetValue(object, ["animJump"], "animLegJump_stand");
	object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_stand");
	object = llJsonSetValue(object, ["animWalkBack"], "animLegStandWalk");
	object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_stand");
	object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_stand");
	object = llJsonSetValue(object, ["jumpPower"], "5");
	object = llJsonSetValue(object, ["name"], "Stand");
	object = llJsonSetValue(object, ["poseDown"], "Sit");
	object = llJsonSetValue(object, ["poseFall"], "Front");
	object = llJsonSetValue(object, ["speedBack"], "20");
	object = llJsonSetValue(object, ["speedFwd"], "20");
	object = llJsonSetValue(object, ["stability"], "5");

	return object;
}

string POSE_SIT() {
	string object = "";
	object = llJsonSetValue(object, ["animBase"], "animLegPose_sit");
	object = llJsonSetValue(object, ["animFail"], "animLegStruggle_sit");
	object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_sit");
	object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_sit");
	object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_sit");
	object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_sit");
	object = llJsonSetValue(object, ["jumpPower"], "0");
	object = llJsonSetValue(object, ["name"], "Sit");
	object = llJsonSetValue(object, ["poseDown"], "Back");
	object = llJsonSetValue(object, ["poseFall"], "Back");
	object = llJsonSetValue(object, ["poseUp"], "Stand");
	object = llJsonSetValue(object, ["speedBack"], "12");
	object = llJsonSetValue(object, ["speedFwd"], "8");
	object = llJsonSetValue(object, ["stability"], "5");

	return object;
}

string POSE_KNEEL() {
	string object = "";
	object = llJsonSetValue(object, ["animBase"], "animLegPose_kneel");
	object = llJsonSetValue(object, ["animFail"], "animLegStruggle_kneel");
	object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_kneel");
	object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_kneel");
	object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_kneel");
	object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_kneel");
	object = llJsonSetValue(object, ["jumpPower"], "0");
	object = llJsonSetValue(object, ["name"], "Kneel");
	object = llJsonSetValue(object, ["poseDown"], "Front");
	object = llJsonSetValue(object, ["poseFall"], "Left");
	object = llJsonSetValue(object, ["poseUp"], "Stand");
	object = llJsonSetValue(object, ["speedBack"], "10");
	object = llJsonSetValue(object, ["speedFwd"], "10");
	object = llJsonSetValue(object, ["stability"], "5");

	return object;
}

string POSE_BACK() {
	string object = "";
	object = llJsonSetValue(object, ["animBase"], "animLegPose_groundBack");
	object = llJsonSetValue(object, ["animFail"], "animLegStruggle_groundBack");
	object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_groundBack");
	object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_groundBack");
	object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_groundBack");
	object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_groundBack");
	object = llJsonSetValue(object, ["jumpPower"], "0");
	object = llJsonSetValue(object, ["name"], "Back");
	object = llJsonSetValue(object, ["poseLeft"], "Right");
	object = llJsonSetValue(object, ["poseRight"], "Left");
	object = llJsonSetValue(object, ["poseUp"], "Sit");
	object = llJsonSetValue(object, ["speedBack"], "8");
	object = llJsonSetValue(object, ["speedFwd"], "8");
	object = llJsonSetValue(object, ["stability"], "5");

	return object;
}

string POSE_FRONT() {
	string object = "";
	object = llJsonSetValue(object, ["animBase"], "animLegPose_groundFront");
	object = llJsonSetValue(object, ["animFail"], "animLegStruggle_groundFront");
	object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_groundFront");
	object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_groundFront");
	object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_groundFront");
	object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_groundFront");
	object = llJsonSetValue(object, ["jumpPower"], "0");
	object = llJsonSetValue(object, ["name"], "Front");
	object = llJsonSetValue(object, ["poseLeft"], "Left");
	object = llJsonSetValue(object, ["poseRight"], "Right");
	object = llJsonSetValue(object, ["poseUp"], "Kneel");
	object = llJsonSetValue(object, ["speedBack"], "8");
	object = llJsonSetValue(object, ["speedFwd"], "8");
	object = llJsonSetValue(object, ["stability"], "5");

	return object;
}

string POSE_LEFT() {
	string object = "";
	object = llJsonSetValue(object, ["animBase"], "animLegPose_groundLeft");
	object = llJsonSetValue(object, ["animFail"], "animLegStruggle_groundLeft");
	object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_groundLeft");
	object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_groundLeft");
	object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_groundLeft");
	object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_groundLeft");
	object = llJsonSetValue(object, ["jumpPower"], "0");
	object = llJsonSetValue(object, ["name"], "Left");
	object = llJsonSetValue(object, ["poseLeft"], "Back");
	object = llJsonSetValue(object, ["poseRight"], "Front");
	object = llJsonSetValue(object, ["poseUp"], "Sit");
	object = llJsonSetValue(object, ["speedBack"], "8");
	object = llJsonSetValue(object, ["speedFwd"], "8");
	object = llJsonSetValue(object, ["stability"], "5");

	return object;
}

string POSE_RIGHT() {
	string object = "";
	object = llJsonSetValue(object, ["animBase"], "animLegPose_groundRight");
	object = llJsonSetValue(object, ["animFail"], "animLegStruggle_groundRight");
	object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_groundRight");
	object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_groundRight");
	object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_groundRight");
	object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_groundRight");
	object = llJsonSetValue(object, ["jumpPower"], "0");
	object = llJsonSetValue(object, ["name"], "Right");
	object = llJsonSetValue(object, ["poseLeft"], "Front");
	object = llJsonSetValue(object, ["poseRight"], "Back");
	object = llJsonSetValue(object, ["poseUp"], "Sit");
	object = llJsonSetValue(object, ["speedBack"], "8");
	object = llJsonSetValue(object, ["speedFwd"], "8");
	object = llJsonSetValue(object, ["stability"], "5");

	return object;
}

string POSE_HOGFRONT() {
	string object = "";
	object = llJsonSetValue(object, ["animBase"], "animLegPose_hogFront");
	object = llJsonSetValue(object, ["animFail"], "animLegStruggle_hogFront");
	object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_hogFront");
	object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_hogFront");
	object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_hogFront");
	object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_hogFront");
	object = llJsonSetValue(object, ["jumpPower"], "0");
	object = llJsonSetValue(object, ["name"], "Front");
//	object = llJsonSetValue(object, ["poseLeft"], "Left");
//	object = llJsonSetValue(object, ["poseRight"], "Right");
	object = llJsonSetValue(object, ["speedBack"], "6");
	object = llJsonSetValue(object, ["speedFwd"], "6");
	object = llJsonSetValue(object, ["stability"], "5");

	return object;
}

init_gui(key prmID, integer prmScreen) {
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

	string btn10 = " "; string btn11 = " ";		 string btn12 = " ";
	string btn7 = " ";	string btn8 = " ";			string btn9 = " ";
	string btn4 = " ";	string btn5 = " ";			string btn6 = " ";
	string btn1 = "<<Back>>";	string btn2 = "<<Done>>";	 string btn3 = " ";

	list mpButtons;
	guiText = " ";

	// GUI: Main
	if (prmScreen == 0) {
		btn3 = "<<Color>>";
		if (_slot) { mpButtons += "Untie"; } 
		else {
			mpButtons += "Ankles";
			mpButtons += "Thighs";
			mpButtons += "Tight";

			// TODO: Only available if arms bound with back, b+sides, uback, or uback+sides
			mpButtons += "Hogtie";
			mpButtons += "Tight Hogtie";
		}
		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}

	// GUI: Colorize
	else if (prmScreen == 100) {
		guiText = "Choose a color for the leg ropes.";
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
add_restraint(string prmName) {
	string restraint;
	string poses;
	restraint = llJsonSetValue(restraint, ["canCut"], "1");
	restraint = llJsonSetValue(restraint, ["canEscape"], "1");
	restraint = llJsonSetValue(restraint, ["canUseItem"], "1");
	restraint = llJsonSetValue(restraint, ["type"], "knot");

	if (prmName == "Ankles") {
		restraint = llJsonSetValue(restraint, ["slot"], "1");
		restraint = llJsonSetValue(restraint, ["difficulty"], "5");
		restraint = llJsonSetValue(restraint, ["tightness"], "5");
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["lrAnkle"]));

		poses = llList2Json(JSON_ARRAY, [POSE_STAND(), POSE_SIT(), POSE_KNEEL(), POSE_BACK(), POSE_FRONT(), POSE_LEFT(), POSE_RIGHT()]);
	} else if (prmName == "Thighs") {
		restraint = llJsonSetValue(restraint, ["slot"], "2");
		restraint = llJsonSetValue(restraint, ["difficulty"], "5");
		restraint = llJsonSetValue(restraint, ["tightness"], "5");
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["lrThigh"]));

		poses = llList2Json(JSON_ARRAY, [POSE_STAND(), POSE_SIT(), POSE_KNEEL(), POSE_BACK(), POSE_FRONT(), POSE_LEFT(), POSE_RIGHT()]);
	} else if (prmName == "Tight") {
		restraint = llJsonSetValue(restraint, ["slot"], "3");
		restraint = llJsonSetValue(restraint, ["difficulty"], "7");
		restraint = llJsonSetValue(restraint, ["tightness"], "15");

		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["lrAnkle", "lrThigh"]));
		poses = llList2Json(JSON_ARRAY, [POSE_STAND(), POSE_SIT(), POSE_KNEEL(), POSE_BACK(), POSE_FRONT(), POSE_LEFT(), POSE_RIGHT()]);
	} else if (prmName == "Hogtie") {
		restraint = llJsonSetValue(restraint, ["slot"], "4");
		restraint = llJsonSetValue(restraint, ["difficulty"], "8");
		restraint = llJsonSetValue(restraint, ["tightness"], "10");
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["lrAnkle"]));

		poses = llList2Json(JSON_ARRAY, [POSE_HOGFRONT()]);
	} else if (prmName == "Tight Hogtie") {
		restraint = llJsonSetValue(restraint, ["slot"], "4");
		restraint = llJsonSetValue(restraint, ["difficulty"], "8");
		restraint = llJsonSetValue(restraint, ["tightness"], "15");
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["lrAnkle", "lrThigh"]));

		poses = llList2Json(JSON_ARRAY, [POSE_HOGFRONT()]);
	}

	string restraintSet;
	restraintSet = llJsonSetValue(restraintSet, ["type"], "leg");
	restraintSet = llJsonSetValue(restraintSet, ["restraint"], restraint);
	simple_request("addRestraint", restraintSet);
	simple_request("setPoses", poses);	// Needs to be separate request - it's just too big!
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
	tmpRequest = llJsonSetValue(tmpRequest, ["attachment"], "leg");
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
		if (llJsonGetValue(value, ["attachment"]) != "leg") { return; }
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
		if (prmChannel == guiChannel) {
			if (prmText == "<<Done>>") { exit("done"); return; }
			else if (prmText == " ") { gui(guiScreen); return;}
			else if (prmText == "<<Back>>") {
				if (guiScreen != 0) { gui(guiScreenLast); return;}

				guiRequest("gui_bind", TRUE, guiUserID, 0);
				return;
			}
			else if (prmText == "Next >>") { multipageIndex ++; gui(guiScreen); return; }
			else if (prmText == "<< Previous") { multipageIndex --; gui(guiScreen); return; }

			if (prmText == "Untie") {
				simple_request("remRestraint", "leg");
				_resumeFunction = "setRestraints";
				return;
			}

			if (guiScreen == 0) {
				if (prmText == "<<Color>>") {
					gui(100);
				} else {
					add_restraint(prmText);
					_resumeFunction = "setRestraints";
					return;
				}
				return;
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
