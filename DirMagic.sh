#!/bin/bash


# Colours
bold="\033[1m"
Underlined="\033[4m"
red="\033[31m"
green="\033[32m"
blue="\033[34m"
end="\033[0m"

echo -e "${blue}${bold}      ____   _        __  ___               _        ${end}"
echo -e "${blue}${bold}     / __ \ (_)_____ /  |/  /____ _ ____ _ (_)_____  ${end}"
echo -e "${blue}${bold}    / / / // // ___// /|_/ // __ \`// __ \`// // ___/  ${end}"
echo -e "${blue}${bold}   / /_/ // // /   / /  / // /_/ // /_/ // // /__    ${end}"
echo -e "${blue}${bold}  /_____//_//_/   /_/  /_/ \__,_/ \__, //_/ \___/    ${end}"
echo -e "${blue}${bold}                                 /____/              ${end}"
echo -e "$end"
echo -e "$blue${bold}        File Organizer tool         $end"
echo -e "$blue${bold}             Made with${end} ${red}${bold}<3${end} ${blue}${bold}by rushikenjale_              $end"
echo -e "$end"


usage1(){
while read -r line; do
        printf "%b\n" "$line"
    done <<-EOF
    \r
    \r ${bold}Options${end}:
    \r ${bold}./DirMagic.sh /source_dir /dest_dir 
    \r ${bold}   -s    ext          ==> Sort files by extension
    \r ${bold}         date         ==> sort files by modification date
    \r ${bold}   -d                 ==> Delete original files
    \r ${bold}   -e  [filetypes]    ==> Exclude given files


EOF
    exit 1
}

if [ $# -lt 2 ]
then
    usage1
    exit 1
fi

total_folders_created=0
total_files_transferred=0
source_dir=$1
destination_dir=$2

if [ ! -d "$source_dir" ]; then
    echo -e "${bold}Source directory does not exist"
    exit 1
fi

if [ ! -d "$destination_dir" ]; then
        echo -e "${bold} ${green}Destination Directory Does not exist "
    echo -e "${bold} ${blue}Creating destination directory: $destination_dir"
    mkdir -p "$destination_dir"
    if [ $? -ne 0 ]; then
        echo -e "${bold} ${red}Failed to create destination directory: $destination_dir"
        exit 1
    fi
fi


exclude_extensions() {
    exclude_list=$(echo "$1" | tr ',' '\n') # Split comma-separated extensions
    for ext in $exclude_list; do
        excluded_extensions+=("$ext")
    done
}

organize_by_extension() {
    find "$source_dir" -type f | while read file; do
        if [ -f "$file" ]; then
            extension=${file##*.}

            if [[ " ${excluded_extensions[@]} " =~ " ${extension} " ]]; then
                echo "Skipping excluded file: $file"
                continue
            fi

            if [ -n "$extension" ]; then
                mkdir -p "$destination_dir/$extension"
                if [ $? -ne 0 ]; then
                    echo -e "${bold} ${red}Failed to create directory for extension: $extension"
                    continue
                fi

                filename=$(basename "$file" ".$extension")

                if [ -e "$destination_dir/$extension/$filename.$extension" ]; then
                    counter=1
                    while [ -e "$destination_dir/$extension/$filename$counter.$extension" ]; do
                        counter=$((counter + 1))
                    done
                    cp "$file" "$destination_dir/$extension/$filename$counter.$extension"
                else
                    cp "$file" "$destination_dir/$extension"
                fi
            else
                echo "Skipping file without extension: $file"
            fi
        fi
    done

    total_folders_created=$(($(find "$destination_dir" -type d | wc -l) - 1))
    total_files_transferred=$(find "$destination_dir" -type f | wc -l)
}


organize_by_creation_date() {
    find "$source_dir" -type f | while read file; do
        if [ -f "$file" ]; then
            extension=${file##*.}

            if [[ " ${excluded_extensions[@]} " =~ " ${extension} " ]]; then
                echo "Skipping excluded file: $file"
                continue
            fi

            creation_date=$(stat -c %y "$file" | cut -d ' ' -f1)

            mkdir -p "$destination_dir/$creation_date"
            if [ $? -ne 0 ]; then
                echo "Failed to create directory for creation date: $creation_date"
                continue
            fi

            filename=$(basename "$file" ".$extension")

            if [ -e "$destination_dir/$creation_date/$filename.$extension" ]; then
                counter=1
                while [ -e "$destination_dir/$creation_date/$filename$counter.$extension" ]; do
                    counter=$((counter + 1))
                done
                cp "$file" "$destination_dir/$creation_date/$filename$counter.$extension"
            else
                cp "$file" "$destination_dir/$creation_date"
            fi
        fi
    done

    total_folders_created=$(($(find "$destination_dir" -type d | wc -l) - 1))
    total_files_transferred=$(find "$destination_dir" -type f | wc -l)
}

confirm_delete() {
    read -p $' \033[1m \033[31m Do you want to permanently delete the original files? (y/yes to confirm): ' choice
    case "$choice" in 
        y|Y|yes|YES)
            rm -r $source_dir
            echo -e "$bold $red Original files permanently deleted."
            ;;
        *)
            echo -e "$green Original files were not deleted."
            ;;
    esac
}


shift $((OPTIND +1))
while getopts "s:e:dh" opt; do
    case $opt in
        
        s)
            svalue=$OPTARG
            if [ $svalue = "ext" ]
            then
                echo -e "$bold $green Organizing by extension..."
                organize_by_extension
            elif [ $svalue = "date" ]
            then
                echo -e " $bold $green organizing  by createtion date ..."
                organize_by_creation_date
            else 
                echo -e " $bold $red Invalid argument"
                echo -e " $bold $red              ext for organise by extension "
                echo -e " $bold $red              date for organise by creation date "
            fi
            ;;
        e)
            evalue=$OPTARG
            exclude_extensions "$evalue"
            ;;
        d)
            confirm_delete
            ;;
        
        h)
            usage1
            ;;
        ?)
            echo -e "$bold $blue For help, use -h"
            ;;
    esac
done
if [ -z "$svalue" ]; then
    echo -e "$bold $blue No style provided. Defaulting to organizing by extension..."
    organize_by_extension
fi

echo -e "\n $blue Summary:"
echo -e "$green Number of folders created: $total_folders_created"
echo -e "$green Number of files transferred: $total_files_transferred"
echo -e "$green Number of files in each folder:"
find "$destination_dir" -type d -exec sh -c 'echo "{}: $(find "{}" -type f | wc -l)"' \;
