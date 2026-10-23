# M11 — Quick HUB audit

Date: 2026-10-24, Asia/Jakarta.

Outcome: **changes required before release integration**. One client/backend contract finding; no implementation fixes made.

## Scope and evidence

Read M11's report, approved brief/checklist/referenced requirements, current Git state and settlement, quest, transaction, clock, validation and route source. Reviewed the corresponding client decision paths. M11 implementation/completion commits are `f9cfbd3` and `ef07392`; the working tree was clean before this audit document was added.

Godot tools were discovered and a read-only editor expression confirmed the exact case-normalized project root. No scenes, gameplay, configuration, database or checklist state were changed. No tests, API calls, exports, playtests or deployments were run. The report's Atlas results remain executor-reported evidence, not independently repeated audit results. Hosted behavior, concurrency, rollback injection and other deferred checks remain unverified.

## Finding

**[P2] Reconcile finalization bounds with legal client revision history.** `backend/src/settlement-rules.ts:94` rejects more than 64 decision events per actor, and `backend/src/http.ts:45-55` applies an 8 KiB body limit to finalization. The client's accepted-choice/claim/final paths permit distinct revisions throughout the four decision windows without an equivalent event-count limit. A legal history can therefore be rejected at settlement, preventing the durable receipt needed to begin the cinematic. The event-count mismatch follows directly from source; the exact byte threshold for a particular serialized client history was not measured.

M12 should resolve payload/event bounds together with its compact wire translation. Preserve the approved revision behavior and required history; do not silently truncate accepted events or invent a gameplay revision cap. Verify the resulting contract with a focused representative valid-history check. Request creator agreement if a consequential gameplay limit is proposed.

## M12 integration prerequisites, distinct from the finding

- Normal handlers deliberately reject the current `productionReady=false` / development-only catalogue. Creator-approved release configuration and a regenerated artifact are needed; private exercise authorization is not deployment authorization.
- Normal `createM11Handlers()` does not enable `allowExerciseEmber`; fallback registration currently returns `BOT_SELECTION_UNCONFIGURED`. Wire creator-approved operational fallback selection, rather than exposing the private exercise capability publicly.
- Vercel currently serves an empty `static-api-only` output and excludes `public/`. No hosted game/API integration is established. Resolve SDK configuration distribution with the creator before uploading a client-bearing package.
- Godot uses a richer history format and preview IDs/revisions; M12 must bind permanent server identities/UUID match IDs and translate history to the backend's validated compact contract.
- M09/M10 checklist/report status remains historical despite the creator confirmations and supplied `0d4d7bb` checkpoint accepted by M11. Reconcile documented progress from actual evidence without rewriting history or fabricating checks.
- Final creator presentation/assets and outstanding release checks remain explicit inputs. M11 completion does not establish submission readiness.

The reviewed transaction/receipt, attribution, aggregate, fresh-instance, expiry-before-payment and private-clock structures broadly match the M11 report. This limited review is not proof of all runtime behavior.
