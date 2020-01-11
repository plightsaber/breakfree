$import Modules.GuiTools.lslm();

// ===== Variables =====
string self;
string restraint;

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

vector color = COLOR_WHITE;
list colors = ["White", "Black", "Purple", "Red", "Blue", "Green", "Pink", "Yellow", "Brown"];
list colorVals = [COLOR_WHITE, COLOR_BLACK, COLOR_PURPLE, COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_BROWN];

list textures = ["Smooth", "Linen", "Bandana"];
list textureVals = [TEXTURE_BLANK, "linen", "bandana"];

// Status
integer gagStuff = FALSE;
integer gagCleave = FALSE;
integer gagOTN = FALSE;
list attachments = [];

string getSelf() {
	if (self != "") return self;

	self = llJsonSetValue(self, ["name"], "Cloth");
	self = llJsonSetValue(self, ["part"], "gag");
	self = llJsonSetValue(self, ["hasColor"], "1");
	return self;
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
		btn3 = "<<Style>>";
		if (gagStuff || gagCleave || gagOTN) { btn4 = "Ungag"; }

		if (!gagStuff && !gagCleave && !gagOTN) btn7 = "Stuff";
		if (!gagCleave && !gagOTN) btn8 = "Cleave";
		if (!gagCleave && !gagOTN) btn9 = "OTN";
	}
	// GUI: Colorize
	else if (prmScreen == 100) {
		guiText = "Choose what you want to style.";
		mpButtons = multipageGui(["Cloth", "Stuffing", "Texture"], 2, multipageIndex);
	}
	else if (prmScreen == 101) {
		guiText = "Choose a color for the cloth.";
		mpButtons = multipageGui(colors, 3, multipageIndex);
	}
	else if (prmScreen == 102) {
		guiText = "Choose a color for the stuffing.";
		mpButtons = multipageGui(colors, 3, multipageIndex);
	}
	else if (prmScreen == 111) {
		guiText = "Choose a texture for the gag.";
		mpButtons = multipageGui(textures, 3, multipageIndex);
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
addGag(string prmName) {
	if (prmName == "Stuff") {
		gagStuff = TRUE;
		attachments += "gStuff";

		restraint = llJsonSetValue(restraint, ["canCut"], "0");
		restraint = llJsonSetValue(restraint, ["canEscape"], "1");
		restraint = llJsonSetValue(restraint, ["mouthOpen"], "1");
		restraint = llJsonSetValue(restraint, ["type"], "knot");
		restraint = llJsonSetValue(restraint, ["difficulty"], "3");
		restraint = llJsonSetValue(restraint, ["tightness"], "1");
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, attachments));
	} else if (prmName == "Cleave") {
		gagCleave = TRUE;
		if (gagStuff) { attachments += ["gCleaveStuff"]; }
		else { attachments += ["gCleave"]; }

		restraint = llJsonSetValue(restraint, ["canCut"], "1");
		restraint = llJsonSetValue(restraint, ["canEscape"], "1");
		restraint = llJsonSetValue(restraint, ["mouthOpen"], (string)getMouthOpen());
		restraint = llJsonSetValue(restraint, ["type"], "knot");
		restraint = llJsonSetValue(restraint, ["difficulty"], (string)(getDifficulty() + 7));
		restraint = llJsonSetValue(restraint, ["tightness"], (string)(getTightness() + 5));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, attachments));
	} else if (prmName == "OTN") {
		gagOTN = TRUE;
		attachments += ["gOTN"];

		restraint = llJsonSetValue(restraint, ["canCut"], "1");
		restraint = llJsonSetValue(restraint, ["canEscape"], "1");
		restraint = llJsonSetValue(restraint, ["mouthOpen"], (string)getMouthOpen());
		restraint = llJsonSetValue(restraint, ["type"], "knot");
		restraint = llJsonSetValue(restraint, ["difficulty"], (string)(getDifficulty() + 5));
		restraint = llJsonSetValue(restraint, ["tightness"], (string)(getTightness() + 5));
		restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, attachments));
	}

	updateGarble();

	bindGag("restraint", TRUE);
}

