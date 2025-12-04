#!/bin/bash

# Target URL for scraping
target_url="10.0.17.47/Courses.html"

# Fetch page content silently
page_content=$(curl -sL "$target_url")

# Parse HTML table using xmlstarlet
parsed_data=$(echo "$page_content" | \
xmlstarlet format --html --recover 2>/dev/null | \
xmlstarlet select --template --copy-of \
"//html//body//table//tr")

# Clean and format the extracted data
# Remove closing row tags and replace with newlines
# Strip out HTML tags and format as semicolon-delimited
echo "$parsed_data" | \
    sed 's/<\/tr>/\n/g' | \
    sed 's/&amp;//g' | \
    sed 's/<tr>//g' | \
    sed 's/<td[^>]*>//g' | \
    sed 's/<\/td>/;/g' | \
    sed 's/<[/]\{0,1\}a[^>]*>//g' | \
    sed 's/<[/]\{0,1\}nobr>//g' \
    > courses.txt
