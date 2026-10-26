# Devpost submission — local draft for creator review

Form inspected 2026-10-26. Nothing below is approved or saved to Devpost. Product facts come from approved scope/spec, static source documentation and creator answers in this shipping session. Personal experiences are used only when the creator supplies them for this entry. Do not copy private learner-profile material here.

## Project overview

- **Project name** (required, 60-character maximum): Devil’s Rock Paper Scissor. Existing name carried forward.
- **Elevator pitch** (required, 200-character maximum), revised proposal from creator answer: Rock Paper Scissor meets Werewolf in a lightweight multiplayer browser game. No downloads, no meta, no builds—just honesty and bluffing.
- Thumbnail: form permits JPG/PNG/GIF, maximum 5 MB, recommends 3:2. Not marked required; no upload selected or authorized.

## Project details

- **About the project** (required): inspiration, functionality, building process, challenges and learning drafted below from approved project facts and creator answers. Awaiting creator wording review/approval.
- **Built with** (required, up to 25 tags), proposed factual tags: Godot, GDScript, GD-Sync, TypeScript, Node.js, MongoDB, Vercel, Codex. Available tag spellings not yet selected in the form.
- **Try it out links**: public source verified at https://github.com/nakaba-ggames/Devpost-RockPaperScissor. Recorded frontend URL exists in the shipping checklist; creator decides whether to include it and confirms its current usability. No game opened or checked here.
- Image gallery: optional-looking, no required marker; permits up to 15 JPG/PNG/GIF files, maximum 5 MB each, recommends 3:2. No images selected/uploaded.
- **Video demo link** (required): pending URL and creator confirmation that reviewers can access it and that it shows the working game. Creator verification only; do not open/play/download/transcribe/analyze it.

### About the project — draft for review

#### Inspiration

I wanted a game people could open and play without a download, studying a meta, or planning a build. Devil’s Rock Paper Scissor is my take on “Rock Paper Scissor + Werewolf”: a simple, familiar game with more room for deception. No meta, no builds—just you, your honesty, and your bluff.

#### What it does

A multiplayer browser game that adds bluffing to rock paper scissor. Your claims can differ from your actual choices, and the final reveal shows what each player really did.

#### How I built it

I used Codex through my Plus subscription as the coding-agent environment. The game uses Godot and GDScript, with GD-Sync for multiplayer and a TypeScript/Node.js backend using MongoDB and Vercel Functions.

I estimate that development took about three to four active workdays, spread across eleven calendar days.

What stood out about Devpost Learn was how deeply its questions explored the product. Compared with my usual interviews about what a feature should do, this process also asked who would play, how the game should feel and what it should achieve. That gave the agents more context to make game-feel decisions without me directing every detail. I also had relatively few issues with image generation during this project, and I think the clearer audience and product direction helped.

#### Challenges

The hardest part was the back-and-forth needed to get the motion and UI polish right. The agent struggled to place menu buttons exactly where I wanted them. A broad instruction like “just polish this” could produce a decent starting point, but in my experience it did not immediately reach the standard of a satisfying game. Getting there needed more precise direction about taste, timing and configuration.

#### What I learned

I learned to be patient and give agents clear boundaries about where they could be creative and where they needed to follow my direction. Sometimes they got it right; sometimes they overcorrected. A word like “snappy” could turn into every motion being too fast, with no waiting time. I needed to be more specific about the pacing I wanted instead of relying on that word alone.

### Claim notes — not submission prose

The creator describes the game as lightweight, multiplayer and loading in five seconds. Browser/multiplayer positioning is carried into the proposed pitch; the exact five-second statement is omitted pending context about device/network and first versus repeat load. No timing, gameplay or networking test was performed by this session. Human-peer verification limits in the shipping checklist remain unchanged.

The creator reports using Codex with their $20 Plus subscription. This is their reported subscription context, not a current pricing claim or evidence of whether costs affected scope. They refer to the image model as “gpt 2.5 image”; its exact product designation is not established, so public copy says image generation. The perceived benefit of product context to image generation is explicitly their impression, not a measured causal result.

