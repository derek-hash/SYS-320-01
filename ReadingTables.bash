#!/bin/bash

# Define source URL
target_page="10.0.17.47/Assignment.html"

# Fetch the HTML content
html_content=$(curl -sL "$target_page")

# Extract and process temperature data from table
temperature_readings=$(echo "$html_content" | \
    xmlstarlet format --html --recover 2>/dev/null | \
    xmlstarlet sel -t -v "//html//body//table[@id='"temp"']" 2>/dev/null | \
    sed 's/&#13;//g' | \
    awk 'NF>0' | \
    awk 'NR%2==1 {hold=$0; next} {print hold, $0}' | \
    tail -n +2)

# Extract and process pressure data from table
pressure_readings=$(echo "$html_content" | \
    xmlstarlet format --html --recover 2>/dev/null | \
    xmlstarlet sel -t -v "//html//body//table[@id='"press"']" 2>/dev/null | \
    sed 's/&#13;//g' | \
    awk 'NF>0' | \
    awk 'NR%2==1 {hold=$0; next} {print hold, $0}' | \
    awk '{print $1}' | \
    tail -n +2)

# Combine both datasets line by line
paste <(echo "$pressure_readings") <(echo "$temperature_readings") | \
    awk '{print $1, $2, $3}'
