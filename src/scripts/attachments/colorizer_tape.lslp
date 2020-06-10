$import Modules.GeneralTools.lslm();

// ===== Variables =====
integer CHANNEL_ATTACHMENT = -9999277;
string RESTRAINT_ATTACHMENT = "";
string RESTRAINT_COMPONENT = "";
string RESTRAINT_NAME = "";

vector color = <0.0, 0.0, 0.0>;
string texture = TEXTURE_BLANK;

key configQueryID;
integer listenerID;


// ===== Initializer =====
init() {
	configQueryID = llGetNotecardLine(".config",0);	// Load config.

	if (listenerID) { llListenRemove(listenerID); }
	listenerID = llListen(CHANNEL_ATTACHMENT, "", NULL_KEY, "");
}

// ===== Main Functions =====
setColor(string prmInfo) {
	if (validateTarget(prmInfo) == FALSE) { return; }
	color = (vector)llJsonGetValue(prmInfo, ["color"]);

	llSetLinkColor(LINK_SET, color, 0); // LINK_SET to color all, LINK_THIS to color prim script is located in.
	simpleRequest("setColor", (string)color);
}

setTexture(string prmInfo) {
 if (validateTarget(prmInfo) == FALSE) { return; }
    texture = llJsonGetValue(prmInfo, ["texture"]);

    llSetTexture(texture, 0);
    simpleRequest("setTexture", texture);
}

integer validateTarget(string prmInfo) {
	if (llJsonGetValue(prmInfo, ["attachment"]) != RESTRAINT_ATTACHMENT) { return FALSE; }
	if (llJsonGetValue(prmInfo, ["component"]) != RESTRAINT_COMPONENT) { return FALSE; }
	if (llJsonGetValue(prmInfo, ["userKey"]) != (string)llGetOwner()) { return FALSE; }
	return TRUE;
}

// ===== Event Controls =====
default {
	on_rez(integer prmStart) { init(); }
	state_entry() { init(); }
	dataserver(key queryID, string configData)
	{
		if (queryID == configQueryID) {
			RESTRAINT_ATTACHMENT = llJsonGetValue(configData, ["attachment"]);
			RESTRAINT_COMPONENT = llJsonGetValue(configData, ["component"]);
			RESTRAINT_NAME = llJsonGetValue(configData, ["name"]);

			string request = "";
			request = llJsonSetValue(request, ["attachment"], RESTRAINT_ATTACHMENT);
			request = llJsonSetValue(request, ["component"], RESTRAINT_COMPONENT);
			request = llJsonSetValue(request, ["name"], RESTRAINT_NAME);
			apiRequest(llGetOwner(), llGetOwner(), "requestStyle", request);
		}
	}

	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel == CHANNEL_ATTACHMENT) {
			string function;
			string value;

			if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
				debug(prmText);
				return;
			}
			value = llJsonGetValue(prmText, ["value"]);

			if (function == "setColor") {
				setColor(value);
			} else if (function == "setTexture") {
				setTexture(value);
			}
		}
	}
}
