$import Modules.GeneralTools.lslm();
$import Modules.GagTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.UserLib.lslm();

// ===== Variables =====
// General Settings
string _gender = "female";
integer _rpMode = FALSE;

integer GUI_HOME = 0;
integer GUI_STYLE = 100;
integer GUI_COLOR_STUFF = 101;
integer GUI_COLOR_CLOTH = 102;
integer GUI_TEXTURE = 111;

string _villain;

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

string _currentColors;
list _colors = ["White", "Black", "Purple", "Red", "Blue", "Green", "Pink", "Yellow", "Brown"];
list _colorVals = [COLOR_WHITE, COLOR_BLACK, COLOR_PURPLE, COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_BROWN];

string _currentTextures;
list _textures = ["Smooth", "Linen", "Bandana"];
list _textureVals = [TEXTURE_BLANK, "linen", "bandana"];

string _restraintLib;

string getSelf() {
	if (_self != "") return _self;

	_self = llJsonSetValue(_self, ["name"], "Cloth");
	_self = llJsonSetValue(_self, ["part"], "gag");
	_self = llJsonSetValue(_self, ["type"], "cloth");
	_self = llJsonSetValue(_self, ["hasColor"], "1");
	return _self;
}

// ===== Initializer =====
init() {
	if (!isSet(_currentColors)) {
		_currentColors = llJsonSetValue(_currentColors, ["cloth"], (string)COLOR_WHITE);
		_currentColors = llJsonSetValue(_currentColors, ["stuff"], (string)COLOR_WHITE);
	}

	if (!isSet(_currentTextures)) {
		_currentTextures = llJsonSetValue(_currentTextures, ["cloth"], TEXTURE_BLANK);
		_currentTextures = llJsonSetValue(_currentTextures, ["stuff"], "linen");
	}
}

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
			mpButtons += "Cleave";
		}

		if (llJsonGetValue(_currentRestraints, ["gag4"]) == JSON_NULL
		) {
			mpButtons += "OTN";
		}

		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}
	// GUI: Colorize
	else if (prmScreen == GUI_STYLE) {
		guiText = "Choose what you want to style.";
		mpButtons = multipageGui(["Cloth", "Stuffing", "Texture"], 2, multipageIndex);
	}
	else if (prmScreen == GUI_COLOR_CLOTH) {
		guiText = "Choose a color for the cloth.";
		mpButtons = multipageGui(_colors, 3, multipageIndex);
	}
	else if (prmScreen == GUI_COLOR_STUFF) {
		guiText = "Choose a color for the stuffing.";
		mpButtons = multipageGui(_colors, 3, multipageIndex);
	}
	else if (prmScreen == GUI_TEXTURE) {
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
	gag = llJsonSetValue(gag, ["type"], llJsonGetValue(getSelf(), ["type"]));
	gag = llJsonSetValue(gag, ["canEscape"], "1");

	integer complexity;
	integer integrity;
	integer tightness;

	if (prmName == "Stuff") {
		complexity = 1;
		integrity = 2;
		tightness = 3;

		gag = llJsonSetValue(gag, ["uid"], "stuff_cloth");
		gag = llJsonSetValue(gag, ["slot"], "gag1");
		gag = llJsonSetValue(gag, ["canCut"], "0");
		gag = llJsonSetValue(gag, ["mouthOpen"], "1");
		gag = llJsonSetValue(gag, ["attachments", JSON_APPEND], "gag_cloth_stuff");
	} else if (prmName == "Cleave") {
		complexity = 3;
		integrity = 5;
		tightness = 5;

		list attachments;
		if (_mouthOpen) { attachments += ["gag_cloth_cleaveStuff"]; }
		else { attachments += ["gag_cloth_cleave"]; }

		gag = llJsonSetValue(gag, ["uid"], "cleave_cloth");
		gag = llJsonSetValue(gag, ["speechGarbled"], "1");
		gag = llJsonSetValue(gag, ["slot"], "gag2");
		gag = llJsonSetValue(gag, ["canCut"], "1");
		gag = llJsonSetValue(gag, ["attachments"], llList2Json(JSON_ARRAY, attachments));
	} else if (prmName == "OTN") {
		complexity = 2;
		integrity = 5;
		tightness = 5;

		gag = llJsonSetValue(gag, ["uid"], "otn_cloth");
		gag = llJsonSetValue(gag, ["speechMuffled"], "1");
		gag = llJsonSetValue(gag, ["slot"], "gag4");
		gag = llJsonSetValue(gag, ["canCut"], "1");
		gag = llJsonSetValue(gag, ["attachments", JSON_APPEND], "gag_cloth_OTN");
		gag = llJsonSetValue(gag, ["preventAttach", JSON_APPEND], "gag_cloth_cleave");
		gag = llJsonSetValue(gag, ["preventAttach", JSON_APPEND], "gag_cloth_cleaveStuff");
		gag = llJsonSetValue(gag, ["preventAttach", JSON_APPEND], "gag_device_ball");
	}

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
	vector color = prmColor;
	_currentColors = llJsonSetValue(_currentColors, [prmComponent], (string)color);

	string tmpRequest = "";
	tmpRequest = llJsonSetValue(tmpRequest, ["color"], (string)color);
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
	_currentTextures = llJsonSetValue(_currentTextures, [prmComponent], prmTexture);

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
	else if (prmFunction == "setRPMode") { _rpMode = (integer)value; }
	else if (prmFunction == "setVillain") { _villain = value; }
	else if (prmFunction == "setColor") {
		if (llJsonGetValue(value, ["attachment"]) != "gag") { return; }
		if (!isSet(llJsonGetValue(value, ["component"]))) { return; }
		_currentColors = llJsonSetValue(_currentColors, [llJsonGetValue(value, ["component"])], llJsonGetValue(value, ["color"]));
	}
	else if (prmFunction == "setTexture") {
		if (llJsonGetValue(value, ["attachment"]) != "gag") { return; }
		if (!isSet(llJsonGetValue(value, ["component"]))) { return; }
		_currentTextures = llJsonSetValue(_currentTextures, [llJsonGetValue(value, ["component"])], llJsonGetValue(value, ["texture"]));
	}
	else if (prmFunction == "requestStyle") {
		if (llJsonGetValue(value, ["attachment"]) != "gag") { return; }
		if (llJsonGetValue(value, ["name"]) != "cloth") { return; }
		string component = llJsonGetValue(value, ["component"]);
		if ("" == component) { component = "cloth"; }

		setColor((vector)llJsonGetValue(_currentColors, [component]), component);
		setTexture(llJsonGetValue(_currentTextures, [component]), component);
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
	state_entry() { init(); }

	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel = guiChannel) {
			if (prmText == "<<Done>>") { exit("done"); return; }
			else if (prmText == " ") { gui(guiScreen); return; }
			else if (prmText == "<<Back>>") {
				if (guiScreen == 100) { gui(GUI_HOME); return; }
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
					gui(GUI_STYLE);
				} else {
					string restraint;
					restraint = llJsonSetValue(restraint, ["type"], llJsonGetValue(getSelf(), ["part"]));
					restraint = llJsonSetValue(restraint, ["restraint"], defineRestraint(prmText));
					simpleRequest("addRestraint", restraint);
					_resumeFunction = "setRestraints";
				}
				return;
			} else if (guiScreen == GUI_STYLE) {
				if ("Cloth" == prmText) { gui(GUI_COLOR_CLOTH); }
				else if ("Stuffing" == prmText) { gui(GUI_COLOR_STUFF); }
				else if ("Texture" == prmText) { gui(GUI_TEXTURE); }
			} else if (guiScreen == GUI_COLOR_CLOTH) {
				setColorByName(prmText, "cloth");
			} else if (guiScreen == GUI_COLOR_STUFF) {
				setColorByName(prmText, "stuff");
			} else if (guiScreen == GUI_TEXTURE) {
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
