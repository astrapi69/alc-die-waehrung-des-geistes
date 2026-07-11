# adaptive-learner-content-template

A **GitHub template** for building your own [Adaptive Learner](https://github.com/astrapi69/adaptive-learner)
content: a Git repository of plain lesson files that the app loads
directly and no vendor can lock away.

> Click **“Use this template” → Create a new repository** (not *Fork*) to
> get a fresh, independent copy under your own account, then clone it.

This template is the clean scaffold — schema, validator, CI, authoring
templates, an AI generator, and **one** small example set. It ships **no**
real content: you replace the example with your own.

## What's inside

- `manifest.yaml` — the root manifest listing your sets (one example set to start).
- `sets/en/es-a1/` — one minimal, valid example lesson + its set manifest.
- `schema/` — the pinned [`learn-content-engine`](https://github.com/astrapi69/learn-content-engine)
  schema mirror + `engine-version.txt` (currently `0.6.0`). This is what
  your content is validated against — independent of the app.
- `templates/` — starting-point lessons per domain (language / programming / knowledge).
- `scripts/validate_content.py` — the local validator.
- `scripts/generate_exercises.py` — an optional BYOK AI exercise generator.
- `generated/` — staging area for AI drafts (never shipped directly).
- `.github/workflows/` — CI that validates every push/PR against the pinned engine.
- `docs/` — [GETTING-STARTED.md](docs/GETTING-STARTED.md) and a local
  [LESSON-FORMAT.md](docs/LESSON-FORMAT.md). The **canonical, test-validated**
  format reference is the engine's
  [`docs/lesson-format.md`](https://github.com/astrapi69/learn-content-engine/blob/main/docs/lesson-format.md).

## Quick start

```bash
# 1. Use this template -> your own repo -> clone it
git clone https://github.com/<you>/<your-content-repo>.git
cd <your-content-repo>

# 2. Validate the example (needs only Python 3 + these two deps)
pip install pyyaml jsonschema
python3 scripts/validate_content.py        # exit 0 == all sets pass

# 3. Replace the example with your own lesson, then re-validate + commit.
```

Full walkthrough: [docs/GETTING-STARTED.md](docs/GETTING-STARTED.md).

## Export a set for AI review

`scripts/export_set.py` writes all lessons of ONE set into a single
YAML (or JSON) file so an AI assistant or a human can review the whole
set in one pass (syntax, correctness, consistency across lessons):

```bash
python3 scripts/export_set.py waehrung-des-geistes
# -> exports/waehrung-des-geistes-de-<timestamp>.yaml
python3 scripts/export_set.py waehrung-des-geistes --format json --out /tmp/review.json
```

The slug is the set id from the root `manifest.yaml` or the folder name
of the set path (both `waehrung-des-geistes` here); when the same
folder name exists under several source-language directories, `--lang`
(default `de`) picks the `sets/<lang>/` directory. Umlauts stay real
UTF-8. An unknown slug aborts with a list of the available sets.

The export is self-contained: its first field `review_instructions`
holds the complete review prompt from
[`docs/ai-review-prompt-template.md`](docs/ai-review-prompt-template.md)
(read at runtime, not copied into the script). The export file can be
handed to a review AI as-is, without manually prepending a prompt. Edit
the review instructions in that template file and keep the sibling
content repos in sync.

**Read-only snapshot, NOT a re-import format:** nothing reads the
export back. Changes flow only through the individual schema-validated
lesson JSONs under `sets/`. The `exports/` folder is gitignored.

## Generate exercises with AI (optional)

`scripts/generate_exercises.py` turns a topic into a lesson with a BYOK
model (Anthropic / OpenAI / Gemini) and gates every draft through
`validate_content.py` before writing it into `generated/`:

```bash
export ANTHROPIC_API_KEY="sk-..."          # or OPENAI_API_KEY / GEMINI_API_KEY
python3 scripts/generate_exercises.py \
  --topic "Ordering food in a café" \
  --target-lang fr --source-lang en --level A1 --set-id fr-a1
```

A draft is a draft until you review it — and for a language you do not
speak natively, get a native-speaker review before shipping. No validator
catches an unnatural phrasing.

## How it stays current

Your content is validated against the **pinned** engine version in
`schema/engine-version.txt` on every push and pull request (structural +
semantic + drift gates in `.github/workflows/`). A green CI means your
content is valid for every consumer of that engine release. When the
engine is bumped, it reaches this repository the same way it reaches the
rest of the chain: a deliberate pin-bump PR that the drift gate guards.

Background and prompt recipes: the blog post *Build Your Own Lessons for
Adaptive Learner*. Licensed MIT (see [LICENSE](LICENSE)); your authored
content may carry its own license via each set manifest's `metadata.license`.
