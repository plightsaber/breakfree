$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.RestraintTools.lslm();
$import Modules.TapeColor.lslm();

integer GUI_HOME = 0;
integer GUI_STYLE = 100;
integer GUI_COLOR = 100;	// Only style option is color

string _resumeFunction;
string _self;

// ===== Initializers =====
init() {
	if (!isSet(_currentColors)) {
		_currentColors = llJsonSetValue(_currentColors, ["cuff"], (string)COLOR_SILVER);
	}
}

init_gui(key prmID, integer prmScreen)
{
	guiUserID = prmID;

	if (guiID) { llListenRemove(guiID); }
	guiChannel = (integer)llFrand(-9998) - 1;
	guiID = llListen(guiChannel, "", guiUserID, "");
	gui(prmScreen);
}

string getSelf()
{
	if (_self != "") return _self;

	_self = llJsonSetValue(_self, ["name"], "Cuff");
	_self = llJsonSetValue(_self, ["part"], "arm");
	_self = llJsonSetValue(_self, ["type"], "cuff");
	return _self;
}

string defineRestraint(string name)
{
	string restraint;

	// Type-specific values
	restraint = llJsonSetValue(restraint, ["name"], name);
	restraint = llJsonSetValue(restraint, ["canCrop"], "1");
	restraint = llJsonSetValue(restraint, ["canCut"], "0");
	restraint = llJsonSetValue(restraint, ["canPick"], "1");
	restraint = llJsonSetValue(restraint, ["canEscape"], "0");
	restraint = llJsonSetValue(restraint, ["canTether"], "0");
	restraint = llJsonSetValue(restraint, ["canUseItem"], "1");
	restraint = llJsonSetValue(restraint, ["type"], "cuff");

	integer complexity = 1;
	integer integrity = 15;
	integer tightness;

	if ("Front" == name) {
		tightness = 3;

		restraint = llJsonSetValue(restraint, ["uid"], "front_cuff");
		restraint = llJsonSetValue(restraint, ["slot"], "wrist");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["frontLoose"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["arm_cuff_wristRight", "arm_cuff_wristLeft", "arm_cuff_frontChain"]));
	} else if ("Back" == name) {
		tightness = 4;

		restraint = llJsonSetValue(restraint, ["uid"], "back_cuff");
		restraint = llJsonSetValue(restraint, ["slot"], "wrist");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["backLoose"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["arm_cuff_wristRight", "arm_cuff_wristLeft", "arm_cuff_backChain"]));
	}

	restraint = llJsonSetValue(restraint, ["complexity"], (string)complexity);
	restraint = llJsonSetValue(restraint, ["integrity"], (string)integrity);
	restraint = llJsonSetValue(restraint, ["tightness"], (string)tightness);

	return restraint;
}

// ===== Main Methods =====
// ===== Color Functions =====

