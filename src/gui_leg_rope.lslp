$import Modules.GuiTools.lslm();

// ===== Variables =====
string self;
//string restraint;    // JSON object

integer CHANNEL_ATTACHMENT = -9999277;

// General Settings
string gender = "female";

// Status
string legsBound = "free";  // 0: FREE; 1: BOUND; 2: HELPLESS  

// Colors
vector COLOR_WHITE = <1.0, 1.0, 1.0>;
vector COLOR_BROWN = <0.824, 0.549, 0.353>;

vector color = COLOR_WHITE;
list colors = ["White", "Brown"];
list colorVals = [COLOR_WHITE, COLOR_BROWN];

// GUI variables
key guiUserID;
list guiButtons;
integer guiChannel;
integer guiScreen;
integer guiScreenLast;
string guiText;
integer guiTimeout = 30;

string getSelf() {
    if (self != "") return self;

    self = llJsonSetValue(self, ["name"], "Rope");
    self = llJsonSetValue(self, ["part"], "leg");
    self = llJsonSetValue(self, ["hasColor"], "1");
    return self;
}

// ===== POSES =====
string POSE_STAND() {
    string object = "";
    object = llJsonSetValue(object, ["animBase"], "animLegPose_stand");
    object = llJsonSetValue(object, ["animFail"], "animLegStruggle_stand");
    object = llJsonSetValue(object, ["animJump"], "animLegJump_stand");
    object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_stand");
    object = llJsonSetValue(object, ["animWalkBack"], "animLegStandWalk");
    object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_stand");
    object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_stand");
    object = llJsonSetValue(object, ["jumpPower"], "5");
    object = llJsonSetValue(object, ["name"], "Stand");
    object = llJsonSetValue(object, ["poseDown"], "Sit");
    object = llJsonSetValue(object, ["poseFall"], "Front");
    object = llJsonSetValue(object, ["speedBack"], "20");
    object = llJsonSetValue(object, ["speedFwd"], "20");
    object = llJsonSetValue(object, ["stability"], "5");
    
    return object;
}

string POSE_SIT() {
    string object = "";
    object = llJsonSetValue(object, ["animBase"], "animLegPose_sit");
    object = llJsonSetValue(object, ["animFail"], "animLegStruggle_sit");
    object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_sit");
    object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_sit");
    object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_sit");
    object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_sit");
    object = llJsonSetValue(object, ["jumpPower"], "0");
    object = llJsonSetValue(object, ["name"], "Sit");
    object = llJsonSetValue(object, ["poseDown"], "Back");
    object = llJsonSetValue(object, ["poseFall"], "Back");
    object = llJsonSetValue(object, ["poseUp"], "Stand");
    object = llJsonSetValue(object, ["speedBack"], "12");
    object = llJsonSetValue(object, ["speedFwd"], "8");
    object = llJsonSetValue(object, ["stability"], "5");
    
    return object;
}

string POSE_KNEEL() {
    string object = "";
    object = llJsonSetValue(object, ["animBase"], "animLegPose_kneel");
    object = llJsonSetValue(object, ["animFail"], "animLegStruggle_kneel");
    object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_kneel");
    object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_kneel");
    object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_kneel");
    object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_kneel");
    object = llJsonSetValue(object, ["jumpPower"], "0");
    object = llJsonSetValue(object, ["name"], "Kneel");
    object = llJsonSetValue(object, ["poseDown"], "Front");
    object = llJsonSetValue(object, ["poseFall"], "Left");
    object = llJsonSetValue(object, ["poseUp"], "Stand");
    object = llJsonSetValue(object, ["speedBack"], "10");
    object = llJsonSetValue(object, ["speedFwd"], "10");
    object = llJsonSetValue(object, ["stability"], "5");
    
    return object;
}

