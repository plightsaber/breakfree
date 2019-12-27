integer CHANNEL_API = -9999274;

apiCall(key prmTargetID, string prmFunction, string prmJson) {
	prmJson = llJsonSetValue(prmJson, ["function"], prmFunction);
	prmJson = llJsonSetValue(prmJson, ["userID"], prmTargetID);
	prmJson = llJsonSetValue(prmJson, ["apiTargetID"], llGetOwner());

	llRegionSayTo(llGetOwner(), CHANNEL_API, prmJson);
}

default {
	touch_start(integer total_number) {
		apiCall(llDetectedKey(0), "touch", "");
	}
}
