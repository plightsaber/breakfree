$import Modules.GeneralTools.lslm();

// ===== Variables =====
integer CHANNEL_GAGCHAT = 9994240;
integer CHANNEL_GAGEMOTE = 9994241;

integer gagChatID;
integer emoteChatID;

integer _gagged;
integer mouthOpen;
integer mouthGarbled;
integer mouthMuffled;
integer mouthSealed;

string _currentRestraints;

init() {
	if (gagChatID) { llListenRemove(gagChatID); }
	gagChatID = llListen(CHANNEL_GAGCHAT, "", llGetOwner(), "");

	if (emoteChatID) { llListenRemove(emoteChatID); }
	emoteChatID = llListen(CHANNEL_GAGEMOTE, "", llGetOwner(), "");

	if (_gagged) {
		llOwnerSay("@redirchat:" + (string)CHANNEL_GAGCHAT + "=add");
		llOwnerSay("@rediremote:" + (string)CHANNEL_GAGEMOTE + "=add");
		llListenControl(gagChatID, TRUE);
	}
}

// ===== Main Function =====
setRestraints(string prmJson) {
	_currentRestraints = prmJson;
	_gagged = isSet(llJsonGetValue(_currentRestraints, ["gagged"]));
	if (!_gagged) {
		llOwnerSay("@redirchat:" + (string)CHANNEL_GAGCHAT + "=rem");
		llOwnerSay("@rediremote:" + (string)CHANNEL_GAGEMOTE + "=rem");
		llListenControl(gagChatID, FALSE);
		return;
	}
	mouthOpen = (isSet(llJsonGetValue(_currentRestraints, ["mouthOpen"])));
	mouthGarbled = (isSet(llJsonGetValue(_currentRestraints, ["speechGarbled"])));
	mouthMuffled = (isSet(llJsonGetValue(_currentRestraints, ["speechMuffled"])));
	mouthSealed = (isSet(llJsonGetValue(_currentRestraints, ["speechSealed"])));
	if (mouthOpen || mouthGarbled || mouthMuffled || mouthSealed) {
		llOwnerSay("@redirchat:" + (string)CHANNEL_GAGCHAT + "=add");
		llOwnerSay("@rediremote:" + (string)CHANNEL_GAGEMOTE + "=add");
		llListenControl(gagChatID, TRUE);
	} else {
		llOwnerSay("@redirchat:" + (string)CHANNEL_GAGCHAT + "=rem");
		llOwnerSay("@rediremote:" + (string)CHANNEL_GAGEMOTE + "=rem");
		llListenControl(gagChatID, FALSE);
	}
}

convertEmote(string strOriginal) {
	string strNew = "";
	integer intMessageLength = llStringLength(strOriginal);
	integer intChar;
	string	char;
	integer isUpper;

	integer activeGarble = FALSE;

	for (intChar = 0; intChar < intMessageLength; intChar++) {
		char = llGetSubString(strOriginal, intChar, intChar);
		if (char == "\"") {
			activeGarble = !activeGarble;
		} else if (activeGarble) {
			char = garbleChar(char);
		}
		strNew = strNew + char;
	}

	// set name to speaker
	string object_name = llGetObjectName();
	llSetObjectName(llGetDisplayName(llGetOwner())); // TODO: Get Name
	llWhisper(0, strNew);
	llSetObjectName(object_name);
}

string garbleChar(string char) {
	integer isUpper;

	if (!mouthMuffled) { isUpper = llToLower(char) != char; }
	else { isUpper = FALSE; }
	char = llToLower(char);

	if (mouthOpen) {
		if (char == "b")		char = "";
		else if (char == "d")	char = "e";
		else if (char == "f")	char = "h";
		else if (char == "j")	char = "y";
		else if (char == "l")	char = "h";
		else if (char == "p")	char = "h";
		else if (char == "q")	char = "k";
		else if (char == "s")	char = "h";
		else if (char == "t")	char = "h";
		else if (char == "v")	char = "w";
		else if (char == "x")	char = "k";
		else if (char == "z")	char = "";
	}
	if (mouthGarbled) {
		if (char == "c")		char = "h";
		else if (char == "r")	char = "h";
		else if (char == "g")	char = "n";
		else if (char == "k")	char = "ng";
		else if (char == "n")	char = "n";
	}

	if (mouthSealed) {
		if (char == "a")		char = "m";
		else if (char == "e")	char = "m";
		else if (char == "i")	char = "n";
		else if (char == "o")	char = "m";
		else if (char == "u")	char = "m";
		else if (char == "y")	char = "n";
	}

	if (mouthOpen && mouthGarbled && mouthSealed && mouthMuffled) {
		if (llRound(llFrand(2)) == 0) {
			char = "";
		} else if (char == "!") { char = "m"; }
	}

	if (isUpper) { char = llToUpper(char); }

	return char;
}

convertSpeech(string strOriginal) {
	string strNew = "";
	integer intMessageLength = llStringLength(strOriginal);
	integer intChar;
	string	char;

	for (intChar = 0; intChar < intMessageLength; intChar++) {
		// get information about char
		char = llGetSubString(strOriginal, intChar, intChar);
		strNew = strNew + garbleChar(char);
	}

	// set name to speaker
	string object_name = llGetObjectName();
	llSetObjectName(llGetDisplayName(llGetOwner())); // TODO: Get Name
	llWhisper(0, strNew);
	llSetObjectName(object_name);
}

// ===== Event Controls =====
default {
	state_entry() { init(); }
	on_rez(integer prmStart) { init(); }

	link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
		string function;
		string value;

		if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
			debug(prmText);
			return;
		}
		value = llJsonGetValue(prmText, ["value"]);

		if (function == "setRestraints") { setRestraints(value); }
	}

	listen(integer prmChannel, string prmName, key senderID, string prmMessage) {
		if (prmChannel == CHANNEL_GAGCHAT) {
			convertSpeech(prmMessage);
		} else if (prmChannel == CHANNEL_GAGEMOTE) {
			convertEmote(prmMessage);
		}
	}
}