setColorByName(string colorName, string component) {
	integer tmpColorIndex = llListFindList(_colors, [colorName]);
	setColor(llList2Vector(_colorVals, tmpColorIndex), component);
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

// ===== GUI =====
gui(integer screen)
{
	// Reset Busy Clock
	llSetTimerEvent(guiTimeout);

	string btn10 = " ";			string btn11 = " ";			string btn12 = " ";
	string btn7 = " ";			string btn8 = " ";			string btn9 = " ";
	string btn4 = " ";			string btn5 = " ";			string btn6 = " ";
	string btn1 = "<<Back>>";	string btn2 = "<<Done>>";	string btn3 = " ";

	list mpButtons;
	guiText = " ";

	// GUI: Main
	if (screen == GUI_HOME) {
		 btn3 = "<<Style>>";	// Cuffs have no style at the moment

		if (isSet(llJsonGetValue(_restraints, ["slots", "wrist"]))
			|| isSet(llJsonGetValue(_restraints, ["slots", "elbow"]))
			|| isSet(llJsonGetValue(_restraints, ["slots", "torso"]))
		) {
			mpButtons += "Release";
		}

		if (isSet(llJsonGetValue(_restraints, ["slots", "hand"]))) { mpButtons += "Free Hands"; }

		if (!isSet(llJsonGetValue(_restraints, ["slots", "wrist"])) && !isSet(llJsonGetValue(_restraints, ["slots", "torso"]))) {
			if (!isSet(llJsonGetValue(_restraints, ["slots", "elbow"]))) {
				mpButtons += "Front";
			}
			mpButtons += "Back";
		}

		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}
	else if (screen == GUI_COLOR) {
		guiText = "Choose a color for the arm cuffs.";
		mpButtons = multipageGui(_colors, 3, multipageIndex);
	}

	if (screen != guiScreen) { guiScreenLast = guiScreen; }
	guiScreen = screen;

	guiButtons = [btn1, btn2, btn3];
	if (btn4+btn5+btn6 != "   ") { guiButtons += [btn4, btn5, btn6]; }
	if (btn7+btn8+btn9 != "   ") { guiButtons += [btn7, btn8, btn9]; }
	if (btn10+btn11+btn12 != "   ") { guiButtons += [btn10, btn11, btn12]; }

	// Load MP Buttons - hopefully the lengths were configured correctly!
	if (llGetListLength(mpButtons)) { guiButtons += mpButtons; }

	llDialog(guiUserID, guiText, guiButtons, guiChannel);
}

// ===== Events =====
executeFunction(string function, string json)
{
	string value = llJsonGetValue(json, ["value"]);

	if ("getAvailableRestraints" == function) {
		simpleRequest("addAvailableRestraint", getSelf());
		return;
	}
	else if ("requestStyle" == function) {
		if (llJsonGetValue(value, ["attachment"]) != llJsonGetValue(getSelf(), ["part"])) { return; }
		if (llJsonGetValue(value, ["name"]) != "cuff") { return; }
		string component = llJsonGetValue(value, ["component"]);
		if ("" == component) { component = "cuff"; }

		setColor((vector)llJsonGetValue(_currentColors, [component]), component);
	}
	else if ("setRestraints" == function) {
		_restraints = value;
		return;
	}
	else if ("gui_arm_cuff" == function) {
		key userkey = (key)llJsonGetValue(json, ["userkey"]);
		integer screen = 0;
		if ((integer)llJsonGetValue(json, ["restorescreen"]) && guiScreenLast) { screen = guiScreenLast;}
		init_gui(userkey, screen);
	}
	else if ("resetGUI" == function) {
		exit("");
	}
}

default {
	state_entry()
	{
		init();
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
		if (channel = guiChannel) {
			if (message == "<<Done>>") { exit("done"); return; }
			else if (message == " ") { gui(guiScreen); return; }
			else if (message == "<<Back>>") {
				if (guiScreen != GUI_HOME) { gui(guiScreenLast); return;}
				guiRequest("gui_bind", TRUE, guiUserID, 0);
				return;
			}
			else if (message == "Next >>") { multipageIndex ++; gui(guiScreen); return; }
			else if (message == "<< Previous") { multipageIndex --; gui(guiScreen); return; }

			if (message == "Release") {
				simpleRequest("remRestraint", llJsonGetValue(getSelf(), ["part"]));
				_resumeFunction = "setRestraints";
				return;
			} else if (message == "Free Hands") {
				simpleRequest("rmSlot", "hand");
				_resumeFunction = "setRestraints";
				return;
			}

			if (guiScreen == GUI_HOME) {
				if (message == "<<Style>>") {
					gui(GUI_STYLE);
					return;
				} else {
					string restraintSet;
					restraintSet = llJsonSetValue(restraintSet, ["type"], llJsonGetValue(getSelf(), ["part"]));
					restraintSet = llJsonSetValue(restraintSet, ["restraint"], defineRestraint(message));
					simpleRequest("addRestraint", restraintSet);
					_resumeFunction = "setRestraints";
					return;
				}
			} else if (guiScreen == GUI_COLOR) {
				setColorByName(message, "cuff");
				gui(guiScreen);
				return;
			}
		}
	}

	timer()
	{
		exit("timeout");
	}
}
