$import Modules.ArmTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.RopeColor.lslm();
$import Modules.UserLib.lslm();

// General Settings
string gender = "female";
integer _rpMode = FALSE;

// GUI screens
integer GUI_HOME = 0;
integer GUI_STYLE = 100;
integer GUI_COLOR = 101;
integer GUI_TEXTURE = 111;

// Status
string armsBound = "free";  // 0: FREE; 1: BOUND; 2: HELPLESS

string _villain;

string _currentRestraints;
string _restraintLib;

string getSelf() {
	if (_self != "") return _self;

	_self = llJsonSetValue(_self, ["name"], "Rope");
	_self = llJsonSetValue(_self, ["part"], "arm");
	_self = llJsonSetValue(_self, ["type"], "rope");
	_self = llJsonSetValue(_self, ["hasColor"], "1");
	return _self;
}

string getCurrentRestraints() {
	if (_currentRestraints) {
		return _currentRestraints;
	}

	_currentRestraints = llJsonSetValue(_currentRestraints, ["wrist"], JSON_NULL);
	_currentRestraints = llJsonSetValue(_currentRestraints, ["elbow"], JSON_NULL);
	_currentRestraints = llJsonSetValue(_currentRestraints, ["torso"], JSON_NULL);
	return _currentRestraints;
}

