$import Modules.GeneralTools.lslm();
$import Modules.GagTools.lslm();
$import Modules.GuiTools.lslm();

// ===== Variables =====
// General Settings
string _gender = "female";

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

vector _color = COLOR_WHITE;
list _colors = ["White", "Black", "Purple", "Red", "Blue", "Green", "Pink", "Yellow", "Brown"];
list _colorVals = [COLOR_WHITE, COLOR_BLACK, COLOR_PURPLE, COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_BROWN];

list _textures = ["Smooth", "Linen", "Bandana"];
list _textureVals = [TEXTURE_BLANK, "linen", "bandana"];

string _restraintLib;

string getSelf() {
	if (_self != "") return _self;

	_self = llJsonSetValue(_self, ["name"], "Cloth");
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

	string btn10 = " "; string btn11 = " ";		 string btn12 = " ";
	string btn7 = " ";	string btn8 = " ";			string btn9 = " ";
	string btn4 = " ";	string btn5 = " ";			string btn6 = " ";
	string btn1 = "<<Back>>";	string btn2 = "<<Done>>";	 string btn3 = " ";

	list mpButtons;
	guiText = " ";

	// GUI: Main
	if (prmScreen == 0) {
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
			mpButtons += "Cleave";
		}

		if (llJsonGetValue(_currentRestraints, ["gag4"]) == JSON_NULL
		) {
			mpButtons += "OTN";
		}

		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}
	// GUI: Colorize
	else if (prmScreen == 100) {
		guiText = "Choose what you want to style.";
		mpButtons = multipageGui(["Cloth", "Stuffing", "Texture"], 2, multipageIndex);
	}
	else if (prmScreen == 101) {
		guiText = "Choose a color for the cloth.";
		mpButtons = multipageGui(_colors, 3, multipageIndex);
	}
	else if (prmScreen == 102) {
		guiText = "Choose a color for the stuffing.";
		mpButtons = multipageGui(_colors, 3, multipageIndex);
	}
	else if (prmScreen == 111) {
		guiText = "Choose a texture for the gag.";
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
	string gag;

	// Type-specific values
	gag = llJsonSetValue(gag, ["name"], prmName);
	gag = llJsonSetValue(gag, ["type"], "knot");
	gag = llJsonSetValue(gag, ["canEscape"], "1");

	if (prmName == "Stuff") {
		gag = llJsonSetValue(gag, ["uid"], "stuff");
		gag = llJsonSetValue(gag, ["slot"], "gag1");
		gag = llJsonSetValue(gag, ["canCut"], "0");
		gag = llJsonSetValue(gag, ["mouthOpen"], "1");

		gag = llJsonSetValue(gag, ["complexity"], "3");
		gag = llJsonSetValue(gag, ["integrity"], "2");
		gag = llJsonSetValue(gag, ["tightness"], "1");
		gag = llJsonSetValue(gag, ["attachments", JSON_APPEND], "gStuff");
	} else if (prmName == "Cleave") {
		list attachments;
		if (_mouthOpen) { attachments += ["gCleaveStuff"]; }
		else { attachments += ["gCleave"]; }

		gag = llJsonSetValue(gag, ["uid"], "cleave");
		gag = llJsonSetValue(gag, ["speechGarbled"], "1");
		gag = llJsonSetValue(gag, ["slot"], "gag2");
		gag = llJsonSetValue(gag, ["canCut"], "1");
		gag = llJsonSetValue(gag, ["complexity"], "3");
		gag = llJsonSetValue(gag, ["integrity"], "5");
		gag = llJsonSetValue(gag, ["tightness"], "5");
		gag = llJsonSetValue(gag, ["attachments"], llList2Json(JSON_ARRAY, attachments));
	} else if (prmName == "OTN") {
		gag = llJsonSetValue(gag, ["uid"], "otn");
		gag = llJsonSetValue(gag, ["speechMuffled"], "1");
		gag = llJsonSetValue(gag, ["slot"], "gag4");
		gag = llJsonSetValue(gag, ["canCut"], "1");
		gag = llJsonSetValue(gag, ["complexity"], "2");
		gag = llJsonSetValue(gag, ["integrity"], "5");
		gag = llJsonSetValue(gag, ["tightness"], "5");
		gag = llJsonSetValue(gag, ["attachments", JSON_APPEND], "gOTN");
		gag = llJsonSetValue(gag, ["preventAttach", JSON_APPEND], "gCleave");
		gag = llJsonSetValue(gag, ["preventAttach", JSON_APPEND], "gCleaveStuff");
		gag = llJsonSetValue(gag, ["preventAttach", JSON_APPEND], "gBall");
	}

	return gag;
}

// Color Functions
setColorByName(string prmColorName, string prmComponent) {
	integer tmpColorIndex = llListFindList(_colors, [prmColorName]);
	setColor(llList2Vector(_colorVals, tmpColorIndex), prmComponent);
}

setColor(vector prmColor, string prmComponent) {
	_color = prmColor;

	string tmpRequest = "";
	tmpRequest = llJsonSetValue(tmpRequest, ["color"], (string)_color);
	tmpRequest = llJsonSetValue(tmpRequest, ["attachment"], "gag");
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
	tmpRequest = llJsonSetValue(tmpRequest, ["attachment"], "gag");
	tmpRequest = llJsonSetValue(tmpRequest, ["component"], prmComponent);
	tmpRequest = llJsonSetValue(tmpRequest, ["texture"], prmTexture);
	tmpRequest = llJsonSetValue(tmpRequest, ["userKey"], (string)llGetOwner());

	simpleAttachedRequest("setTexture", tmpRequest);
	simpleRequest("setTexture", tmpRequest);
}

// ===== Sets =====
setGender(string prmGender) {
	_gender = prmGender;
}

// ===== Event Controls =====
execute_function(string prmFunction, string prmJson) {
	string value = llJsonGetValue(prmJson, ["value"]);
	if (JSON_INVALID == value) {
		//return;		// TODO: Rewrite all linked calls to send value in Json
	}

	if (prmFunction == "setGender") { setGender(value); }
    else if (prmFunction == "setRestraints") {
    	_currentRestraints = llJsonGetValue(value, ["slots"]);
    	_mouthOpen = llJsonGetValue(value, ["mouthOpen"]) == "1";
	}
	else if (prmFunction == "getAvailableRestraints") { sendAvailabilityInfo(); }
	else if (prmFunction == "requestColor") {
		if (llJsonGetValue(value, ["attachment"]) != "gag") { return; }
		if (llJsonGetValue(value, ["name"]) != "cloth") { return; }
		string component = llJsonGetValue(value, ["component"]);
		if ("" == component) { component = "cloth"; }
		setColor(_color, component);
	}
	else if (prmFunction == "gui_gag_cloth") {
		key userkey = (key)llJsonGetValue(prmJson, ["userkey"]);
		integer screen = 0;
		if ((integer)llJsonGetValue(prmJson, ["restorescreen"]) && guiScreenLast) { screen = guiScreenLast;}
		initGUI(userkey, screen);
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

			if (guiScreen == 0) {
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
			} else if (guiScreen == 100) {
				if ("Cloth" == prmText) { gui(101); }
				else if ("Stuffing" == prmText) { gui(102); }
				else if ("Texture" == prmText) { gui(111); }
			} else if (guiScreen == 101) {
				setColorByName(prmText, "cloth");
			} else if (guiScreen == 102) {
				setColorByName(prmText, "stuffing");
			} else if (guiScreen == 111) {
				setTextureByName(prmText, "cloth");
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
			initGUI(guiUserID, guiScreen);
		}
	}

	timer() {
		exit("timeout");
	}
}
