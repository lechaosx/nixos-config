<!-- Managed by Home Manager; edit home-manager-modules/ai/AGENTS.md in nixos-config, not the deployed file. -->

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly, including the ones you acted on instead of asking about.
- Ask when the readings diverge. If two interpretations would lead to materially different work, put
  both to me rather than picking one silently. If they converge, pick one, name it, and keep going.
- If a simpler approach exists, say so. Push back when warranted.
- Don't hide a blocker. If something is genuinely unclear and no assumption makes the work safe or
  useful, stop and name what's confusing.
- When I ask a design or decision question (not a request phrased as one), answer it with a
  recommendation, then wait for my decision before acting on it; redirecting a running subagent is
  acting.
- Any post others can see (issue, MR, MR comment) needs my explicit yes for that exact text;
  approving a plan or another item is not that yes.

## 2. Simplicity First

**Minimum resulting code that solves the problem. Nothing speculative (YAGNI).**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

**Everything added has a carrying cost.** Code, abstractions, tests and prose are run, read,
maintained and loaded into context long after they're written; add only what pays for that.
- Tests cost runtime and pin behavior, and generated tests pile up fast. Keep a test you write only
  if it earns its place (§4).
- Prose costs upkeep, context and reader patience; people don't read long text. Lead replies with
  the answer. Rewrite the parts of docs you edit to the shortest form that keeps their information
  (omit needless words), as a separate step (Tidy First?, below). Keep claims calibrated: hedge or
  omit what you haven't verified.
