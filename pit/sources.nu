# avoids clashing names
alias save-file = save

# Lists available sources.
export def list [] {
    open data/sources.csv
}

# Overrides the list of sources.
export def save [] {
    $in | save-file -f data/sources.csv
}

# Tags any entry matching the given token as expired with today's date.
export def expire [
    token: string # The token to filter by
    date?: string # The expiration date `YYYY-MM-DD`
] {
    let stamp = if $date != null {
        $date
    } else {
        (date now | format date "%Y-%m-%d")
    }

    list
    | update end_date { |x|
          if ($x.id =~ $token) { $stamp } else { $x.end_date }
      }
}

# Lists available sources and lets you select one using fuzzy matching.
export def picker [] {
    list
    | get id
    | input list --fuzzy "source: "
}

# Commands to operate over the sea sources
export def main [] {
    "
    sources list
    sources save
    sources expire
    " | nu-highlight
}
