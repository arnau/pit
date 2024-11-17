# avoids clashing names
alias save-file = save
alias open-file = open

export def new [] {
    let stamp = date now
    let creation_date = $stamp | format date "%Y-%m-%d"
    
    {
      key: "",
      entries: [],
      tags: [],
      creation_date: ($creation_date),
    }
}

export def list [] {
    open-file data/sessions.json
}

def "nu-complete session_list" [] {
    list | get key
}

# Gets the session for the given key. Errors if the session key does not exist.
#
# ```nu
# session list | session pick reading_list
# session pick reading_list
# ```
export def pick [key: string@"nu-complete session_list"] {
    let list = if ($in | is-empty) { list } else { $in }
    let item = $list | where key == $key

    if ($item | is-empty) {
        error make --unspanned { msg: "The given key does not exist." }
    } else {
        $item | get 0
    }
}

# Drops the session for the given key
#
# ```nu
# session list | session drop reading_list | session save
# ```
export def drop [key: string@"nu-complete session_list"] {
    $in
    | where key != $key
}

# Adds or replaces the given session.
#
# ```nu
# $session | session add | session save
# ```
export def add []: [record -> list<record>] {
    let input = $in
    let sessions = (list | where key != $input.key)

    $sessions
    | append $input
}

# Overrides the session list.
export def save [] {
    $in
    | to json --raw
    | collect { save-file -fr data/sessions.json }  
}


# Opens a session in Firefox.
export def open [key: string@"nu-complete session_list"] {
    let url_list = (list | where key == $key | get entries.0)

    firefox --url ...$url_list
}


export def "from firefox" [] {
    ^lizard $"($env.FIREFOX_HOME)/sessionstore-backups/recovery.jsonlz4" $"data/firefox/recovery_(date now | format date "%Y-%m-%dT%H:%M:%S").json"
}

# Inspect a raw firefox session
export def "firefox tabs" [tab = 1] {
    ls data/firefox
    | last
    | get name
    | open-file
    | get windows.tabs | get $tab | each { get entries.0 }
}