The creator subsequently confirms that usage-limit pauses disrupted development and that most work used the model they call “GPT 6.1-sol-high”, which they found efficient. Three to four active workdays over eleven calendar days is their approximate effort estimate, not a measured development benchmark. Their report of a working multiplayer product with backend support does not expand the independent testing evidence in the shipping checklist.

## Additional info — actual form prompts

These go to judges/organizers unless the form marks them as appearing in the gallery. Do not infer personal answers from account details, timezone, private profile or project records.

| Prompt | Required | Choices / visibility |
| --- | --- | --- |
| Are you submitting as an individual, a team, or an organization? | Yes | Visible choices: Individual, Team. Appears in gallery. |
| Country of residence | Yes | Creator supplies. |
| Organization name (if applicable) | No | Creator supplies if applicable. |
| Which of these did you actually use? Check all that apply. | Yes | Intro video; Live build session; Cup of Joe office hours; Discord; None. Appears in gallery. |
| Did the cost of AI (subscription, tokens, credits) affect what you did? | Yes | No, I never thought about it; It made me cut scope or switch to a cheaper model; I hit a usage limit or paywall; It stopped me from doing something I wanted to do. Multiple choices permitted. |
| Now, how confident are you that you could plan and build a small, maintainable project with a coding agent? | Yes | Scale 1 (No idea where to start) to 5 (Easily). |
| If we could fix one thing before the next person tries this, what should it be? | No | Creator's experience only. |
| URL to your open-source license within your code repository. | Yes | Verified public MIT file: https://github.com/nakaba-ggames/Devpost-RockPaperScissor/blob/main/LICENSE. Online entry not performed by agent. |
| What kind of value did your project create for you? (select all that apply) | Yes | Saved me time; Made or saved me money; Created delight / was just fun; Let me do something I couldn't do before. Appears in gallery. |
| Tell us more about the value your project provides for you? | No | Creator's experience only. |
| Explain how your project meets the main technology requirement. | Yes | Draft below based on creator process and approved planning records; awaiting creator review. |

### Survey responses captured from creator

- **Submission type:** Individual.
- **Country of residence:** Indonesia.
- **Event resources actually used:** None.
- **AI cost/limits:** “I hit a usage limit or paywall.” Creator explicitly describes usage-limit waits disrupting development. No scope cut or model switch is inferred. No form choice entered online.
- **Confidence:** **5 (Easily)**, explicitly supplied by creator. Not entered online.
- **Value categories:** “Saved me time”; “Created delight / was just fun”; “Let me do something I couldn't do before.” Explicit creator selections. Do not select the money category.
- Optional organization name, improvement feedback and value elaboration: no answer supplied; leave blank unless creator chooses to add one.
- Required personal survey selections are captured locally. Creator eligibility declarations, online completion and wording review remain pending.
- **License decision, updated 2026-10-27:** creator authorized the license and subsequently added root LICENSE/LICENSING.md in local commit f46dde9. Public standard MIT LICENSE verified through GitHub contents API, copyright 2026 nakaba-ggames. Use its direct file URL above. Earlier agent push failed; no license was published by the agent.

### Main technology requirement — proposed answer

I used the Devpost Learn Skill Pack with Codex. Its flipped-interaction questions helped me define the audience, intended game feel and goals before implementation. The resulting scope, PRD and technical spec recorded the product and architecture decisions for the build. This gave the agents product context beyond individual feature requests and helped them make decisions closer to the experience I wanted. I still directed the presentation and refined the results, especially motion and UI placement.

The additional-info form also includes required majority-age/eligibility/new-project declarations. The finalization page requires agreement to the Official Rules and Devpost Terms of Service. Creator must review and confirm their own declarations; nothing checked or submitted by this session.

## Review state

Name carried forward. Pitch, complete story sections and main-technology answer drafted from approved project facts and creator answers; no wording approval yet. Tags proposed. Required personal survey selections captured locally; creator eligibility declarations and online completion not confirmed. Optional answers may remain blank. Public source and MIT license file verified; video URL pending. Last observed Devpost entry is an Untitled DRAFT; its preview is not proof of submission. No final wording approval or submission confirmation. User may edit Devpost separately; never overwrite unsaved form contents.
