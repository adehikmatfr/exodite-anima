# Export format specification

Exodite Anima never locks your writing into this app. This page documents the export archive exactly, so you (or anyone) can write a program that reads it without the app, forever, even if this project stops.

Source of truth for the design decisions behind this format: the project's own architecture record (`ADR-003`), not repeated here. This page describes only the format itself, at `formatVersion` 1, the only version that exists so far.

## Two export modes, one layout

Every export is the same ZIP archive. The difference is only whether that ZIP is wrapped in an encrypted envelope:

- **Plaintext export**: the ZIP archive itself, as a normal `.zip` file, readable by any ZIP tool.
- **Encrypted export**: the same ZIP, encrypted, saved with a `.anima` extension. You need the export password you chose when you made it. There is no way to recover a forgotten export password.

## Inside the ZIP

```
manifest.json
entries.json
entries/YYYY/YYYY-MM-DD-<id>.md
media/
```

- **`manifest.json`**: one JSON object describing the archive. Fields: `format` (a constant string identifying this as an Exodite Anima export), `formatVersion` (the layout version, an integer; this document describes version 1), `schemaVersion` (the data model version of the entries themselves), `appVersion` (the app version that made the export), `createdAt` (when the export was made, ISO 8601 UTC), `entryCount` (how many entries follow), and a SHA-256 hash of `entries.json`'s bytes (to detect accidental corruption).
- **`entries.json`**: a JSON array of entries. This is the only file a reader needs for the content; everything else is for people, not programs. Each entry has:
  - `id`: a random, stable identifier. It never changes, even across exports and imports, so you can tell the same entry apart from a copy.
  - `entryDate`: the calendar date the entry belongs to, as `YYYY-MM-DD`, in the phone's local time when it was written. Not a timestamp.
  - `createdAt`, `updatedAt`: ISO 8601 timestamps in UTC, for when the entry was first saved and last edited.
  - `text`: the entry's content, UTF-8 plain text.
  - `mood` (added 2026-09-23, optional): one of `great`, `good`, `okay`, `bad`, `awful`. Present only when the writer set a mood; absent, not `null`, otherwise.
  - `tags` (added 2026-09-23, optional): an array of tag names, in the order the writer added them. Present only when the entry has at least one tag; absent, not an empty array, otherwise. A tag from the app's preset list and one typed as free text look exactly the same here: plain strings.
  - `media` (added 2026-09-23, FEAT-011): an array of this entry's photos, each with an `id`, an optional `caption`, and `path`: where the photo's own bytes are, under `media/`. Present only when the entry has at least one photo. A photo the entry has but that could not be read on the device (damaged or undecryptable) is simply left out of this array, not a failed export.
  - A reader should ignore any field it does not recognise, and this app does too: importing an export made by a version older than 2026-09-23 simply finds no `mood`, `tags`, or `media` fields and leaves those entries without them. This is why none of these needed a new `formatVersion`.
- **`entries/YYYY/YYYY-MM-DD-<id>.md`**: one Markdown file per entry, one per year folder, for a human to read directly (a text editor, a Markdown viewer, anything). Present only in a plaintext export. These files are not read by the app on import; `entries.json` is the only source of truth for content, so if you ever hand-edit these Markdown files, the app will not see your changes.
- **`media/`**: one file per photo (added 2026-09-23, FEAT-011), named `<id>.<ext>` - the same `id` as its entry's `media` field, with a file extension matching its type (`jpg`, `png`, `heic`, or `webp`), so the file is recognisable outside the app too. Each entry's `media` field in `entries.json` (present only on an entry that has at least one photo) lists that entry's photos: `id`, `caption` (present only when set), and `path`, the exact string this file is found at. A photo's bytes are its plain, decrypted content — the same treatment `text` gets — never encrypted a second time by the export password on top of the device's own encryption. Audio is not part of this feature; this folder may carry it too in a still-later version.

## The encrypted envelope (`.anima` files)

An encrypted export is the same ZIP archive as above, wrapped once more:

1. A short **header**, stored unencrypted: a fixed set of magic bytes identifying the format, the `formatVersion`, which key-derivation algorithm was used and its parameters (so they can be strengthened in a later version without breaking old files), a random salt, and a random nonce. The header itself is authenticated as associated data, so tampering with it is detected even though it is not secret.
2. The **payload**: the entire ZIP archive from above, encrypted as one block with an authenticated cipher. The encryption key is derived from your export password and the header's salt using a memory-hard key-derivation function (Argon2id), so guessing the password is deliberately slow.

If the password is wrong, or a single byte of the file was changed or truncated, decryption fails outright and nothing is read as data. There is no partial or "best effort" recovery of a damaged encrypted file by design: a file that does not authenticate is treated as unreadable, not as a puzzle to solve.

## Compatibility promise

Every future version of the app will be able to read every `formatVersion` that has ever shipped, including this one. A file made by a newer app than yours may use a `formatVersion` your app does not know; your app will refuse it and ask you to update, rather than guess at a format it does not understand. This is the same rule the app itself follows when reading its own local database, applied to the export file you carry between phones.

## Writing your own reader

If you want to read your entries without this app: unzip the file (or decrypt it first, if it is a `.anima` file, using the parameters in its header and your export password), then parse `entries.json` as ordinary JSON. That array is your entire journal. The Markdown files exist only for convenience.
