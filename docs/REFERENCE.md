# BreakFree Reference Guide
The following is a breakdown of the technical aspects of BreakFree. Users may find this interesting, too, but it's written more for me than anyone else.

## User Settings
- RP Mode - If enabled, the escape game is disabled and all users have full control over the restraints.

## Restraint Properties

### Slots
#### Arm
wrist
elbow
torso
#### Leg
ankle
knee
special
#### Gag
stuffing
sealer
muffler





### JSON structure
#### Pose
{
	"name": STRING
	"idle": STRING
	"struggle_success": STRING
	"struggle_failure": STRING
	"walk": STRING
}

#### Arm
{
	"uid": STRING,
	"name": STRING,
	"tightness": INT,
	"difficulty": INT,
	"pose": STRING,
	"attachments": [],
	"preventAttach: [],
	"canCut": BOOL,
	"knotted": BOOL,
	"sticky": BOOL,
	"slot": STRING (wrist|elbow|torso),
	"prerequisites": {
		"feat": STRING,
		"armPose": [],
		"legPose": []
		"notUID": []
	}
}

#### Leg
#### Gag
{
	"name": "STRING",
	"displayName": "STRING",
	"slot": "STRING"
	"tightness": INT,	
	"difficulty": INT,
	"animations": [
	],
	"attachments": [],
	"preventAttach": [],
	"properties": {
		"canCut": BOOL
		"knotted": BOOL
		"sticky": BOOL
	},
	"prerequisites": {
		"feats": [
			"STRING",
		],
		"arm": {
			"wrist": []
			"elbow": []
			"torso": []
		},
		"leg": {
			"ankle": []
			"knee": []
			"special" []
		},
		"gag": {
		
		},
	}
}

### Meta properties
{
	isGagged,
	isArmBound,
	isArmTetherable,
	isLegBound,
	isArmTetherable,
}

### Add restraint
{
	"type": arm|leg|gag,
	"restraint" {
		"name",
		"tightness",
		"difficulty",
		"animations": [],
		"attachments": [],
	}
}


- canCut - whether or not a blade can help with a quick escape
- knotted - whether or not restraint has knots to untie
- sticky - whether or not it is possible to wriggle free of the restraint
- tightness - integrity of the restraint. This is what needs to be reduced to break free.
- difficulty - restriction level of the restraint. Determines the complexity of an escape chain.

- priority - determines with part should be escaped from first
- tightness - length of puzzle (cumulative with other restraint parts)
- integrity - remaining strength of puzzle
- complexity - number of puzzles that need to be solved


### Gag Properties
- mouthOpen - should an open mouth animation play.
- garble
	- garbled - Garble parameter simulating a full mouth. 
	- sealed - Garble parameter simulating a sealed mouth.
	- muffled - Garble parameter simulating a muffled mouth.

## Pseudo code!

ESCAPE
if (sticky) {
	tightness = 3;
	difficulty = 3;
	integrity = difficulty x2 + tightness;
}

- difficulty - length of puzzle
- complexity - number of puzzles that need to be solved
- integrity - remaining strength of puzzle


- dexterity - being more limber, you can make more mistakes without being penalized
- strength - additional endurance for solving the puzzle

## Example escape

Rachel's arms are tightly tied.  Can she escape? Let's find out!
difficulty - 10
integrity - 5
tightness - 3

Endurance = 12


Rachel tries to struggle, and is successful!
progress = 1; remaining = 9
endurance = 11;

Rachel struggles again, but fails
progress = 1; remaining = 9
endurance = 10
