// src.scripts.RealRestraint._BreakFree.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated
////////////////////////////////////////////////////////////////////////////////
list lDefault = [" ","Main..."," "];
                                        // always be the middle one, the left
                                        // and right ones are " ", or "<<" 
                                        // and ">>" respectively, or custom 
                                        // labels if absolutely needed

list lCustom = [];
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
integer DEBUG_LEVEL = 0;
                            // level <= DEBUG_LEVEL (see the DEBUGN() function)
                            // set to 0 for no debug at all
                            // here 5 and upper will show function calls

integer DIALOG_TIMEOUT = 70;
                            // user needs more time before the dialog expires
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
key kHolder;
integer nDialogHandle;
integer nDialogChannel;
integer nDialogTimeout;
integer nLock;
integer nIndent = 0;
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
integer CHANNEL_API = -9999274;
////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////
apiCall(string prmFunction,string prmJson){
  string request = "";
  (request = llJsonSetValue(prmJson,["function"],prmFunction));
  (request = llJsonSetValue(request,["apiTargetID"],((string)llGetOwner())));
  llRegionSayTo(llGetOwner(),CHANNEL_API,request);
}

DEBUGN(integer level,string msg){
  if ((DEBUG_LEVEL && (level <= DEBUG_LEVEL))) {
    string indent = "";
    integer i;
    for ((i = 0); (i < nIndent); (++i)) {
      (indent = (((indent = "") + indent) + "|       "));
    }
    llOwnerSay(((((((((llGetScriptName() + "   ") + indent) + msg) + "   <lvl ") + ((string)level)) + ", ") + ((string)llGetFreeMemory())) + " b>"));
  }
}

DEBUGF(integer entering,string functionName,list params){
  if (DEBUG_LEVEL) {
    string hdr = "";
    if ((entering == 1)) {
      (hdr = "ENTER ");
    }
    else  if ((entering == 0)) {
      (hdr = "LEAVE ");
      if ((nIndent > 0)) (--nIndent);
    }
    DEBUGN(5,((((hdr + functionName) + " (") + llList2CSV(params)) + ")"));
    if ((entering == 1)) (++nIndent);
  }
}
////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////
Menu(key id){
  DEBUGF(1,"Menu",[id]);
  llListenRemove(nDialogHandle);
  (nDialogChannel = (-(100000 + ((integer)llFrand(900000.0)))));
  (nDialogHandle = llListen(nDialogChannel,"",id,""));
  string hdr = "\n";
  (hdr += "Your BreakFree Integration is successfully installed");
  DEBUGN(10,("Dialog " + hdr));
  DEBUGN(10,(("Dialog [" + llList2CSV((lDefault + lCustom))) + "]"));
  llDialog(id,hdr,(lDefault + lCustom),nDialogChannel);
  (nDialogTimeout = DIALOG_TIMEOUT);
  DEBUGF(0,"Menu",[id]);
}

Init(){
  DEBUGF(1,"Init",[]);
  (nDialogChannel = (-(100000 + ((integer)llFrand(900000.0)))));
  (nDialogHandle = 0);
  (kHolder = NULL_KEY);
  (nLock = 0);
  (nDialogTimeout = 0);
  llOwnerSay((llGetScriptName() + " ready"));
  DEBUGF(0,"Init",[]);
}
////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////
default {

    state_entry() {
    DEBUGF(1,"state_entry",[]);
    Init();
    DEBUGF(0,"state_entry",[]);
  }

    
    
    
    listen(integer channel,string name,key id,string msg) {
    DEBUGF(1,"listen",[channel,name,id,msg]);
    if ((channel == nDialogChannel)) {
      (nDialogTimeout = 0);
      llListenRemove(nDialogHandle);
      (nDialogHandle = 0);
      if ((msg == "Main...")) {
        llMessageLinked(LINK_SET,0,"Toucher",id);
      }
      else  {
        integer remenu = 1;
        if (remenu) Menu(id);
      }
    }
    DEBUGF(0,"listen",[channel,name,id,msg]);
  }

    
    
    
    link_message(integer sender_num,integer num,string str,key id) {
    if ((str == "Lockable")) {
      if ((num == (-9))) {
        DEBUGN(3,"Resetting...");
        llResetScript();
      }
      else  if ((num == (-3))) {
        DEBUGN(3,(llKey2Name(id) + " has taken keys."));
        (kHolder = id);
      }
      else  if ((num == (-4))) {
        DEBUGN(3,(llKey2Name(id) + " has left keys."));
        (kHolder = NULL_KEY);
      }
      else  if ((num == 0)) {
        DEBUGN(3,(llKey2Name(id) + " has unlocked."));
        (nLock = 0);
        (kHolder = NULL_KEY);
        string apiJson = "";
        (apiJson = llJsonSetValue(apiJson,["type"],"arm"));
        apiCall("releaseRestraint",apiJson);
      }
      else  if ((num > 0)) {
        DEBUGN(3,(((llKey2Name(id) + " has locked (type ") + ((string)num)) + ")."));
        (nLock = num);
        (kHolder = id);
        string apiJson = "";
        (apiJson = llJsonSetValue(apiJson,["type"],"arm"));
        (apiJson = llJsonSetValue(apiJson,["restraint"],"{\"type\":\"external\"}"));
        apiCall("overrideRestraint",apiJson);
      }
      else  if ((num == (-21))) {
        if ((nDialogTimeout > 0)) {
          (--nDialogTimeout);
          if ((nDialogTimeout <= 0)) {
            llListenRemove(nDialogHandle);
            (nDialogHandle = 0);
            DEBUGN(10,"Menu timed out.");
          }
        }
      }
    }
    else  if ((str == llGetScriptName())) {
      Menu(id);
    }
  }
}
// src.scripts.RealRestraint._BreakFree.lslp 
// 2020-05-03 12:36:49 - LSLForge (0.1.9.6) generated
