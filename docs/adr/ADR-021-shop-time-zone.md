# ADR-021 — Shop time zone is Asia/Kolkata in V1

**Status:** Accepted (Phase 1, 17 Nov 2026). Closes open decision 7.

## Context

`shops.time_zone` is `NOT NULL` and defines the shop's business day: "today's credit", daily closing and report ranges all use it (schema decision 11, PRD 9.5). Shop setup (WF-002) does not ask for a time zone, and V1 serves shops in India only.

## Decision

1. Shop setup stores `Asia/Kolkata` (`ShopTimeZone.defaultName`) without asking the owner.
2. Every business-date calculation reads the stored zone through `ShopTimeZone.resolve(shop.timeZone)`, never the phone's zone. An unknown stored name falls back to `Asia/Kolkata` rather than failing a write.
3. A screen that shows a date from a stored instant converts it with the shop zone, not `DateTime.toLocal()`.

## Consequences

- A phone set to another zone still records the shop's Indian business day.
- If V1 ever serves shops outside India, setup gains a zone picker and existing rows keep their stored value; no migration is needed.
