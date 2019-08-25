string activePart;

// Avi Settings
string gender = "female";
list SKILLS = [];
integer DEX = 1;
integer STR = 1;
integer INT = 1;

// Foreign Avi Settings
string helper_gender = "female";
integer helper_DEX = 1;
integer helper_STR = 1;
integer helper_INT = 1;

// GUI variables
key guiUserID;
list guiButtons;
integer guiChannel;
integer guiID;
integer guiScreen;
integer guiScreenLast;
string guiText;
integer guiTimeout = 30;

// Bindings
// Arm
integer arm_canEscape;
integer arm_canCut;
integer arm_difficulty;
integer arm_tightness;
string arm_type;
// TODO: Tensile strength?

/// Leg
integer leg_canEscape;
integer leg_canCut;
integer leg_difficulty;
integer leg_tightness;
string leg_type;
// TODO: Tensile strength?

// Gag
integer gag_canEscape;
integer gag_canCut;
integer gag_difficulty;
integer gag_tightness;
string gag_type;

// Escape Vars
list struggle_puzzle;
integer struggle_progress;
string actionmsg;

init(key prmID, integer prmScreen) {
    guiUserID = prmID;

    if (guiID) { llListenRemove(guiID); }
    guiChannel = (integer)llFrand(-9998) - 1;
    guiID = llListen(guiChannel, "", guiUserID, "");
    gui(prmScreen);
}

// ===== Main Functions =====
integer assisted() { return guiUserID != llGetOwner(); }

escape(string prmVerb) {
    string tmpAction;
    string tmpMessage = "";
    integer tmpSuccess = FALSE;

    if (prmVerb == "Twist") { tmpAction = "1"; } 
    else if (prmVerb == "Squirm") { tmpAction = "2"; } 
    else if (prmVerb == "Struggle") { tmpAction = "3"; } 
    else if (prmVerb == "Thrash") { tmpAction = "4"; }
    
    else if (prmVerb == "Pick") { tmpAction = "1";}
    else if (prmVerb == "Pluck") { tmpAction = "2";}
    else if (prmVerb == "Pull") { tmpAction = "3";}
    else if (prmVerb == "Yank") { tmpAction = "4";}
    
    // Execute action
    if (tmpAction == llList2String(struggle_puzzle, struggle_progress)) {
        actionmsg ="You think you've made some progress.";
        tmpSuccess = TRUE;
        if (assisted()) { struggle_progress += 5;  }   // TODO: Do this better?
        else { struggle_progress++; }
        
        if (struggle_progress >= llGetListLength(struggle_puzzle)) {
            // Progress based on strength 
            // TODO: and energy?
            integer tmpProgress = roll(1, llFloor(STR/2));
            if (!assisted()) { 
                llOwnerSay("Your restraints have loosened.");

                // Earn experience!
                if (activePart == "arm") { simpleRequest("addExp", (string)arm_difficulty); }
                if (activePart == "leg") { simpleRequest("addExp", (string)leg_difficulty); }
                if (activePart == "gag") { simpleRequest("addExp", (string)gag_difficulty); }
            }
            
            struggle_puzzle = newPuzzle(activePart);
            
            if (activePart == "arm") { arm_tightness -= tmpProgress; } 
            else if (activePart == "leg") { leg_tightness -= tmpProgress; }
            else if (activePart == "gag") { gag_tightness -= tmpProgress; }
        } else {
            // TODO: Reset progress based on Dex/Energy?
        }
    } else {
        actionmsg = "Your " + prmVerb + " didn't help.";
        if (!assisted() && struggle_progress > 0) { struggle_progress--; }
    }

    // Animate
    if (!assisted()) {
        if (tmpSuccess) { simpleRequest("animate", "animation_" + activePart + "_success"); }
        else { simpleRequest("animate", "animation_" + activePart + "_failure"); }
    }
    
    if (restraintFreed()) {
        gui(0);
    } else {
        gui(guiScreen);
    }    
}

