# Shipping Git/privacy review — 2026-10-26

Read-only inspection at `a515314` on `main`, before preparing shipping documents. The working tree/index were clean. Both Godot and backend directories resolve to the shared parent repository; cached `origin/main` equals HEAD. This is not fresh server confirmation. No staging, commit, push, visibility change, cleanup or history rewrite.

## Local findings

- 1,210 tracked paths, no nonignored untracked files, 34 commits across available local refs. Current tracked text and 1,288 distinct historical text blobs were checked for selected credential-bearing MongoDB URIs, private-key headers, AWS/GitHub/OpenAI tokens and issued anonymous-account credentials. No selected-pattern matches.
- No real `.env` variants, actual `devpost/learner-profile.md`, `.local/` test state, `keys.cfg` or `export_credentials.cfg` found among current tracked/historical paths. `backend/.env.example` contains an empty URI. Existing ignore rules cover the private profile and local environment/service/test state. The private learner profile was not loaded or copied into shipping copy.
- **Generated output is already committed:** 12 `builds/` files total 47,348,533 bytes. The historical statement that generated exports are ignored does not cover this tracked sibling directory. No build file was opened, executed or changed in this review.
- **Metadata is already committed:** six `.DS_Store` paths at repository root and under Godot root, Graphics, Graphics/Simple Shapes, Sounds and addons. These can contain local Finder metadata; binary contents were not inspected. Recommend omitting them from future publication inputs, subject to creator direction about history.
- **Test material is already committed:** 38 report screenshots and JSON evidence. `M07_evidence/data_checks.json` and `M08_evidence/quest_checks.json` have player-ID fields. `AGY_Polishing_report.md`, especially “Two native flows” and “Approved-origin local browser journey”, contains test-profile names, points and match/receipt identifiers. These are not detected credentials, but they need a deliberate public inclusion/redaction decision. Screenshots were not visually privacy-reviewed. No personal learning reflections have been put into the new public-facing README.
- No project-wide license file found. Existing license notices belong to Devpost Learn, GD-Sync and the MCP toolkit; they do not establish a license for all game code/art/audio. Do not select a blanket license or remove notices without creator direction.

## Limits and remote access

Text-content scans skipped binaries and files over 2 MB: 233 binary / 4 large current files, 244 binary / 8 large historical blobs. Arbitrary passwords, unknown/encoded tokens, copied private prose and binary/image disclosures are not exhaustively detected. Filename checks and selected regex checks are bounded evidence, not universal clearance.

GitHub connector metadata returned 404; the signed-out browser also showed “Page not found”. Creator subsequently confirmed the repository has not been made public. These observations do not inspect private remote contents, remote-only branches, deleted objects, Actions artifacts, forks or deployment uploads. No repository-fetch/write authentication or secret material was requested.

The earlier [Git secrets report](Git_Secrets_Check_2026-10-26.md) remains valid for its older snapshot. Its release-failure note is superseded by later sections of the polishing report and the creator's release-resolution confirmation; neither report is a new gameplay check.

## Proposed handling

Keep the existing repository private while the creator reviews source/publication scope. Retain safe scope/PRD/spec and functional source/assets/setup. Decide explicitly whether builds/test evidence/metadata should stay public. Ordinary future removal does not erase history; a sanitized source snapshot or history remediation would be separate proposals requiring authorization. No secret finding currently justifies credential rotation or a history rewrite.

New prepared files are `rock-paper-scissor/README.md`, `rock-paper-scissor/devpost/shipping-checklist.md`, `rock-paper-scissor/devpost/submission-draft.md` and this report. None is staged or approved for publication. The actual Devpost form additionally confirms an open-source license URL is mandatory. No original report, scene, script, project setting, backend behavior or service configuration was changed.

## Later access/license addendum — 2026-10-27

The creator independently made the existing repository public and explicitly authorized adding/changing the license. Public GitHub metadata and a signed-out browser now confirm access; the earlier 404 limitation is historical. A live `ls-remote` confirms remote main is `a51531428c71d62cca1e3db51133ac8f7d12412c`, matching the locally scanned baseline. No remote-only branch/artifact/deleted-object clearance is inferred.

Prepared standard MIT text for original code (copyright 2026 nakaba-ggames) and separate LICENSING.md scope notes retaining third-party terms and excluding artwork/audio/fonts/branding. Only those two files were staged/committed in an isolated temporary local clone, commit `4518fae`; the shared checkout/index and unrelated output folder remain untouched. Push failed because Git has no GitHub credentials. Connector permissions are read-only, and the available browser still showed Sign in after creator reported logging in, so the exact in-app browser login was opened/requested. Nothing was uploaded/published by the agent. Ready root-file copies are in `devpost/license-files/`; their presence locally is not proof of an active public project license.
