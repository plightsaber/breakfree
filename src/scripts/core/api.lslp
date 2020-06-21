$import Modules.GeneralTools.lslm();
$import Modules.RestraintTools.lslm();
$import Modules.UserLib.lslm();

// Objects
string _owner;

// Listener Vars
integer listenID;

// ===== Initializer =====
init() {
	// Reset owner if mismatched.
	if (llJsonGetValue(_owner, ["uid"]) != llGetOwner()) {
		_owner = "";
	}

	if (listenID) { llListenRemove(listenID); }
	llListen(CHANNEL_API, "", NULL_KEY, "");
	if (_owner == "") { _owner = getDefaultUser(llGetOwner()); }
}

// ===== Primary Functions ====
api(string prmJson) {
	string function = llJsonGetValue(prmJson, ["function"]);
	string value = llJsonGetValue(prmJson, ["value"]);
	if (!isSet(function)) {
		debug("ERROR: API call missing function: " + prmJson);
	}

	// Check for general requests that don't require validation
	if ("pingBound" == function) {
		if (isBound()) {
			string response = "";
			response = llJsonSetValue(response, ["function"], "pongBound");
			response = llJsonSetValue(response, ["bound"], "1");
			response = llJsonSetValue(response, ["userKey"], llGetOwner());
			llRegionSayTo(llJsonGetValue(prmJson, ["key"]), CHANNEL_API, response);
		}
		return;
	}

	// Validate
	if (llJsonGetValue(prmJson, ["toKey"]) != llGetOwner()) { return; }

	// Execute API Call
	if (function == "getTouchInfo") {
		apiRequest(llJsonGetValue(prmJson, ["fromKey"]), llGetOwner(), "touchUser", _owner);
	} else {
		if (value == JSON_INVALID) {
			debug("WARNING: Legacy api call detected: " + prmJson);
			value = prmJson;
		}

		simpleRequest(function, value);
	}
}

// ===== Event Controls =====
default {
	on_rez(integer prmStart) { init(); }
	state_entry() {	init();	}

	link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
		string function;
		string value;

		if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
			debug(prmText);
			return;
		}
		value = llJsonGetValue(prmText, ["value"]);

		if (function == "setRestraints") {
			_restraints = value;
			_owner = llJsonSetValue(_owner, ["armBound"], llJsonGetValue(value, ["armBound"]));
			_owner = llJsonSetValue(_owner, ["handBound"], (string)isSet(llJsonGetValue(value, ["slots", "hand"])));
		} else if (function == "setOwnerFeats") {
			_owner = llJsonSetValue(_owner, ["feats"], value);
		}
	}

	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		api(prmText);
	}
}
