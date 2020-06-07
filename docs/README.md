README
======
Thanks for using the BreakFree restraint system!  Here's a few things you should know before you begin.

Installation
------------
Since BreakFree is highly modular, it relies on RLV queries to attach the restraints as required.  As such, you need to do the following to make sure that BreakFree works properly.
* Use RLV-compatible viewer.
* Make sure all your restraint folders are in a folder named "BreakFree" the top-level #RLV directory in your Inventory.

As of BreakFree 4.0, there are too many restraint folders to deliver in one package from the marketplace. To get all the required restraint meshes you will need to purchase the following items:
* BF Restraints (rope)
* BF Restraints (tape)
* BF Restraints (gags)

When you are done your directory tree should look something like this:
My Inventory
+-- #RLV
|   +-- BreakFree
|   |   +-- bf_armRope_back
|   |   |   |   armRope_back (r forearm)
|   |   +-- bf_armRope_back_harness
|   |   |   |   armRope_back_harness (chest)
|   |   +-- bf_armRope_backTight
|   |   |   |   armRope_backTight (r forearm)
... and so on.

Once these folders are properly configured in your inventory, the hard part is over! Simply attach the item called BreakFree and you are now good-to-go.


Using BreakFree
---------------
When your BreakFree object it attached, it should appear as an invisible cylinder around your torso.  Simply click your torso (or the torso of an avi wearing BreakFree) and you will be presented with a dialog box from your viewer.

You may not be able to access the dialog if you are too far away from the avi or if someone else is currently using the avi's dialogs. 

### Owner Dialog
This dialog appears when you touch your own BreakFree object.

#### Bind
Allows you to perform self-bondage.  See "Bind Dialog" for more detail.

#### Escape
Allows you to attempt to escape from any bindings.  See "Escape System" for more detail.

#### Pose
Allows you to change your position if you are bound and have multiple poses available.  See "Poses" for more detail.

#### Options
You can customize how your BreakFree set behaves. While unbound, you will have an "Options" button when touching your BreakFree object.
* RP Mode - When enabled, the escape game is disabled and any avi has full access to your restraints. Additionally, all restraint types and positions will be available.
* RLV - When enabled, BreakFree will activate RLV locks when you are bound.

#### Stats
See "Stats (Experience & Feats) for more detail.

### Bind Dialog
This dialog appears when you touch a different avi's BreakFree object and:
* The avi is unbound
* You have already bound this avi and are returning to secure her

#### Bind
* You have the ability to bind three areas: Arms, Legs, and Gag.
* Clicking through these menus, you then choose a material to bind with.
* After choosing an area and a material, you can choose the position or slot to bind the avi in.  Certain slots or positions block others, or occasionally open new binding possibilities.  Mix and match and explore the options to make your victim secure.
* Color: You also may have a dialog option to style the active area / material.  Click and select from a few colors or textures to customize the look of the restraints.

#### Tether
Certain positions allow you to tether the avi.  While tethered, an avi has a limited radius of movement from the origin of the tether.
* Distances:  You can choose how long to make the tether to determine how much freedom your victim has.
* Grab:       Make yourself the tether origin to grab the tether and lead around your victim
* Release:    Release the tether to allow your victim to freely roam (as best as they can, if her legs are bound)
* Hitch:      Select a LOCKMEISTER-compatible leashing post to attach the tether to. 
* Pull:       Ignore the current distance restriction and quickly pull your victim close to you.

#### Pose
Allows you to change your position if you are bound and have multiple poses available.  See "Poses" for more detail.

### Hero Dialog
This dialog appears when you touch a different avi's BreakFree object and:
* The avi is bound
* AND you didn't bind her.

This dialog will take you straight to the escape/rescue dialog.  See "Escape System" for more detail.

Poses
-----
When an avi's legs are bound, she can be in a variety of positions.  They are mostly decorative, but do have some affect on movement speed.
Both the owner and the villain has access to the Pose menu to select from the currently available poses.

The owner has the additional ability to bypass the menu and change between common poses using the movement keys: JUMP, CROUCH, STRAFE LEFT, and STRAFE RIGHT.

Poseball animations:
There are a few animations that are only meant to be used if the avi is currently sitting on an object, such as a bed or a chair.  Select these while sitting to attempt to correct animation display issues when BreakFree is competing with other animations used with the poseball.

!! Standing up from a poseball can sometimes break your avi's current animation.  Changing the pose will reset your animations and fix these errors.

Stats (Experience & Feats)
--------------------------
As you continue to use the BreakFree system you will gain EXPERIENCE.  After enough experience, you will gain a LEVEL.  When you gain a level, you can use it to gain a FEAT, giving you certain advantages in escaping or the restraining of others.

All avis can choose a single FEAT to start with from the owner dialog.

### Experience
Experience can be earned in the following ways:
* Binding another Avi*
* Loosening your restraints while bound
* Loosening the restraints of another bound avi*

