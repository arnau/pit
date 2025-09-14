# avoids clashing names
alias save-file = save

# Opens the bulletin stash.
export def list [] {
    open data/bulletins/stash.toml
}

# Overrides the bulletin stash.
export def save [] {
    $in | collect { save-file -f data/bulletins/stash.toml }
}

# Removes the given entries.
#
# ```
# mut stash = (stash list)
# $stash.entries = ($bulletin.entries | stash drop)
# ```
export def drop [] {
    let input = $in

    list
    | get entries
    | where { |e| $input | all { |x| $x != $e } }
}

# Wipes out the bulletin stash entries.
export def flush [] {
    list
    | update entries [] 
    | save
}

# The list of possible content types for a bulletin entry.
export def content-types [] { ["text" "pdf" "video" ] }

# Transforms a trail entry into a bulletin entry
def "into bulletin" [] {
    let entry = $in 

    {
        url: ($entry.url)
        title: ($entry.title)
        summary: ($entry.summary)
        content_type: ($entry.content_type)
    }
}


# Adds an entry to the stash. Use it in combination with `stash save`.
#
# Example:
#
# ```
# $entry | stash add | stash save
# ```
export def add [--content-type (-t): string@content-types] {
    mut type = $content_type
    let input = $in
        if ($type == null) {
            $type = (content-types | input list --fuzzy "content_type: ")      

            if ($type == null) {
                error make {msg: "aborted"}
            }
        }


        list
        | update entries {
              $in
              | append ($input | insert content_type $content_type | into bulletin)
          }

}

# Lists the list of stashed entries.
export def summary [] {
    list
    | get entries
    | select title summary
}


# Commands to operate over the sea bulletin
export def main [] {
    "
    mut stash = (stash list)
    $stash.entries | ($bulletin.entries | stash drop)
    $stash | stash save
    " | nu-highlight
}
