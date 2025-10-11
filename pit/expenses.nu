def "compose datetime" [
    date: string
    time: string
] {
    [$date $time] | str join " " | into datetime
}


def to-weeknumber [] {
    $in | format date "%V" | into int
}

# Convert text or datetime into weeknumber.
def "date to-weeknumber" [
    --format (-f): string # Specify expected format of INPUT string to parse datetime
]: [string -> int, datetime -> int, list<string> -> list<int>, int -> int, list<int> -> list<int>] {
    let input = $in

    match ($input | describe) {
        "string" | "list<string>" => {
            $input | into datetime | to-weeknumber
        },
        "int" | "list<int>" => {
            $input | into datetime | to-weeknumber
        },
        "datetime" => {
            $input | to-weeknumber
        },
    }
}

# Like `$date | into record` but with weeknumber added.
export def "date split" [] {
    let input = $in

    $input
    | into record
    | insert week { $input | date to-weeknumber }
}




# Lists the journey expenses from TFL.
export def "tfl list" [] {
    let column_mapping = {
        "Date": date,
        "Start Time": start_time,
        "End Time": end_time,
        "Journey/Action": action,
        "Charge": charge,
        "Credit": credit,
        "Balance": balance,
        "Note": note
    }

    open data/tfl/*.csv
    | rename --column $column_mapping
    | insert start_date {|row| compose datetime $row.date $row.start_time }
    | insert end_date {|row|
          if ($row.end_time | is-empty) {
              $row.start_date
          } else {
              compose datetime $row.date $row.end_time
          }
      }
    | select start_date end_date charge credit balance action
    | insert duration {|row| $row.end_date - $row.start_date }
    | move duration --after end_date
    | sort-by start_date duration
}

export def "tfl month-activity" [filter: datetime] {
    let date = $filter | into record

    tfl list
    | insert weeknum { get start_date | date to-weeknumber }
    | insert month { get start_date | into record | select year month day }
    | flatten
    | where year == $date.year and month == $date.month
    | group-by --to-table day
}

export def "tfl week-activity" [filter: string] {
    tfl list
    | insert week { get start_date | format date "%Y-W%V" }
    | where week == $filter
}
