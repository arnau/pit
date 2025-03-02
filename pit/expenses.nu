def "compose datetime" [
    date: string
    time: string
] {
    [$date $time] | str join " " | into datetime
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

export def "tfl week-activity" [filter: int] {
    tfl list
    | insert weeknum { get start_date | date to-weeknumber }
    | where weeknum == $filter
}
