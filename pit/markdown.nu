def "markdown parse body" [] {
    let text = $in | to text | str trim

    $text
    | wrap body
    | insert title { try { $text | lines | get 0? | str substring 2.. } catch { null } }
}


# Split header and body from the given markdown file.
export def "from markdown" [] {
    let text = $in

    # No metadata section
    if not ($text | str starts-with "---") {
        return ($text | markdown parse body)
    }
    
    # Empty metadata section
    if ($text | str starts-with "---\n---") {
        let result = $text
        | lines
        | split list "---"
        | markdown parse body

        return $result
    }

    let parts = $text
        | lines
        | split list "---"

      let len = $parts | length

      if $len == 0 { return }

      if ($parts | length) == 1 {
          $parts.0
          | to text
          | from yaml
      } else {
          let body = $parts.1? | markdown parse body

          $parts.0
          | to text
          | from yaml
          | merge $body
      }
}

export def "from md" [] { from markdown }
