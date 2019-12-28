$import Modules.GuiTools.lslm();

// Quick Keys
key ownerID;
key villainID;

// Settings


// Stats
integer userExp = 0;
integer userStr = 1;
integer userDex = 1;
integer userInt = 1;
integer userLevel = 1;
list userSkills = [];

// Status Variables
string self;
integer armsBound = FALSE;
integer legsBound = FALSE;
integer gagBound = FALSE;

// GUI screens
integer GUI_HOME = 0;
integer GUI_STATS = 10;
integer GUI_OPTIONS = 20;

init() {
	ownerID = llGetOwner();
}

initGui(key prmID) {
	guiUserID = prmID;

	if (guiID) { llListenRemove(guiID); }
	guiChannel = (integer)llFrand(-9998) - 1;
	guiID = llListen(guiChannel, "", guiUserID, "");
	gui(0);
}

// ===== GUI =====
gui(integer prmScreen) {
	// Reset Busy Clock
	llSetTimerEvent(guiTimeout);

	string btn10 = " ";	string btn11 = " ";			string btn12 = " ";
	string btn7 = " ";	string btn8 = " ";			string btn9 = " ";
	string btn4 = " ";	string btn5 = " ";			string btn6 = " ";
	string btn1 = " ";	string btn2 = "<<Done>>";	string btn3 = " ";
		
	guiText = " ";
		
	// GUI: Main
	if (prmScreen == GUI_HOME) {
		if ((!armsBound && !legsBound && !gagBound) || villainID == ownerID) { btn4 = "Bind"; }
		if (armsBound || legsBound || gagBound) { btn5 = "Escape"; }
		btn3 = "Stats";
		btn1 = "Options";
	}
	// GUI: Stats 
	else if (prmScreen == GUI_STATS) {
		guiText = "Level: " + (string)getUserLevel() + "\n";
		guiText += "Experience: " + (string)userExp + "/" + (string)getNextLevelExp() + "\n";
		guiText += "STR: " + (string)userStr + "\tDEX: " + (string)userDex + "\tINT: " + (string)userInt;

		if (canLevelUp()) {
			btn4 = "STR ↑";
			btn5 = "DEX ↑";
			btn6 = "INT ↑";
		}

		btn1 = "<<Back>>";
	}

	if (prmScreen != guiScreen) { guiScreenLast = guiScreen; }		
	guiScreen = prmScreen;

	guiButtons = [btn1, btn2, btn3];
	if (btn4+btn5+btn6 != "   ") { guiButtons += [btn4, btn5, btn6]; }
	if (btn7+btn8+btn9 != "   ") { guiButtons += [btn7, btn8, btn9]; }
	if (btn10+btn11+btn12 != "   ") { guiButtons += [btn10, btn11, btn12]; }

	llDialog(guiUserID, guiText, guiButtons, guiChannel);
}

// ===== Gets & Sets =====
bindArms(string prmInfo) {
	if (prmInfo == "free") { armsBound = FALSE; }
	else { armsBound = TRUE; }
}

bindLegs(string prmInfo) {
	if (prmInfo == "free") { legsBound = FALSE; }
	else { legsBound = TRUE; }
}

bindGag(string prmInfo) {
	if (prmInfo == "free") { gagBound = FALSE; }
	else { gagBound = TRUE; }
}

addExp(string prmValue) {
	integer addValue = (integer)prmValue;
	if (addValue > 0) { userExp += addValue; }
}

integer getUserLevel() { 
	return userStr + userDex + userInt - 2;
}

integer getNextLevelExp() {
	integer tmpLevel = getUserLevel();
	return ((tmpLevel) * 200) + ((tmpLevel-1)*100);
}

setStats(string stats) {
	userDex = (integer)llJsonGetValue(stats, ["dex"]);
	userInt = (integer)llJsonGetValue(stats, ["int"]);
	userStr = (integer)llJsonGetValue(stats, ["str"]);
	userExp = (integer)llJsonGetValue(stats, ["exp"]);
	userSkills = llJson2List(llJsonGetValue(stats, ["skills"]));
}

// ===== Main Functions =====
integer canLevelUp() {
	integer tmpLevel = getUserLevel();
	integer tmpRequired = getNextLevelExp();

	if (tmpLevel < 20 && userExp > tmpRequired) { return TRUE; }

	return FALSE;
}

// ===== Other Functions =====
debug(string output) {
	// TODO: global enable/disable?
	llOwnerSay(output);
}

// ===== Event Controls =====

default {
	state_entry() {
		init();
	}

	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel = guiChannel) {
			if (prmText == "<<Done>>") { exit("done"); return; }
			else if (prmText == "<<Back>>") { gui(guiScreenLast); }
			else if (prmText == " ") { gui(guiScreen); }

			if (guiScreen == GUI_HOME) {
				if (prmText == "Bind") { guiRequest("gui_bind", FALSE, guiUserID, 0); return; }
				else if (prmText == "Escape") { guiRequest("gui_escape", FALSE, guiUserID, 0); return; }
				else if (prmText == "Stats") { gui(GUI_STATS); }
				else if (prmText == "Options") { gui(GUI_OPTIONS); }
			} else if (guiScreen == GUI_STATS) {
				if (prmText == "STR ↑") { userStr++; simpleRequest("addStr", "1"); }
				if (prmText == "DEX ↑") { userDex++; simpleRequest("addDex", "1"); }
				if (prmText == "INT ↑") { userInt++; simpleRequest("addInt", "1"); }
				gui(guiScreen);
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
		value = llJsonGetValue(prmText, ["value"]);

		if (function == "gui_owner") {
			key userkey = (key)llJsonGetValue(prmText, ["userkey"]);
			initGui(userkey);
		}
		else if (function == "setVillainID") { villainID = value; }
		else if (function == "addExp") { addExp(value); }
		else if (function == "setStats") { setStats(value); }
		else if (function == "bindArms") { bindArms(value); }
		else if (function == "bindLegs") { bindLegs(value); }
		else if (function == "bindGag") { bindGag(value); }
		else if (function == "resetGUI") {
			exit("");
		}
	}

	timer() {
		exit("timeout");
	}
}
