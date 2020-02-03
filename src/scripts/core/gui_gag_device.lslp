$import Modules.GeneralTools.lslm();
$import Modules.GagTools.lslm();
$import Modules.GuiTools.lslm();

// ===== Variables =====
// General Settings
string gender = "female";

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

vector color = COLOR_RED;
list colors = ["White", "Black", "Purple", "Red", "Blue", "Green", "Pink", "Yellow", "Brown"];
list colorVals = [COLOR_WHITE, COLOR_BLACK, COLOR_PURPLE, COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_BROWN];

//list textures = ["Smooth", "Duct"];
//list textureVals = [TEXTURE_BLANK, "duct"];

string getSelf() {
	if (_self != "") return _self;

	_self = llJsonSetValue(_self, ["name"], "Device");
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

	string btn10 = " ";			string btn11 = " ";			string btn12 = " ";
	string btn7 = " ";			string btn8 = " ";			string btn9 = " ";
	string btn4 = " ";			string btn5 = " ";			string btn6 = " ";
	string btn1 = "<<Back>>";	string btn2 = "<<Done>>";	string btn3 = " ";

	list mpButtons;
	guiText = " ";

	// GUI: Main
	if (prmScreen == 0) {
		btn3 = "<<Style>>";
		if (_slot) { mpButtons += "Ungag"; }
		else { mpButtons += "Ballgag"; }
		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}
	// GUI: Colorize
	else if (prmScreen == 100) {
		guiText = "Choose what you want to style.";
		mpButtons = multipageGui(["Strap", "Ball"], 2, multipageIndex);
	}
	else if (prmScreen == 101) {
		guiText = "Choose a color for the straps.";
		mpButtons = multipageGui(colors, 3, multipageIndex);
	}
	else if (prmScreen == 102) {
		guiText = "Choose a color for the ball.";
		mpButtons = multipageGui(colors, 3, multipageIndex);
	}
	/*
	else if (prmScreen == 111) {
		guiText = "Choose a texture for the gag.";
		mpButtons = multipageGui(textures, 3, multipageIndex);
	}
	*/

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
addGag(string prmName) {
	string gag;
	gag = llJsonSetValue(gag, ["name"], prmName);
	if (prmName == "Ballgag") {
		gag = llJsonSetValue(gag, ["garble", "garbled"], "1");
		gag = llJsonSetValue(gag, ["slot"], "1");
		gag = llJsonSetValue(gag, ["canCut"], "0");
		gag = llJsonSetValue(gag, ["canEscape"], "0");
		gag = llJsonSetValue(gag, ["mouthOpen"], "1");
		gag = llJsonSetValue(gag, ["type"], "strap");
		gag = llJsonSetValue(gag, ["difficulty"], "24");
		gag = llJsonSetValue(gag, ["tightness"], "2");
		gag = llJsonSetValue(gag, ["attachments", JSON_APPEND], "gBall");
	}

	string restraint;
	restraint = llJsonSetValue(restraint, ["type"], "gag");
	restraint = llJsonSetValue(restraint, ["restraint"], gag);
	simple_request("addRestraint", restraint);
}

// Color Functions
setColorByName(string prmColorName, string prmComponent) {
	integer tmpColorIndex = llListFindList(colors, [prmColorName]);
	setColor(llList2Vector(colorVals, tmpColorIndex), prmComponent);
}

setColor(vector prmColor, string prmComponent) {
	color = prmColor;

	string tmpRequest = "";
	tmpRequest = llJsonSetValue(tmpRequest, ["color"], (string)color);
	tmpRequest = llJsonSetValue(tmpRequest, ["attachment"], "gag");
	tmpRequest = llJsonSetValue(tmpRequest, ["component"], prmComponent);
	tmpRequest = llJsonSetValue(tmpRequest, ["userKey"], (string)llGetOwner());

	simpleAttachedRequest("setColor", tmpRequest);
	simpleRequest("setColor", tmpRequest);
}
/*
setTextureByName(string prmTextureName, string prmComponent) {
	integer tmpTextureIndex = llListFindList(textures, [prmTextureName]);
	setTexture(llList2String(textureVals, tmpTextureIndex), prmComponent);
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
*/

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
		if (llJsonGetValue(value, ["attachment"]) != "gag") { return; }
		if (llJsonGetValue(value, ["name"]) != "tape") { return; }
		string component = llJsonGetValue(value, ["component"]);
		if ("" == component) { component = "tape"; }
		setColor(color, component);
	}
	else if (prmFunction == "gui_gag_device") {
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
				simple_request("remRestraint", "gag");
				_resumeFunction = "setRestraints";
				return;
			}

			if (guiScreen == 0) {
				if (prmText == "<<Style>>") {
					gui(100);
				} else {
					addGag(prmText);
					_resumeFunction = "setRestraints";
				}
				return;
			} else if (guiScreen == 100) {
				if ("Strap" == prmText) { gui(101); }
				else if ("Ball" == prmText) { gui(102); }
				//else if ("Texture" == prmText) { gui(111); }
				return;
			} else if (guiScreen == 101) {
				setColorByName(prmText, "strap");
			} else if (guiScreen == 102) {
				setColorByName(prmText, "ball");
			} 
			/*
			else if (guiScreen == 111) {
				setTextureByName(prmText, "cloth");
			}
			*/
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
