integer CHANNEL_LOCKGUARD = -9119;
integer CHANNEL_LOCKMEISTER = -8888;

string _mooring;
key _configQueryId;
integer _listenId;

// ===== Initializers =====
init()
{
	_configQueryId = llGetNotecardLine(".lockmeister", 0);	// Load config.

	if (_listenId) { llListenRemove(_listenId); }
	_listenId = llListen(CHANNEL_LOCKGUARD, "", "", "");
}

// ===== Main Methods =====
lockmeister(string message, key id)
{
	// Lockmeister V1
	if (message == (string)llGetOwner() + _mooring) {
		llRegionSayTo(id, CHANNEL_LOCKMEISTER, (string)llGetOwner() + _mooring + " ok");
	}

	// Lockmeister V2
	list params = llParseString2List(message, ["|"], []);
	if (llList2String(params, 0) != (string)llGetOwner()
		|| llList2String(params, 1) != "LMV2"
		|| llList2String(params, 2) != "RequestPoint"
		|| llList2String(params, 3) != _mooring
	) {
		return;
	}

	llRegionSayTo(id, CHANNEL_LOCKMEISTER, llDumpList2String( [llGetOwner(), "LMV2", "ReplyPoint", _mooring, llGetKey()], "|" ));
}

// ===== Events =====
default
{
	on_rez(integer prmStart) { init(); }
	state_entry() { init(); }

	dataserver(key queryID, string configData)
	{
		if (queryID == _configQueryId) {
			_mooring = configData;
		}
	}

	listen(integer channel, string name, key id, string message)
	{
		// Only answer when attached
		if (!llGetAttached()) { return; }

		if (CHANNEL_LOCKMEISTER == channel) {
			lockmeister(message, id);
			return;
		}
    }
}