integer restraintFreed() {
    if (activePart == "arm" && arm_tightness <= 0) {    
        llWhisper(0, getOwnerName() + " is freed from " + getOwnerPronoun("her") +"  arm restraints.");
        bindArms("free");
        simpleRequest("bindArms", "free");
        return TRUE;
    }
    
    else if (activePart == "leg" && leg_tightness <= 0) {
        llWhisper(0, getOwnerName() + " is freed from " + getOwnerPronoun("her") +"  leg restraints.");
        bindLegs("free");
        simpleRequest("bindLegs", "free");
        return TRUE;
    }
    
    else if (activePart == "gag" && gag_tightness <= 0) {
        llWhisper(0, getOwnerName() + " is freed from " + getOwnerPronoun("her") +" gag.");
        bindGag("free");
        simpleRequest("bindGag", "free");
        return TRUE;
    }
    return FALSE;
}

list newPuzzle(string prmRestraint) {
    integer tmpDifficulty;
    struggle_progress = 0;
    if (prmRestraint == "arm") { tmpDifficulty = arm_difficulty; }
    if (prmRestraint == "leg") { tmpDifficulty = leg_difficulty; }
    if (prmRestraint == "gag") { tmpDifficulty = gag_difficulty; }
    
    // Modify difficulty based on DEX
    if (assisted()) { 
        // TODO: assisted difficulty
    } else {
        integer tmpDifficultyReduction = llFloor(DEX/2);
        if (tmpDifficultyReduction > (tmpDifficulty/2)) { tmpDifficultyReduction = llFloor(tmpDifficulty/2); }
        tmpDifficulty -= tmpDifficultyReduction;
    }
    // TODO: Energy?
    
    list tmpPuzzle = [];
    integer tmpIndex;
    for (tmpIndex = 0; tmpIndex < tmpDifficulty; tmpIndex++) {
        integer tmpDie = roll(1, 4);
        if (tmpDie == 1)       tmpPuzzle += "1";
        else if (tmpDie == 2)  tmpPuzzle += "2";
        else if (tmpDie == 3)  tmpPuzzle += "3";
        else if (tmpDie == 4)  tmpPuzzle += "4";
    }
    
    return tmpPuzzle;
}

string displayTightness(string prmRestraint) {
    integer tmpIndex;
    integer tmpTightness;
    string tmpDisplay;
    string tmpChar = " ";
    
    if (prmRestraint == "arm") { tmpTightness = arm_tightness; }
    if (prmRestraint == "leg") { tmpTightness = leg_tightness; }
    if (prmRestraint == "gag") { tmpTightness = gag_tightness; }
    
    if (tmpTightness > 30) {
        tmpChar = "=";
        tmpTightness -= 30;
        for (tmpIndex = 0; tmpIndex < tmpTightness; tmpIndex ++) { tmpDisplay += "#"; }
    } else if (tmpTightness > 20) {
        tmpChar = "~";
        tmpTightness -= 20;
        for (tmpIndex = 0; tmpIndex < tmpTightness; tmpIndex ++) { tmpDisplay += "="; }
    } else if (tmpTightness > 10) {
        tmpChar = "-";
        tmpTightness -= 10;
        for (tmpIndex = 0; tmpIndex < tmpTightness; tmpIndex ++) { tmpDisplay += "~"; }
    } else {
        tmpChar = " ";
        for (tmpIndex = 0; tmpIndex < tmpTightness; tmpIndex ++) { tmpDisplay += "-"; }
    }
    
    while (tmpIndex < 10) {
        tmpDisplay += tmpChar;
        tmpIndex++;
    }
    return tmpDisplay;
}

// ===== GUI =====
getGui(string prmPart) {
    string tmpType;
    activePart = prmPart;
    actionmsg = "";

    if (activePart == "arm") { tmpType = arm_type; }
    else if (activePart == "leg") { tmpType = leg_type; }
    else if (activePart == "gag") { tmpType = gag_type; }

    struggle_puzzle = newPuzzle(activePart);

    if (guiUserID == llGetOwner() && isArmsBound()) {
        gui(10);
        return;
    } else {
        gui(20);
        return;
    }
}

