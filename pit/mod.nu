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


# Search across the trail and bulletin main text fields. It forces a case-insensitive search.
#
# Usage: search foo
export def search [term: string, --short (-s)]: string -> list<any> {
    let trail_results = trail search $term | into value
    let bulletin_results = bulletin search $term
        | reject year

    let results = $trail_results
        | join -l $bulletin_results url
        | reject year id
        | move publication_date --after date
        | upsert date {|row|
              if ($row.date | is-empty) { $row.publication_date } else { $row.date } 
          }
        | upsert title {|row|
              if ($row.title | is-empty) { $row.title_ } else { $row.title } 
          }
        | upsert summary {|row|
              if ($row.summary | is-empty) { $row.summary_ } else { $row.summary } 
          }
        | insert is_published {|row|
              $row.publication_date | is-not-empty 
          }
        | reject title_ summary_ publication_date

    if ($short) {
        $results
        | select date title url is_published
    } else {
        $results
    }
}



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
