$import Modules.ArmTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.RopeColor.lslm();

// General Settings
string gender = "female";

// Status
string armsBound = "free";  // 0: FREE; 1: BOUND; 2: HELPLESS

string _currentRestraints;
string _restraintLib;

string getSelf() {
	if (_self != "") return _self;

	_self = llJsonSetValue(_self, ["name"], "Rope");
	_self = llJsonSetValue(_self, ["part"], "arm");
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
			&& (llJsonGetValue(_currentRestraints, ["wrist"]) == JSON_NULL || llJsonGetValue(_currentRestraints, ["wrist"]) == "back")
		) {
			mpButtons += "Elbow";
		}

		if (llJsonGetValue(_currentRestraints, ["torso"]) == JSON_NULL && llJsonGetValue(_currentRestraints, ["elbow"]) == JSON_NULL && llJsonGetValue(_currentRestraints, ["wrist"]) == JSON_NULL) {
			mpButtons += "Sides";
		} else if (llJsonGetValue(_currentRestraints, ["torso"]) == JSON_NULL) {
			mpButtons += "Harness";
		}

		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}

	// GUI: Colorize
	else if (prmScreen == 100) {
		guiText = "Choose what you want to style.";
		mpButtons = multipageGui(["Color", "Texture"], 2, multipageIndex);
	}
	else if (prmScreen == 101) {
		guiText = "Choose a color the ropes.";
		mpButtons = multipageGui(_colors, 3, multipageIndex);
	}
	else if (prmScreen == 111) {
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
	restraint = llJsonSetValue(_self, ["canCut"], "1");
	restraint = llJsonSetValue(restraint, ["canEscape"], "1");
	restraint = llJsonSetValue(restraint, ["canTether"], "0");
	restraint = llJsonSetValue(restraint, ["canUseItem"], "1");
	restraint = llJsonSetValue(restraint, ["type"], "rope");

	if (prmName == "Sides") {
		restraint = llJsonSetValue(restraint, ["uid"], "sides");
		restraint = llJsonSetValue(restraint, ["slot"], "torso");
		restraint = llJsonSetValue(restraint, ["complexity"], "2");
		restraint = llJsonSetValue(restraint, ["integrity"], "5");
		restraint = llJsonSetValue(restraint, ["tightness"], "5");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["sides"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["armRope_sides"]));
	} else if (prmName == "Front") {
		restraint = llJsonSetValue(restraint, ["uid"], "front");
		restraint = llJsonSetValue(restraint, ["slot"], "wrist");
		restraint = llJsonSetValue(restraint, ["complexity"], "3");
		restraint = llJsonSetValue(restraint, ["integrity"], "5");
		restraint = llJsonSetValue(restraint, ["tightness"], "4");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["front"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["armRope_front_wrist"]));
	} else if (prmName == "Back") {
		string pose = "back";
		list liAttachments = ["armRope_back_wrist"];
		if (llJsonGetValue(getCurrentRestraints(), ["elbow"]) != JSON_NULL) {
			pose = "backTight";
			liAttachments = ["armRope_backTight_wrist"];
		}

		restraint = llJsonSetValue(restraint, ["uid"], "back");
		restraint = llJsonSetValue(restraint, ["slot"], "wrist");
		restraint = llJsonSetValue(restraint, ["complexity"], "3");
		restraint = llJsonSetValue(restraint, ["integrity"], "5");
		restraint = llJsonSetValue(restraint, ["tightness"], "5");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, [pose]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, liAttachments));
	} else if (prmName == "Elbow") {
		list liAttachments = ["armRope_backTight_elbow"];
		if (llJsonGetValue(getCurrentRestraints(), ["wrist"]) == "back") {
			liAttachments += "armRope_backTight_wrist";
		}

		restraint = llJsonSetValue(restraint, ["uid"], "elbow");
		restraint = llJsonSetValue(restraint, ["slot"], "elbow");
		restraint = llJsonSetValue(restraint, ["complexity"], "3");
		restraint = llJsonSetValue(restraint, ["integrity"], "5");
		restraint = llJsonSetValue(restraint, ["tightness"], "8");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["backTight"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, liAttachments));
		restraint = llJsonSetValue(restraint, ["preventAttach"], llList2Json(JSON_ARRAY, ["armRope_back_wrist", "armTape_back_wrist"]));
	} else if (prmName == "Harness") {
		list liAttachments;
		if (llJsonGetValue(getCurrentRestraints(), ["elbow"]) != JSON_NULL) {
			liAttachments += "armRope_backTight_harness";
		} else if (llJsonGetValue(getCurrentRestraints(), ["wrist"]) == "back") {
			liAttachments += "armRope_back_harness";
		} else if (llJsonGetValue(getCurrentRestraints(), ["wrist"]) == "front") {
			liAttachments += "armRope_front_harness";
		}

		restraint = llJsonSetValue(restraint, ["uid"], "harness");
		restraint = llJsonSetValue(restraint, ["slot"], "torso");
		restraint = llJsonSetValue(restraint, ["complexity"], "3");
		restraint = llJsonSetValue(restraint, ["integrity"], "5");
		restraint = llJsonSetValue(restraint, ["tightness"], "6");
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, liAttachments));
	} else if (prmName == "Box") {
		restraint = llJsonSetValue(restraint, ["uid"], "box");
		restraint = llJsonSetValue(restraint, ["slot"], "torso");
		restraint = llJsonSetValue(restraint, ["complexity"], "5");
		restraint = llJsonSetValue(restraint, ["integrity"], "10");
		restraint = llJsonSetValue(restraint, ["tightness"], "20");
		restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, ["box"]));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["armRope_box"]));
	}

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

