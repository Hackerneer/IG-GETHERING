#!/bin/bash
# Instagram Tool - Hacker Neer Edition
# YouTube: https://youtube.com/@hackerneer

clear
echo "==================================="
echo "   INSTAGRAM TOOL - HACKER NEER    "
echo "   Channel: @hackerneer            "
echo "==================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check dependencies
check_deps() {
    echo -e "${BLUE}[*] Checking dependencies...${NC}"
    if ! command -v curl &> /dev/null; then
        echo -e "${YELLOW}[!] Installing curl...${NC}"
        pkg install curl -y
    fi
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}[!] Installing jq...${NC}"
        pkg install jq -y
    fi
}

# Banner
banner() {
    echo -e "${GREEN}"
    echo "  ╔═══════════════════════════════════╗"
    echo "  ║   HACKER NEER INSTAGRAM TOOL     ║"
    echo "  ║   Version: 3.0 - FINAL           ║"
    echo "  ║   YouTube: @hackerneer           ║"
    echo "  ╚═══════════════════════════════════╝"
    echo -e "${NC}"
}

# Method 1: Using RapidAPI (Free)
get_rapidapi() {
    echo -e "${BLUE}[*] Using RapidAPI method...${NC}"
    
    # Using free Instagram API from RapidAPI
    response=$(curl -s "https://instagram-api244.p.rapidapi.com/user/${username}" \
        -H "X-RapidAPI-Key: 2e5f9c8b7dmsh3a4b5c6d7e8f9g0h1i2j3k4l5" \
        -H "X-RapidAPI-Host: instagram-api244.p.rapidapi.com" 2>/dev/null)
    
    if echo "$response" | grep -q "full_name"; then
        fullname=$(echo "$response" | jq -r '.full_name' 2>/dev/null)
        followers=$(echo "$response" | jq -r '.follower_count' 2>/dev/null)
        following=$(echo "$response" | jq -r '.following_count' 2>/dev/null)
        posts=$(echo "$response" | jq -r '.media_count' 2>/dev/null)
        bio=$(echo "$response" | jq -r '.biography' 2>/dev/null)
        
        display_info
        return 0
    fi
    return 1
}

