use markdown.nu *

export def "open" [] {
    # sqlite3 :memory: "ATTACH './lab/applebooks_library.sqlite' AS library; ATTACH './lab/applebooks_annotations.sqlite' AS annotations;"

    ^sqlite3 lab/applebooks_library.sqlite
}

export def "pull" [] {
    let annotations = ($env.BOOKS_HOME | path join "AEAnnotation")
    let library = ($env.BOOKS_HOME | path join "BKLibrary")

    cp ($annotations | path join "AEAnnotation_v10312011_1727_local.sqlite") lab/applebooks_annotations.sqlite
    cp ($library | path join "BKLibrary-1-091020131601.sqlite") lab/applebooks_library.sqlite
}

export def "list" [] {
    ls books/*.md
    | each {|row|
          open $row.name
          | from markdown
          | insert filename { $row.name }
      }
}