setColor(vector prmColor, string prmComponent) {
	_color = prmColor;

	string tmpRequest = "";
	tmpRequest = llJsonSetValue(tmpRequest, ["color"], (string)_color);
	tmpRequest = llJsonSetValue(tmpRequest, ["attachment"], llJsonGetValue(getSelf(), ["part"]));
	tmpRequest = llJsonSetValue(tmpRequest, ["component"], prmComponent);
	tmpRequest = llJsonSetValue(tmpRequest, ["userKey"], (string)llGetOwner());

	simpleAttachedRequest("setColor", tmpRequest);
	simpleRequest("setColor", tmpRequest);
}

setTextureByName(string prmTextureName, string prmComponent) {
	integer tmpTextureIndex = llListFindList(_textures, [prmTextureName]);
	setTexture(llList2String(_textureVals, tmpTextureIndex), prmComponent);
}

setTexture(string prmTexture, string prmComponent) {
	string tmpRequest = "";
	tmpRequest = llJsonSetValue(tmpRequest, ["attachment"], llJsonGetValue(getSelf(), ["part"]));
	tmpRequest = llJsonSetValue(tmpRequest, ["component"], prmComponent);
	tmpRequest = llJsonSetValue(tmpRequest, ["texture"], prmTexture);
	tmpRequest = llJsonSetValue(tmpRequest, ["userKey"], (string)llGetOwner());

	simpleAttachedRequest("setTexture", tmpRequest);
	simpleRequest("setTexture", tmpRequest);
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
    else if (prmFunction == "requestColor") {
      	if (llJsonGetValue(value, ["attachment"]) != llJsonGetValue(getSelf(), ["part"])) { return; }
      	if (llJsonGetValue(value, ["name"]) != "rope") { return; }
		string component = llJsonGetValue(value, ["component"]);
		if ("" == component) { component = "rope"; }
		setColor(_color, component);
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
				if (guiScreen == 100) { gui(0); return; }
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
				if ("Color" == prmText) { gui(101); }
				else if ("Texture" == prmText) { gui(111); }
			} else if (guiScreen == 101) {
				setColorByName(prmText, "rope");
			} else if (guiScreen == 111) {
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