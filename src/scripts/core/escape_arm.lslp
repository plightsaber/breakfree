$import Modules.GeneralTools.lslm();
$import Modules.RestraintTools.lslm();

string RESTRAINT_TYPE = "arm";

string _progress;
string _puzzles;

// ===== Methods =====
getEscapeData(string restraint)
{
	if (restraint != RESTRAINT_TYPE) {
		return;
	}

	// Always reset current tightness progress on request
	_progress = llJsonSetValue(_progress, ["tightness", "progress"], "0");

	string request;
	request = llJsonSetValue(request, ["progress"], _progress);
	request = llJsonSetValue(request, ["puzzles"], _puzzles);
	simpleRequest("setActiveEscapeData", request);
}

setRestraints(string restraints) {
	list slots = getSearchSlots(RESTRAINT_TYPE);
	integer index;

	for (index = 0; index < llGetListLength(slots); ++index) {
		string slot = llList2String(slots, index);
		if (llJsonGetValue(_restraints, ["slots", slot]) != llJsonGetValue(restraints, ["slots", slot])) {
			// Refresh puzzles and progress on restraint change
			_progress = JSON_NULL;
			_puzzles = JSON_NULL;
			index = llGetListLength(slots); // Break the loop
		}
	}

	_restraints = restraints;
}

// ===== Events =====
executeFunction(string function, string json)
{
	string value = llJsonGetValue(json, ["value"]);

	if ("getEscapeData" == function) {
		getEscapeData(value);
	} else if ("setProgress" == function) {
		if (llJsonGetValue(value, ["restraint"]) != RESTRAINT_TYPE) {
			return;
		}
		_progress = llJsonGetValue(value, ["progress"]);
	} else if ("setPuzzles" == function) {
		if (llJsonGetValue(value, ["restraint"]) != RESTRAINT_TYPE) {
			return;
		}
		_puzzles = llJsonGetValue(value, ["puzzles"]);
	} else if ("setRestraints" == function) {
		setRestraints(value);
		return;
	}
}

default
{
	link_message(integer sender_num, integer num, string str, key id)
	{
		string function;
		string value;

		if ((function = llJsonGetValue(str, ["function"])) == JSON_INVALID) {
			debug(str);
			return;
		}
		executeFunction(function, str);
	}
}