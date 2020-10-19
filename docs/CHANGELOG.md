# Changelog

## [4.1.3]
### Added
- New Feat: Steadfast - recover stamina while you struggle.

### Fixed
- Do not recover stamina while you struggle (unless you take the new feat: Steadfast)
- Fix issue where you sometimes do not recover stamina after log in, making escape impossible
- Fix issue where dialog control never times out.

## [4.1.2]
### Added
- Self-bondage SECURE button to remove bind options when performing self-bondage

### Changed
- New rope mesh for arm back.  Old version added to alternates package
- Swapped knee ropes with their alternates

### Fixed
- Arm tether no longer blocked by leg tether
- Feats now properly apply when being used on another user
- Smooth bound animation transitions when fighting with avi AOs
- Zips and cuffs back pose use incorrect harness

## [4.1.1]
### Fixed
- Fixed bug that made all restraints inescapable o_o

## [4.1.0]
### Added
- Alternate animations for avis with narrow shoulders (Kemono)
- Handcuffs with unique lockable escape path
- Hero dialog now checks feats to give rescue suggestions
- LockGuard and LockMeister scripts added to rope wrist and leg restraints to better furniture interaction
- Owner option to disable lock pick requirement for cuffs
- Pick (Lock pick) and Cropper (bolt cutters) escape item scripts added
- Zip ties for arms and legs.

### Changed
- Action verbs for cutting changed to unique values
- Restraint folders renamed for ease of dynamic identification in code
- Performance improvements for deploying restraint changes
- "Untie" verb changed to "Release" to make more sense with non-rope restraints

### Fixed
- Adding or changing restraints no longer resets current pose if set to a PoseBall pose
- Animations will self-refresh after being interrupted by sitting/standing from PoseBall
- "Tightness" relabeled "Security" in Hero dialog to match Escape dialog terminology
- Escape-item menu entry now defaults to Escape menu when using on self
- Fix garbler sometimes treating avi as gagged after logging back in even if not gagged
- Fix pbBed01 animation not triggering
- Prevent cleave gagging avis who are ball gagged
- Security display now resets when rebound after a successful escape
- Touchers now use feats when using the dialogs of other avis
