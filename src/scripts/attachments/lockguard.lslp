
integer CHANNEL_LOCKGUARD = -9119;
integer CHANNEL_LOCKMEISTER = -8888;

string ANCHOR  = "";
string MOORING = "lcuff";

integer _listenId;

// ===== Initializers =====
init()
{
	if (_listenId) { llListenRemove(_listenId); }
	_listenId = llListen(CHANNEL_LOCKGUARD, "", "", "");
}

// ===== Events =====
default
{
	state_entry()
	{
		init();
	}

	listen(integer channel, string name, key id, string message)
	{
		// Only answer when attached
		if (!llGetAttached()) { return; }
		
		list commands = llParseString2List(message, [" "], []);
		
		// Check if lockguard command
		if ("lockguard" != llList2String(commands, 0)) {
			return;
		}
		
		// Check if correct target
		if (llGetOwner() != llList2Key(commands, 1)) {
			return;
		}
		
		
		
		
		llOwnerSay(message);
		return;
 
        if (message == (string)llGetOwner()+ MOORING)
        {   //This part reply to Lockmeister v1 messages
            //message structure:   llGetOwner()+mooring_point ( without the '+' )
 
            llWhisper(-8888, (string)llGetOwner()+ MOORING+" ok");//answering it
            //message structure:   llGetOwner()+mooring_point+" ok" ( without the '+' )
        }
 
        //we parse the message into a list and recover each element.
        list params = llParseString2List( message, ["|"], [] );
 
        //NOTE: You can check all of these in a single statement, this is just for the sake of clarity.
        if(llList2String(params,0) != (string)llGetOwner())
            return;
        if(llList2String(params,1) != "LMV2")
            return;
        if(llList2String(params,2) != "RequestPoint")
            return;
        if(llList2String(params,3) != MOORING)
            return;
 
        //this message is for us, it's claiming to be an LMV2 message, it's a "Request" message, and concerns the mooring_point we specified
        //message structure:   llGetOwner()|LMV2|RequestPoint|anchor_name
 
        //Now that we are certain that the message concerns us, we look for the prim key to insert in our reply.
 
        if(ANCHOR   == "")
        {
            //If there is no anchor set, we assume root prim.
            llRegionSayTo( id, -8888, llDumpList2String( [llGetOwner(), "LMV2", "ReplyPoint", MOORING, llGetKey()], "|" ) );
        }
        else
        {
            //Otherwise, we loop through the link set looking for a match.
            integer i;
            for( i = 1; i <= llGetNumberOfPrims(); i++)
            {
                if( llGetLinkName(i) == ANCHOR )
                {   //If this is our anchor prim, we reply
                    //pattern sent:   llGetOwner()|LMV2|ReplyPoint|anchor_name|anchor_key
                    llRegionSayTo( id, -8888, llDumpList2String( [llGetOwner(), "LMV2", "ReplyPoint", MOORING, llGetLinkKey(i)], "|" ) );
                    return;
                }
            }
        }
    }
}