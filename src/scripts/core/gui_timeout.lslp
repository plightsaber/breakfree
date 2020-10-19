$import Modules.GeneralTools.lslm();

integer GUI_TIMEOUT = 10;

key _activeKey;

// ===== Main functions ====
initTimer() {
	llSetTimerEvent(GUI_TIMEOUT);
}

// ===== Events =====
executeFunction(string function, string json)
{
	string value = llJsonGetValue(json, ["value"]);

	if ("resetGuiTimer" == function) {
		initTimer();
	} else if ("setTimedOut" == function) {
		llSetTimerEvent(0.0);
	} else if ("setToucher" == function) {
		_activeKey = llJsonGetValue(value, ["key"]);
	}
}

default
{
	state_entry()
	{
		initTimer();
	}

	on_rez(integer start_param)
	{
		initTimer();
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
		llSetTimerEvent(0.0);
		simpleRequest("setTimedOut", "1");
		simpleRequest("startRecoveryTimer", "timeout");
	}
}