removeGag() {
	if (gagOTN) {
		gagOTN = FALSE;
		restraint = llJsonSetValue(restraint, ["difficulty"], (string)(getDifficulty() - 5));
		restraint = llJsonSetValue(restraint, ["tightness"], (string)(getTightness() - 5));
	}
	else if (gagCleave) {
		gagCleave = FALSE;
		restraint = llJsonSetValue(restraint, ["difficulty"], (string)(getDifficulty() - 7));
		restraint = llJsonSetValue(restraint, ["tightness"], (string)(getTightness() - 5));
	}
	else if (gagStuff) {
		gagStuff = FALSE;
		restraint = llJsonSetValue(restraint, ["difficulty"], (string)(getDifficulty() - 3));
		restraint = llJsonSetValue(restraint, ["tightness"], (string)(getTightness() - 1));
	}

	attachments = llDeleteSubList(attachments, -1, 1);
	restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, attachments));

	updateGarble();

	if (!gagStuff && !gagCleave && !gagOTN) { bindGag("free", TRUE); }
	else { bindGag("restraint", TRUE); }
}

bindGag(string prmType, integer prmSend) {
	if (prmType == "free") {
		restraint = "";
		attachments = [];
		gagOTN = FALSE;
		gagCleave = FALSE;
		gagStuff = FALSE;
		if (prmSend) { simpleRequest("bindGag", "free"); }
	} else if (prmSend) {
		simpleRequest("bindGag", restraint);
	}
}

updateGarble() {
	restraint = llJsonSetValue(restraint, ["mouthGarbled"], "0");
	restraint = llJsonSetValue(restraint, ["mouthMuffled"], "0");
	restraint = llJsonSetValue(restraint, ["mouthSealed"], "0");

	if (gagCleave) { restraint = llJsonSetValue(restraint, ["mouthGarbled"], "1"); }
	if (gagOTN) { restraint = llJsonSetValue(restraint, ["mouthMuffled"], "1"); }
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

// ===== Gets =====
string getName() {
	return llGetDisplayName(llGetOwner());
}

integer getDifficulty() {
	string tmpData = llJsonGetValue(restraint, ["difficulty"]);
	if (tmpData == JSON_INVALID) { return 0; }
	else { return (integer)tmpData; }
}

integer getTightness() {
	string tmpData = llJsonGetValue(restraint, ["tightness"]);
	if (tmpData == JSON_INVALID) { return 0; }
	else { return (integer)tmpData; }
}

integer getMouthOpen() {
	return llJsonGetValue(restraint, ["mouthOpen"]) == "1";
}

// ===== Sets =====
setGender(string prmGender) {
	gender = prmGender;
}

// ===== Other Functions =====
debug(string output) {
	// TODO: global enable/disable?
	llOwnerSay(output);
}

// ===== Event Controls =====

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

			if (prmText == "Ungag") {
				removeGag();
				gui(guiScreen);
				return;
			}

			if (guiScreen == 0) {
				if (prmText == "<<Style>>") {
					gui(100);
				} else {
					addGag(prmText);
					gui(guiScreen);
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
		value = llJsonGetValue(prmText, ["value"]);

		if (function == "setGender") { setGender(value); }
		else if (function == "bindGag") { bindGag(value, FALSE); }
		else if (function == "getAvailableRestraints") { sendAvailabilityInfo(); }
		else if (function == "requestColor") {
			if (llJsonGetValue(value, ["attachment"]) != "gag") { return; }
			if (llJsonGetValue(value, ["name"]) != "cloth") { return; }
			string component = llJsonGetValue(value, ["component"]);
			if ("" == component) { component = "cloth"; }
			setColor(color, component);
		}
		else if (function == "gui_gag_cloth") {
			key userkey = (key)llJsonGetValue(prmText, ["userkey"]);
			integer screen = 0;
			if ((integer)llJsonGetValue(prmText, ["restorescreen"]) && guiScreenLast) { screen = guiScreenLast;}
			initGUI(userkey, screen);
		} else if (function == "resetGUI") {
			exit("");
		}
	}

	timer() {
		exit("timeout");
	}
}