// ===== Initializers =====
init() {
	if (!isSet(_currentColors)) {
		_currentColors = llJsonSetValue(_currentColors, ["rope"], (string)COLOR_WHITE);
	}
	if (!isSet(_currentTextures)) {
		_currentTextures = llJsonSetValue(_currentTextures, ["rope"], "ropeBraid");
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
	if (prmScreen == 0) {
		btn3 = "<<Style>>";

		if (llJsonGetValue(getCurrentRestraints(), ["wrist"]) != JSON_NULL
			|| llJsonGetValue(_currentRestraints, ["elbow"]) != JSON_NULL
			|| llJsonGetValue(_currentRestraints, ["torso"]) != JSON_NULL
		) {
			mpButtons += "Untie";
		}

		if (llJsonGetValue(_currentRestraints, ["wrist"]) == JSON_NULL && llJsonGetValue(_currentRestraints, ["torso"]) == JSON_NULL) {
			if (llJsonGetValue(_currentRestraints, ["elbow"]) == JSON_NULL) { mpButtons += "Front"; }
			mpButtons += "Back";
		}

		if (llJsonGetValue(_currentRestraints, ["elbow"]) == JSON_NULL
			&& llJsonGetValue(_currentRestraints, ["torso"]) == JSON_NULL
			&& (llSubStringIndex(llJsonGetValue(_currentRestraints, ["wrist"]), "back") != -1 && "backCuff" != llJsonGetValue(_currentRestraints, ["wrist"]))
		) {
			mpButtons += "Elbow";
		}

		if (llJsonGetValue(_currentRestraints, ["torso"]) == JSON_NULL && llJsonGetValue(_currentRestraints, ["elbow"]) == JSON_NULL && llJsonGetValue(_currentRestraints, ["wrist"]) == JSON_NULL) {
			mpButtons += "Sides";
		} else if (llJsonGetValue(_currentRestraints, ["torso"]) == JSON_NULL) {
			mpButtons += "Harness";
		}

		if ((hasFeat(_villain, "Rigger") || _rpMode)
			&& llJsonGetValue(_currentRestraints, ["elbow"]) == JSON_NULL
			&& llJsonGetValue(_currentRestraints, ["torso"]) == JSON_NULL
			&& llJsonGetValue(_currentRestraints, ["wrist"]) == JSON_NULL
		) {
			mpButtons += "Box";
		}

		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}

	// GUI: Colorize
	else if (prmScreen == GUI_STYLE) {
		guiText = "Choose what you want to style.";
		mpButtons = multipageGui(["Color", "Texture"], 2, multipageIndex);
	}
	else if (prmScreen == GUI_COLOR) {
		guiText = "Choose a color the ropes.";
		mpButtons = multipageGui(_colors, 3, multipageIndex);
	}
	else if (prmScreen == GUI_TEXTURE) {
		guiText = "Choose a texture for the ropes.";
		mpButtons = multipageGui(_textures, 3, multipageIndex);
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
	restraint = llJsonSetValue(restraint, ["canCut"], "1");
	restraint = llJsonSetValue(restraint, ["canEscape"], "1");
	restraint = llJsonSetValue(restraint, ["canTether"], "1");
	restraint = llJsonSetValue(restraint, ["canUseItem"], "1");
	restraint = llJsonSetValue(restraint, ["type"], "rope");

	integer complexity;
	integer integrity;
	integer tightness;

	if (prmName == "Sides") {
		complexity = 2;
		integrity = 5;
		tightness = 5;

		restraint = llJsonSetValue(restraint, ["uid"], "sides_rope");
		restraint = llJsonSetValue(restraint, ["slot"], "torso");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["sides"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["arm_rope_sides"]));
	} else if (prmName == "Front") {
		complexity = 3;
		integrity = 5;
		tightness = 4;

		restraint = llJsonSetValue(restraint, ["uid"], "front_rope");
		restraint = llJsonSetValue(restraint, ["slot"], "wrist");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["front"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["arm_rope_front_wrist"]));
	} else if (prmName == "Back") {
		complexity = 3;
		integrity = 5;
		tightness = 5;

		string pose = "back";
		list liAttachments = ["arm_rope_back_wrist"];
		if (llJsonGetValue(getCurrentRestraints(), ["elbow"]) != JSON_NULL) {
			pose = "backTight";
			liAttachments = ["arm_rope_backTight_wrist"];
		}

		restraint = llJsonSetValue(restraint, ["uid"], "back_rope");
		restraint = llJsonSetValue(restraint, ["slot"], "wrist");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, [pose]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, liAttachments));
	} else if (prmName == "Elbow") {
		complexity = 3;
		integrity = 5;
		tightness = 8;

		restraint = llJsonSetValue(restraint, ["uid"], "elbow_rope");
		restraint = llJsonSetValue(restraint, ["slot"], "elbow");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["backTight"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["arm_rope_backTight_elbow"]));
	} else if (prmName == "Harness") {
		complexity = 3;
		integrity = 5;
		tightness = 6;

		list liAttachments;
		list liPoses;
		string wristRestraintId = llJsonGetValue(getCurrentRestraints(), ["wrist"]);
		if (llJsonGetValue(getCurrentRestraints(), ["elbow"]) != JSON_NULL
			|| wristRestraintId == "backCuff"
			|| wristRestraintId == "backZip"
		) {
			liAttachments += "arm_rope_backTight_harness";
		} else if (llSubStringIndex(wristRestraintId, "back") != -1) {
			liAttachments += "arm_rope_back_harness";
		} else if (llSubStringIndex(wristRestraintId, "front") != -1) {
			liAttachments += "arm_rope_front_harness";
		}

		restraint = llJsonSetValue(restraint, ["uid"], "harness_rope");
		restraint = llJsonSetValue(restraint, ["slot"], "torso");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, liPoses));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, liAttachments));
	} else if (prmName == "Box") {
		complexity = 5;
		integrity = 10;
		tightness = 20;

		restraint = llJsonSetValue(restraint, ["uid"], "box_rope");
		restraint = llJsonSetValue(restraint, ["slot"], "torso");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["box"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["arm_rope_box"]));
	}

	if (hasFeat(_villain, "Rigger")) { integrity = integrity+5; }
	if (hasFeat(_villain, "Rigger+")) { complexity++; }

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
	else if (prmFunction == "requestStyle") {
	  	if (llJsonGetValue(value, ["attachment"]) != llJsonGetValue(getSelf(), ["part"])) { return; }
	  	if (llJsonGetValue(value, ["name"]) != "rope") { return; }
		string component = llJsonGetValue(value, ["component"]);
		if ("" == component) { component = "rope"; }

		setColor((vector)llJsonGetValue(_currentColors, [component]), component);
		setTexture(llJsonGetValue(_currentTextures, [component]), component);
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
	state_entry() { init(); }

	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel = guiChannel) {
			if (prmText == "<<Done>>") { exit("done"); return; }
			else if (prmText == " ") { gui(guiScreen); return; }
			else if (prmText == "<<Back>>") {
				if (guiScreen == GUI_STYLE) { gui(0); return; }
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
			} else if (guiScreen == GUI_STYLE) {
				if ("Color" == prmText) { gui(GUI_COLOR); }
				else if ("Texture" == prmText) { gui(GUI_TEXTURE); }
			} else if (guiScreen == GUI_COLOR) {
				setColorByName(prmText, "rope");
			} else if (guiScreen == GUI_TEXTURE) {
				setTextureByName(prmText, "rope");
			}

			gui(guiScreen);
			return;
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