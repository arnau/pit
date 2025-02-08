# avoids clashing names
alias save-file = save


# Creates a new trail entry.
#
# Usage: sea trail new
#
# Example
#
# ```nu
# mut entry = (trail new)
# ```
export def new [] {
    {
        url: null
        date: (date now | format date "%Y-%m-%d")
        title: null
        summary: null
        tags: []
        source: null
    } 
}

# Lists all trail entries
#
# Usage: trail list
export def list [] {
    open data/trail/*.csv
    | update date { into datetime }
    | insert year {|row| $row.date | into record | get year }
    | update tags { from json }
}

# Appends the given entry to the trail.
export def save [] {
    let input = $in
    let stamp = $input.date | parse "{year}-{month}-{day}"

    # if (list | where ($it.url | str distance $input.url) <= 1) {
    #     error make {msg: "Found a URL that is too similar."}
    # }

    $input 
    | update tags { to json -r }
    | select date url title summary tags source
    | to csv -n
    | save-file -a $"data/trail/($stamp.year.0).csv"
}

export def crates [] {
    cargo packages
    | join -l (list | insert name { |row| $row.title | str downcase }) package name
    | select package summary
}


# Search across the trail main text fields. It forces a case-insensitive search.
#
# Usage: trail search
export def search [term: string]: nothing -> list<any> {
    let search_term = $"\(?i\)($term)"

    list
    | where title =~ $search_term or url =~ $search_term or summary =~ $search_term
}

# Filter by any given tag
export def any-tag [tags: list<string>] {
    $in
    | where {|row| $tags | any {|| $in in $row.tags}}
}

# Filter by all given tags
export def all-tag [tags: list<string>] {
    $in
    | where {|row| $tags | all {|| $in in $row.tags}}
}

# Lists all tags from the trail
export def "tags list" [] {
    list
    | get tags
    | flatten
    | uniq
    | sort
}

# Lists available tags and lets you select one using fuzzy matching.
export def "tags picker" [] {
    tags list
    | input list --fuzzy "tag: "
}

# Adds the selected source to the given trail entry.
export def "add source" [] {
    $in | upsert source (sources picker)
}

# Adds the selected tag to the given trail entry.
export def "add tag" [] {
    $in | upsert tags { |record|  $record.tags | append (tags picker) }
}

# Commands to operate over the sea trail.
export def main [] {
    "
    mut entry = (trail new)
    $entry.url = ""
    $entry.title = ""
    $entry.summary = ""
    $entry = ($entry | trail add tag)
    $entry = ($entry | trail add source)
    " | nu-highlight
}