string POSE_BACK() {
    string object = "";
    object = llJsonSetValue(object, ["animBase"], "animLegPose_groundBack");
    object = llJsonSetValue(object, ["animFail"], "animLegStruggle_groundBack");
    object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_groundBack");
    object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_groundBack");
    object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_groundBack");
    object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_groundBack");
    object = llJsonSetValue(object, ["jumpPower"], "0");
    object = llJsonSetValue(object, ["name"], "Back");
    object = llJsonSetValue(object, ["poseLeft"], "Right");
    object = llJsonSetValue(object, ["poseRight"], "Left");
    object = llJsonSetValue(object, ["poseUp"], "Sit");
    object = llJsonSetValue(object, ["speedBack"], "8");
    object = llJsonSetValue(object, ["speedFwd"], "8");
    object = llJsonSetValue(object, ["stability"], "5");
    
    return object;
}

string POSE_FRONT() {
    string object = "";
    object = llJsonSetValue(object, ["animBase"], "animLegPose_groundFront");
    object = llJsonSetValue(object, ["animFail"], "animLegStruggle_groundFront");
    object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_groundFront");
    object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_groundFront");
    object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_groundFront");
    object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_groundFront");
    object = llJsonSetValue(object, ["jumpPower"], "0");
    object = llJsonSetValue(object, ["name"], "Front");
    object = llJsonSetValue(object, ["poseLeft"], "Left");
    object = llJsonSetValue(object, ["poseRight"], "Right");
    object = llJsonSetValue(object, ["poseUp"], "Kneel");
    object = llJsonSetValue(object, ["speedBack"], "8");
    object = llJsonSetValue(object, ["speedFwd"], "8");
    object = llJsonSetValue(object, ["stability"], "5");
    
    return object;
}

string POSE_LEFT() {
    string object = "";
    object = llJsonSetValue(object, ["animBase"], "animLegPose_groundLeft");
    object = llJsonSetValue(object, ["animFail"], "animLegStruggle_groundLeft");
    object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_groundLeft");
    object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_groundLeft");
    object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_groundLeft");
    object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_groundLeft");
    object = llJsonSetValue(object, ["jumpPower"], "0");
    object = llJsonSetValue(object, ["name"], "Left");
    object = llJsonSetValue(object, ["poseLeft"], "Back");
    object = llJsonSetValue(object, ["poseRight"], "Front");
    object = llJsonSetValue(object, ["poseUp"], "Sit");
    object = llJsonSetValue(object, ["speedBack"], "8");
    object = llJsonSetValue(object, ["speedFwd"], "8");
    object = llJsonSetValue(object, ["stability"], "5");
    
    return object;
}

string POSE_RIGHT() {
    string object = "";
    object = llJsonSetValue(object, ["animBase"], "animLegPose_groundRight");
    object = llJsonSetValue(object, ["animFail"], "animLegStruggle_groundRight");
    object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_groundRight");
    object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_groundRight");
    object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_groundRight");
    object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_groundRight");
    object = llJsonSetValue(object, ["jumpPower"], "0");
    object = llJsonSetValue(object, ["name"], "Right");
    object = llJsonSetValue(object, ["poseLeft"], "Front");
    object = llJsonSetValue(object, ["poseRight"], "Back");
    object = llJsonSetValue(object, ["poseUp"], "Sit");
    object = llJsonSetValue(object, ["speedBack"], "8");
    object = llJsonSetValue(object, ["speedFwd"], "8");
    object = llJsonSetValue(object, ["stability"], "5");
    
    return object;
}

string POSE_HOGFRONT() {
    string object = "";
    object = llJsonSetValue(object, ["animBase"], "animLegPose_hogFront");
    object = llJsonSetValue(object, ["animFail"], "animLegStruggle_hogFront");
    object = llJsonSetValue(object, ["animSuccess"], "animLegStruggle_hogFront");
    object = llJsonSetValue(object, ["animWalkBack"], "animLegWalk_hogFront");
    object = llJsonSetValue(object, ["animWalkFwd"], "animLegWalk_hogFront");
    object = llJsonSetValue(object, ["animWobble"], "animLegStruggle_hogFront");
    object = llJsonSetValue(object, ["jumpPower"], "0");
    object = llJsonSetValue(object, ["name"], "Front");
//    object = llJsonSetValue(object, ["poseLeft"], "Left");
//    object = llJsonSetValue(object, ["poseRight"], "Right");
    object = llJsonSetValue(object, ["speedBack"], "6");
    object = llJsonSetValue(object, ["speedFwd"], "6");
    object = llJsonSetValue(object, ["stability"], "5");
    
    return object;
}

