$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.RestraintTools.lslm();
$import Modules.UserLib.lslm();

float TOUCH_BOUND_MAX_DISTANCE = 1.5;
float TOUCH_MAX_DISTANCE = 3.0;
float TOUCH_TIMEOUT = 3.0;

// Quick Keys
key _activeKey = NULL_KEY;
key _toucherKey;
key _villainKey;

string _owner;

// Settings
integer _rpMode = FALSE;

// ==== Initializer =====

init(key prmID) {
	// Don't start GUI if requesting user does not have control priority
	if (_activeKey != NULL_KEY && _activeKey != prmID) {
		if (prmID != llGetOwner()) {
			if (_activeKey == _villainKey) {
				llRegionSayTo(prmID, 0, "You cannot do anything because " + llGetDisplayName(llGetOwner()) + " is being controlled by " + llGetDisplayName(_activeKey) + ".");
				return;
			}
		} else if (prmID != _villainKey) {
			llRegionSayTo(prmID, 0, "You cannot do anything because you are being controlled by " + llGetDisplayName(_activeKey) + ".");
			return;
		}
	}

	if (prmID == llGetOwner()) {
		simpleRequest("resetGUI", "override");
		_activeKey = prmID;
		simpleRequest("setToucher", _owner);
		guiRequest("gui_owner", FALSE, _activeKey, 0);
	} else {
		_toucherKey = prmID;
		apiRequest(prmID, llGetOwner(), "getTouchInfo", "");
		//debug("Setting timer...");
		llSetTimerEvent(TOUCH_TIMEOUT); // Stop Timer
	}
}

// ===== Main Functions =====

touchUser(string user) {
	//debug("touchUser Event");
	llSetTimerEvent(0.0);	 // Stop Timer

	// Is the toucher in a reasonable range?
	key userKey = (key)llJsonGetValue(user, ["key"]);
	vector toucherPos = llList2Vector(llGetObjectDetails(userKey, [OBJECT_POS]), 0);

	integer toucherDistance = llAbs(llFloor(llVecDist(toucherPos, llGetPos())));
	integer toucherBound = (integer)llJsonGetValue(user, ["armBound"]);

	float checkDistance;
	if (toucherBound) { checkDistance = TOUCH_BOUND_MAX_DISTANCE; }
	else { checkDistance = TOUCH_MAX_DISTANCE; }

	if (toucherDistance > TOUCH_MAX_DISTANCE) {
		// TODO: Get preferred username
		llRegionSayTo(userKey, 0, llGetDisplayName(llGetOwner()) + " is too far away.");
		return;
	}

	if (toucherBound && !isBound()) {
		llRegionSayTo(userKey, 0, "You can't do that while bound.");
		return;
	}

	simpleRequest("resetGUI", "override");
	_activeKey = userKey;

	simpleRequest("setToucher", user);
	if (isBound()) {
		if (_rpMode || (!toucherBound && _activeKey == _villainKey) && _activeKey != llGetOwner()) {
			guiRequest("gui_bind", FALSE, _activeKey, 0);
			return;
		}

		guiRequest("gui_escape", FALSE, _activeKey, 0);
		return;
	}

	llOwnerSay(llJsonGetValue(user, ["name"]) + " is eyeing you suspiciously.");
	simpleRequest("setVillain", user);
	guiRequest("gui_bind", FALSE, _activeKey, 0);
}

// ===== Event Controls =====

default {
	touch_start(integer prmCount) {
		key toucherID = llDetectedKey(0);
		init(toucherID);
	}

	link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
		string function;
		string value;

		if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
			debug(prmText);
			return;
		}
		value = llJsonGetValue(prmText, ["value"]);

		if (function == "touch") { init(value);	}
		else if (function == "touchUser") {	touchUser(value); }
		else if (function == "setOwner") { _owner = value; }
		else if (function == "setRestraints") { _restraints = value; }
		else if (function == "setVillainKey") { _villainKey = value; }
		else if (function == "setRPMode") { _rpMode = (integer)value; }
		else if (function == "resetGUI") {
			if (value == "timeout") {
				llRegionSayTo(_activeKey, 0, llGetDisplayName(llGetOwner()) + "'s menu has timed out.");
				_activeKey = NULL_KEY;
			} else if (value != "override") { _activeKey = NULL_KEY; }

			if (!isBound()) { _villainKey = NULL_KEY; }
		}
	}

	timer() {
		//debug("Toucher not wearing BreakFree - assuming defaults.");
		touchUser(getDefaultUser(_toucherKey));
	}
}
