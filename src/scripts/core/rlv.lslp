// ===== Variables =====
integer _armBound;
integer _legBound;
integer _gagBound;

integer _RLV;	// Toggle if RLV should be activated or not
string _restraints;

// ==== Main Functions =====
init() {
	set_restraints(_restraints);
}

detachCheck() {
	if (_armBound || _legBound || _gagBound) {
		llOwnerSay("@detach=n");
	} else {
		llOwnerSay("@detach=y");
	}
}

set_restraints(string prmJson) {
	_restraints = prmJson;
	if (!_RLV) { return; }

	if ((integer)llJsonGetValue(prmJson, ["armBound"])) {
		_armBound = TRUE;
		llOwnerSay("@touchfar=n");
	} else {
		_armBound = FALSE;
		llOwnerSay("@touchfar=y");
	}

	_legBound = (integer)llJsonGetValue(prmJson, ["legBound"]);
	_gagBound = (integer)llJsonGetValue(prmJson, ["gagged"]);

	detachCheck();
}

// ===== Other Functions =====
debug(string output) {
	// TODO: global enable/disable?
	llOwnerSay(output);
}

// ===== Events =====

default {
	on_rez(integer prmStart) { init(); }
	state_entry() { init(); }
	link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
		string function;
		string value;

		if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
			debug(prmText);
			return;
		}
		value = llJsonGetValue(prmText, ["value"]);

		if (function == "setRestraints") { set_restraints(value); }
		else if (function == "setRLV") { _RLV = (integer)value; }
	}
}
