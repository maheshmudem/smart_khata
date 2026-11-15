# Contributing

## Before you start

1. Pick a task from `docs/product/07_Implementation_Backlog.md` and check it meets the Definition of Ready (§5): the rule, the screen and the acceptance criteria are clear.
2. Read the documents listed for that kind of change at the top of `CLAUDE.md`.
3. If an accounting rule, a Telugu term or a security choice is unclear, add it to `docs/engineering/open-decisions.md` and ask. Do not guess.

## Workflow

```bash
git checkout main && git pull
git checkout -b feature/SK-0302-add-edit-party
# ... work in small commits ...
dart format . && flutter analyze && flutter test
git push -u origin feature/SK-0302-add-edit-party    # then open a pull request
```

- Build inside-out: domain and its tests → data and its tests → BLoC → page → strings in both languages.
- Commit messages follow Conventional Commits and cite IDs:

  ```
  feat(parties): add and edit party (SK-0302)

  Implements FR-PAR-001, FR-PAR-002, FR-PAR-004 for WF-021.
  ```

- Fill in the pull request template. A schema change or a change to financial behaviour must be called out and needs explicit sign-off.
- `main` is always releasable. Merge only with green CI and an approval.

## Definition of Done

`docs/product/07_Implementation_Backlog.md` §6. In short: rules outside the UI, all four screen states, English and Telugu, tests at the right levels, nothing sensitive in logs, formatted, analyzed, reviewed, docs updated.

## Never commit

Keystores, `android/key.properties`, `.env` files, backup archives, or any real customer or shop data, including in test fixtures and screenshots.

## Reporting a problem

Wrong balance, lost data, a restore that damaged records, or data exposed to the wrong party is **Critical**: stop and raise it immediately. Severity definitions are in the backlog §9.
