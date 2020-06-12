$import Modules.GeneralTools.lslm();

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