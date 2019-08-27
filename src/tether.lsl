// src.tether.lslp 
// 2019-08-26 23:56:38 - LSLForge (0.1.9.6) generated
integer CHANNEL_ATTACHMENT = -9999277;
integer CHANNEL_LOCKMEISTER = -8888;

// ===== Variables =====
integer lockmeisterID;
key armTargetID;
key legTargetID;

// GUI variables
key guiUserID;
list guiButtons;
integer guiChannel;
integer guiID;
integer guiScreen;
string guiText;
integer guiTimeout = 60;

// Status
integer armTetherLength = 1;
integer legTetherLength = 1;

string requestingAttachment;

// ===== Initializer =====
init(){
  if (lockmeisterID) {
    llListenRemove(lockmeisterID);
  }
  (lockmeisterID = llListen(CHANNEL_LOCKMEISTER,"",NULL_KEY,""));
}

initGUI(key prmID,integer prmScreen){
  (guiUserID = prmID);
  if (guiID) {
    llListenRemove(guiID);
  }
  (guiChannel = (((integer)llFrand((-9998))) - 1));
  (guiID = llListen(guiChannel,"",guiUserID,""));
  gui(prmScreen);
}

// ===== Main Functions =====
requestHitch(string prmAttachment){
  (requestingAttachment = prmAttachment);
  llRegionSayTo(guiUserID,0,"Please select a hitching post.");
  llListenControl(lockmeisterID,TRUE);
}

tetherTo(key prmTargetID,string prmAttachment){
  string request = "";
  (request = llJsonSetValue(request,["targetID"],prmTargetID));
  (request = llJsonSetValue(request,["attachment"],prmAttachment));
  if ((prmAttachment == "arm")) {
    (request = llJsonSetValue(request,["length"],((string)armTetherLength)));
    (armTargetID = prmTargetID);
  }
  else  if ((prmAttachment == "leg")) {
    (request = llJsonSetValue(request,["length"],((string)legTetherLength)));
    (legTargetID = prmTargetID);
  }
  simpleAttachedRequest("tetherTo",request);
  simpleRequest("tetherTo",request);
}

setArmTetherLength(string prmLength){
  (armTetherLength = ((integer)llDeleteSubString(prmLength,(-1),2)));
  tetherTo(armTargetID,"arm");
}


// ===== GUI =====
gui(integer prmScreen){
  llSetTimerEvent(guiTimeout);
  string btn10 = " ";
  string btn11 = " ";
  string btn12 = " ";
  string btn7 = " ";
  string btn8 = " ";
  string btn9 = " ";
  string btn4 = " ";
  string btn5 = " ";
  string btn6 = " ";
  string btn1 = "<<Back>>";
  string btn2 = "<<Done>>";
  string btn3 = " ";
  (guiText = " ");
  if ((prmScreen == 0)) {
    (guiText = (((("How do you want to tether " + llGetDisplayName(llGetOwner())) + "'s arms?\nCurrent length: ") + ((string)armTetherLength)) + "m"));
    (btn7 = "1m");
    (btn8 = "2m");
    (btn9 = "3m");
    (btn10 = "5m");
    (btn11 = "8m");
    (btn12 = "10m");
    (btn4 = "Release");
    (btn5 = "Grab");
    (btn6 = "Hitch");
    (btn3 = "Pull");
  }
  else  if ((prmScreen == 10)) {
    (guiText = (((("How do you want to tether " + llGetDisplayName(llGetOwner())) + "'s legs?\nCurrent length: ") + ((string)legTetherLength)) + "m"));
    (btn7 = "1m");
    (btn8 = "2m");
    (btn9 = "3m");
    (btn10 = "5m");
    (btn11 = "8m");
    (btn12 = "10m");
    (btn4 = "Release");
    (btn5 = "Tether");
    (btn6 = "Post");
    (btn3 = "Pull");
  }
  (guiScreen = prmScreen);
  (guiButtons = [btn1,btn2,btn3]);
  if ((((btn4 + btn5) + btn6) != "   ")) {
    (guiButtons += [btn4,btn5,btn6]);
  }
  if ((((btn7 + btn8) + btn9) != "   ")) {
    (guiButtons += [btn7,btn8,btn9]);
  }
  if ((((btn10 + btn11) + btn12) != "   ")) {
    (guiButtons += [btn10,btn11,btn12]);
  }
  llDialog(guiUserID,guiText,guiButtons,guiChannel);
}

