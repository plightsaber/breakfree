$import Modules.GuiTools.lslm();


list _agents;
list _agentKeys;

init_gui(key aviKey, integer screen) {
	guiUserID = aviKey;

	if (guiID) { llListenRemove(guiID); }
	guiChannel = (integer)llFrand(-9998) - 1;
	guiID = llListen(guiChannel, "", guiUserID, "");
	gui(screen);
}

gui(integer screen)
{
	string btn10 = " ";	string btn11 = " ";	string btn12 = " ";
	string btn7 = " ";	string btn8 = " ";	string btn9 = " ";
	string btn4 = " ";	string btn5 = " ";	string btn6 = " ";
	string btn1 = " ";	string btn2 = " ";	string btn3 = " ";

	list mpButtons;

	guiText = "Who do you want to cuff?";
	guiButtons = multipageGui(_agents, 4, multipageIndex);

	if (btn1+btn2+btn3 != "   ") { guiButtons += [btn1, btn2, btn3]; }
	if (btn4+btn5+btn6 != "   ") { guiButtons += [btn4, btn5, btn6]; }
	if (btn7+btn8+btn9 != "   ") { guiButtons += [btn7, btn8, btn9]; }
	if (btn10+btn11+btn12 != "   ") { guiButtons += [btn10, btn11, btn12]; }

	// Load MP Buttons - hopefully the lengths were configured correctly!
	if (llGetListLength(mpButtons)) { guiButtons += mpButtons; }

	llDialog(guiUserID, guiText, guiButtons, guiChannel);
}

cuff(string aviName)
{
	integer index = llListFindList(_agents, [aviName]);
	key agentKey = llList2Key(_agentKeys, index);

	llRequestPermissions(agentKey, PERMISSION_ATTACH);
}

default
{
	listen(integer channel, string name, key id, string message)
	{
		if (channel = guiChannel) {
			if (message == " ") { gui(guiScreen); }
			else if (message == "Next >>") { multipageIndex ++; gui(guiScreen); return; }
			else if (message == "<< Previous") { multipageIndex --; gui(guiScreen); return; }

			cuff(message);
		}
	}

	touch_start(integer num_detected) {
		if (llDetectedKey(0) != llGetOwner()) {
			llRegionSayTo(llDetectedKey(0), 0, "These aren't yours to touch!");
			return;
		}
		llSensor("", NULL_KEY, AGENT, 10.0, PI );
	}

	run_time_permissions(integer perm)
    {
        if(perm & PERMISSION_ATTACH) {
            llAttachToAvatarTemp(ATTACH_RLARM);
        }
        else {
            llOwnerSay("Permission to attach denied");
        }
    }

	sensor(integer detected)
    {
    	_agents = [];
        while(detected--)
        {
        	_agents += llDetectedName(detected);
        	_agentKeys += llDetectedKey(detected);
        }

       	init_gui(llGetOwner(), 0);
    }
}
