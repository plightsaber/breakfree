// ===== Variables =====
integer armBound;
integer legBound;
integer gagBound;

string armRestraints = "free";
string legRestraints = "free";
string gagRestraints = "free";

// ==== Main Functions =====
init() {
    bindArms(armRestraints);
    bindLegs(legRestraints);
    bindGag(gagRestraints);
}

detachCheck() {
    if (armBound || legBound || gagBound) {
        llOwnerSay("@detach=n");
    } else {
        llOwnerSay("@detach=y");
    }
}

bindArms(string prmValue) {
    armRestraints = prmValue;
    if (prmValue == "free") {
        armBound = 0;
        llOwnerSay("@touchfar=y");
    } else {
        armBound = 1;
        llOwnerSay("@touchfar=n");
    }
    
    detachCheck();
}

bindLegs(string prmValue) {
    legRestraints = prmValue;
    if (prmValue == "free") {
        legBound = 0;
    } else {
        legBound = 1;
    }
    
    detachCheck();
}

bindGag(string prmValue) {
    gagRestraints = prmValue;
    if (prmValue == "free") {
        gagBound = 0;
    } else {
        gagBound = 1;
    }
    
    detachCheck();
}


// ===== Other Functions =====
debug(string output) {
    // TODO: global enable/disable?
    llOwnerSay(output);
}


// ===== Events =====

default {
    on_rez(integer prmStart) { init(); }
    state_entry() { init(); }
    link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
        string function;
        string value;

        if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
            debug(prmText);
            return;
        }
        value = llJsonGetValue(prmText, ["value"]);

             if (function == "bindArms") { bindArms(value);}
        else if (function == "bindLegs") { bindLegs(value); }
        else if (function == "bindGag") { bindGag(value); }
    }
}
