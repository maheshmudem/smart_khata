# Documentation

| Folder | What | Who changes it |
|---|---|---|
| [`product/`](product/README.md) | The approved V1 baseline: PRD, UI/UX spec, architecture, test plan, wireframes, schema, backlog, decision log, `schema_v1.sql` | Nobody, in place. A change is a new ADR |
| [`engineering/`](engineering/) | How this codebase is built | Updated with the code |
| [`adr/`](adr/README.md) | Decisions made after the baseline | One new file per decision |
| [`release/`](release/release-checklist.md) | What is left before release, the device test checklist, store and privacy drafts | Updated as gates are passed |

## Engineering docs

- [Architecture](engineering/architecture.md) — layers, data flow, errors, state, lifecycle
- [Coding standards](engineering/coding-standards.md) — naming, money, dates, logging, git
- [Design system](engineering/design-system.md) — colours, type, tokens, components, states
- [Testing](engineering/testing.md) — levels, the 14 invariants, how to write a composite-write test
- [CI/CD](engineering/ci-cd.md) — pipelines, GitHub setup, signing, releasing
- [Glossary](engineering/glossary.md) — domain terms and draft Telugu terms
- [Open decisions](engineering/open-decisions.md) — what still needs a person or a spike

## Reading order for a new contributor

1. `product/README.md` and `product/01_PRD.md` §1–§9
2. `engineering/architecture.md`
3. `adr/ADR-015` and `adr/ADR-016`
4. `product/06_Drift_Database_Schema.md`
5. The root `CLAUDE.md` (the rules that are never broken)
