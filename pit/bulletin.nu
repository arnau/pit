# avoids clashing names
alias save-file = save

# use std formats * should do it but nu seems to loose context.
def "from jsonl" [] {
    $in
    | each { open --raw | from json --objects }
    | flatten
}

def "to jsonl" [] {
    $in
    | each { to json --raw }
    | to text
    | $"($in)\n"
}

# Creates a bulletin structure
#
# ```nu
# mut bulletin = (bulletin new)
# $bulletin | bulletin save
# ```
export def new [
    date?: datetime # The publication date
] {

    let stamp = if ($date | is-not-empty) { $date } else { date now }
    let week = $stamp | format date "%G-W%V"
    let publication_date = $stamp | format date "%Y-%m-%d"
    let entries = (stash list | get entries | input list --multi)

    print $entries
    
    {
        type: "bulletin"
        id: ($week)
        publication_date: ($publication_date)
        summary: (input "summary: ")
        entries: $entries
    }
}


# Creates a bulletin structure
#
# ```nu
# mut bulletin = (bulletin new)
# $bulletin | bulletin save
# ```
export def save [] {
    let input = $in
    let stamp_year = $input
        | get publication_date
        | into datetime
        | into record
        | get year
    let stamp_week = $input.id

    ($input
    | save-file $"../seachess/corpus/bulletins/($stamp_year)/($stamp_week).toml")

    ($input
    | to jsonl
    | save-file -a $"data/bulletins/($stamp_year).jsonl")
}


# List all bulletins
export def list [] {
    glob data/bulletins/*.jsonl
    | from jsonl
    | update publication_date { into datetime }
    | insert year { |row| $row.publication_date | into record | get year }
}


# Gets the bulletin for the given identifier.
#
# ```nu
# bulletin pick "2024-W05"
# ```
export def pick [bulletin_id: string] {
    list
    | where id == $bulletin_id
    | get 0?
}

# Displays a bulletin in html.
#
# ```nu
# bulletin pick "2023-W49" | bulletin to html
# ```
export def "to html" [] {
    let input = $in
    let week_stamp = $input.id | parse "{year}-{week}"

    let preface = [
        $"($input.summary)"
        "<br><br>"
        $"Also available online: https://www.seachess.net/bulletins/($week_stamp.year.0)/($input.id)"
    ]
    let entries = $input
        | get entries
        | each { |entry|
            [
                ""
                $"<h2># ($entry.title)</h2>"
                ""
                $"URL: ($entry.url)\n<br><br>\n($entry.summary)"
            ]
        }

    $preface 
    | append $entries
    | flatten --all
    | str join "\n"
}

# Displays a bulletin excerpt for posting e.g. in Mastodon.
#
# ```nu
# bulletin pick "2023-W49" | bulletin excerpt
# ```
export def excerpt [] {
    let input = $in
    let week_stamp = $input.id | parse "{year}-{week}"

    [
        $"($input.summary)"
        $"https://www.seachess.net/bulletins/($week_stamp.year.0)/($input.id)"
    ]
    | str join "\n\n"
}



# Search across the bulletin main text fields. It forces a case-insensitive search.
#
# Usage: bulletin search
export def search [term: string]: nothing -> list<any> {
    let search_term = $"\(?i\)($term)"

    list
    | reject summary type
    | flatten --all
    | where title =~ $search_term or url =~ $search_term or summary =~ $search_term
}


export def "links check" [] {
    ^lychee -f json -m 5 --user-agent "Mozilla/5.0 (Windows NT 10.0; rv:108.0) Gecko/20100101 Firefox/108.0" -o b_report.json b_links.txt
}


# Commands to operate over the sea bulletin
export def main [] {
    "
    mut bulletin = (bulletin new)
    $bulletin | bulletin save
    $bulletin | bulletin excerpt | pbcopy
    " | nu-highlight
}
