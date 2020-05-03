# Changelog

## [3.2.2] - 2020-02-04

### Fixed
- Gags now garble again.
- RealRestraint integration no longer frees all your BreakFree restraints on a status change.

## [3.2.1] - 2020-02-03

### Added
- RLV Mode - New setting to enable/disable the use of RLV locks when bound.

### Changed
- Active touch user can now reinitialize dialog before timeout.
- Free-handed escapes made faster, requiring just one successful action per tightness.
- Multi-layer gags need to be escaped from one layer at a time.

### Fixed
- Binding yourself now keeps you in control of your bindings.
- Emotes whispers no longer persist after gag is removed.
- Free-handed escapes now give less experience than bound-handed escapes instead of more.
- Gag escape difficulty properly set - no longer set to zero, making it either too easy or impossible to escape from.
- You can now return to the Main menu from the Options menu.

## [3.2.0] - 2020-01-18
### Added
- Tape gags
- Ball gag

### Changed
- Gag API overhauled to accommodate mixing and matching gag types.
- Slight adjustments to garbler to better accommodate the new gag types.
- Garbler now garbles quoted emotes.

### Fixed
- When using the RealRestraint plug-in, villains are no longer blocked from accessing BreakFree if they secure the RealRestraint first.

## [3.1.1] - 2020-01-11
### Added
- RP Mode - Enable to complete skip the struggle mini-game to facilitate better RPs.
- RealRestraint Plugin - Add to a RealRestraint arm restraint to tell BreakFree your arms are restrained and to behave accordingly.

## [3.1.0] - 2019-12-27
### Added
- Bento heads now open their mouths with stuffed gags
- Cloth gags can be textured
- Cloth gag stuffing can be colored

### Changed
- Escaping from restraints with free hands made significantly easier
- Escaping from restraints with free hands gives 66% less experience
- Swapped out cloth gags with improved meshes
- Stuffed mouths now are extra garbled.

## 3.0.2
### Added
- Earn experience though escapes!
- Use experience to level up and improve stats
- Stats can affect struggle-out functionality
- Hogtie for leg ropes
- Villains can select a pose for their victims
### Fixed
- Fix issue where being gagged not considered as bound
- Fix silent message spamming of attach/detach calls to null lists

## 3.0.1
### Changed
- Mistakes in the escape game now cause you to lose struggle progress
- Decrease binding difficulties to balance with the new mistake mechanic
- Struggle status moved to the dialog box
### Fixed
- You no longer capture yourself when touching someone else's bindings
- Corrected pose-side animations to prevent grotesque head angles
- Set walk animation override to help AO priority conflicts
- Fix rope harnesses not updating color
- Fix restraint pieces that weren't clickable
- Fix gag-speak restrictions being lost after logout