exit(string prmReason){
  llListenRemove(guiID);
  llSetTimerEvent(0.0);
  if (prmReason) {
    simpleRequest("resetGUI",prmReason);
  }
}


// ===== Other Functions =====
debug(string output){
  llOwnerSay(output);
}

guiRequest(string prmGUI,integer prmRestore,key prmUserID,integer prmScreen){
  string guiRequest = "";
  (guiRequest = llJsonSetValue(guiRequest,["function"],prmGUI));
  (guiRequest = llJsonSetValue(guiRequest,["restorescreen"],((string)prmRestore)));
  (guiRequest = llJsonSetValue(guiRequest,["userkey"],((string)prmUserID)));
  (guiRequest = llJsonSetValue(guiRequest,["value"],((string)prmScreen)));
  llMessageLinked(LINK_THIS,0,guiRequest,NULL_KEY);
  exit("");
}

simpleAttachedRequest(string prmFunction,string prmValue){
  string request = "";
  (request = llJsonSetValue(request,["function"],prmFunction));
  (request = llJsonSetValue(request,["value"],prmValue));
  llRegionSayTo(llGetOwner(),CHANNEL_ATTACHMENT,request);
}

simpleRequest(string prmFunction,string prmValue){
  string request = "";
  (request = llJsonSetValue(request,["function"],prmFunction));
  (request = llJsonSetValue(request,["value"],prmValue));
  llMessageLinked(LINK_THIS,0,request,NULL_KEY);
}


// ===== Event Controls =====
default {

    state_entry() {
    init();
  }

    listen(integer prmChannel,string prmName,key prmID,string prmText) {
    if ((prmChannel == CHANNEL_LOCKMEISTER)) {
      if ((llGetSubString(prmText,(-2),(-1)) != "ok")) {
        return;
      }
      if ((llGetSubString(prmText,0,35) != ((string)guiUserID))) {
        return;
      }
      llListenControl(lockmeisterID,FALSE);
      tetherTo(prmID,requestingAttachment);
      gui(guiScreen);
    }
    else  if ((prmChannel == guiChannel)) {
      if ((prmText == "<<Done>>")) {
        exit("done");
        return;
      }
      else  if ((prmText == " ")) {
        gui(guiScreen);
      }
      else  if ((prmText == "<<Back>>")) {
        guiRequest("gui_bind",TRUE,guiUserID,0);
      }
      if ((guiScreen == 0)) {
        if ((prmText == "Grab")) {
          tetherTo(guiUserID,"arm");
        }
        else  if ((prmText == "Release")) {
          tetherTo(NULL_KEY,"arm");
        }
        else  if ((prmText == "Hitch")) {
          requestHitch("arm");
          return;
        }
        else  {
          setArmTetherLength(prmText);
        }
        gui(guiScreen);
      }
    }
  }

    
    link_message(integer prmLink,integer prmValue,string prmText,key prmID) {
    string function;
    string value;
    if (((function = llJsonGetValue(prmText,["function"])) == JSON_INVALID)) {
      debug(prmText);
      return;
    }
    (value = llJsonGetValue(prmText,["value"]));
    if (((function == "gui_tether_arm") || (function == "gui_tether_leg"))) {
      key userkey = ((key)llJsonGetValue(prmText,["userkey"]));
      integer screen = 0;
      if ((function == "gui_tether_leg")) {
        (screen = 10);
      }
      initGUI(userkey,screen);
    }
    else  if ((function == "resetGUI")) {
      exit("");
    }
  }

    
    timer() {
    llListenControl(lockmeisterID,FALSE);
    exit("timeout");
  }
}
// src.tether.lslp 
// 2019-08-26 23:56:38 - LSLForge (0.1.9.6) generated
