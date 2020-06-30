# Changelog

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