### Feats
Here are a list of feats you can learn:
* Athletic:   Improved chance to decrease INTEGRITY with a THRASH action
* Athletic+:  Improved chance to decrease INTEGRITY with a THRASH action
* Eidetic:    You automatically remember any lost progress you've made in the TIGHTNESS puzzle
* Intuitive:  For any puzzle, you have a good feeling that the correction action to take is one of two
* Endurant:   +25 stamina
* Endurant+:  +25 stamina
* Flexible:   Only regress back one action in the tightness puzzle after choosing the wrong action
* Flexible+:  No regression penalty for choosing the wrong tightness action
* Resolute:   Half the time to fully recover stamina
* Resolute+:  Half the time to fully recover stamina

* Anubis:     +2 tightness for every tape restraint. Additionally unlocks TAPE BOX TIE
* Anubis+:    +2 tightness for every tape restraint. Additionally unlocks TAPE BALL TIE
* Anibis++:	  Unlocks TAPE MITTEN
* Rigger:     +5 integrity for every rope restraint.  Additionally unlocks ROPE BOX TIE
* Rigger+:    +1 complexity for every rope restraint. Additionally unlocks ROPE BALL TIE
* Gag Snob:   +5 integrity for every gag
* Gag Snob+:  +1 complexity for every gag
* Sadist:     Unlocks CROTCH TIE

Any feat noted with a "+". Is an upgraded version of the feat.  An avi needs the non-plus version of the feat before learning the upgraded version.  Noted effects of these feats are cumulative.

Escape System
-------------
Well, you screwed up (or succeeded).  You're bound, gagged and stuffed off in some dark corner somewhere, at the mercy of some pervert or lunatic - and completely helpless.  Or are you?  Here's what you need to know if you want to attempt to BreakFree:

### Terminology
* Complexity:  The number of escape puzzles you need to complete before you are freed from a restraint
* Integrity:   The remaining strength of your active escape puzzle
* Tightness:   The number of successful actions you need to take to position yourself to weaken a restraint's integrity
* Stamina:     Determines the number of actions you take before you need to take a short rest.

### Actions
Click on your restraint to bring up the dialog menu.  You want to escape?  Click escape.  Easy!  Well, now the tricky part.

You should have 6 moves available to you. The first three you should familiarize yourself are those used to decrease the TIGHTNESS of your restraint:
* Twist:     Medium chance this is the move you need to make.  Uses a low amount of stamina.
* Struggle:  Best chance this is the move you need to make.  Uses a medium about of stamina.
* Thrash:    Low chance this is the move you need to make.  Uses a high amount of stamina. VERY LOW chance this will cause "unexpected progress", weakening your restraint's INTEGRITY.

An incorrect action will undo some tightness progress you've previously made and you will need to repeat those actions.  Additionally, if you take a rest, you will lose all current tightness progress.

The next three moves are those that decrease the INTEGRITY of your restraint.
* Pick:  Low odds.  Low stamina.
* Tug:   Good odds. Medium stamina.
* Yank:  Middling odds. Medium stamina.

If you have not loosened the tightness of your restraint enough, even a correct action here may not weaken the restraint's integrity.  The more tightness progress you make, the better chance you have that an an integrity action will succeed.  Fully solving the tightness puzzle guarantees that a correct integrity action will succeed.

### Special Considerations
* Certain skills give you hints to the correct action to take.  If the suggested action displays as "???", it is because your villain fitted you with a crotch rope and you are ... distracted.  You may want to take a rest to compose yourself.
* You may not have the option to PICK if your captor has restrained you in a way to make this impossible.  You aren't stuck though.  Some THRASHing has a possibility of reducing the restraint's integrity so you can continue your escape.
* If you are in the menu as a HERO, you only will have the INTEGRITY actions.  This is because it's a bit easier for you to work the restraints than the bound Avi.  If you are fortunate enough to be unbound yourself, you also will only need to solve a single INTEGRITY step to reduce the restraint's COMPLEXITY.

Accessories
-----------
Certain items can affect your escape.  Included with your BreakFree product is an official BreakFree knife.  While you are holding it or are near by, you can click it and choose a nearby bound Avi to free (including yourself).  While using a knife, any successful INTEGRITY action will reduce the restraint's COMPLEXITY.

Anyone can also click the knife to remove it from the world or detach it from your avi.  So keep them well hidden if you are relying on them to escape!

Along with the included knife a standalone script "blade" is included for use on other sharp objects you may want to make or use.
!! The script includes logic that self-deletes the object when REMOVE is selected.  DO NOT USE on any non-copyable items you do not currently have a backup for. !!

RealRestraints Plug-in
----------------------
If you want to use BreakFree along with a RealRestraints product, we recommend you install the included script into the main RealRestraint attachment (the one that attaches to (r forearm). No other action is required, just drag-and-drop!

Contribute!
-----------
BreakFree is modular and fully open source.  While maintained by Myshel Neiro and Rachel Kyomoon, we are happy to review community-contributed fixes, features, and modules.  

The code and other resources are available @ https://github.com/plightsaber/breakfree if you are interested in helping with the development of this system.
