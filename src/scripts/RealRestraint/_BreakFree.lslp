$import Modules.GeneralTools.lslm();
$import Modules.UserLib.lslm();

////// BREAKFREE /////
integer _armBound;
integer _listenID;

////////////////////////////////////////////////////////////////////////////////
list lDefault = [" ", "Main...", " "];    // the 3 lower buttons, "Main..." must
                                        // always be the middle one, the left
                                        // and right ones are " ", or "<<"
                                        // and ">>" respectively, or custom
                                        // labels if absolutely needed

list lCustom = [];     // <-- YOUR BUTTONS HERE
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
integer DEBUG_LEVEL = 0;    // set to > 0 if you want to show debug messages of
                            // level <= DEBUG_LEVEL (see the DEBUGN() function)
                            // set to 0 for no debug at all
                            // here 5 and upper will show function calls

integer DIALOG_TIMEOUT = 70;    // x10 seconds, increase this if you think the
                            // user needs more time before the dialog expires
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
key kHolder;            // UUID of the current keyholder or NULL_KEY
integer nDialogHandle;    // handle for the current dialog menu
integer nDialogChannel;    // channel for the current dialog menu
integer nDialogTimeout;    // time x10 seconds before the dialog expires
integer nLock;            // current lock, 0 means unlock, 9 means basic lock
integer nIndent = 0;    // indentation for debugging purposes
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
DEBUG (string msg) {
    // Won't do anything if DEBUG_LEVEL == 0
    if (DEBUG_LEVEL) DEBUGN (1, msg);
}

DEBUGN (integer level, string msg) {
    // Choose a level <= DEBUG_LEVEL to display the message
    // The levels used in this template are totally arbitrary, but
    // the lower the more important the debug message
    // Debug messages are indented according to nIndent, which changes
    // when calling DEBUGF()
    if (DEBUG_LEVEL && level <= DEBUG_LEVEL) {
        string indent = "";
        integer i;
        for (i=0; i<nIndent; ++i) {
            indent = (indent="") + indent + "|       ";
        }
        llOwnerSay (llGetScriptName() + "   " + indent + msg
        + "   <lvl " + (string)level + ", " + (string)llGetFreeMemory() + " b>");
    }
}

DEBUGF (integer entering, string functionName, list params) {
    // Call this when entering or exiting a function
    // If entering == 1, indents and displays "enter"
    // Else if entering == 0, unindents and displays "leave"
    // Else it doesn't change indentation
    if (DEBUG_LEVEL) {
        string hdr = "";
        if (entering == 1) {
            hdr = "ENTER ";
        }
        else if (entering == 0) {
            hdr = "LEAVE ";
            if (nIndent > 0) --nIndent;
        }
        DEBUGN (5, hdr + functionName + " (" + llList2CSV (params) + ")");
        if (entering == 1) ++nIndent;
    }
}

string Lbl (integer expr, string label) {
    if (expr) return     "(#) " + label;
    return                     "( ) " + label;
}

string Iif (integer expr, string right, string wrong) {
     if (expr) return right;
     return wrong;
}
////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////
Menu (key id) {
    // shows a menu, sets a listening channel, a listen handle and a
    // 60 seconds timeout
    DEBUGF (1, "Menu", [id]);
    llListenRemove (nDialogHandle);
    nDialogChannel = - (100000+(integer)llFrand(900000.0));
    nDialogHandle = llListen (nDialogChannel, "", id, "");

    string hdr = "\n";

    hdr += "Your BreakFree Integration is successfully installed";

    DEBUGN (10, "Dialog " + hdr);
    DEBUGN (10, "Dialog [" + llList2CSV (lDefault + lCustom) + "]");
    llDialog (id, hdr, lDefault + lCustom, nDialogChannel);
    nDialogTimeout = DIALOG_TIMEOUT; // decreases every 10 seconds
    DEBUGF (0, "Menu", [id]);
}

