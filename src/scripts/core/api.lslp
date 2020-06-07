$import Modules.GeneralTools.lslm();
$import Modules.RestraintTools.lslm();
$import Modules.UserLib.lslm();

// Objects
string _self;

// Listener Vars
integer CHANNEL_API = -9999274;
integer listenID;

// ===== Initializer =====
init() {
	if (listenID) { llListenRemove(listenID); }
	llListen(CHANNEL_API, "", NULL_KEY, "");

	if (_self == "") { _self = getDefaultUser(llGetOwner()); }
}

// ===== Primary Functions ====
api(string prmJson) {

	string function = llJsonGetValue(prmJson, ["function"]);
	key apiTargetID = (key)llJsonGetValue(prmJson, ["apiTargetID"]);
	key senderID = (key)llJsonGetValue(prmJson, ["userID"]);

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
	if (apiTargetID != llGetOwner()) { return; }

	// Execute API Call
	if (function == "getTouchInfo") {
		// Check arm bound status
		send(senderID, "touchUser", _self);
	} else {
		simpleRequest(function, prmJson);
	}
}

send(key prmTargetID, string prmFunction, string prmJson) {
	prmJson = llJsonSetValue(prmJson, ["function"], prmFunction);
	prmJson = llJsonSetValue(prmJson, ["userID"], (string)llGetOwner());
	prmJson = llJsonSetValue(prmJson, ["apiTargetID"], (string)prmTargetID);

	llRegionSayTo(prmTargetID, CHANNEL_API, prmJson);
}

// ===== Event Controls =====
default {
	on_rez(integer prmStart) {
		init();
	}
	state_entry() {
		init();
	}

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
			_self = llJsonSetValue(_self, ["armBound"], llJsonGetValue(value, ["armBound"]));
			_self = llJsonSetValue(_self, ["handbound"], (string)isSet(llJsonGetValue(value, ["slots", "hand"])));
		} else if (function == "setFeats") {
			_self = llJsonSetValue(_self, ["feats"], value);
		}
	}

	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		api(prmText);
	}
}
