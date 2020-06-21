$import Modules.GeneralTools.lslm();
$import Modules.GuiTools.lslm();
$import Modules.UserLib.lslm();

// ===== Constants and Variables ===== (Thanks Bioshock <_<)
string TOOL_TYPE = "blade";		// blade | cropper | pick
integer TOUCH_MAX_DISTANCE = 1;
float TOUCH_TIMEOUT = 3.0;

integer _apiListener;

key _toucherKey;
string _guiUser;

list _boundUserKeys;
list _boundUserNames;

string _currentState = "default";

// ===== Main Methods =====
init(key userKey) {
	if (_apiListener) { llListenRemove(_apiListener); }
	_apiListener = llListen(CHANNEL_API, "", NULL_KEY, "");

	_toucherKey = userKey;

	_boundUserKeys = [];
	_boundUserNames = [];

	// Request User Object
	string request = "";
	request = llJsonSetValue(request, ["function"], "getTouchInfo");
	request = llJsonSetValue(request, ["fromKey"], llGetKey());
	request = llJsonSetValue(request, ["toKey"], _toucherKey);

	_currentState = "getTouchInfo";
	llRegionSayTo(_toucherKey, CHANNEL_API, request);
	llSetTimerEvent(TOUCH_TIMEOUT);
}

init_gui(key prmID) {
	guiUserID = prmID;

	if (guiID) { llListenRemove(guiID); }
	guiChannel = (integer)llFrand(-9998) - 1;
	guiID = llListen(guiChannel, "", guiUserID, "");
	gui();
}

gui() {
	_currentState = "GUI";

	// Reset Busy Clock
	llSetTimerEvent(guiTimeout);

	list mpButtons = ["Remove"];
	guiText = "What do you want to do with this?";
	guiButtons = multipageGui(mpButtons + _boundUserNames, 4, multipageIndex);
	llDialog(guiUserID, guiText, guiButtons, guiChannel);
}

pingBound() {
	_currentState = "pingBound";
	string request;
	request = llJsonSetValue(request, ["function"], "pingBound");
	request = llJsonSetValue(request, ["key"], llGetKey());

	llWhisper(CHANNEL_API, request);
	llSetTimerEvent(TOUCH_TIMEOUT);
}


sendTouch(key userKey) {
	_toucherKey = NULL_KEY;
	string value = _guiUser;
	value = llJsonSetValue(value, [TOOL_TYPE], "1");

	string request;
	request = llJsonSetValue(request, ["function"], "touchUser");
	request = llJsonSetValue(request, ["fromKey"], llJsonGetValue(value, ["key"]));
	request = llJsonSetValue(request, ["toKey"], userKey);
	request = llJsonSetValue(request, ["value"], value);
	llRegionSayTo(userKey, CHANNEL_API, request);

	_currentState = "default";
	llSetTimerEvent(0.0);
}

// ===== Events =====
default {
	listen(integer channel, string name, key id, string message) {
		if ("GUI" == _currentState && channel == guiChannel) {
			if (message == "Next >>") { multipageIndex ++; gui(); return; }
			else if (message == "<< Previous") { multipageIndex --; gui(); return; }
			else if (message == " ") { gui(); return; }
			else if (message == "Remove") {
				llDie();

				// If that didn't work - we must be an attachment
				llRequestPermissions(llGetOwner(), PERMISSION_ATTACH );
				llDetachFromAvatar();
				return;
			}

			integer index = llListFindList(_boundUserNames, [message]);
			sendTouch(llList2Key(_boundUserKeys, index));
		} else if ("pingBound" == _currentState) {
			string function = llJsonGetValue(message, ["function"]);
			_boundUserKeys += llJsonGetValue(message, ["userKey"]);
			_boundUserNames += llGetDisplayName(llJsonGetValue(message, ["userKey"]));
			return;
		} else if ("getTouchInfo" == _currentState) {
			_guiUser = llJsonGetValue(message, ["value"]);
			pingBound();
			return;
		}
	}

	timer() {
		if ("getTouchInfo" == _currentState) {
			_guiUser = getDefaultUser(_toucherKey);
			pingBound();
			return;
		} else if ("pingBound" == _currentState) {
			init_gui(_toucherKey);
			return;
		} else if ("GUI" == _currentState) {
			_currentState = "default";
			exit("");
			return;
		}

		// We shouldn't get here - but clean up just in case.
		debug("WARNING! timer entered in invalid state: " + _currentState);
		llSetTimerEvent(0.0);
		_currentState = "default";
	}

	touch_start(integer num_detected) {
		key toucherID = llDetectedKey(0);

		if (_currentState != "default") {
			if (toucherID == guiUserID) {
				init_gui(toucherID);
				return;
			}
			llRegionSayTo(toucherID, 0, "This item is currently being handled by " + llGetDisplayName(guiUserID) + ".");
			return;
		}

		init(toucherID);
	}
}
