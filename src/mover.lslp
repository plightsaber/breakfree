string self;    // JSON object
list poses;
string pose;

// Tether Variables
key armTetherID;
key legTetherID;

integer armTetherLength;
integer legTetherLength;

// Global Variables
init() {
    llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS | PERMISSION_TRACK_CAMERA);
}

bindArms(string prmInfo) {
    if (prmInfo == "free") {
        armTetherID = NULL_KEY;
    }
}

bindLegs(string prmInfo) {
    init();
    
    if (prmInfo == "free") {
        llReleaseControls();
        pose = "";
        legTetherID = NULL_KEY;
        return;
    }

    poses = llJson2List(llJsonGetValue(prmInfo, ["poses"]));
    string poseName = llJsonGetValue(pose, ["name"]);
    if (poseName == JSON_INVALID) { setPoseIndex(0, FALSE); }
    else { setPoseIndex(getPoseIndexFromName(poseName), FALSE); }

    llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_RIGHT | CONTROL_LEFT | CONTROL_UP | CONTROL_DOWN, TRUE, FALSE);
}

// ===== Main Functions =====
setPoseIndex(integer prmIndex, integer prmSend) {
    pose = llList2String(poses, prmIndex);
    if (prmSend) {
        simpleRequest("setPose", get_poseName());
    }
}

setPose(string prmPoseName, integer prmSend) {
    integer index = getPoseIndexFromName(prmPoseName);
    if (index == -1) {
        debug("INVALID POSE: " + prmPoseName);
        return;
    }
    
    setPoseIndex(index, prmSend);
}

string get_poseName() {
    return llJsonGetValue(pose, ["name"]);
}

float get_speedBack() {
    return (float)llJsonGetValue(pose, ["speedBack"])/10;
}
float get_speedFwd() {
    return (float)llJsonGetValue(pose, ["speedFwd"])/10;
}

integer getPoseIndexFromName(string prmName) {
    integer index;
    for (index = 0; index < llGetListLength(poses); index++) {
        if (llJsonGetValue(llList2String(poses, index), ["name"]) == prmName) {
            return index;
        }
    }
    return -1;
}

tetherTo(string prmJson) {
    if (llJsonGetValue(prmJson, ["attachment"]) == "arm") {
        armTetherID = (key)llJsonGetValue(prmJson, ["targetID"]);
        armTetherLength = (integer)llJsonGetValue(prmJson, ["length"]);
    } else if (llJsonGetValue(prmJson, ["attachment"]) == "leg") {
        legTetherID = (key)llJsonGetValue(prmJson, ["targetID"]);
        legTetherLength = (integer)llJsonGetValue(prmJson, ["length"]);
    }
    
    if (armTetherID != NULL_KEY) {
        llSensorRepeat("", armTetherID, AGENT|SCRIPTED, armTetherLength, PI, 0.5);
    } else if (legTetherID != NULL_KEY) {
        llSensorRepeat("", legTetherID, AGENT|SCRIPTED, legTetherLength, PI, 0.5);
    } else {
        llSensorRemove();
    }
}

updateAviTetherPos() {
    if (armTetherID != NULL_KEY) {
        vector armTetherPos = llList2Vector(llGetObjectDetails(armTetherID, [OBJECT_POS]), 0);
        integer armTetherDistance = llAbs(llFloor(llVecDist(armTetherPos, llGetPos())));
        if (armTetherDistance > armTetherLength) {
            llMoveToTarget(armTetherPos, 0.5);
        }
        else { llStopMoveToTarget(); }
    }
}

// ===== Other Functions =====
debug(string output) {
    // TODO: global enable/disable?
    llOwnerSay(output);
}

simpleRequest(string prmFunction, string prmValue) {
    string request = "";
    request = llJsonSetValue(request, ["function"], prmFunction);
    request = llJsonSetValue(request, ["value"], prmValue);
    llMessageLinked(LINK_THIS, 0, request, NULL_KEY);
}

// ===== Event Controls =====

default {
    control(key prmAviID, integer prmLevel, integer prmEdge) {
        integer press   = prmLevel & prmEdge;
        integer release = ~prmLevel & prmEdge;
        integer hold    = prmLevel & ~prmEdge;

        // General Movement
        if (hold == CONTROL_FWD) {            
            llSetVelocity(<get_speedFwd(),0,0>, TRUE);
        }
        
        // Position Changes
        integer poseIndex = -1;
        if (press == CONTROL_UP) {
            poseIndex = getPoseIndexFromName(llJsonGetValue(pose, ["poseUp"]));
            if (poseIndex != -1) {
                setPoseIndex(poseIndex, TRUE);
            }
        }
        if (press == CONTROL_DOWN) {
            poseIndex = getPoseIndexFromName(llJsonGetValue(pose, ["poseDown"]));
            if (poseIndex != -1) {
                setPoseIndex(poseIndex, TRUE);
            }
        }
        if (press == CONTROL_RIGHT) {
            poseIndex = getPoseIndexFromName(llJsonGetValue(pose, ["poseRight"]));
            if (poseIndex != -1) {
                setPoseIndex(poseIndex, TRUE);
            }
        }
        if (press == CONTROL_LEFT) {
            poseIndex = getPoseIndexFromName(llJsonGetValue(pose, ["poseLeft"]));
            if (poseIndex != -1) {
                setPoseIndex(poseIndex, TRUE);
            }
        }

        // Animations
        if (press == CONTROL_FWD) { simpleRequest("animate_mover", "animation_walk_forward"); }
        
        if (release) { simpleRequest("animate_mover", "stop"); }
    }
    
    link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
        string function;
        string value;

        if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
            debug(prmText);
            return;
        }
        value = llJsonGetValue(prmText, ["value"]);

        if (function == "bindArms") { bindArms(value); }
        else if (function == "bindLegs") { bindLegs(value); }
        else if (function == "tetherTo") { tetherTo(value); }
        else if (function == "setPose") { setPose(value, FALSE); }
    }
    
    sensor(integer prmCount) {
        updateAviTetherPos();
    }
    no_sensor() {
        updateAviTetherPos();
    }
}
