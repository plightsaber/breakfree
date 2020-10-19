$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();

integer CHANNEL_LOCKMEISTER = -8888;
vector COLOR_WHITE = <1.00, 1.00, 1.00>;

// ===== Variables =====
integer lockmeisterID;
key _armTargetID;
key _legTargetID;

integer GUI_ARM = 0;
integer GUI_LEG = 10;

// Status
integer _armTetherLength = 1;
integer _legTetherLength = 1;

string requestingAttachment;

// ===== Initializer =====
init() {
	if (lockmeisterID) { llListenRemove(lockmeisterID); }
	lockmeisterID = llListen(CHANNEL_LOCKMEISTER, "", NULL_KEY, "");
}

initGUI(key prmID, integer prmScreen) {
	guiUserID = prmID;

	if (guiID) { llListenRemove(guiID); }
	guiChannel = (integer)llFrand(-9998) - 1;
	guiID = llListen(guiChannel, "", guiUserID, "");
	gui(prmScreen);
}

// ===== Main Functions =====
requestHitch(string prmAttachment) {
	requestingAttachment = prmAttachment;
	llRegionSayTo(guiUserID, 0, "Please select a hitching post.");
	llListenControl(lockmeisterID, TRUE);
}

tetherTo(key prmTargetID, string prmAttachment) {
	string request = "";
	request = llJsonSetValue(request, ["targetID"], prmTargetID);
	request = llJsonSetValue(request, ["attachment"], prmAttachment);
	if (prmAttachment == "arm") {
		request = llJsonSetValue(request, ["length"], (string)_armTetherLength);
		_armTargetID = prmTargetID;
	} else if (prmAttachment == "leg") {
		request = llJsonSetValue(request, ["length"], (string)_legTetherLength);
		_legTargetID = prmTargetID;
	}

	simpleAttachedRequest("tetherTo", request);
	simpleRequest("tetherTo", request);
}

setArmTetherLength(string prmLength) {
	_armTetherLength = (integer)llDeleteSubString(prmLength, -1, 2);
	tetherTo(_armTargetID, "arm");
}

setLegTetherLength(string prmLength) {
	_legTetherLength = (integer)llDeleteSubString(prmLength, -1, 2);
	tetherTo(_legTargetID, "leg");
}

// ===== GUI =====
gui(integer prmScreen) {
	// Reset Busy Clock
	simpleRequest("resetGuiTimer", "1");

	string btn10 = " ";     string btn11 = " ";     string btn12 = " ";
	string btn7 = " ";      string btn8 = " ";      string btn9 = " ";
	string btn4 = " ";      string btn5 = " ";      string btn6 = " ";
	string btn1 = "<<Back>>";   string btn2 = "<<Done>>";   string btn3 = " ";

	guiText = " ";

	// Arm Tether
	if (prmScreen == GUI_ARM) {
		guiText = "How do you want to tether " + llGetDisplayName(llGetOwner()) + "'s arms?\nCurrent length: " + (string)_armTetherLength + "m";
	} else if (prmScreen == GUI_LEG) {
		guiText = "How do you want to tether " + llGetDisplayName(llGetOwner()) + "'s legs?\nCurrent length: " + (string)_legTetherLength + "m";
	}

	btn7 = "1m";
	btn8 = "2m";
	btn9 = "3m";
	btn10 = "5m";
	btn11 = "8m";
	btn12 = "10m";

	btn4 = "Release";
	btn5 = "Grab";
	btn6 = "Hitch";
	btn3 = "Pull";

	guiScreen = prmScreen;
	guiButtons = [btn1, btn2, btn3];

	if (btn4+btn5+btn6 != "   ") { guiButtons += [btn4, btn5, btn6]; }
	if (btn7+btn8+btn9 != "   ") { guiButtons += [btn7, btn8, btn9]; }
	if (btn10+btn11+btn12 != "   ") { guiButtons += [btn10, btn11, btn12]; }
	llDialog(guiUserID, guiText, guiButtons, guiChannel);
}

// ===== Event Controls =====
default {
	state_entry() {
		init();
	}

	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel == CHANNEL_LOCKMEISTER) {

			// Check if post is okay
			if (llGetSubString(prmText,-2,-1) != "ok") { return; }
			if (llGetSubString(prmText, 0, 35) != (string)guiUserID ) { return; }

			llListenControl(lockmeisterID, FALSE);
			tetherTo(prmID, requestingAttachment);

			gui(guiScreen);
		} else if (prmChannel == guiChannel) {
			if (prmText == "<<Done>>") { exit("done"); return; }
			else if (prmText == " ") { gui(guiScreen); return; }
			else if (prmText == "<<Back>>") { guiRequest("gui_bind", TRUE, guiUserID, 0); return; }

			if (guiScreen == GUI_ARM || guiScreen == GUI_LEG) {
				string restraintType = "arm";	// Default
				if (guiScreen == GUI_LEG) { restraintType = "leg"; }

				if (prmText == "Grab") { tetherTo(guiUserID, restraintType); }
				else if (prmText == "Release") { tetherTo(NULL_KEY, restraintType); }
				else if (prmText == "Hitch") { requestHitch(restraintType); return; }
				else if (prmText == "Pull") { simpleRequest("tetherPull", guiUserID); }
				else {
					if (GUI_ARM == guiScreen) { setArmTetherLength(prmText); }
					else if (GUI_LEG == guiScreen) { setLegTetherLength(prmText); }
				}
				gui(guiScreen);
			}
		}
	}

	link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
		string function = llJsonGetValue(prmText, ["function"]);
		string value = llJsonGetValue(prmText, ["value"]);

		if (!isSet(function)) {
			debug(prmText);
			return;
		}

		if (function == "gui_tether_arm" || function == "gui_tether_leg") {
			key userkey = (key)llJsonGetValue(prmText, ["userkey"]);
			integer screen = 0;
			if (function == "gui_tether_leg") { screen = 10; }

			initGUI(userkey, screen);
		} else if (function == "resetGUI") {
			exit("");
		}
	}
}
