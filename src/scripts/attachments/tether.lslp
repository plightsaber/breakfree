$import Modules.GeneralTools.lslm();

// ===== Variables =====
integer CHANNEL_API = -9999274;

integer CHANNEL_ATTACHMENT = -9999277;
string RESTRAINT_ATTACHMENT = "";
string RESTRAINT_COMPONENT = "";
string RESTRAINT_NAME = "";

vector _color = <255.0, 255.0, 255.0>;
string _texture = TEXTURE_BLANK;
key _targetKey;

key configQueryID;
integer listenerID;

// ===== Initializer =====
init() {
	configQueryID = llGetNotecardLine(".config",0);	// Load config.

	if (listenerID) { llListenRemove(listenerID); }
	listenerID = llListen(CHANNEL_ATTACHMENT, "", NULL_KEY, "");
	
	llParticleSystem([]);
}

// ===== Methods =====
integer isCallTarget(string json) {
	string attachment = llJsonGetValue(json, ["attachment"]);
	string component = llJsonGetValue(json, ["component"]);
	string type = llJsonGetValue(json, ["type"]);
	
	if (RESTRAINT_ATTACHMENT != attachment) { return FALSE; }
	if (RESTRAINT_COMPONENT != component) { return FALSE; }
	if (RESTRAINT_NAME != type) { return FALSE; }
		
	return TRUE;
}

renderParticles() {
	if (!isSet(_targetKey)) {
		llParticleSystem([]);
		return;
	}
	
	list tetherEffect = [
		PSYS_PART_FLAGS, PSYS_PART_RIBBON_MASK | PSYS_PART_TARGET_POS_MASK | PSYS_PART_TARGET_LINEAR_MASK,
    	PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,

    	PSYS_SRC_TARGET_KEY, _targetKey,
    	PSYS_SRC_TEXTURE, _texture,
    	PSYS_PART_START_COLOR, _color,
    	PSYS_PART_END_COLOR, _color,

    	PSYS_PART_START_SCALE, <0.05,1.0,1.0>,
    	PSYS_PART_END_SCALE, <0.05,1.0,1.0>,

    	PSYS_PART_MAX_AGE, 1,
    	PSYS_SRC_BURST_RATE, 0.01,
    	PSYS_SRC_BURST_PART_COUNT, 1
	];

	llParticleSystem(tetherEffect);
}

// ===== Event Controls =====
executeFunction(string function, string params) {
	if ("tetherTo" == function) {
		_targetKey = llJsonGetValue(params, ["targetID"]);
		renderParticles();
	} else if ("setColor" == function) {
		if (!isCallTarget(params)) { return; }
		_color = (vector)llJsonGetValue(params, ["color"]);
		renderParticles();
	} else if ("setTexture" == function ) {
		if (!isCallTarget(params)) { return; }
		_texture = llJsonGetValue(params, ["texture"]);
		if (!isSet(_texture) || "blank" == _texture) {
			_texture = TEXTURE_BLANK; 
		}
		renderParticles();
	}
}

default {
	on_rez(integer prmStart) { init(); }
	state_entry() { init(); }
	
	dataserver(key queryID, string configData) {
		if (queryID == configQueryID) {
			RESTRAINT_ATTACHMENT = llJsonGetValue(configData, ["attachment"]);
			RESTRAINT_COMPONENT = llJsonGetValue(configData, ["component"]);
			RESTRAINT_NAME = llJsonGetValue(configData, ["type"]);
		}
	}
	
	listen(integer prmChannel, string prmName, key prmID, string prmText) {
		if (prmChannel == CHANNEL_ATTACHMENT) {
			string function = llJsonGetValue(prmText, ["function"]);
			string value = llJsonGetValue(prmText, ["value"]);

			if (!isSet(function)) {
				debug(prmText);
				return;
			}

			executeFunction(function, value);			
			value = llJsonGetValue(prmText, ["value"]);
		}
	}

}