# Method 2: Using Instagram Direct with Cookies
get_with_cookies() {
    echo -e "${BLUE}[*] Using cookie method...${NC}"
    
    # Get initial cookies
    cookie_jar=$(mktemp)
    curl -s -c "$cookie_jar" "https://www.instagram.com" > /dev/null 2>&1
    
    # Then fetch profile
    response=$(curl -s -L -b "$cookie_jar" \
        "https://www.instagram.com/${username}/" \
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" 2>/dev/null)
    
    rm -f "$cookie_jar"
    
    # Extract JSON from page source
    json_data=$(echo "$response" | grep -o '"graphql":{[^}]*}' | sed 's/^"graphql"://' | sed 's/,$//' 2>/dev/null)
    
    if [ -n "$json_data" ]; then
        fullname=$(echo "$json_data" | jq -r '.user.full_name' 2>/dev/null)
        followers=$(echo "$json_data" | jq -r '.user.edge_followed_by.count' 2>/dev/null)
        following=$(echo "$json_data" | jq -r '.user.edge_follow.count' 2>/dev/null)
        posts=$(echo "$json_data" | jq -r '.user.edge_owner_to_timeline_media.count' 2>/dev/null)
        bio=$(echo "$json_data" | jq -r '.user.biography' 2>/dev/null)
        
        if [ "$fullname" != "null" ] && [ -n "$fullname" ]; then
            display_info
            return 0
        fi
    fi
    return 1
}

# Method 3: Using Alternative API
get_alternative_api() {
    echo -e "${BLUE}[*] Using alternative API...${NC}"
    
    # Using different endpoint
    response=$(curl -s "https://www.instagram.com/api/v1/users/web_profile_info/?username=${username}" \
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
        -H "Accept: application/json" \
        -H "x-ig-app-id: 936619743392459" \
        -H "Accept-Language: en-US" 2>/dev/null)
    
    if echo "$response" | grep -q '"user"'; then
        fullname=$(echo "$response" | jq -r '.data.user.full_name' 2>/dev/null)
        followers=$(echo "$response" | jq -r '.data.user.edge_followed_by.count' 2>/dev/null)
        following=$(echo "$response" | jq -r '.data.user.edge_follow.count' 2>/dev/null)
        posts=$(echo "$response" | jq -r '.data.user.edge_owner_to_timeline_media.count' 2>/dev/null)
        bio=$(echo "$response" | jq -r '.data.user.biography' 2>/dev/null)
        
        if [ "$fullname" != "null" ] && [ -n "$fullname" ]; then
            display_info
            return 0
        fi
    fi
    return 1
}

# Method 4: Using Public Instagram View
get_public_view() {
    echo -e "${BLUE}[*] Using public view method...${NC}"
    
    # Get the profile page
    html=$(curl -s -L "https://www.instagram.com/p/instagram/" 2>/dev/null)
    
    # Extract the JSON from the page
    json_data=$(echo "$html" | grep -o 'window._sharedData = {.*};' | sed 's/window._sharedData = //;s/;$//' 2>/dev/null)
    
    if [ -n "$json_data" ]; then
        # Try to find user data
        user_data=$(echo "$json_data" | jq -r ".entry_data.ProfilePage[].graphql.user" 2>/dev/null)
        
        if [ -n "$user_data" ] && [ "$user_data" != "null" ]; then
            fullname=$(echo "$user_data" | jq -r '.full_name' 2>/dev/null)
            followers=$(echo "$user_data" | jq -r '.edge_followed_by.count' 2>/dev/null)
            following=$(echo "$user_data" | jq -r '.edge_follow.count' 2>/dev/null)
            posts=$(echo "$user_data" | jq -r '.edge_owner_to_timeline_media.count' 2>/dev/null)
            bio=$(echo "$user_data" | jq -r '.biography' 2>/dev/null)
            
            if [ "$fullname" != "null" ] && [ -n "$fullname" ]; then
                display_info
                return 0
            fi
        fi
    fi
    return 1
}

# Display user information
display_info() {
    echo -e "\n${GREEN}════════════════════════════════════${NC}"
    echo -e "${GREEN}[+] USER INFORMATION${NC}"
    echo -e "${GREEN}════════════════════════════════════${NC}"
    echo -e "${BLUE}Username:${NC} @$username"
    [ "$fullname" != "null" ] && [ -n "$fullname" ] && echo -e "${BLUE}Full Name:${NC} $fullname"
    [ "$followers" != "null" ] && [ -n "$followers" ] && echo -e "${BLUE}Followers:${NC} $followers"
    [ "$following" != "null" ] && [ -n "$following" ] && echo -e "${BLUE}Following:${NC} $following"
    [ "$posts" != "null" ] && [ -n "$posts" ] && echo -e "${BLUE}Posts:${NC} $posts"
    [ "$bio" != "null" ] && [ -n "$bio" ] && echo -e "${BLUE}Bio:${NC} $bio"
    
    # Check if private
    is_private=$(echo "$response" | jq -r '.data.user.is_private' 2>/dev/null)
    [ "$is_private" = "true" ] && echo -e "${YELLOW}Status:${NC} Private Account"
    [ "$is_private" = "false" ] && echo -e "${GREEN}Status:${NC} Public Account"
    
    echo -e "${GREEN}════════════════════════════════════${NC}"
}

# Get user info with multiple methods
get_user_info() {
    echo -e "\n${YELLOW}[+] Enter Instagram Username:${NC}"
    read -p "> " username
    
    if [ -z "$username" ]; then
        echo -e "${RED}[!] Username required!${NC}"
        return
    fi
    
    echo -e "${BLUE}[*] Trying to fetch data...${NC}"
    
    # Try all methods
    if ! get_alternative_api; then
        if ! get_public_view; then
            if ! get_with_cookies; then
                if ! get_rapidapi; then
                    echo -e "${RED}[!] All methods failed!${NC}"
                    echo -e "${YELLOW}[!] Possible reasons:${NC}"
                    echo -e "${YELLOW}   • Account is private${NC}"
                    echo -e "${YELLOW}   • Username doesn't exist${NC}"
                    echo -e "${YELLOW}   • Rate limited (wait 5 mins)${NC}"
                    echo -e "${YELLOW}   • Instagram changed API${NC}"
                    echo -e "\n${BLUE}[*] Try again with:${NC}"
                    echo -e "${BLUE}   • Public accounts only${NC}"
                    echo -e "${BLUE}   • Correct username${NC}"
                    echo -e "${BLUE}   • Wait 1-2 minutes between tries${NC}"
                fi
            fi
        fi
    fi
}

# Quick stats
quick_stats() {
    echo -e "\n${YELLOW}[+] Enter Instagram Username:${NC}"
    read -p "> " username
    
    if [ -z "$username" ]; then
        echo -e "${RED}[!] Username required!${NC}"
        return
    fi
    
    echo -e "\n${GREEN}════════════════════════════════════${NC}"
    echo -e "${GREEN}[+] STATS FOR @${username}${NC}"
    echo -e "${GREEN}════════════════════════════════════${NC}"
    
    # Try to get stats
    response=$(curl -s "https://www.instagram.com/api/v1/users/web_profile_info/?username=${username}" \
        -H "User-Agent: Mozilla/5.0" \
        -H "x-ig-app-id: 936619743392459" 2>/dev/null)
    
    followers=$(echo "$response" | jq -r '.data.user.edge_followed_by.count' 2>/dev/null)
    following=$(echo "$response" | jq -r '.data.user.edge_follow.count' 2>/dev/null)
    posts=$(echo "$response" | jq -r '.data.user.edge_owner_to_timeline_media.count' 2>/dev/null)
    
    [ "$followers" != "null" ] && [ -n "$followers" ] && echo -e "${BLUE}📊 Followers:${NC} $followers"
    [ "$following" != "null" ] && [ -n "$following" ] && echo -e "${BLUE}📊 Following:${NC} $following"
    [ "$posts" != "null" ] && [ -n "$posts" ] && echo -e "${BLUE}📊 Posts:${NC} $posts"
    
    if [ -z "$followers" ] || [ "$followers" = "null" ]; then
        echo -e "${RED}[!] Could not fetch stats${NC}"
        echo -e "${YELLOW}[!] Try the full info option instead${NC}"
    fi
    echo -e "${GREEN}════════════════════════════════════${NC}"
}

# About
about() {
    clear
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════╗"
    echo "║         ABOUT HACKER NEER           ║"
    echo "╠══════════════════════════════════════╣"
    echo "║  Name: Hacker Neer                  ║"
    echo "║  YouTube: @hackerneer               ║"
    echo "║  Channel Link:                      ║"
    echo "║  https://youtube.com/@hackerneer    ║"
    echo "║                                     ║"
    echo "║  ⚠️ DISCLAIMER:                     ║"
    echo "║  • Educational purpose only         ║"
    echo "║  • Respect Instagram ToS            ║"
    echo "║  • Don't misuse/harass              ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Main menu
main_menu() {
    echo -e "\n${BLUE}[1]${NC} Get User Info (Full Details)"
    echo -e "${BLUE}[2]${NC} Get Followers Count"
    echo -e "${BLUE}[3]${NC} Get Following Count"
    echo -e "${BLUE}[4]${NC} Get Post Count"
    echo -e "${BLUE}[5]${NC} About Hacker Neer"
    echo -e "${RED}[6]${NC} Exit"
    echo ""
}

# Main execution
main() {
    check_deps
    banner
    
    while true; do
        main_menu
        read -p "Enter your choice: " choice
        
        case $choice in
            1)
                get_user_info
                ;;
            2)
                quick_stats | grep Followers
                ;;
            3)
                quick_stats | grep Following
                ;;
            4)
                quick_stats | grep Posts
                ;;
            5)
                about
                ;;
            6)
                echo -e "${GREEN}[+] Thanks for using Hacker Neer Tool!${NC}"
                echo -e "${GREEN}[+] Subscribe: https://youtube.com/@hackerneer${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[!] Invalid option!${NC}"
                ;;
        esac
    done
}

main
