# Devil Run MVP Revamp

## Product promise

Devil Run should be easy to understand in the first 20 seconds, difficult to
master, and fair enough that every death feels like useful information. The
first release target is a polished ten-level Android MVP.

## Difficulty curve

1. Movement and jumping with a safe finish.
2. Visible spikes and double-jump practice.
3. One clearly demonstrated hidden trap.
4. Falling and disappearing platforms.
5. Moving hazards with safe observation space.
6. Temporary reversed controls with a countdown.
7. Fake doors and readable visual clues.
8. Combined traps with optional collectible routes.
9. Timing challenge with checkpoints.
10. A final mastery level combining learned mechanics.

Every new mechanic gets a safe demonstration before it can kill the player.
Trap combinations must not require blind input or unavoidable deaths.

## Retention loop

- Three objectives per level: finish, low-death target, optional collectible.
- Coins awarded for objectives, not for repeatedly watching ads.
- Unlockable cosmetic trails and player silhouettes.
- Daily challenge reuses verified level pieces with a fixed daily seed.
- Daily reward has a forgiving streak and never removes earned rewards.
- Level select shows mastery and the next achievable objective.

## Monetization rules

- Rewarded ad: one revive per run, optional double reward, optional hint.
- Interstitial: only after several completed levels, never after a death.
- No banner covering gameplay or touch controls.
- First sessions remain ad-light while the player learns the game.
- Remove-ads purchase removes interstitials but preserves optional rewards.
- Development builds use Google sample ad units only.
- Production ads wait for consent eligibility and configured privacy options.

## Analytics events

- tutorial_step_seen and tutorial_step_completed
- level_started, level_failed, level_completed, level_abandoned
- trap_death with level, trap type, and entity id
- revive_offered, revive_accepted, revive_completed
- objective_completed and cosmetic_unlocked

Do not send names, email addresses, precise location, or free-form user text.

## Release gates

- Controls remain correct across multitouch, pause, death, and app lifecycle.
- Every level is completable on a common phone aspect ratio.
- No forced ad appears during active gameplay.
- Consent and privacy options are testable for EEA and US privacy regions.
- Crash-free smoke test passes on low-, mid-, and high-tier Android devices.
- Store listing, data-safety answers, privacy policy, and production IDs match.
