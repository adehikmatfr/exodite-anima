---
name: information-architecture-and-navigation
description: Use when structuring or restructuring content, menus, categories or labels, when users cannot find things, or when a product adds sections. Covers content inventory, card sorting, tree testing, labelling, navigation models and findability metrics.
---
# Information Architecture and Navigation

## Purpose
Organise content and functions so that users find them using their own words, and prove it before building.

## When to use
- New product, new section, or growth past about 7 top-level items.
- Search logs, support tickets or analytics show failed finding ("can't find", high search-after-navigation).
- A rename, merger or migration changes labels or URLs.

## Principles
- Structure follows user mental models and tasks, not the org chart.
- Labels use users' vocabulary (from research and search logs), consistent with the glossary and support content.
- Test structure separately from visual design: tree test the hierarchy, then test the interface.
- Prefer breadth of about 5-9 items per level and depth of 3 clicks or fewer to frequent content; treat these as heuristics, not rules; clear labels beat a click count.
- Navigation must remain usable with keyboard and screen reader (`inclusive-and-accessible-design`).

## Steps / Checklist
1. Content inventory: list every page or function (ID, title, owner, last updated, traffic, keep / merge / retire). Audit at least the top 80% of traffic.
2. Gather user vocabulary: search terms, support ticket wording, interview quotes; list synonyms.
3. Open card sort: 15-30 participants, 30-60 cards, analyse with a similarity matrix and dendrogram; expect agreement pairs above 60% to indicate a strong group.
4. Draft the hierarchy (2-3 variants); write labels; note synonyms and redirects.
5. Closed card sort or tree test: 50+ participants per variant, 6-10 tasks, each a findability goal.
6. Choose a navigation model: 

| Model | Fits | Watch out |
|-------|------|-----------|
| Top bar | 5-7 sections, content sites | overflow on mobile |
| Sidebar | many tools, dashboards | hides on small screens |
| Bottom tab bar | 3-5 mobile primary areas | no room for growth |
| Hub and spoke | task-focused mobile flows | return path |
| Search-first plus facets | large catalogues | poor when categories are unclear |

7. Define labelling rules: nouns for places, verbs for actions, no jargon, no two items with overlapping labels; check every label in a 5-second test.
8. Plan URLs and redirects; keep breadcrumbs, current-location indicators and a visible search on content-heavy products.
9. After launch monitor findability metrics and iterate.

## Output format
Sitemap (hierarchy with labels and content IDs), label list with synonyms, tree-test report, navigation spec. Findability targets: tree test task success 70% or higher (80% or higher for critical tasks); directness (first click correct, no backtracking) 60% or higher; median time under 20 s for a known-item task; search exits below 15%. Mini-example: 3 of 8 tasks below 70%; task "Change billing email" 41% success because 46% clicked Profile rather than Billing; rename to "Billing and contact" and retest: 78%.

## References
`_shared/glossary.md`, `_shared/standards/project-tiers.md`, `FEAT-NNN`, `RISK-NNN` (for example traffic loss on migration), `TC-NNN` for regression on key paths. Sample sizes and methods: `user-research-planning`; testing the built interface: `usability-testing`.

## Language notes
Tools are examples only: Optimal Workshop (card sort, tree test), Maze, spreadsheets for the inventory, search-log export from the analytics tool.
