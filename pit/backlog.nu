# avoids clashing names
alias save-file = save

# use std formats * should do it but nu seems to loose context after `use toolbox/sea.nu`
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

export def new [] {
    let stamp = date now
    let creation_date = $stamp | format date "%Y-%m-%d"
    
    {
      url: "",
      "tags": [],
      "summary": "",
      creation_date: ($creation_date),
    }
}

export def list [] {
  open data/backlog.jsonl | from json --objects
}

export def save [] {
  let input = $in

  $input
  | to json --raw
  | $in + "\n"
  | save-file -a data/backlog.jsonl
}
