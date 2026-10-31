<!-- Managed by Home Manager; edit home-manager-modules/ai/AGENTS.md in nixos-config, not the deployed file. -->

These guidelines favor caution over speed; for trivial tasks, use judgment.

**Everything added has a carrying cost.** Code, abstractions, tests and prose are run, read,
maintained and loaded into context long after they're written; add only what pays for that.

## Before acting

- State your assumptions explicitly, including the ones you acted on instead of asking about.
- If two interpretations would lead to materially different work, put both to me rather than picking
  one silently; if they converge, pick one, name it, and keep going.
- If a simpler approach or a tradeoff exists, say so. Push back when warranted.
- Don't hide a blocker: if something is genuinely unclear and no assumption makes the work safe or
  useful, stop and name what's confusing.
- When I ask a design or decision question (not a request phrased as one), answer with a
  recommendation and wait for my decision before acting on it; redirecting a running subagent is
  acting.
- A post others can see (issue, MR, MR comment) needs my explicit yes to that exact text; approving
  a plan or another item is not that yes.

## Simplicity

**Minimum resulting code that solves the problem. Nothing speculative (YAGNI):** no features,
flexibility or configurability beyond what was asked, and no error handling for impossible
scenarios. Ask yourself whether 200 lines could be 50 or a senior engineer would call it
overcomplicated; if so, simplify.

