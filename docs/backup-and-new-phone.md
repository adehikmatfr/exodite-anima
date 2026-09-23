# Backing up your journal, and moving to a new phone

Exodite Anima keeps your journal on this phone only. There is no account and no cloud, so there is exactly one way to keep a copy or move to a new phone: **export**.

## Why this matters

If you lose your phone, or delete the app, or forget your passcode, your journal is gone unless you exported it first. There is no way for anyone — including the people who made this app — to recover it. This is a deliberate trade for privacy: nobody else can read your journal either, because nobody else ever holds a copy of the key that unlocks it.

The app reminds you in the timeline if it has been a while since your last export. Do not ignore that reminder.

## Making a backup

1. Open **Settings**, then **Export your journal**.
2. Choose **Protected with a password** (recommended) or **Readable by anyone**. The protected option needs an export password — this is not your app passcode, and it also cannot be recovered if you forget it. Write it down somewhere separate from the file itself.
3. Save the file wherever you keep backups: a cloud drive, a computer, a USB drive. The app does not do this for you; it hands the file to your phone's normal share or save screen, and you choose where it goes.

Keep more than one copy, in more than one place, the same as you would for any file you cannot afford to lose.

## Moving to a new phone

1. On your old phone, export your journal (see above) and get the file onto your new phone (by cloud storage, cable, email to yourself, however you normally move files).
2. On the new phone, install Exodite Anima and go through setup as normal (you will still choose a passcode for this phone).
3. Open **Settings**, then **Import your journal**, and choose the file. If it is password-protected, enter the export password from step 1.
4. Your entries appear exactly as they were. Entries already on the new phone (if any) are kept; nothing is deleted by an import.

Your old phone's journal is untouched by any of this — exporting and importing never deletes anything from the source.

## If something goes wrong

- **Wrong export password**: the app tells you and changes nothing. Try again; there is no way around a forgotten export password.
- **"This file is damaged"**: the file was corrupted or incomplete (a failed download, an interrupted transfer). Try getting the file again from wherever you saved it.
- **"This export needs a newer version of the app"**: the file was made by a newer version of Exodite Anima than the one you are importing into. Update the app first.
- **"This is not an export from this app"**: you picked the wrong file. Choose the file you saved during export.

None of these ever change your existing journal on the phone you are importing into: an import either finishes completely or does nothing at all.

## The file itself

An export is an open, documented format — not something only this app can read. See `export-format.md` if you ever want to read your entries without the app, or write your own tool against them.