Init () {
    // Initialisation, called right after a reset
    DEBUGF (1, "Init", []);
    nDialogChannel = - (100000+(integer)llFrand(900000.0));
    nDialogHandle = 0;
    kHolder = NULL_KEY;
    nLock = 0;
    nDialogTimeout = 0;
    llOwnerSay (llGetScriptName () + " ready");
    DEBUGF (0, "Init", []);

    // BREAKFREE
	if (_listenID) { llListenRemove(_listenID); }
	_listenID = llListen(CHANNEL_API, "", NULL_KEY, "");
}
////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////
default {
    state_entry () {
        DEBUGF (1, "state_entry", []);
        Init ();
        DEBUGF (0, "state_entry", []);
    }



    listen(integer channel, string name, key id, string msg) {
        DEBUGF (1, "listen", [channel, name, id, msg]);
        if (channel == nDialogChannel) {
            // Messages received when user presses a dialog button
            nDialogTimeout = 0;
            llListenRemove (nDialogHandle);
            nDialogHandle = 0;
            if (msg == "Main...") {
                // Return to main menu
                llMessageLinked (LINK_SET, 0, "Toucher", id);
            }
            else {
                // Don't set remenu to 0 unless absolutely necessary
                // (when you don't want the menu to reopen after clicking)
                integer remenu = 1;
                // YOUR CODE HERE >>>
                // <<< YOUR CODE HERE
                // Reopen menu for this plugin
                if (remenu) Menu (id);
            }
        }

        // BREAKFREE
        if (channel = _listenID) {
			string function = llJsonGetValue(msg, ["function"]);
			string value = llJsonGetValue(msg, ["value"]);
			if (!isSet(function)) {
				debug("ERROR: API call missing function: " + msg);
				return;
			}

			if (function == "getTouchInfo") {
				string user = getDefaultUser(llGetOwner());
				user = llJsonSetValue(user, ["armBound"], (string)_armBound);
				apiRequest(llJsonGetValue(msg, ["fromKey"]), llGetOwner(), "touchUser", user);
			}

        }


        DEBUGF (0, "listen", [channel, name, id, msg]);
    }



    link_message(integer sender_num, integer num, string str, key id) {
//~         DEBUGF (1, "link_message", [sender_num, num, str, id]);
        if (str=="Lockable") {
            if (num == -9) { // reset
                DEBUGN (3, "Resetting...");
                llResetScript ();
            }
            else if (num == -3) { // take keys
                DEBUGN (3, llKey2Name (id) + " has taken keys.");
                kHolder = id;
            }
            else if (num == -4) { // leave keys
                DEBUGN (3, llKey2Name (id) + " has left keys.");
                kHolder = NULL_KEY;
            }
            else if (num == 0) { // unlock
                DEBUGN (3, llKey2Name (id) + " has unlocked.");
                nLock = 0;
                kHolder = NULL_KEY;
                // BF BEGIN
                _armBound = FALSE;
                apiRequest(llGetOwner(), llGetOwner(), "rmSlot", "armExternal");
                // BF END
            }
            else if (num > 0) { // lock
                DEBUGN (3, llKey2Name (id) + " has locked (type "
                +(string)num+").");
                nLock = num;
                kHolder = id;
                // BF BEGIN
                _armBound = TRUE;
                string apiJson = "";
                string restraint;
                restraint = llJsonSetValue(restraint, ["uid"], "RealRestraint");
                restraint = llJsonSetValue(restraint, ["name"], "RealRestraint");
                restraint = llJsonSetValue(restraint, ["type"], "external");
                restraint = llJsonSetValue(restraint, ["slot"], "armExternal");

                apiRequest(llGetOwner(), llGetOwner(), "addRestraint", llJsonSetValue(apiJson, ["restraint"], restraint));
                // BF END
            }
            else if (num == -21) { // periodical report from Lockable
                // Terminate the dialog listener if we have waited too long
                // (user probably pressed "Ignore" on the menu)
                if (nDialogTimeout > 0) {
                    --nDialogTimeout;
                    if (nDialogTimeout <= 0) {
                        llListenRemove (nDialogHandle);
                        nDialogHandle = 0;
                        DEBUGN (10, "Menu timed out.");
                    }
                }
            }
        }
        else if (str == llGetScriptName ()) {
            // message received from the Plugins Browser page => show menu
            Menu (id);
        }
//~         DEBUGF (0, "link_message", [sender_num, num, str, id]);
    }
}
////////////////////////////////////////////////////////////////////////////////





//~ ////////////////////////////////////////////////////////////////////////

//~ This sheet shows the list of Linked Messages sent from and received by the Lockable script (and its satellite extensions, if any).
//~ Up to date with V1.31

//~ LINKED MESSAGES *FROM* THE LOCKABLE SYSTEM

