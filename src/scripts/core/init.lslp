$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.RestraintTools.lslm();
$import Modules.UserLib.lslm();

float TOUCH_BOUND_MAX_DISTANCE = 1.5;
float TOUCH_MAX_DISTANCE = 3.0;
float TOUCH_TIMEOUT = 3.0;

integer _timedOut = TRUE;

// Quick Keys
key _activeKey = NULL_KEY;
key _toucherKey = NULL_KEY;
key _villainKey = NULL_KEY;

string _activeUser;
string _owner;

// Settings
integer _rpMode = FALSE;

// ==== Initializer =====

init()
{
	_timedOut = TRUE;
}

initTouch(key prmID) {

	if (!canTouch(prmID)) {
		if (prmID == llGetOwner()) {
			llRegionSayTo(prmID, 0, "You cannot do anything because you are being controlled by " + llGetDisplayName(_activeKey) + ".");
			return;
		}

		llRegionSayTo(prmID, 0, "You cannot do anything because " + llGetDisplayName(llGetOwner()) + " is being controlled by " + llGetDisplayName(_activeKey) + ".");
		return;
	}

	if (prmID == llGetOwner()) {
		_activeUser = _owner;
		initGuiRequest("gui_owner", FALSE, prmID, 0);
	} else {
		_toucherKey = prmID;
		apiRequest(prmID, llGetOwner(), "getTouchInfo", "");
		llSetTimerEvent(TOUCH_TIMEOUT);
	}
}

// ===== Main Functions =====
integer canTouch(key toucherID) {

	// No dialogs are active
	if (_timedOut || !isSet(_activeKey)) {
		return TRUE;
	}

	// Owner can't click themselves for production
	if (_activeKey == llGetOwner()) {
		return TRUE;
	}

	// Allow active user to restart dialogs
	if (_activeKey == toucherID) {
		return TRUE;
	}

	// Don't interrupt a villain at work
	if (_activeKey == _villainKey) {
		return FALSE;
	}

	// Failover to allow touching
	return TRUE;
}

initGuiRequest(string prmGUI, integer prmRestore, key prmUserID, integer prmScreen) {
	simpleRequest("resetGUI", "init");
	if (isSet(_activeKey) && _activeKey != prmUserID) {
		llRegionSayTo(_activeKey, 0, llGetDisplayName(llGetOwner()) + "'s menu has been claimed by " + llGetDisplayName(prmUserID) + ".");
	}

	// Special rules for initing bind (villain) menu
	if ("gui_bind" == prmGUI && _activeKey != prmUserID) {
		llOwnerSay(llJsonGetValue(_activeUser, ["name"]) + " is eyeing you suspiciously.");
		simpleRequest("setVillain", _activeUser);
	}

	_activeKey = prmUserID;
	_timedOut = FALSE;

	simpleRequest("setToucher", _activeUser);
	guiRequest(prmGUI, prmRestore, prmUserID, prmScreen);
}

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

	_activeUser = user;
	if (isBound()) {
		if (_rpMode || (!toucherBound && userKey == _villainKey) && _activeKey != llGetOwner()) {
			initGuiRequest("gui_bind", FALSE, userKey, 0);
			return;
		}

		initGuiRequest("gui_escape", FALSE, userKey, 0);
		return;
	}

	initGuiRequest("gui_bind", FALSE, userKey, 0);
}

// ===== Event Controls =====

default {
	state_entry() {
		init();
	}

	on_rez(integer startParam) {
		init();
	}

	touch_start(integer prmCount) {
		key toucherID = llDetectedKey(0);
		initTouch(toucherID);
	}

	link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
		string function;
		string value;

		if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
			debug(prmText);
			return;
		}
		value = llJsonGetValue(prmText, ["value"]);

		if (function == "touch") { initTouch(value); }
		else if (function == "touchUser") {	touchUser(value); }
		else if (function == "setOwner") { _owner = value; }
		else if (function == "setRestraints") { _restraints = value; }
		else if (function == "setVillainKey") { _villainKey = value; }
		else if (function == "setRPMode") { _rpMode = (integer)value; }
		else if (function == "resetGUI" && "init" != value) {
			if (!isBound()) { _villainKey = NULL_KEY; }
			_activeKey = NULL_KEY;
			_activeUser = JSON_NULL;
			_timedOut = TRUE;
		}
		else if (function == "resetGuiTimer") {
			_timedOut = FALSE;
		}
		else if ("setTimedOut") {
			_timedOut = TRUE;
		}
	}

	timer() {
		//debug("Toucher not wearing BreakFree - assuming defaults.");
		touchUser(getDefaultUser(_toucherKey));
	}
}
