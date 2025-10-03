function daysTranslator($FullTable) {
    # Go over every record in the table
    for ($i = 0; $i -lt $FullTable.Count; $i++) {
        # Empty array to hold normalized day names
        $Days = @()

        $dayString = $FullTable[$i].Days

        # M -> Monday
        if ($dayString -like "*M*") { $Days += "Monday" }

        # "T" (but not TH) -> Tuesday
        if ($dayString -like "*T*" -and $dayString -notlike "*TH*") { $Days += "Tuesday" }

        # W -> Wednesday
        if ($dayString -like "*W*") { $Days += "Wednesday" }

        # TH -> Thursday
        if ($dayString -like "*TH*") { $Days += "Thursday" }

        # F -> Friday
        if ($dayString -like "*F*") { $Days += "Friday" }

        # Replace the original Days string with the array
        $FullTable[$i].Days = $Days
    }

    return $FullTable
}