- Shortening keeps every rule human authors wrote. Dropping one is a content change, made separately
  and only once you know why it exists (Chesterton's fence). In any doc, add a prescriptive rule
  only if the project's authors stated it or breaking it causes a defect.
- In new files, prefer established idioms over handrolled code, whether the language, ecosystem,
  company or team established them; every custom approach is one more thing to learn. Boring is
  fine; an idiom superseded by a newer, widely respected one is not. Edits to existing files match
  that file's style (§3).

**Defer abstraction** (Muratori's compression-oriented programming). Start at the lowest practical
level and keep code concrete and local while requirements are still changing. Let patterns emerge
before introducing an abstraction: it must have demonstrated semantic merit, not merely make the
current code look organized. Make architectural decisions at the last responsible moment, when
concrete constraints justify them.

**WET until break-even.** Duplication multiplies edits and lets copies drift; abstraction adds
indirection and couples its callers. A third occurrence of the same *semantic* need, not mere
lookalikes, permits extraction (Rule of Three); break-even decides it: extract once duplication's
overhead has reached the abstraction's. An abstraction pays more the simpler its interface is
relative to what it hides (Ousterhout's deep modules), and shared code must be semantically general,
valuable on its own, and a stable concept unlikely to change with any one caller. When an
abstraction stops fitting its callers, prefer inlining it back over piling on parameters and
conditionals, weighed against its risk and cost (Metz, "the wrong abstraction"). Keep structural
changes apart from behavior and content changes (Beck's *Tidy First?*): extracting, inlining back,
and restructuring or rewording docs are each a separate behavior- or meaning-preserving step, in its
own commit when committing, before or after the change, whichever costs less; fold a trivially small
one into the change.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request. Shortening doc parts you
edit, and extracting duplication at break-even or inlining back a misfit abstraction in code you
touch, are part of the change, each as its own preserving step (§2).

**Comments must say something the code cannot.** This is the one test, and it governs everything written for someone who was not there — comments, docstrings, READMEs, help text, and equally issues, MR descriptions, runbooks and commit messages. Each earns its place only if it carries information the reader cannot recover from the thing itself. All of it is read later without the ticket, the prompt, or your reasoning in view: the reader has the artifact and nothing else — not the conversation, not your earlier draft, not the position you argued yourself out of an hour ago. Apply the test at write-time and delete anything that fails it. These five kinds fail. The last four pass a quick read, so check for each by name:

- **Task-context** — only parses if you saw the ticket/prompt/conversation. The reader didn't. E.g. `// Unlike usernameAvailable, this ignores whether the account exists` — meaningful only against the issue's framing. Its sharpest form is publishing your own correction: you believed X, learned not-X, and wrote not-X down. The reader never believed X — ship the corrected fact and say nothing about the correction.
- **Reasoning-path** — the story of how you arrived here: alternatives tried, roads not taken, why you did *less* than expected. This is your PR description leaking into the file. The destination may matter; the path there almost never does. E.g. "mtd exposes no configured-max series, but the alert fires relative to the pool's own max, so no hardcoded threshold is needed."
- **Justify-the-absence** — explaining what the code *doesn't* do or why other things aren't here. It evades the redundancy check (there's no code to compare against) but it's aimed at a reviewer, not a maintainer, and it goes stale silently when the referenced thing changes. E.g. "Generic error alerts come from the shared default group and already cover this, so the only alert here is X." The same fault covers negating what nobody proposed — "no reissue is needed", "this is not a new CN", "there is no data migration" — each answering a question the reader never asked and planting the doubt it dispels. Where the fact still matters, write the positive instruction ("add the store to the existing certificate"), never the negation; a negation earns its place only when it stops someone doing damage.
- **Elsewhere-comparison** — explains this code by pointing at another app, repo, service or sibling module: "as icon-server does", "the image userbox also pins", "unlike consent-server's expiration jobs". You reach for these while working across repos, because the comparison is what convinced *you*. It is worthless to a maintainer who has not read that other repo, and it rots without warning — nothing in this repo fails when the other one changes, so the comment quietly starts lying. Worse, when the comparison carries the actual explanation, deleting the stale half leaves no reason at all. State the local fact on its own terms; a comparison is only admissible when the other thing is a hard dependency of this code, and then name the coupling, not the resemblance. Pointing at a *sibling within the same repo* is fine — it cannot drift out from under you.
- **Restatement** — paraphrases what the code plainly says. No information now, and a staleness liability later. E.g. `i++ // increment i`. The same goes for copying values that live elsewhere and change without the prose noticing (config values, versions, counts, lists of callers): state the mechanism and name where the value lives.

What passes: **non-obvious rationale** — *why this way and not the obvious way.* A workaround (name the upstream bug), a performance tradeoff, an ordering constraint, a footgun avoided. Load-bearing precisely because it can't be read off the code.

- Bad: `// Retry with backoff. First tried a fixed 1s sleep but the downstream rate-limiter needs exponential; fixed sleep caused thundering-herd on recovery.` (reasoning-path — the history is noise)
- Good: `// Exponential backoff: the downstream rate-limiter rejects fixed-interval retries as a burst.` (rationale — why, not how you got there)
- Bad: `# Pulled into every overlay — unlike consent-server's expiration jobs, this one is not pinned to a locality.` (elsewhere-comparison — and the contrast is doing the explaining)
- Good: `# Pulled into every overlay: the job takes an etcd lock, so exactly one instance runs and it survives losing a cluster.` (the local mechanism, true no matter what siblings do)

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For bug fixes and testable behavioral changes, work test-first in this direction (red → green):
1. Write the test before the implementation/fix.
2. Run it and confirm it fails — and fails for the *right reason* (asserting the real behavior, not a typo/setup error). A test that was never seen red proves nothing.
3. Only then write the minimal code to make it pass.
4. Run again and confirm green.

Then keep the test only if it earns its place (below); the red step verified the fix either way.

If the test infra is slow/unavailable, say so explicitly rather than skipping the red step.

What earns a test: observable behavior, compatibility boundaries, deterministic calculations, and
regressions likely to recur — anything exercisable through a stable interface at reasonable cost.

What does not (change-detector tests): assertions that search source text, pin private names or
structure, or encode subjective visual tuning. They obstruct implementation changes without
protecting product behavior.
Never duplicate production logic in a test solely to make an implementation detail testable.
Documentation, formatting, metadata, and compile-only changes do not require a contrived failing
test; run the smallest relevant verification after the change.

For multi-step tasks, decide how each step will be verified before starting it.

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Git Commits

- Do not add AI-agent or vendor attribution to commit messages, including `Co-Authored-By` trailers.
- Keep commit messages strictly factual - describe what changed, no speculative or unverified claims.

## 6. NixOS Environment

- This is a NixOS system. If a needed program is unavailable in the current shell, use `nix develop`, `nix run`, or `nix shell` to run it.
