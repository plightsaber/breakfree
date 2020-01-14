// ===== Variables =====
integer CHANNEL_GAGCHAT = 999424;

integer gagChatID;

integer mouthOpen;
integer mouthGarbled;
integer mouthMuffled;
integer mouthSealed;

init() {
	if (gagChatID) { llListenRemove(gagChatID); }
	gagChatID = llListen(CHANNEL_GAGCHAT, "", llGetOwner(), "");

	if (isGagged()) {
		llOwnerSay("@redirchat:" + (string)CHANNEL_GAGCHAT + "=add");
		llListenControl(gagChatID, TRUE);
	}
}

// ===== Main Function =====

bindGag(string prmInfo) {
	mouthOpen = FALSE;
	mouthGarbled = FALSE;
	mouthMuffled = FALSE;
	mouthSealed = FALSE;

	if (prmInfo == "free") {
		llOwnerSay("@redirchat:" + (string)CHANNEL_GAGCHAT + "=rem");
		llListenControl(gagChatID, FALSE);
		return;
	}

	list liGags = llJson2List(prmInfo);
	integer index;
	for (index = 0; index < llGetListLength(liGags); ++index) {
		string gag = llList2String(liGags, index);
		if ("1" == llJsonGetValue(gag, ["mouthOpen"])) { mouthOpen = TRUE; }
		if ("1" == llJsonGetValue(gag, ["garble", "garbled"])) { mouthGarbled = TRUE; };
		if ("1" == llJsonGetValue(gag, ["garble", "muffled"])) { mouthMuffled = TRUE; };
		if ("1" == llJsonGetValue(gag, ["garble", "sealed"])) { mouthSealed = TRUE; };
	}

	if (mouthOpen || mouthGarbled || mouthMuffled || mouthSealed) {
		llOwnerSay("@redirchat:" + (string)CHANNEL_GAGCHAT + "=add");
		llListenControl(gagChatID, TRUE);
	} else {
		llOwnerSay("@redirchat:" + (string)CHANNEL_GAGCHAT + "=rem");
		llListenControl(gagChatID, FALSE);
	}
}

convertSpeech(string strOriginal) {
	string strNew = "";
	integer intMessageLength = llStringLength(strOriginal);
	integer intChar;
	string	char;
	integer isUpper;

	for (intChar = 0; intChar < intMessageLength; intChar++) {

		// get information about char
		char = llGetSubString(strOriginal, intChar, intChar);
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
		strNew = strNew + char;
	}

	// set name to speaker
	string object_name = llGetObjectName();
	llSetObjectName(llGetDisplayName(llGetOwner())); // TODO: Get Name
	llWhisper(0, strNew);
	llSetObjectName(object_name);
}

integer isGagged() {
	return mouthOpen || mouthGarbled || mouthMuffled || mouthSealed;
}

// ===== Other Functions =====
debug(string output) {
	// TODO: global enable/disable?
	llOwnerSay(output);
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

		if (function == "bindGag") { bindGag(value); }
	}

	listen(integer prmChannel, string prmName, key senderID, string prmMessage) {
		convertSpeech(prmMessage);
	}
}