initGui(key prmID, integer prmScreen) {
    guiUserID = prmID;

    if (guiID) { llListenRemove(guiID); }
    guiChannel = (integer)llFrand(-9998) - 1;
    guiID = llListen(guiChannel, "", guiUserID, "");
    gui(prmScreen);
}

sendAvailabilityInfo () {
    simpleRequest("addAvailableRestraint", getSelf());
}

// ===== GUI =====
gui(integer prmScreen) {
    // Reset Busy Clock
    llSetTimerEvent(guiTimeout);

    string btn10 = " "; string btn11 = " ";         string btn12 = " ";
    string btn7 = " ";  string btn8 = " ";          string btn9 = " ";
    string btn4 = " ";  string btn5 = " ";          string btn6 = " ";
    string btn1 = "<<Back>>";  string btn2 = "<<Done>>";   string btn3 = " ";
    
    list mpButtons;
    guiText = " ";
        
    // GUI: Main
    if (prmScreen == 0) {
        btn3 = "<<Color>>";
        if (legsBound != "free") { btn4 = "Untie"; }

        btn7 = "Ankles";
        btn8 = "Thighs";
        btn9 = "Tight";

        // TODO: Only available if arms bound with back, b+sides, uback, or uback+sides
        btn10 = "Hogtie";
        btn12 = "Tight Hogtie";
    }
    
    // GUI: Colorize
    else if (prmScreen == 100) {
        guiText = "Choose a color for the leg ropes.";
        mpButtons = multipageGui(colors, 3, multipageIndex);
    }

    if (prmScreen != guiScreen) { guiScreenLast = guiScreen; }    
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
bindLegs(string prmType, integer prmSend) {    
    
    if (prmType == "free") { 
        setLegsBound("free"); 
        if (prmSend) { simpleRequest("bindLegs", "free"); }
    } else {
        setLegsBound("bound");
        
        string restraint;
        restraint = llJsonSetValue(restraint, ["canCut"], "1");
        restraint = llJsonSetValue(restraint, ["canEscape"], "1");
        restraint = llJsonSetValue(restraint, ["canUseItem"], "1");
        restraint = llJsonSetValue(restraint, ["type"], "knot");

        if (prmType == "Ankles") {
            restraint = llJsonSetValue(restraint, ["difficulty"], "5");
            restraint = llJsonSetValue(restraint, ["tightness"], "5");

            restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, [POSE_STAND(), POSE_SIT(), POSE_KNEEL(), POSE_BACK(), POSE_FRONT(), POSE_LEFT(), POSE_RIGHT()]));
            restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["lrAnkle"]));
        } else if (prmType == "Thighs") {
            restraint = llJsonSetValue(restraint, ["difficulty"], "5");
            restraint = llJsonSetValue(restraint, ["tightness"], "5");

            restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, [POSE_STAND(), POSE_SIT(), POSE_KNEEL(), POSE_BACK(), POSE_FRONT(), POSE_LEFT(), POSE_RIGHT()]));
            restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["lrThigh"]));
        } else if (prmType == "Tight") {
            restraint = llJsonSetValue(restraint, ["difficulty"], "7");
            restraint = llJsonSetValue(restraint, ["tightness"], "15");

            restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, [POSE_STAND(), POSE_SIT(), POSE_KNEEL(), POSE_BACK(), POSE_FRONT(), POSE_LEFT(), POSE_RIGHT()]));
            restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["lrAnkle", "lrThigh"]));
        } else if (prmType == "Hogtie") {
            restraint = llJsonSetValue(restraint, ["difficulty"], "8");
            restraint = llJsonSetValue(restraint, ["tightness"], "10");

            restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, [POSE_HOGFRONT()]));
            restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["lrAnkle"]));
        } else if (prmType == "Tight Hogtie") {
            restraint = llJsonSetValue(restraint, ["difficulty"], "8");
            restraint = llJsonSetValue(restraint, ["tightness"], "15");

            restraint = llJsonSetValue(restraint, ["poses"], llList2Json(JSON_ARRAY, [POSE_HOGFRONT()]));
            restraint = llJsonSetValue(restraint, ["attachments"], llList2Json(JSON_ARRAY, ["lrAnkle", "lrThigh"]));
        }

        if (prmSend) { simpleRequest("bindLegs", restraint); }
    }
}