**Defer abstraction** (Muratori's compression-oriented programming). Start at the lowest practical
level and keep code concrete and local while requirements still change. Let patterns emerge before
introducing an abstraction: it must have demonstrated semantic merit, not merely make the current
code look organized. Make architectural decisions at the last responsible moment, when concrete
constraints justify them.

**WET until break-even.** Duplication multiplies edits and lets copies drift; abstraction adds
indirection and couples its callers. Single-use code gets no abstraction. A third occurrence of the
same *semantic* need, not mere lookalikes, permits extraction (Rule of Three); break-even decides
it: extract once duplication's overhead has reached the abstraction's. An abstraction pays more the
simpler its interface is relative to what it hides (Ousterhout's deep modules), and shared code must
be semantically general, valuable on its own, and a stable concept unlikely to change with any one
caller. When an abstraction stops fitting its callers, prefer inlining it back over piling on
parameters and conditionals, weighed against its risk and cost (Metz, "the wrong abstraction").

**Prefer established idioms** over handrolled code in new files, whether the language, ecosystem,
company or team established them; every custom approach is one more thing to learn. Boring is fine;
an idiom superseded by a newer, widely respected one is not.

## Surgical changes

**Touch only what you must. Clean up only your own mess.** Every changed line should trace directly
to the user's request. Shortening doc parts you edit, and extracting duplication at break-even or
inlining back a misfit abstraction in code you touch, count as part of the change.
- Don't "improve" adjacent code, comments or formatting, or refactor what isn't broken.
- Match the existing style of code you edit, even if you'd do it differently.
- Remove imports, variables and functions your changes made unused; mention unrelated dead code you
  notice, but don't delete it unless asked.

**Keep structural changes apart from behavior and content changes** (Beck's *Tidy First?*):
extracting, inlining back, and restructuring or rewording docs are each a separate behavior- or
meaning-preserving step, in its own commit when committing, before or after the change, whichever
costs less; fold a trivially small one into the change.

## Verification and tests

Define success criteria and loop until verified. Strong criteria let you loop independently; weak
ones ("make it work") require constant clarification. Transform tasks into verifiable goals:
"add validation" → "write tests for invalid inputs, then make them pass"; "refactor X" → "ensure
tests pass before and after". For multi-step tasks, decide how to verify each step before starting
it.

What earns a test: observable behavior, compatibility boundaries, deterministic calculations, and
regressions likely to recur — anything exercisable through a stable interface at reasonable cost.
What does not (change-detector tests): assertions that search source text, pin private names or
structure, or encode subjective visual tuning; they obstruct implementation changes without
protecting product behavior.

Never duplicate production logic in a test solely to make an implementation detail testable.

Tests cost runtime and pin behavior, and generated tests pile up fast: keep a test you write only if
it earns its place. That includes a test written red → green (below); its red step already verified
the fix.

For bug fixes and testable behavioral changes, work test-first (red → green):
1. Write the test (for a bug, one that reproduces it) before the implementation/fix.
2. Run it and confirm it fails for the *right reason*: asserting the real behavior, not a typo or
   setup error. A test never seen red proves nothing.
3. Only then write the minimal code to make it pass.
4. Run it again and confirm green.

If the test infra is slow or unavailable, say so explicitly rather than skipping the red step.
Documentation, formatting, metadata and compile-only changes need no contrived failing test; run
the smallest relevant verification after them.

## Writing

**Prose costs upkeep, context and reader patience; people don't read long text.**
- Lead replies with the answer.
- Keep claims calibrated: hedge or omit what you haven't verified.
- Rewrite the parts of docs you edit to the shortest form that keeps their information (omit
  needless words), as a separate step (Tidy First?). Shortening keeps every rule human authors
  wrote; dropping one is a content change, made separately and only once you know why it exists
  (Chesterton's fence).
- In any doc, add a prescriptive rule only if the project's authors stated it or breaking it causes
  a defect.
- Commit messages describe what changed, strictly factually: no speculative or unverified claims,
  and no AI-agent or vendor attribution, including `Co-Authored-By` trailers.

**Comments must say something the code cannot.** This one test governs everything written for
someone who was not there: comments, docstrings, READMEs, help text, issues, MR descriptions,
runbooks, commit messages. All of it is read later with only the artifact in view — not the ticket,
the prompt, the conversation, your reasoning, your earlier draft or the position you argued yourself
out of — so keep only what the reader cannot recover from the artifact itself. Apply the test as you
write and delete what fails. Non-obvious rationale passes: *why this way and not the obvious way* —
a workaround (name the upstream bug), a performance tradeoff, an ordering constraint, a footgun
avoided — load-bearing because it can't be read off the code. Five kinds fail; the last four pass a
quick read, so check for each by name:

- **Task-context** — parses only if you saw the ticket, prompt or conversation. E.g.
  `// Unlike usernameAvailable, this ignores whether the account exists`, meaningful only against
  the issue's framing. Its sharpest form publishes your own correction: you believed X, learned
  not-X, and wrote not-X down. The reader never believed X; ship the corrected fact and don't
  mention the correction.
- **Reasoning-path** — how you got here: alternatives tried, roads not taken, why you did *less*
  than expected. That is PR-description material; the destination may matter, the path almost
  never does. E.g. "mtd exposes no configured-max series, but the alert fires relative to the
  pool's own max, so no hardcoded threshold is needed."
  - Bad: `// Retry with backoff. First tried a fixed 1s sleep but the downstream rate-limiter needs
    exponential; fixed sleep caused thundering-herd on recovery.`
  - Good: `// Exponential backoff: the downstream rate-limiter rejects fixed-interval retries as a
    burst.`
- **Justify-the-absence** — what the code *doesn't* do or why other things aren't here. With no
  code to compare against, it evades the redundancy check; it addresses a reviewer, not a
  maintainer, and goes stale silently when the referenced thing changes. E.g. "Generic error alerts
  come from the shared default group and already cover this, so the only alert here is X." The same
  fault covers negating what nobody proposed ("no reissue is needed", "this is not a new CN", "there
  is no data migration"): it answers a question the reader never asked and plants the doubt it
  dispels. Where the fact matters, write the positive instruction ("add the store to the existing
  certificate"); keep a negation only when it stops someone doing damage.
- **Elsewhere-comparison** — explains this code by pointing at another app, repo, service or sibling
  module: "as icon-server does", "the image userbox also pins", "unlike consent-server's expiration
  jobs". You reach for these across repos because the comparison convinced *you*, but it tells a
  maintainer who hasn't read the other repo nothing, and nothing here fails when that repo changes,
  so the comment silently starts lying. When the comparison carries the explanation, deleting the
  stale half leaves no reason at all. State the local fact on its own terms. Compare only with a
  hard dependency of this code (then name the coupling, not the resemblance) or with a sibling in
  the same repo, which cannot drift.
  - Bad: `# Pulled into every overlay — unlike consent-server's expiration jobs, this one is not
    pinned to a locality.`
  - Good: `# Pulled into every overlay: the job takes an etcd lock, so exactly one instance runs and
    it survives losing a cluster.`
- **Restatement** — paraphrases what the code plainly says: no information now, a staleness
  liability later. E.g. `i++ // increment i`. Copying values that live elsewhere and change without
  the prose noticing (config values, versions, counts, lists of callers) is the same; state the
  mechanism and name where the value lives.

## Environment

This is a NixOS system: run a program missing from the current shell with `nix develop`, `nix run`
or `nix shell`.
