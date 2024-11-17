### Pit is a toolbox for managing sessions of urls, read urls and urls published in
### my bulletin.
###
### Usage:
###
### ```nu
### mut entry = (trail new)
### $entry.url = ""
### $entry.title = ""
### $entry.summary = ""
### $entry = ($entry | trail add tag)
### $entry = ($entry | trail add source)
###
### mut bulletin = (bulletin new)
### $bulletin | bulletin save
###
### mut stash = (stash list)
### $stash.entries = ($bulletin.entries | stash drop)
### $stash | stash save
### ```

export use sources.nu
export use trail.nu
export use stash.nu
export use bulletin.nu
export use backlog.nu
export use session.nu
export use expenses.nu
export use books.nu
export use markdown.nu *



# Lists old resource collection
export def "resource list" [] {
    open resources/*.csv
}

export def "cookie fetch" [] {
    ./firefox_wrangling/cookie_gathering.nu
}

# Lists tasks (ideas, projects, etc)
export def "task list" [] {
    ls backlog/*.md
    | each {|row|
          open $row.name
          | from markdown
          | insert filename { $row.name }
      }
    | flatten
    | default low priority
    | select filename status priority creation_date? start_date? end_date? tags? title body 
    | into value
}
