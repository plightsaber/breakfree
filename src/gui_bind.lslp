$import Modules.GuiTools.lslm();

string self;  // JSON object

// General Settings
string gender = "female";

// Status
integer armsBound = FALSE;
integer legsBound = FALSE;
integer gagBound = FALSE;

// Tether Variables
integer armsTetherable;
integer legsTetherable;

list availablePoses;

// Restaint Lists
list armRestraints;
list legRestraints;
list gagRestraints;

// GUI variables
key guiUserID;
list guiButtons;
integer guiChannel;
integer guiScreen;
integer guiScreenLast;
string guiText;
integer guiTimeout = 30;

init() {
  armRestraints = ["Unbound"];
  legRestraints = ["Unbound"];
  gagRestraints = ["Unbound"];

  simpleRequest("getAvailableRestraints", "all");
}

initGui(key prmID, integer prmScreen) {
  guiUserID = prmID;
  simpleRequest("setVillainID", (string)guiUserID);

  if (guiID) { llListenRemove(guiID); }
  guiChannel = (integer)llFrand(-9998) - 1;
  guiID = llListen(guiChannel, "", guiUserID, "");
  gui(prmScreen);
}

// ===== GUI =====
gui(integer prmScreen) {
  // Reset Busy Clock
  llSetTimerEvent(guiTimeout);

  string btn10 = " "; string btn11 = " ";     string btn12 = " ";
  string btn7 = " ";  string btn8 = " ";      string btn9 = " ";
  string btn4 = " ";  string btn5 = " ";      string btn6 = " ";
  string btn1 = " ";  string btn2 = "<<Done>>";   string btn3 = " ";

  if (guiUserID == llGetOwner()) { btn1 = "<<Back>>"; }   // Allow users to bind selves and return to own menu

  list mpButtons;

  guiText = " ";

  // GUI: Main
  if (prmScreen == 0) {
    // reset previous screen
    guiScreenLast = 0;

    if (armsTetherable) { btn7 = "Tether Arms"; }
    if (legsTetherable) { btn7 = "Tether Legs"; }

    btn4 = "Bind Arms";
    btn5 = "Bind Legs";
    btn6 = "Gag";

    if (llGetListLength(getAvailablePoses()) > 1) { btn3 = "Position"; }

    // TODO: Get quick release options
  }

  // GUI: Bind Arms
  if (prmScreen == 10) {
    guiText = "What do you want to bind " + getName() + "'s arms with?";
    mpButtons = multipageGui(armRestraints, 3, multipageIndex);
  }

  // GUI: Bind Legs
  if (prmScreen == 20) {
    guiText = "What do you want to bind " + getName() + "'s legs with?";
    mpButtons = multipageGui(legRestraints, 3, multipageIndex);
  }

  // GUI: Bind Gag
  if (prmScreen == 30) {
    guiText = "What do you want to gag " + getName() + " with?";
    mpButtons = multipageGui(gagRestraints, 3, multipageIndex);
  }

  // GUI: Position
  if (prmScreen == 70) {
    guiText = "How do you want to pose " + getName() + "?";
    mpButtons = multipageGui(getAvailablePoses(), 3, multipageIndex);
  }

  if (prmScreen != guiScreen) { guiScreenLast = guiScreen; }
  if (btn1 == " " && (prmScreen != 0)) { btn1 = "<<Back>>"; };

  guiScreen = prmScreen;
  guiButtons = [btn1, btn2, btn3];

  if (btn4+btn5+btn6 != "   ") { guiButtons += [btn4, btn5, btn6]; }
  if (btn7+btn8+btn9 != "   ") { guiButtons += [btn7, btn8, btn9]; }
  if (btn10+btn11+btn12 != "   ") { guiButtons += [btn10, btn11, btn12]; }

  // Load MP Buttons - hopefully the lengths were configured correctly!
  if (llGetListLength(mpButtons)) { guiButtons += mpButtons; }

  llDialog(guiUserID, guiText, guiButtons, guiChannel);
}

// ===== Main Functions =====
addAvailableRestraint(string prmInfo) {
  string tmpName = llJsonGetValue(prmInfo, ["name"]);
  string tmpPart = llJsonGetValue(prmInfo, ["part"]);
  integer hasColor = llJsonGetValue(prmInfo, ["hasColor"]) == "1";

  if (tmpPart == "arm") {
    armRestraints += tmpName;
  } else if (tmpPart == "leg") {
    legRestraints += tmpName;
  } else if (tmpPart == "gag") {
    gagRestraints += tmpName;
  }
}

// ===== Gets =====
string getName() {
  return llGetDisplayName(llGetOwner());
}

list getAvailablePoses() {
  return availablePoses;
}

// ===== Sets =====
setGender(string prmGender) {
  gender = prmGender;
}

