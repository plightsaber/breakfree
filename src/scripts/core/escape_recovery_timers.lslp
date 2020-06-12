$import Modules.GeneralTools.lslm();
$import Modules.RestraintTools.lslm();
$import Modules.UserLib.lslm();

string  _owner;
integer _distraction;
integer _maxStamina;
integer _stamina;

string _progress;
string _puzzles;

// ===== Methods =====
setOwner(string user)
{
	_owner = user;
	_maxStamina = 100;

	if (hasFeat(_owner, "Endurant+")) { _maxStamina = 150; }
	else if (hasFeat(_owner, "Endurant")) { _maxStamina = 125; }
}

// ===== Events =====
executeFunction(string function, string json)
{
	string value = llJsonGetValue(json, ["value"]);
	
	if ("setOwner" == function) {
		setOwner(value);
	} else if ("setEscapeDistraction" == function) {
		_distraction = (integer)value;
	} else if ("setEscapeStamina" == function) {
		_stamina = (integer)value;
	} else if ("setProgress" == function) {
		_progress = llJsonGetValue(value, ["progress"]);
	} else if ("setPuzzles" == function) {
		_puzzles = llJsonGetValue(value, ["puzzles"]);
	} else if ("resetRecoveryTimer" == function) {
		llSetTimerEvent((float)value);
	} else if ("setRestraints" == function) {
		_restraints = value;
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
	
	timer()
	{		
		if (!isBound()) {
			// Oops, shouldn't be here.  Just clean up
			_distraction = 0;
			_stamina = _maxStamina;
			llSetTimerEvent(0.0);
			return;
		}

		// Decrease distraction
		if (_distraction > 0) {
			_distraction -= 20/4;

			if (_distraction <= 0) {
				_distraction = 0;
				llOwnerSay("You are feeling less distracted.");
			}
			simpleRequest("setEscapeDistraction", (string)_distraction);
		}

		if (_stamina == _maxStamina) {
			return;
		}

		// Refresh stamina
		integer denominator = 4;
		if (hasFeat(_owner, "Resolute+")) {
			denominator = 1;
		} else if (hasFeat(_owner, "Resolute")) {
			denominator = 2;
		}

		_stamina += _maxStamina/denominator;
		if (_stamina >= _maxStamina) {
			_stamina = _maxStamina;
			llOwnerSay("You are feeling fully rested.");
		}
		
		simpleRequest("setEscapeStamina", (string)_stamina);
	}
}