//~ MESSAGE                 NUM         ID                                DESCRIPTION
//~ -------------------------------------------------------------
//~ Lockable                -43         Special               Same periodical report as -21 (see below), but sent because of a specific Pulse request. NUm is different to avoid confusing plugin relying on -21 to count time (v1.31)
//~ Lockable                -42         (time in sec)         A timer was just set (even to zero, also sent automatically after a -41) (v1.31)
//~ Lockable                -41         NULL_KEY                    The timer just ran out (v1.31)
//~ Lockable                -40         AV                                Someone has clicked on "Force" on a restraint that uses Unlockable and its Vulnerable plugin is active
//~ Lockable                -39         AV                                Lockable is set to Use Alarm
//~ Lockable                -38         AV                                Lockable is set to No Alarm
//~ Lockable                -37         AV                                Lockable is set to Verbose
//~ Lockable                -36         AV                                Lockable is set to Silent
//~ Lockable                -35         AV                                AV examines but has no try left
//~ Lockable                -34         AV                                AV examines but guesses nothing
//~ Lockable                -32         AV                                AV examines and guesses a struggle
//~ Lockable                -31         AV                                AV examines and guesses a squirm
//~ Lockable                -30         AV                                AV examines and guesses a tug
//~ Lockable                -27         AV                                AV opens the last plugin used (no access to keyholder plugins)
//~ Lockable                -26         AV                                AV opens the last plugin used (with access to keyholder plugins)
//~ Lockable                -25         New amount                New amount of tries available to wearer after a change (struggle, examine, waiting, locking...)
//~ Lockable                -24         AV                                AV opens the plugins browser page (no access to keyholder plugins)
//~ Lockable                -23         AV                                AV opens the plugins browser page (with access to keyholder plugins)
//~ Lockable                -22         AV                                AV has detached the restraints while locked
//~ Lockable                -21         Special                    Periodical report (1 every 10 seconds), see below
//~ Lockable                -20         AV                                AV tries to manipulate the restraints but is not authorized
//~ Lockable                -19         cur. version            version update request. "cur. version" is a string like "1.17.1". Lockable_Plugins sends a "Version" message as an integer when reset (see below)
//~ Lockable                -18         AV                                AV's Block state has been toggled
//~ Lockable                -17         AV                                AV's Autoref state has been toggled
//~ Lockable                -16         AV                                AV's ML state has been toggled
//~ Lockable                -15         AV                                AV is stuck ("in vain...")
//~ Lockable                -14         AV                                AV has failed to find the next move ("to no avail")
//~ Lockable                -13         AV                                AV has found the next move ("is making progress")
//~ Lockable                -12         AV                                AV tugs
//~ Lockable                -11         AV                                AV squirms
//~ Lockable                -10         AV                                AV struggles
//~ Lockable                -9         NULL_KEY                    Lockable has just reset (and waits 0.5 seconds after sending this message)
//~ Lockable                -8         AV                                AV has hit Load on the menu, but the load failed (invalid save token)
//~ Lockable                -7         AV                                AV has hit Load on the menu, and the load succeeded
//~ Lockable                -6         AV                                AV has hit Save on the menu. The save token created is merely a short string stored in the Description field of the main item, it is signed so it cannot be reused for other restraints or other avatars. Plugins are not supposed to generate save tokens, if the signature key is cracked it will be changed in a future update.
//~ Lockable                -5         AV,message                Ask Lockable_Plugins to send an IM to AV (useful in Silent mode). Internal use, don't use this unless the user is in the menu of the Plugin, because it freezes Lockable_Plugins for 2 seconds !
//~ Lockable                -4         AV                                AV has left keys on the restraints
//~ Lockable                -3         AV                                AV has taken keys from the restraints
//~ Lockable                0             AV                                AV has unlocked wearer
//~ Lockable                1             AV                                AV has locked wearer (1st lock)
//~ Lockable                2             AV                                AV has locked wearer (2nd lock)
//~ Lockable                3             AV                                AV has locked wearer (3rd lock)
//~ Lockable                4             AV                                AV has locked wearer (4th lock)
//~ Lockable                5             AV                                AV has locked wearer (5th lock)
//~ Lockable                6             AV                                AV has locked wearer (6th lock)
//~ Lockable                7             AV                                AV has locked wearer (7th lock)
//~ Lockable                8             AV                                AV has locked wearer (8th lock)
//~ Lockable                9             AV                                AV has locked wearer (9th lock)


//~ Periodical report (LM -21) :
//~ - ID is TimeInSeconds/TimeLeftInSeconds/BestTimeInSeconds/BestEscapeTimeInSeconds,Gender/ShowingTime/UsingAlarm/TimesCheated/Verbose,Blocked/Mouselooked/Escapes,Keyholder_UUID/Keyholder_Name
//~ - Caution : times are floats
//~ - Note the comma (",") before Gender and Blocked, instead of a slash ("/"), this is on purpose to distinguish completely different kinds of data