// Color Functions
setColorByName(string prmColorName) {
    integer tmpColorIndex = llListFindList(colors, [prmColorName]);
    setColor(llList2Vector(colorVals, tmpColorIndex));
}
setColor(vector prmColor) {
    color = prmColor;
    
    string tmpRequest = "";
    tmpRequest = llJsonSetValue(tmpRequest, ["color"], (string)color);
    tmpRequest = llJsonSetValue(tmpRequest, ["attachment"], "leg");
    tmpRequest = llJsonSetValue(tmpRequest, ["userKey"], (string)llGetOwner());

    simpleAttachedRequest("setColor", tmpRequest);
    simpleRequest("setColor", tmpRequest);
}

// ===== Gets =====
string getName() {
    return llGetDisplayName(llGetOwner());
}

// ===== Sets =====
setGender(string prmGender) {
    gender = prmGender;
}

setLegsBound(string prmLegsBound) {
    legsBound = prmLegsBound;
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

simpleAttachedRequest(string prmFunction, string prmValue) {
    string request = "";
    request = llJsonSetValue(request, ["function"], prmFunction);
    request = llJsonSetValue(request, ["value"], prmValue);
    llRegionSayTo(llGetOwner(), CHANNEL_ATTACHMENT, request);
}

// ===== Event Controls =====
default {
    listen(integer prmChannel, string prmName, key prmID, string prmText) {
        if (prmChannel = guiChannel) {
            if (prmText == "<<Done>>") { exit("done"); return; }
            else if (prmText == " ") { gui(guiScreen); return;}
            else if (prmText == "<<Back>>") { 
                if (guiScreen != 0) { gui(guiScreenLast); return;}
                
                guiRequest("gui_bind", TRUE, guiUserID, 0);
                return; 
            }
            
            if (prmText == "Untie") {
                bindLegs("free", TRUE);
                gui(guiScreen);
                return;
            }

            if (guiScreen == 0) {
                if (prmText == "<<Color>>") {
                    gui(100);
                } else {
                    bindLegs(prmText, TRUE);
                    gui(guiScreen);
                }
                return;
            } else if (guiScreen == 100) {
                setColorByName(prmText);
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
        else if (function == "bindLegs") { bindLegs(value, FALSE); }
        else if (function == "getAvailableRestraints") { sendAvailabilityInfo(); }
        else if (function == "requestColor") {
            if (llJsonGetValue(value, ["attachment"]) != "leg") { return; }
            if (llJsonGetValue(value, ["name"]) != "rope") { return; }
            setColor(color);
        }
        else if (function == "gui_leg_rope") {
            key userkey = (key)llJsonGetValue(prmText, ["userkey"]);
            integer screen = 0;
            if ((integer)llJsonGetValue(prmText, ["restorescreen"]) && guiScreenLast) { screen = guiScreenLast;}
            initGui(userkey, screen);
        } else if (function == "resetGUI") {
            exit("");
        }
    }

    timer() {
        exit("timeout");
    }
}
