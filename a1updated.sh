#!/bin/bash

# Function to display messages with different colors
function display_message {
    case "$2" in
        "red") color="\033[1;31m" ;;
        "green") color="\033[1;32m" ;;
        "yellow") color="\033[1;33m" ;;
        "blue") color="\033[1;34m" ;;
        "magenta") color="\033[1;35m" ;;
        "cyan") color="\033[1;36m" ;;
        *) color="\033[1;37m" ;;  # Default is white
    esac
    echo -e "${color}$1...\033[0m"
}

# Function to display ASCII art with letter-by-letter animation
function display_ascii_art_animation {
    clear  # Clear the terminal screen
    echo -e "\033[1;36m"  # Set text color to cyan (bright)
    text=' _____   ____  __  __   ______ _____ _   _ _____  ______ _____  
|  __ \ / __ \|  \/  | |  ____|_   _| \ | |  __ \|  ____|  __ \ 
| |  | | |  | | \  / | | |__    | | |  \| | |  | | |__  | |__) |
| |  | | |  | | |\/| | |  __|   | | | .  | |  | |  __| |  _  / 
| |__| | |__| | |  | | | |     _| |_| |\  | |__| | |____| | \ \ 
|_____/ \____/|_|  |_| |_|    |_____|_| \_|_____/|______|_|  \_\'
    length=${#text}
    delay=0.01  # Adjust the delay between each character (in seconds)

    for (( i=0; i<$length; i++ )); do
        echo -n "${text:$i:1}"
        sleep $delay
    done

    echo -e "\033[0m"  # Reset text color to default
}

# Function to display the welcome message and instructions
function display_welcome_message {
    echo -e "\n\n"  # Add blank lines for spacing
    echo -e "\033[1;31mWelcome to Domain Finder!\033[0m"
    echo -e "\033[1;37m-----------------------------------\033[0m"
    echo -e "\033[1;37mThis script will find subdomains for a given domain.\033[0m"
    echo -e "\033[1;32mTool Developed by Aswanth\033[0m"  # Your name in green
        echo -e "\033[1;32mFor more tools, visit: https://github.com/Aswanthkp333\033[0m"
    echo -e "\033[1;37mPlease enter the domain name when prompted.\033[0m"
}

# Function to display a more interesting loading animation
function display_loading {
    local delay=0.1
    local colors=("[1;31m" "[1;32m" "[1;33m" "[1;34m" "[1;35m" "[1;36m")
    local spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local spinner_length=${#spinner[@]}
    local color_length=${#colors[@]}
    local i=0
    local j=0
    while true; do
        printf "\r${colors[$i]}${spinner[$j]}  "
        sleep $delay
        ((j = (j + 1) % spinner_length))
        if [ "$j" == 0 ]; then
            ((i = (i + 1) % color_length))
        fi
    done
}

# Function to stop loading animation
function stop_loading {
    exec 2>/dev/null
    printf "\b \b"
    kill $!
    wait $! 2>/dev/null
    exec 2>/dev/tty
}

# Function to confirm the domain name entered by the user
function confirm_domain {
    read -p "You entered '$1'. Continue? (y/n): " choice
    case "$choice" in
        y|Y) return 0 ;;
        n|N) return 1 ;;
        *) echo "Invalid choice. Please enter 'y' to continue or 'n' to exit."; confirm_domain "$1" ;;
    esac
}

# Function to check if assetfinder found any subdomains
function check_subdomains {
    if [ ! -s sub ]; then
        display_message "No subdomains found for '$dom' using assetfinder" "red"
        return 1
    fi
    return 0
}

# Function to display a wave animation for "Goodbye"
function display_goodbye {
    local delay=0.1
    local wave=("Goodbye ~    " "Goodbye  ~   " "Goodbye   ~  " "Goodbye    ~ " "Goodbye     ~")
    local wave_length=${#wave[@]}
    for (( i=0; i<20; i++ )); do
        for (( j=0; j<$wave_length; j++ )); do
            printf "\r\033[1;33m${wave[$j]}\033[0m"
            sleep $delay
        done
    done
    printf "\n"
}

# Function to open a URL in default web browser (cross-platform)
function open_url {
    if which xdg-open > /dev/null; then
        xdg-open "$1"  # Linux
    elif which open > /dev/null; then
        open "$1"      # macOS
    else
        echo "Could not detect the web browser to open the URL."
    fi
}

# Function to handle user click on [visit]
function handle_visit {
    local subdomain="$1"
    local url="http://$subdomain"
    open_url "$url"
}

# Function to display help message
function display_help {
    echo -e "\033[1;36mUsage:\033[0m"
    echo -e "  \033[1;32mEnter the domain name when prompted\033[0m"
    echo -e "  \033[1;32mFollow the instructions to confirm or re-enter the domain\033[0m"
    echo -e "  \033[1;32mChoose a subdomain to visit from the list\033[0m"
    echo -e "  \033[1;32mUse 'y' or 'n' to proceed with the prompts\033[0m"
}

# Display the custom ASCII art and welcome message
display_ascii_art_animation
display_welcome_message

# Loop to handle domain input and confirmation
while true; do
    # Read domain input from user
    echo -e "\n"
    read -p "Enter the domain: " dom

    # Validate the domain format
    if [[ ! "$dom" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        display_message "Invalid domain format. Please try again." "red"
        continue
    fi

    # Confirm the domain name with the user
    confirm_domain "$dom" || { echo "Please enter a new domain."; continue; }

    # Step 1: Use assetfinder to find subdomains
    echo -e "\n"
    display_message "Finding subdomains" "yellow"
    display_loading &
    loading_pid=$!
    assetfinder -subs-only "$dom" > sub
    stop_loading

    # Check if assetfinder found any subdomains
    check_subdomains || continue

    # Step 2: Use httprobe to check which subdomains are reachable
    display_message "Checking reachable subdomains" "yellow"
    display_loading &
    loading_pid=$!
    cat sub | httprobe > sub1
    stop_loading

    # Step 3: Remove duplicates and sort the list
    display_message "Removing duplicates and sorting" "yellow"
    display_loading &
    loading_pid=$!
    sort -u sub1 > sub2
    stop_loading

    # Step 4: Display the final list of subdomains with clickable [visit] links
    display_message "Final list of subdomains" "green"
    echo -e "\n"
    subdomains=()
    index=0
    while read -r subdomain; do
        subdomains+=("$subdomain")
        echo -e "[$index] $subdomain [\033[1;34mvisit\033[0m]"
        ((index++))
    done < sub2

    echo -e "\n"
    echo -e "\033[1;32mDone!\033[0m"
    echo -e "\033[1;37mThank you for using Domain Finder.\033[0m"

    # Prompt user to choose a subdomain to visit
    echo -e "\n"
    while true; do
        read -p "Enter the number of the subdomain you want to visit, or 'n' to skip: " choice
        if [[ $choice =~ ^[0-9]+$ ]] && [ $choice -lt ${#subdomains[@]} ]; then
            handle_visit "${subdomains[$choice]}"
            break
        elif [[ $choice =~ ^[Nn]$ ]]; then
            break
        else
            echo "Invalid choice. Please enter a valid number or 'n' to skip."
        fi
    done

    # Prompt user for another domain input
    read -p "Do you want to enter another domain? (y/n): " choice
    case "$choice" in
        y|Y) continue ;;
        *) display_goodbye; echo "Exiting script."; break ;;
    esac
done
