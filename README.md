# alc-die-waehrung-des-geistes

[![content validation](https://github.com/astrapi69/alc-die-waehrung-des-geistes/actions/workflows/validate-content.yml/badge.svg)](https://github.com/astrapi69/alc-die-waehrung-des-geistes/actions/workflows/validate-content.yml)
[![engine on npm](https://img.shields.io/npm/v/learn-content-engine?label=engine%20on%20npm)](https://www.npmjs.com/package/learn-content-engine)

The [Adaptive Learner](https://github.com/astrapi69/adaptive-learner)
content repository for the book **Die Währung des Geistes** by Asterios
Raptis: a Git repository of plain lesson files that the app loads
directly and no vendor can lock away.

It ships one German-language knowledge set, `waehrung-des-geistes`
(domain `philosophy`), with 11 lessons on the six currencies of the
mind (Aufmerksamkeit, Zeit, Vertrauen, Empathie, Präsenz and Ideen)
and the values that grow from them. This repository was created from
[adaptive-learner-content-template](https://github.com/astrapi69/adaptive-learner-content-template),
which provides the schema mirror, validator, CI and authoring tooling
described below.

## The set

`sets/de/waehrung-des-geistes` (source and target language: German,
level `reflexion`, content license CC-BY-SA-4.0), one lesson per topic:

| # | Lesson | Title |
|---|--------|-------|
| 01 | `01-ueberblick.json` | Überblick: Die sechs Währungen des Geistes |
| 02 | `02-aufmerksamkeit.json` | Aufmerksamkeit: Das Gold der Seele |
| 03 | `03-zeit.json` | Zeit: Die nicht erstattungsfähige Münze |
| 04 | `04-vertrauen.json` | Vertrauen: Die Ökonomie des Glaubens |
| 05 | `05-empathie.json` | Empathie: Die gemeinsame Geldbörse |
| 06 | `06-praesenz.json` | Präsenz: Das Gold des Augenblicks |
| 07 | `07-ideen.json` | Ideen: Die Währung, die sich beim Teilen vermehrt |
| 08 | `08-frieden-stille.json` | Innerer Frieden und Stille |
| 09 | `09-klarheit-grenzen.json` | Klarheit, Grenzen und Produktivität |
| 10 | `10-wirkung-verbindung.json` | Wirkung, Sinn und Verbindung |
| 11 | `11-integration.json` | Integration: Die innere Ökonomie ins Gleichgewicht bringen |

Each lesson combines theory steps with exercises (cloze, free text,
matching) and links the book (E-Book and Taschenbuch) as its resource.

## What's inside

- `manifest.yaml`: the root manifest listing the single set above.
- `sets/de/waehrung-des-geistes/`: the set manifest plus the 11 lesson JSONs.
- `schema/`: the pinned [`learn-content-engine`](https://github.com/astrapi69/learn-content-engine)
  schema mirror; [`engine-version.txt`](schema/engine-version.txt) holds the
  pinned engine version and is the source of truth. This
  is what the content is validated against, independent of the app.
- `templates/`: starting-point lessons per domain (language / programming /
  knowledge), kept from the template for authoring new lessons.
- `scripts/validate_content.py`: the local validator.
- `scripts/generate_exercises.py`: an optional BYOK AI exercise generator.
- `generated/`: staging area for AI drafts (never shipped directly).
- `.github/workflows/`: CI that validates every push/PR against the pinned engine.
- `docs/`: [GETTING-STARTED.md](docs/GETTING-STARTED.md) and a local
  [LESSON-FORMAT.md](docs/LESSON-FORMAT.md). The **canonical, test-validated**
  format reference is the engine's
  [`docs/lesson-format.md`](https://github.com/astrapi69/learn-content-engine/blob/main/docs/lesson-format.md).

## Quick start

```bash
git clone https://github.com/astrapi69/alc-die-waehrung-des-geistes.git
cd alc-die-waehrung-des-geistes

# Validate the set (needs only Python 3 + these two deps)
pip install pyyaml jsonschema
python3 scripts/validate_content.py        # exit 0 == all sets pass
```

Before you push, `make lint` runs the same semantic engine gate as CI
(`Engine conformance`): it installs the engine release pinned in
`schema/engine-version.txt` into `node_modules/` (gitignored; needs Node.js
and npm) and checks every lesson and manifest with the engine's rule ids
(`E-CARD-REF` & co.). `make lint-warnings` additionally prints the engine
CLI's warnings (`W-*`).

Full authoring walkthrough: [docs/GETTING-STARTED.md](docs/GETTING-STARTED.md).

## Export a set for AI review

`scripts/export_set.py` writes all lessons of ONE set into a single
YAML (or JSON) file so an AI assistant or a human can review the whole
set in one pass (syntax, correctness, consistency across lessons).

**Recommended (via make; reuses the local environment `make validate` set up):**

```bash
make export ARGS="waehrung-des-geistes"
# -> exports/waehrung-des-geistes-de-<timestamp>.yaml
```

**Direct (fallback; run it inside the venv from the Quick start):**

```bash
python3 scripts/export_set.py waehrung-des-geistes
python3 scripts/export_set.py waehrung-des-geistes --format json --out /tmp/review.json
```

The slug is the set id from the root `manifest.yaml` or the folder name
of the set path (both `waehrung-des-geistes` here); when the same
folder name exists under several source-language directories, `--lang`
(default `de`) picks the `sets/<lang>/` directory. Umlauts stay real
UTF-8. An unknown slug aborts with a list of the available sets.

For a large set, `--split-size N` writes multiple self-contained files
of at most N lessons each instead of one huge file, e.g.
`make export ARGS="waehrung-des-geistes --split-size 4"` (each part
keeps its own `review_instructions` copy, so any one file can be
handed to an AI on its own). Cannot be combined with `--out`.

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

Full usage guide and best practices (incl. the source-chapter workflow):
[`docs/export-set-usage.md`](docs/export-set-usage.md) (English) /
[`docs/export-set-usage.de.md`](docs/export-set-usage.de.md) (Deutsch).

## Generate exercises with AI (optional)

`scripts/generate_exercises.py` turns a topic into a lesson with a BYOK
model (Anthropic / OpenAI / Gemini) and gates every draft through
`validate_content.py` before writing it into `generated/`:

```bash
export ANTHROPIC_API_KEY="sk-..."          # or OPENAI_API_KEY / GEMINI_API_KEY
python3 scripts/generate_exercises.py \
  --topic "Vertrauen als Ökonomie des Glaubens" \
  --target-lang de --source-lang de --set-id waehrung-des-geistes
```

A draft is a draft until you review it against the book's actual
wording: no validator catches a claim the book never makes.

## How it stays current

The content is validated against the **pinned** engine version in
`schema/engine-version.txt` on every push and pull request (structural +
semantic + drift gates in `.github/workflows/`). A green CI means the
content is valid for every consumer of that engine release. When the
engine is bumped, it reaches this repository the same way it reaches the
rest of the chain: a deliberate pin-bump PR that the drift gate guards.

Background and prompt recipes: the blog post *Build Your Own Lessons for
Adaptive Learner*. The tooling is licensed MIT (see [LICENSE](LICENSE));
the lesson content carries its own license, CC-BY-SA-4.0, declared in the
set manifest's `metadata.license`.
