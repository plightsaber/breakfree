$import Modules.ArmTools.lslm();
$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.RestraintTools.lslm();

// General Settings
string gender = "female";

// Status
string armsBound = "free";  // 0: FREE; 1: BOUND; 2: HELPLESS

// Colors
vector COLOR_WHITE = <1.0, 1.0, 1.0>;
vector COLOR_BROWN = <0.824, 0.549, 0.353>;

vector color = COLOR_WHITE;
list colors = ["White", "Brown"];
list colorVals = [COLOR_WHITE, COLOR_BROWN];

list _availableRestraints;
list _liCurrentRestraints;
string _slots;

// Dataserver variables.
integer _restraintLibQueryLine;
key 	_restraintLibQueryId;
string 	_restraintLib;
string 	_restraintLibNotecard;

readNotecard(string prmName) {
	_restraintLibNotecard = prmName;
	_restraintLibQueryLine = 0;
	_restraintLibQueryId = llGetNotecardLine(_restraintLibNotecard, _restraintLibQueryLine);
}

string getSelf() {
	if (_self != "") return _self;
	_self = llJsonSetValue(_self, ["name"], "Tape");
	_self = llJsonSetValue(_self, ["part"], "arm");
	_self = llJsonSetValue(_self, ["hasColor"], "1");
	return _self;
}

// ===== Initializers =====
init() {
	readNotecard(".restraints_armTape");
}

init_gui(key prmID, integer prmScreen) {
	guiUserID = prmID;

	if (guiID) { llListenRemove(guiID); }
	guiChannel = (integer)llFrand(-9998) - 1;
	guiID = llListen(guiChannel, "", guiUserID, "");
	gui(prmScreen);
}

integer can_apply_restraint(string restraint) {
	
	// Is the restraint slot already applied?
	integer isApplied = llListFindList(_liCurrentRestraints, [llJsonGetValue(restraint, ["uid"])]);
	if (isApplied != -1) {
		return FALSE;
	}
	
	// Do we have the required feat? (TODO)
	
	// Any other prerequisites? (TODO)
	list liUidBlacklist = llJson2List(llJsonGetValue(restraint, ["prerequisites", "notUID"]));
	integer isBlacklisted = llListFindList(_liCurrentRestraints, liUidBlacklist);
	if (isBlacklisted != -1) {
		return FALSE;
	}
	
	debug(restraint);
	
	return TRUE;
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
		
		if (llJsonGetValue(_restraints, ["isArmBound"]) == "1") { mpButtons += "Untie"; }
		
		_availableRestraints = [];
		list options = llJson2List(_restraintLib);
		integer index;
		for (index=0; index < llGetListLength(options); index++) {
			string restraint = llList2String(options, index);
			if (can_apply_restraint(restraint)) {
				_availableRestraints += restraint;
				mpButtons += llJsonGetValue(restraint, ["name"]);
			}
		}
		mpButtons = multipageGui(mpButtons, 2, multipageIndex);
	}
	
	// GUI: Colorize
	else if (prmScreen == 100) {
		guiText = "Choose a color for the arm tape.";
		mpButtons = multipageGui(colors, 3, multipageIndex);
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
addRestraint(string uid) {
	string restraint = getRestraintByParam(llJson2List(_restraintLib), "uid", uid);
	if (restraint == NULL_KEY) {
		debug("No restraint found with uid: " + uid);
		return;
	}
	
	string restraintSet;
	restraintSet = llJsonSetValue(restraintSet, ["type"], "arm");
	restraintSet = llJsonSetValue(restraintSet, ["restraint"], restraint);
	simpleRequest("addRestraint", restraintSet);
}

sendAvailabilityInfo () {
	simpleRequest("addAvailableRestraint", getSelf());
}

// Color Functions
setColorByName(string prmColorName) {
  integer tmpColorIndex = llListFindList(colors, [prmColorName]);
  setColor(llList2Vector(colorVals, tmpColorIndex));
}
setColor(vector prmColor) {
  color = prmColor;

  string tmpRequest = "";
  tmpRequest = llJsonSetValue(tmpRequest, ["color"], (string)color);
  tmpRequest = llJsonSetValue(tmpRequest, ["attachment"], "arm");
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
    else if (prmFunction == "setSlots") { _slots = value; }
    else if (prmFunction == "setRestraints") { _restraints = value; }
    else if (prmFunction == "setRestraintUids") { _liCurrentRestraints = (list)value; }
    else if (prmFunction == "getAvailableRestraints") { sendAvailabilityInfo(); }
    else if (prmFunction == "requestColor") {
      if (llJsonGetValue(value, ["attachment"]) != "arm") { return; }
      if (llJsonGetValue(value, ["name"]) != "tape") { return; }
      setColor(color);
    }
    else if (prmFunction == "gui_arm_tape") {
      key userkey = (key)llJsonGetValue(prmJson, ["userkey"]);
      integer screen = 0;
      if ((integer)llJsonGetValue(prmJson, ["restorescreen"]) && guiScreenLast) { screen = guiScreenLast;}
      init_gui(userkey, screen);
    } else if (prmFunction == "resetGUI") {
      exit("");
    }
}

default {
	
	state_entry() {
		init();
	}

	on_rez(integer prmStart) {
		init();
	}
	
	dataserver(key queryID, string data) {
		if (data == EOF) {
			_restraintLibQueryLine = 0;
			_restraintLibQueryId = NULL_KEY;
			return;
		}
		
		if (queryID == _restraintLibQueryId) {
			_restraintLibQueryLine++;
			_restraintLib += data;
			_restraintLibQueryId = llGetNotecardLine(_restraintLibNotecard, _restraintLibQueryLine);
		}
	}
	
	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel = guiChannel) {
			if (prmText == "<<Done>>") { exit("done"); return; }
			else if (prmText == " ") { gui(guiScreen); return; }
			else if (prmText == "<<Back>>") {
				if (guiScreen != 0) { gui(guiScreenLast); return;}
				guiRequest("gui_bind", TRUE, guiUserID, 0);
				return;
			}
			else if (prmText == "Next >>") { multipageIndex ++; gui(guiScreen); return; }
			else if (prmText == "<< Previous") { multipageIndex --; gui(guiScreen); return; }

			if (prmText == "Untie") {
				simpleRequest("remRestraint", "arm");
				_resumeFunction = "setRestraints";
				return;
			}

			if (guiScreen == 0) {
				if (prmText == "<<Color>>") {
					gui(100);
					return;
				} else {
					string restraint = getRestraintByParam(_availableRestraints, "name", prmText);
					if (restraint == NULL_KEY) {
						debug("No available restraint with name: " + prmText);
						return;
					}
					
					addRestraint(llJsonGetValue(restraint, ["uid"]));
					_resumeFunction = "setRestraints";
					return;
				}
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