gui(integer prmScreen) {
    // Reset Busy Clock
    llSetTimerEvent(guiTimeout);

    string btn10 = " "; string btn11 = " ";         string btn12 = " ";
    string btn7 = " ";  string btn8 = " ";          string btn9 = " ";
    string btn4 = " ";  string btn5 = " ";          string btn6 = " ";
    string btn1 = " ";  string btn2 = "<<Done>>";   string btn3 = " ";
    
    guiText = " ";
    
    // GUI: Main
    if (prmScreen == 0) {
        if (guiUserID == llGetOwner()) { btn1 = "<<Back>>"; }
        
        // reset previous screen
        guiScreenLast = 0;
        
        if (arm_tightness > 0) { btn4 = "Free Arms"; }
        if (leg_tightness > 0) { btn5 = "Free Legs"; }
        if (gag_tightness > 0) { btn6 = "Free Gag"; }
        
        // TODO: Get quick release options
    } 
    
    // GUI: Self Escape
    else if (prmScreen == 10) {
        btn4 = "Twist";
        btn5 = "Squirm";
        btn6 = "Struggle";
        btn8 = "Thrash";
        
        guiText = "Restraint: " + ToTitle(activePart);  // TODO: Get full name of restraint
        guiText += "\nTightness: " + displayTightness(activePart);
        // TODO: Show suggestion based on INT
        if (actionmsg) { guiText += "\n" + actionmsg; }
    }
    
    // GUI Assisted Escape
    else if (prmScreen == 20) {
        btn4 = "Pick";
        btn5 = "Pluck";
        btn6 = "Pull";
        btn8 = "Yank";
        
        guiText = "Restraint: " + ToTitle(activePart);  // TODO: Get full name of restraint
        guiText += "\nTightness: " + displayTightness(activePart);
        // TODO: Show suggestion based on INT
        if (actionmsg) { guiText += "\n" + actionmsg; }
    }

    if (prmScreen != guiScreen) { guiScreenLast = guiScreen; }    
    if (btn1 == " " && (prmScreen != 0)) { btn1 = "<<Back>>"; };

    guiScreen = prmScreen;
    guiButtons = [btn1, btn2, btn3];

    if (btn4+btn5+btn6 != "   ") { guiButtons += [btn4, btn5, btn6]; }
    if (btn7+btn8+btn9 != "   ") { guiButtons += [btn7, btn8, btn9]; }
    if (btn10+btn11+btn12 != "   ") { guiButtons += [btn10, btn11, btn12]; }
    llDialog(guiUserID, guiText, guiButtons, guiChannel);
}

exit(string prmReason) {
    llListenRemove(guiID);
    llSetTimerEvent(0.0);
    
    if (prmReason) { simpleRequest("resetGUI", prmReason); }
}

// ===== Gets =====
string getOwnerName() {
    return llGetDisplayName(llGetOwner());
}

string getOwnerPronoun(string prmPlaceholder) {
    // TODO: Get gender
    string gender = "female";
    if (gender == "female") { return prmPlaceholder; }
    else {
    }

    return "";
}

integer isArmsBound() {
    return arm_tightness > 0;
}

// ===== Sets =====
bindArms(string prmInfo) {
    if (prmInfo == "free") {
        arm_tightness = 0;
        // TODO: remove settings? (May not be necessary)
        return;
    }

    arm_canCut = (integer)llJsonGetValue(prmInfo, ["canCut"]);    
    arm_canEscape = (integer)llJsonGetValue(prmInfo, ["canEscape"]);
    arm_difficulty = (integer)llJsonGetValue(prmInfo, ["difficulty"]);
    arm_tightness = (integer)llJsonGetValue(prmInfo, ["tightness"]);
    arm_type = llJsonGetValue(prmInfo, ["type"]);
    // TODO: Tensile strength?

    string type = llJsonGetValue(prmInfo, ["value"]);
}

