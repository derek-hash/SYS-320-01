function gatherClasses {
    # Get the page content
    $page = Invoke-WebRequest -TimeoutSec 2 -Uri "http://10.0.17.x/Courses2025A.html"

    # Get all the tr elements of HTML document
    $trs = $page.ParsedHtml.getElementsByTagName("tr")

    # Empty array to hold results
    $fullTable = @()

    for ($i = 1; $i -lt $trs.length; $i++) {  # Skip header row
        # Get every td element of current tr element
        $tds = $trs[$i].getElementsByTagName("td")

        # Separate start time and end time from one time field (assuming format "HH:MM - HH:MM")
        $times = $tds[3].innerText -split " - "

        $fullTable += [PSCustomObject]@{
            "Class Code" = $tds[0].innerText
            "Title"      = $tds[1].innerText
            "Days"       = $tds[2].innerText
            "Time Start" = $times[0]
            "Time End"   = $times[1]
            "Instructor" = $tds[4].innerText
            "Location"   = $tds[5].innerText
        }
    }
    # end of for loop
    return $fullTable
}