//~ - TimeInSeconds: always 0.0 when unlocked
//~ - /TimeLeftInSeconds: always 0.0 when unlocked
//~ - /BestTimeInSeconds: 0.0 when never locked
//~ - /BestEscapeTimeInSeconds: 999999.0 when never escaped
//~ - ,Gender: 0=female, 1=male
//~ - /ShowingTime: 0=timers hidden, 1=timers shown
//~ - /UsingAlarm: 0=no alarm, 1=alarm displayed when cheating
//~ - /TimesCheated: number of times when the restraint has been detached while locked
//~ - /Verbose: 0=llOwnerSay only, 1=llWhisper too (applies only for the Lockable script in 1.20)
//~ - ,Blocked: 0=allowed to interact, 1=prevented from interacting
//~ - /Mouselooked: 0=can go to 3rd view, 1=restricted to first view
//~ - /Escapes: number of times the captive escaped by their own means (note : it should have been after "BestEscapeTimeInSeconds", but historically was not included in the reports before
//~ - ,Keyholder_UUID: UUID of the keyholder, NULL_KEY if nobody has the key (v1.31)
//~ - /Keyholder_name: Display name of the keyholder at the time it was known (could be different now) (v1.31)
//~


//~ ////////////////////////////////////////////////////////////////////////

//~ LINKED MESSAGES *TO* THE LOCKABLE SYSTEM OR TO OTHER SYSTEMS

//~ MESSAGE                         NUM         ID                                DESCRIPTION
//~ -------------------------------------------------------------
//~ Data                         -             -                               Tells Lockable to send its data via a -43 message (same as -21) (v1.31)
//~ Names                         -             -                               Tells Lockable resend its "Locks" message (see below) (v1.31)
//~ Name                         -             name                             Tells Lockable to set its keyholder display name to "name". Attention, this does not change the keyholder's UUID and there is no check for consistency  (v1.31)
//~ Send                                -             msg                             Sends msg to the keyholder. Caution : Lockable is big and could crash with a long message, try to keep it short (50 chars approx) (since v1.31 this LM is no longer treated by Lockable but by Lockable_Plugins instead so memory is less of a concern now)
//~ RealRestraint             0             -                                 RealRestraint script has just reset
//~ RealRestraint             1             -                                 Wearer has touched the HUD cache => show menu
//~ RealRestraint             2             -                                 Wearer has detached the HUD cache
//~ RealRestraint             3             -                                 Wearer has attached the HUD cache
//~ Toucher                         -             AV                                AV has touched one of the restraints (opens the main menu)
//~ Ext                                 -             -                                 Plugins Browser has just reset (used to show the "Plugins..." button, off by default)
//~ Cmd:XXX                         -             AV                                Simulates a button press from AV (see below)
//~ Backdoor                        -             AV                                Gives the keys to AV, and shows the main menu (triggers a Lockable/-3/AV message)
//~ Config                            N             "tgt"                         Sets Tightness to N
//~ Config                            N             "str"                         Sets Strength to N
//~ Config                            N             "show"                        Hides timers if N==0, shows them if N==1
//~ Config                            N             "sex"                         Sets gender to female if N==0, to male if N==1
//~ Locks                             1             AnimList                    Sets the list of locks to AnimList (CSV-shaped list, 1st element is "")
//~ ForceAnim                     1             AnimList                    Same as Locks above, plus sets the Autoref button as shown (hidden by default)
//~ ForceAnim                    2            AV                            Autoref switched to OFF
//~ ForceAnim                    3            AV                            Autoref switched to ON
//~ Lockable_Check_RL     0/Ver     -                                 NUM = 0 if user doesn't use RLV, NUM = RLV version otherwise : ver "X.Y.Z.P" => NUM = X*10^6 + Y*10^4 + Z*10^2 + P. Ex : "1.15.1" => 1150100. Sent every time the object rezzes (worn or logging in) and when the inventory changes. Warning : older Lockable_Check_RL scripts (before Lockable 1.14) only send 0 or 1 !
//~ Version                        Ver                -                            Sent when Plugins Browser resets, just before Ext. Ver is an integer and represents the version of Lockable (and Lockable_Plugins, which share the same version number). Same format as Lockable_Check_RL. Only from 1.17.1 (which gives 1170100) and later.
//~ Vulnerable                0/1                -                            Signals that the "Vulnerable" plugin is set to allow unauthorized users to access some plugins (1), or nothing at all (0, which is the default)


//~ Command Cmd:XXX
//~ If XXX is equal (case-sensitive) to the label of a menu button of the Lockable script (not a plugin nor the plugin browser), executes this command without any access check
//~ Ex : "Cmd:+30 mn" will add 30 minutes to the timer, no matter whether the user has access or not

//~ Note : Lockable 1.20 now responds to Cmd:L0 to Cmd:L9 as initially planned. "L0" is synonym to "Unlock", "L9" to "Lock", "L1" to "L6" are synonyms to the corresponding lock labels (ex : "1 Hnd front" or "Tight"), "L7" and "L8" are not used for the moment
//~ Example : To lock the RR Police Handcuffs into the "1 Hnd front" pose, issue either a "Cmd:1 Hnd front" or a "Cmd:L1" Link Message


