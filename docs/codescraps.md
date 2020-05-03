# Code Scraps!

## GUI get list from json?
string testJson = "{[{name: Option1}, {name: Option2}]}";
list options = llJson2List(testJson);
list guiOptions;
integer index;
for (index=0; index < llGetListLength(options); index++) {
	string restraint = llList2String(options, index);
	
	// Is the restraint able to be applied?
	
	
	guiOptions += llJsonGetValue(restraint, ["name"]);
}