setAvailablePoses(string prmPoses) {
  availablePoses = [];
  list tmpPoses = llJson2List(prmPoses);
  integer i;
  for (i = 0; i < llGetListLength(tmpPoses); i++) {
    availablePoses += llJsonGetValue(llList2String(tmpPoses, i), ["name"]);
  }
}

bindArms(string prmInfo) {
  if (prmInfo == "free") { armsBound = FALSE; armsTetherable = FALSE; }
  else {
    armsBound = TRUE;
    armsTetherable = llJsonGetValue(prmInfo, ["canTether"]) == "1";
  }
}

bindLegs(string prmInfo) {
  if (prmInfo == "free") { legsBound = FALSE; legsTetherable = FALSE; }
  else {
    legsBound = TRUE;
    legsTetherable = llJsonGetValue(prmInfo, ["canTether"]) == "1";
    setAvailablePoses(llJsonGetValue(prmInfo, ["poses"]));
  }
}

// ===== Other Functions =====
debug(string output) {
  // TODO: global enable/disable?
  llOwnerSay(output);
}

guiRequest(string prmGUI, integer prmRestore, key prmUserID, integer prmScreen) {
  string guiRequest = "";
  guiRequest = llJsonSetValue(guiRequest, ["function"], prmGUI);
  guiRequest = llJsonSetValue(guiRequest, ["restorescreen"], (string)prmRestore);
  guiRequest = llJsonSetValue(guiRequest, ["userkey"], (string)prmUserID);
  guiRequest = llJsonSetValue(guiRequest, ["value"], (string)prmScreen);
  llMessageLinked(LINK_THIS, 0, guiRequest, NULL_KEY);
  exit("");
}

// ===== Event Controls =====

default {
  state_entry() {
    init();
  }

  on_rez(integer prmStart) {
    init();
  }

  listen(integer prmChannel, string prmName, key prmID, string prmText) {
    if (prmChannel = guiChannel) {
      if (prmText == "<<Done>>") { exit("done"); return; }
      else if (prmText == " ") { gui(guiScreen); }
      else if (guiScreen !=0 && prmText == "<<Back>>") { gui(guiScreenLast); return; }

      else if (prmText == "Next >>") { multipageIndex ++; gui(guiScreen); return; }
      else if (prmText == "<< Previous") { multipageIndex --; gui(guiScreen); return; }

      if (guiScreen == 0) {
             if (prmText == "Bind Arms") { gui(10); }
        else if (prmText == "Bind Legs") { gui(20); }
        else if (prmText == "Gag") { gui(30); }
        else if (prmText == "Position") { gui(70); }
        else if (prmText == "Tether Arms") { guiRequest("gui_tether_arm", FALSE, guiUserID, 0); return; }
        else if (prmText == "Tether Legs") { guiRequest("gui_tether_leg", FALSE, guiUserID, 0); return; }
        else if (prmText == "<<Back>>") {
          guiRequest("gui_owner", FALSE, guiUserID, 0);
          return;
        }
      }
      else if (guiScreen == 10) {
        if (prmText == "Unbound") {
          armsBound = FALSE;
          armsTetherable = FALSE;
          simpleRequest("bindArms", "free");
          gui(guiScreen);
          return;
        }
        else { guiRequest("gui_arm_" + llToLower(prmText), FALSE, guiUserID, 0); return; }
      } else if (guiScreen == 20) {
        if (prmText == "Unbound") {
          legsBound = FALSE;
          legsTetherable = FALSE;
          simpleRequest("bindLegs", "free");
          gui(guiScreen);
          return;
        }
        else { guiRequest("gui_leg_" + llToLower(prmText), FALSE, guiUserID, 0); return; }
      } else if (guiScreen == 30) {
        if (prmText == "Unbound") {
          gagBound = FALSE;
          simpleRequest("bindGag", "free");
          gui(guiScreen);
          return;
        }
        else { guiRequest("gui_gag_" + llToLower(prmText), FALSE, guiUserID, 0); return; }
      } else if (guiScreen == 70) {
        simpleRequest("setPose", prmText);
        gui(guiScreen);
        return;
      }
    }
  }

  link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
    string function;
    string value;

    if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
      debug(prmText);
      return;
    }
    value = llJsonGetValue(prmText, ["value"]);

         if (function == "setGender") { setGender(value); }
    else if (function == "bindArms") { bindArms(value); }
    else if (function == "bindLegs") { bindLegs(value); }
    else if (function == "addAvailableRestraint") { addAvailableRestraint(value); }
    else if (function == "gui_bind") {
      key userkey = (key)llJsonGetValue(prmText, ["userkey"]);
      integer screen = 0;
      if ((integer)llJsonGetValue(prmText, ["restorescreen"]) && guiScreen) { screen = guiScreen;}
      initGui(userkey, screen);
    } else if (function == "resetGUI") {
      exit("");
    }
  }

  timer() {
    exit("timeout");
  }
}
