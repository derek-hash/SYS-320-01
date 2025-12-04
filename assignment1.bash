#!/bin/bash

clear

# Populate course data file
bash courses.bash
data_file="courses.txt"

function showInstructorCourses(){
    echo -n "Enter Instructor's Full Name: "
    read instructor_name
    echo ""
    echo "Courses taught by $instructor_name:"
    cat "$data_file" | grep "$instructor_name" | cut -d';' -f1,2 | \
    sed 's/;/ | /g'
    echo ""
}

function instructorCourseCount(){
    echo ""
    echo "Instructor Course Load Summary"
    cat "$data_file" | cut -d';' -f7 | \
    grep -v "/" | grep -v "\.\.\." | \
    sort -n | uniq -c | sort -n -r 
    echo ""
}

function showLocationCourses(){
    echo -n "Enter a classroom location: "
    read location
    echo ""
    echo "Classes in $location:"
    cat "$data_file" | grep "$location" | cut -d';' -f1,2,5,6,7 | \
    sed 's/;/ | /g'
    echo ""
}

function availableSeats(){
    echo -n "Enter course subject code: "
    read subject_code
    echo ""
    echo "Available seats in $subject_code courses:"
    cat "$data_file" | grep "$subject_code" > temp_data.txt
    while IFS= read -r course_line;
    do
        seat_count=$(echo "$course_line" | cut -d';' -f4)
        if [ "$seat_count" -gt 0 ]; then
            echo "$course_line" | grep "$subject_code" | cut -d';' -f1,2,3,4,5,6,7,8,9,10 | \
            sed 's/;/ | /g'
        fi
    done < "temp_data.txt"
}

while true
do
    echo ""
    echo "Course Management System - Select an option:"
    echo "[1] Search courses by instructor"
    echo "[2] View instructor course statistics"
    echo "[3] Search courses by location"
    echo "[4] Check course availability by subject"
    echo "[5] Exit"
    read user_choice
    echo ""
    
    if [[ "$user_choice" == "5" ]]; then
        echo "Exiting program. Goodbye!"
        break
    elif [[ "$user_choice" == "1" ]]; then
        showInstructorCourses
    elif [[ "$user_choice" == "2" ]]; then
        instructorCourseCount
    elif [[ "$user_choice" == "3" ]]; then
        showLocationCourses
    elif [[ "$user_choice" == "4" ]]; then
        availableSeats
    else
        echo "Error: Invalid selection. Please choose 1-5."
        echo ""
    fi
done
