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
  if (prmInfo == "free") {
    mouthOpen = FALSE;
    mouthGarbled = FALSE;
    mouthMuffled = FALSE;
    mouthSealed = FALSE;

    llOwnerSay("@redirchat:" + (string)CHANNEL_GAGCHAT + "=rem");
    llListenControl(gagChatID, FALSE);
  } else {
    mouthOpen = llJsonGetValue(prmInfo, ["mouthOpen"]) == "1";
    mouthGarbled = llJsonGetValue(prmInfo, ["mouthGarbled"]) == "1";
    mouthMuffled = llJsonGetValue(prmInfo, ["mouthMuffled"]) == "1";
    mouthSealed = llJsonGetValue(prmInfo, ["mouthSealed"]) == "1";

    if (mouthOpen || mouthGarbled || mouthMuffled || mouthSealed) {
      llOwnerSay("@redirchat:" + (string)CHANNEL_GAGCHAT + "=add");
      llListenControl(gagChatID, TRUE);
    } else {
      llOwnerSay("@redirchat:" + (string)CHANNEL_GAGCHAT + "=rem");
      llListenControl(gagChatID, FALSE);
    }
  }
}

convertSpeech(string strOriginal) {
  string strNew = "";
  integer intMessageLength = llStringLength(strOriginal);
  integer intChar;
  string  char;
  integer isUpper;

  for (intChar = 0; intChar < intMessageLength; intChar++) {

    // get information about char
    char = llGetSubString(strOriginal, intChar, intChar);
    if (!mouthMuffled && !mouthSealed) { isUpper = llToLower(char) != char; }
    else { isUpper = FALSE; }
    char = llToLower(char);

    if (mouthOpen || mouthGarbled) {
         if (char == "b")     char = "";
      else if (char == "d")     char = "n";
      else if (char == "f")     char = "h";
      else if (char == "j")     char = "y";
      else if (char == "l")     char = "n";
      else if (char == "p")     char = "h";
      else if (char == "q")     char = "k";
      else if (char == "s")     char = "h";
      else if (char == "t")     char = "h";
      else if (char == "v")     char = "w";
      else if (char == "x")     char = "k";
      else if (char == "z")     char = "";
    }

    if (isUpper)  char = llToUpper(char);
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
