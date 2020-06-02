$import Modules.ContribLib.lslm();
$import Modules.GeneralTools.lslm();

// Global Variables
list _attachedFolders = [];

setAttachments(string attachments) {
	list bindFolders = [];
	list preventFolders = [];
	string restraint;
	integer index;

	list liAttachments = llJson2List(attachments);
	list addFolders = ListXnotY(liAttachments, _attachedFolders);
	list remFolders = ListXnotY(_attachedFolders, liAttachments);

	// Add Folders.
	for (index = 0; index < llGetListLength(addFolders); index++) {
		llOwnerSay("@attachover:BreakFree/bf_" + llList2String(addFolders, index) + "=force");
	}

	// Detatch Folders.
	for (index = 0; index < llGetListLength(remFolders); index++) {
		llOwnerSay("@detachall:BreakFree/bf_" + llList2String(remFolders, index) + "=force");
	}

	// Save setting
	_attachedFolders = liAttachments;
}

// ===== Event Controls =====

default {
	link_message(integer prmLink, integer prmValue, string prmText, key prmID) {
		string function;
		string value;

		if ((function = llJsonGetValue(prmText, ["function"])) == JSON_INVALID) {
			debug(prmText);
			return;
		}
		value = llJsonGetValue(prmText, ["value"]);

		if ("setAttachments" == function) { setAttachments(value); }
	}
}
