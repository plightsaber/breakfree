$import Modules.GeneralTools.lslm();
$import Modules.RestraintTools.lslm();
$import Modules.UserLib.lslm();


integer DEFAULT_STAMINA = 100;
float RECOVERY_RATE = 60.0;

string  _owner;
integer _distraction;
integer _maxStamina = DEFAULT_STAMINA;
integer _stamina;

string _progress;
string _puzzles;

integer _resting = TRUE;
integer _timerActive = FALSE;

// ===== Methods =====
setOwner(string user)
{
	_owner = user;
	_maxStamina = DEFAULT_STAMINA;

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
	} else if ("startRecoveryTimer" == function) {
		if (!_timerActive) {
			_timerActive = TRUE;
			llSetTimerEvent(RECOVERY_RATE);
		}

		_resting = TRUE;
		if ("Steadfast" == value) {
			_resting = FALSE;
		}

	} else if ("stopRecoveryTimer" == function) {
		_timerActive = FALSE;
		llSetTimerEvent(0.0);
	} else if ("setRestraints" == function) {
		_restraints = value;
	}
}

default
{
	on_rez(integer start_param)
	{
		llSetTimerEvent(RECOVERY_RATE);
	}

	state_entry()
	{
		llSetTimerEvent(RECOVERY_RATE);
	}

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
			simpleRequest("setEscapeStamina", (string)_stamina);
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
			simpleRequest("setEscapeStamina", (string)_stamina);
			return;
		}

		// Refresh stamina
		integer denominator = 4;
		if (hasFeat(_owner, "Resolute+")) {
			denominator = 1;
		} else if (hasFeat(_owner, "Resolute")) {
			denominator = 2;
		}

		if (!_resting) {
			denominator = denominator * 2;
		}

		_stamina += _maxStamina/denominator;
		if (_stamina >= _maxStamina) {
			_stamina = _maxStamina;
			llOwnerSay("You are feeling fully rested.");
		}

		simpleRequest("setEscapeStamina", (string)_stamina);
	}
}
