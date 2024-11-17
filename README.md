# Pit

A tool for managing all sorts of stuff.

> [!warning] 
This is a personal tool with no versioning schema, no free use licence and no commitments of any kind.

## Install and load

```nushell
# clone repository and follow the nupm guidelines.
use pit *
```

## Usage

Create a new _trail_ entry.

```nushell
mut entry = (trail new)
$entry.url = "https://www.seachess.net/"
$entry.title = "Seachess"
$entry.summary = "My website."

# Pick tags from previous entries.
$entry = ($entry | trail add tag)

# Pick a source from the list of sources in `data/sources.csv`.
$entry = ($entry | trail add source)

# Save the entry.
$entry | trail save

# Stash for the bulletin.
$entry | stash add | stash save
```

Create a new _bulletin_ entry from the stashed entries.

```nushell
mut bulletin = (bulletin new)
$bulletin | bulletin save

mut stash = (stash list)
$stash.entries = ($bulletin.entries | stash drop)
$stash | stash save
```