bindLegs(string prmInfo) {
    if (prmInfo == "free") {
        leg_tightness = 0;
        // TODO: remove settings? (May not be necessary)
        return;
    }

    leg_canCut = (integer)llJsonGetValue(prmInfo, ["canCut"]);    
    leg_canEscape = (integer)llJsonGetValue(prmInfo, ["canEscape"]);
    leg_difficulty = (integer)llJsonGetValue(prmInfo, ["difficulty"]);
    leg_tightness = (integer)llJsonGetValue(prmInfo, ["tightness"]);
    leg_type = llJsonGetValue(prmInfo, ["type"]);
    // TODO: Tensile strength?    

    string type = llJsonGetValue(prmInfo, ["value"]);
}

bindGag(string prmInfo) {
    if (prmInfo == "free") {
        gag_tightness = 0;
        // TODO: remove settings? (May not be necessary)
        return;
    }

    gag_canCut = (integer)llJsonGetValue(prmInfo, ["canCut"]);    
    gag_canEscape = (integer)llJsonGetValue(prmInfo, ["canEscape"]);
    gag_difficulty = (integer)llJsonGetValue(prmInfo, ["difficulty"]);
    gag_tightness = (integer)llJsonGetValue(prmInfo, ["tightness"]);
    gag_type = llJsonGetValue(prmInfo, ["type"]);
    // TODO: Tensile strength?

    string type = llJsonGetValue(prmInfo, ["value"]);
}

setGender(string prmGender) {
    gender = prmGender;
}

setStats(string stats) {
    DEX = (integer)llJsonGetValue(stats, ["dex"]);
    INT = (integer)llJsonGetValue(stats, ["int"]);
    STR = (integer)llJsonGetValue(stats, ["str"]);
    SKILLS = llJson2List(llJsonGetValue(stats, ["skills"]));
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

simpleRequest(string prmFunction, string prmValue) {
    string request = "";
    request = llJsonSetValue(request, ["function"], prmFunction);
    request = llJsonSetValue(request, ["value"], prmValue);
    llMessageLinked(LINK_THIS, 0, request, NULL_KEY);
}

integer roll (integer dice, integer sides) {
    integer result = 1;
    integer i;
    for (i = 0; i < dice; i++) {
        result += llCeil(llFrand(sides));
    }
    return result;
}

// ===== Contrib Functions =====
string ToTitle(string src) {
    list words = llParseString2List(llToLower(src), [], [".",";","?","!","\""," ","\n"]);
    integer ll = llGetListLength(words);
    integer lc = -1;
    string word = "";
    while((++lc) < ll)
    {
        string cap = llToUpper(llGetSubString((word = llList2String(words, lc)), 0, 0));
        words = llListReplaceList(words, [(cap + llDeleteSubString(word, 0, 0))], lc, lc);
    }
    return llDumpList2String(words, "");
}


// ===== Event Controls =====

default {
    listen(integer prmChannel, string prmName, key prmID, string prmText) {
        if (prmChannel = guiChannel) {
            if (prmText == "<<Done>>") { exit("done"); return; }
            else if (prmText == " ") { gui(guiScreen); return; }
            else if (guiScreen !=0 && prmText == "<<Back>>") { gui(guiScreenLast); return; }

            if (guiScreen == 0) {
                     if (prmText == "Free Arms") { getGui("arm"); }
                else if (prmText == "Free Legs") { getGui("leg"); }
                else if (prmText == "Free Gag") { getGui("gag"); }
                else if (prmText == "<<Back>>") {
                    guiRequest("gui_owner", TRUE, guiUserID, 0);
                    return;
                }
            }
            else if (guiScreen == 10) {
                escape(prmText);
            } else if (guiScreen == 20) {
                escape(prmText);
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
        else if (function == "setStats") { setStats(value); }
        else if (function == "bindArms") { bindArms(value); }
        else if (function == "bindLegs") { bindLegs(value); }
        else if (function == "bindGag") { bindGag(value); }
        else if (function == "gui_escape") {
            key userkey = (key)llJsonGetValue(prmText, ["userkey"]);
            integer screen = 0;
            if ((integer)llJsonGetValue(prmText, ["restorescreen"]) && guiScreen) { screen = guiScreen;}
            init(userkey, screen);
        } else if (function == "resetGUI") {
            exit("");
        }
    }
    
    timer() {
        exit("timeout");
    }
}
