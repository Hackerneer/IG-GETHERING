#!/bin/bash
# Instagram Tool - Hacker Neer Pro (Fully Working)
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
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Files
FAVORITES_FILE="$HOME/.ig_favorites.txt"
HISTORY_FILE="$HOME/.ig_history.txt"

# Create files if not exist
touch $FAVORITES_FILE 2>/dev/null
touch $HISTORY_FILE 2>/dev/null

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
    echo "  ╔════════════════════════════════════════════╗"
    echo "  ║     HACKER NEER INSTAGRAM TOOL PRO        ║"
    echo "  ║     Version: 5.0 - FULLY WORKING          ║"
    echo "  ║     YouTube: @hackerneer                  ║"
    echo "  ╚════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Get user data (WORKING METHOD)
get_user_data() {
    username=$1
    
    # Method 1: Using Instagram API
    response=$(curl -s -L "https://www.instagram.com/api/v1/users/web_profile_info/?username=${username}" \
        -H "User-Agent: Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36" \
        -H "Accept: application/json" \
        -H "x-ig-app-id: 936619743392459" \
        -H "Accept-Language: en-US,en;q=0.9" \
        -H "Sec-Fetch-Site: same-origin" \
        -H "Sec-Fetch-Mode: cors" \
        --compressed 2>/dev/null)
    
    if echo "$response" | grep -q '"user"'; then
        echo "$response"
        return 0
    fi
    
    # Method 2: Alternative
    response=$(curl -s -L "https://www.instagram.com/${username}/?__a=1&__d=1" \
        -H "User-Agent: Mozilla/5.0" 2>/dev/null)
    
    if echo "$response" | grep -q '"graphql"'; then
        echo "$response"
        return 0
    fi
    
    return 1
}

# Parse and display user info
display_user_info() {
    username=$1
    response=$(get_user_data "$username")
    
    if [ $? -eq 0 ]; then
        # Parse JSON properly
        if echo "$response" | grep -q '"graphql"'; then
            fullname=$(echo "$response" | jq -r '.graphql.user.full_name' 2>/dev/null)
            followers=$(echo "$response" | jq -r '.graphql.user.edge_followed_by.count' 2>/dev/null)
            following=$(echo "$response" | jq -r '.graphql.user.edge_follow.count' 2>/dev/null)
            posts=$(echo "$response" | jq -r '.graphql.user.edge_owner_to_timeline_media.count' 2>/dev/null)
            bio=$(echo "$response" | jq -r '.graphql.user.biography' 2>/dev/null)
            is_private=$(echo "$response" | jq -r '.graphql.user.is_private' 2>/dev/null)
            is_verified=$(echo "$response" | jq -r '.graphql.user.is_verified' 2>/dev/null)
            pic_url=$(echo "$response" | jq -r '.graphql.user.profile_pic_url_hd' 2>/dev/null)
        else
            fullname=$(echo "$response" | jq -r '.data.user.full_name' 2>/dev/null)
            followers=$(echo "$response" | jq -r '.data.user.edge_followed_by.count' 2>/dev/null)
            following=$(echo "$response" | jq -r '.data.user.edge_follow.count' 2>/dev/null)
            posts=$(echo "$response" | jq -r '.data.user.edge_owner_to_timeline_media.count' 2>/dev/null)
            bio=$(echo "$response" | jq -r '.data.user.biography' 2>/dev/null)
            is_private=$(echo "$response" | jq -r '.data.user.is_private' 2>/dev/null)
            is_verified=$(echo "$response" | jq -r '.data.user.is_verified' 2>/dev/null)
            pic_url=$(echo "$response" | jq -r '.data.user.profile_pic_url_hd' 2>/dev/null)
        fi
        
        echo -e "\n${GREEN}════════════════════════════════════════════${NC}"
        echo -e "${PURPLE}📱 USER PROFILE - @${username}${NC}"
        echo -e "${GREEN}════════════════════════════════════════════${NC}"
        [ "$fullname" != "null" ] && [ -n "$fullname" ] && echo -e "${CYAN}👤 Name:${NC} $fullname"
        [ "$followers" != "null" ] && echo -e "${CYAN}👥 Followers:${NC} $followers"
        [ "$following" != "null" ] && echo -e "${CYAN}👤 Following:${NC} $following"
        [ "$posts" != "null" ] && echo -e "${CYAN}📸 Posts:${NC} $posts"
        [ "$bio" != "null" ] && [ "$bio" != "" ] && echo -e "${CYAN}📝 Bio:${NC} $bio"
        [ "$is_private" = "true" ] && echo -e "${CYAN}🔒 Status:${NC} ${YELLOW}Private Account${NC}"
        [ "$is_private" = "false" ] && echo -e "${CYAN}🔓 Status:${NC} ${GREEN}Public Account${NC}"
        [ "$is_verified" = "true" ] && echo -e "${CYAN}✅ Verified:${NC} ${GREEN}Yes ✅${NC}"
        echo -e "${GREEN}════════════════════════════════════════════${NC}"
        
        # Save to history
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Viewed: $username" >> $HISTORY_FILE
        
        return 0
    else
        echo -e "\n${RED}❌ Failed to fetch data for @$username${NC}"
        echo -e "${YELLOW}💡 Tips:${NC}"
        echo -e "   • Check username spelling"
        echo -e "   • Account might be private"
        echo -e "   • Try again after 1 minute"
        return 1
    fi
}

# FEATURE 1: Get User Info
feature_user_info() {
    echo -e "\n${YELLOW}[+] Enter Instagram Username:${NC}"
    read -p "> " username
    username=$(echo "$username" | xargs)  # Trim spaces
    
    if [ -z "$username" ]; then
        echo -e "${RED}[!] Username cannot be empty!${NC}"
        return
    fi
    
    display_user_info "$username"
}

# FEATURE 2: Multiple Users
feature_multiple_users() {
    echo -e "\n${YELLOW}[+] Enter usernames (comma separated):${NC}"
    echo -e "${BLUE}Example: neerajsaini9948,instagram,nasa${NC}"
    read -p "> " input
    
    IFS=',' read -ra users <<< "$input"
    for user in "${users[@]}"; do
        user=$(echo "$user" | xargs)
        if [ -n "$user" ]; then
            display_user_info "$user"
            sleep 1
        fi
    done
}

# FEATURE 3: Compare Users
feature_compare() {
    echo -e "\n${YELLOW}[+] Enter first username:${NC}"
    read -p "> " user1
    user1=$(echo "$user1" | xargs)
    
    echo -e "\n${YELLOW}[+] Enter second username:${NC}"
    read -p "> " user2
    user2=$(echo "$user2" | xargs)
    
    if [ -z "$user1" ] || [ -z "$user2" ]; then
        echo -e "${RED}[!] Both usernames required!${NC}"
        return
    fi
    
    data1=$(get_user_data "$user1")
    data2=$(get_user_data "$user2")
    
    if [ $? -eq 0 ] && [ $? -eq 0 ]; then
        f1=$(echo "$data1" | jq -r '.data.user.edge_followed_by.count // .graphql.user.edge_followed_by.count' 2>/dev/null)
        f2=$(echo "$data2" | jq -r '.data.user.edge_followed_by.count // .graphql.user.edge_followed_by.count' 2>/dev/null)
        
        echo -e "\n${GREEN}════════════════════════════════════════════${NC}"
        echo -e "${PURPLE}📊 COMPARISON RESULT${NC}"
        echo -e "${GREEN}════════════════════════════════════════════${NC}"
        echo -e "${CYAN}@$user1:${NC} $f1 followers"
        echo -e "${CYAN}@$user2:${NC} $f2 followers"
        
        if [ "$f1" -gt "$f2" ] 2>/dev/null; then
            echo -e "${GREEN}🏆 @$user1 has MORE followers!${NC}"
        elif [ "$f2" -gt "$f1" ] 2>/dev/null; then
            echo -e "${GREEN}🏆 @$user2 has MORE followers!${NC}"
        else
            echo -e "${YELLOW}🤝 Both have SAME followers!${NC}"
        fi
        echo -e "${GREEN}════════════════════════════════════════════${NC}"
    else
        echo -e "${RED}[!] Could not compare - one or both users not found${NC}"
    fi
}

# FEATURE 4: Favorites
feature_favorites() {
    echo -e "\n${YELLOW}[+] Favorites Menu:${NC}"
    echo -e "  ${BLUE}[a]${NC} Add to favorites"
    echo -e "  ${BLUE}[v]${NC} View favorites"
    echo -e "  ${BLUE}[r]${NC} Remove from favorites"
    echo -e "  ${BLUE}[c]${NC} Clear all favorites"
    read -p "> " choice
    
    case $choice in
        a|A)
            echo -e "\n${YELLOW}[+] Enter username to add:${NC}"
            read -p "> " fav_user
            fav_user=$(echo "$fav_user" | xargs)
            if [ -n "$fav_user" ]; then
                if grep -q "^$fav_user$" $FAVORITES_FILE 2>/dev/null; then
                    echo -e "${YELLOW}[!] $fav_user already in favorites!${NC}"
                else
                    echo "$fav_user" >> $FAVORITES_FILE
                    echo -e "${GREEN}✅ Added $fav_user to favorites!${NC}"
                fi
            fi
            ;;
        v|V)
            if [ -f "$FAVORITES_FILE" ] && [ -s "$FAVORITES_FILE" ]; then
                echo -e "\n${GREEN}════════════════════════════════════════════${NC}"
                echo -e "${PURPLE}⭐ YOUR FAVORITES${NC}"
                echo -e "${GREEN}════════════════════════════════════════════${NC}"
                count=0
                while read -r user; do
                    if [ -n "$user" ]; then
                        count=$((count+1))
                        echo -e "${CYAN}[$count]${NC} @$user"
                        display_user_info "$user"
                        echo ""
                    fi
                done < $FAVORITES_FILE
                if [ $count -eq 0 ]; then
                    echo -e "${YELLOW}[!] No favorites found!${NC}"
                fi
            else
                echo -e "${YELLOW}[!] No favorites found!${NC}"
            fi
            ;;
        r|R)
            echo -e "\n${YELLOW}[+] Enter username to remove:${NC}"
            read -p "> " rem_user
            rem_user=$(echo "$rem_user" | xargs)
            if [ -n "$rem_user" ]; then
                sed -i "/^$rem_user$/d" $FAVORITES_FILE 2>/dev/null
                echo -e "${GREEN}✅ Removed $rem_user from favorites!${NC}"
            fi
            ;;
        c|C)
            echo -e "${RED}[!] Clear all favorites? (y/n)${NC}"
            read -p "> " confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                > $FAVORITES_FILE
                echo -e "${GREEN}✅ All favorites cleared!${NC}"
            fi
            ;;
        *)
            echo -e "${RED}[!] Invalid choice!${NC}"
            ;;
    esac
}

# FEATURE 5: Download Profile Picture
feature_download_pic() {
    echo -e "\n${YELLOW}[+] Enter username:${NC}"
    read -p "> " username
    username=$(echo "$username" | xargs)
    
    if [ -z "$username" ]; then
        echo -e "${RED}[!] Username required!${NC}"
        return
    fi
    
    response=$(get_user_data "$username")
    if [ $? -eq 0 ]; then
        pic_url=$(echo "$response" | jq -r '.data.user.profile_pic_url_hd // .graphql.user.profile_pic_url_hd' 2>/dev/null)
        if [ "$pic_url" != "null" ] && [ -n "$pic_url" ]; then
            filename="${username}_dp_$(date +%s).jpg"
            curl -s -o "$filename" "$pic_url"
            if [ -f "$filename" ]; then
                echo -e "${GREEN}✅ Downloaded: $filename${NC}"
                echo "$(date '+%Y-%m-%d %H:%M:%S') - Downloaded DP: $username" >> $HISTORY_FILE
            else
                echo -e "${RED}[!] Download failed!${NC}"
            fi
        else
            echo -e "${RED}[!] No profile picture found${NC}"
        fi
    else
        echo -e "${RED}[!] User not found!${NC}"
    fi
}

# FEATURE 6: Account Status
feature_account_status() {
    echo -e "\n${YELLOW}[+] Enter username:${NC}"
    read -p "> " username
    username=$(echo "$username" | xargs)
    
    if [ -z "$username" ]; then
        echo -e "${RED}[!] Username required!${NC}"
        return
    fi
    
    response=$(get_user_data "$username")
    if [ $? -eq 0 ]; then
        if echo "$response" | grep -q '"graphql"'; then
            is_private=$(echo "$response" | jq -r '.graphql.user.is_private' 2>/dev/null)
            is_verified=$(echo "$response" | jq -r '.graphql.user.is_verified' 2>/dev/null)
            is_business=$(echo "$response" | jq -r '.graphql.user.is_business' 2>/dev/null)
            is_professional=$(echo "$response" | jq -r '.graphql.user.is_professional_account' 2>/dev/null)
        else
            is_private=$(echo "$response" | jq -r '.data.user.is_private' 2>/dev/null)
            is_verified=$(echo "$response" | jq -r '.data.user.is_verified' 2>/dev/null)
            is_business=$(echo "$response" | jq -r '.data.user.is_business' 2>/dev/null)
            is_professional=$(echo "$response" | jq -r '.data.user.is_professional_account' 2>/dev/null)
        fi
        
        echo -e "\n${GREEN}════════════════════════════════════════════${NC}"
        echo -e "${PURPLE}🔍 ACCOUNT STATUS - @${username}${NC}"
        echo -e "${GREEN}════════════════════════════════════════════${NC}"
        [ "$is_private" = "true" ] && echo -e "${YELLOW}🔒 Private Account${NC}"
        [ "$is_private" = "false" ] && echo -e "${GREEN}🌍 Public Account${NC}"
        [ "$is_verified" = "true" ] && echo -e "${GREEN}✅ Verified Account${NC}"
        [ "$is_business" = "true" ] && echo -e "${BLUE}💼 Business Account${NC}"
        [ "$is_professional" = "true" ] && echo -e "${PURPLE}👔 Professional Account${NC}"
        echo -e "${GREEN}════════════════════════════════════════════${NC}"
    else
        echo -e "${RED}[!] User not found!${NC}"
    fi
}

# FEATURE 7: Random User
feature_random() {
    echo -e "\n${BLUE}[*] Selecting random user...${NC}"
    users=("instagram" "nasa" "natgeo" "bbc" "cnn" "nytimes" "elonmusk" "cristiano" "neerajsaini9948" "techcrunch")
    random_index=$((RANDOM % ${#users[@]}))
    random_user=${users[$random_index]}
    echo -e "${YELLOW}[+] Random user: @$random_user${NC}"
    display_user_info "$random_user"
}

# FEATURE 8: History
feature_history() {
    if [ -f "$HISTORY_FILE" ] && [ -s "$HISTORY_FILE" ]; then
        echo -e "\n${GREEN}════════════════════════════════════════════${NC}"
        echo -e "${PURPLE}📜 SEARCH HISTORY${NC}"
        echo -e "${GREEN}════════════════════════════════════════════${NC}"
        tail -20 $HISTORY_FILE | nl
        echo -e "${GREEN}════════════════════════════════════════════${NC}"
    else
        echo -e "${YELLOW}[!] No history found!${NC}"
    fi
}

# FEATURE 9: Clear Data
feature_clear_data() {
    echo -e "\n${RED}⚠️  WARNING: This will delete all saved data!${NC}"
    echo -e "${YELLOW}Are you sure? (y/n)${NC}"
    read -p "> " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        > $FAVORITES_FILE 2>/dev/null
        > $HISTORY_FILE 2>/dev/null
        echo -e "${GREEN}✅ All data cleared successfully!${NC}"
    else
        echo -e "${YELLOW}[!] Operation cancelled${NC}"
    fi
}

# FEATURE 10: Auto Mode
feature_auto_mode() {
    echo -e "\n${BLUE}[*] Auto Mode - Scanning all favorites...${NC}"
    if [ -f "$FAVORITES_FILE" ] && [ -s "$FAVORITES_FILE" ]; then
        count=0
        while read -r user; do
            if [ -n "$user" ]; then
                count=$((count+1))
                echo -e "\n${CYAN}[$count] Processing @$user...${NC}"
                display_user_info "$user"
                sleep 1
            fi
        done < $FAVORITES_FILE
        if [ $count -eq 0 ]; then
            echo -e "${YELLOW}[!] No favorites found!${NC}"
        else
            echo -e "\n${GREEN}✅ Auto scan completed! Processed $count users${NC}"
        fi
    else
        echo -e "${YELLOW}[!] No favorites found! Add some first.${NC}"
    fi
}

# FEATURE 11: Export Data
feature_export() {
    if [ -f "$FAVORITES_FILE" ] && [ -s "$FAVORITES_FILE" ]; then
        export_file="ig_export_$(date +%Y%m%d_%H%M%S).txt"
        {
            echo "Instagram Tool Export - $(date)"
            echo "================================="
            echo ""
            echo "FAVORITES:"
            cat $FAVORITES_FILE
            echo ""
            echo "HISTORY:"
            cat $HISTORY_FILE
        } > $export_file
        echo -e "${GREEN}✅ Data exported to: $export_file${NC}"
    else
        echo -e "${YELLOW}[!] No data to export!${NC}"
    fi
}

# About
about() {
    clear
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════╗"
    echo "║         ABOUT HACKER NEER TOOL              ║"
    echo "╠═══════════════════════════════════════════════╣"
    echo "║  Name: Hacker Neer                          ║"
    echo "║  YouTube: @hackerneer                       ║"
    echo "║  Version: 5.0 PRO                         ║"
    echo "║                                             ║"
    echo "║  📱 FEATURES:                              ║"
    echo "║  ✓ Profile Viewer                         ║"
    echo "║  ✓ Multiple Users Search                  ║"
    echo "║  ✓ Compare Users                         ║"
    echo "║  ✓ Favorites List                        ║"
    echo "║  ✓ Download Profile Picture              ║"
    echo "║  ✓ Account Status                       ║"
    echo "║  ✓ Random User Generator                ║"
    echo "║  ✓ History Log                          ║"
    echo "║  ✓ Auto Mode                            ║"
    echo "║  ✓ Export Data                          ║"
    echo "║                                             ║"
    echo "║  ⚠️ DISCLAIMER:                             ║"
    echo "║  • Educational purpose only                ║"
    echo "║  • Respect Instagram Terms                ║"
    echo "║  • Don't misuse or harass                 ║"
    echo "╚═══════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "\n${YELLOW}📺 Channel: https://youtube.com/@hackerneer${NC}"
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Main Menu
main_menu() {
    echo -e "\n${CYAN}════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}📱 MAIN MENU${NC}"
    echo -e "${CYAN}════════════════════════════════════════════${NC}"
    echo -e "${BLUE} [1]${NC} Get User Info"
    echo -e "${BLUE} [2]${NC} Multiple Users Search"
    echo -e "${BLUE} [3]${NC} Compare Users"
    echo -e "${BLUE} [4]${NC} Favorites (Add/View/Remove)"
    echo -e "${BLUE} [5]${NC} Download Profile Picture"
    echo -e "${BLUE} [6]${NC} Check Account Status"
    echo -e "${BLUE} [7]${NC} Random User"
    echo -e "${BLUE} [8]${NC} View History"
    echo -e "${BLUE} [9]${NC} Clear Data"
    echo -e "${BLUE}[10]${NC} Auto Mode"
    echo -e "${BLUE}[11]${NC} Export Data"
    echo -e "${BLUE}[12]${NC} About Hacker Neer"
    echo -e "${RED}[13]${NC} Exit"
    echo -e "${CYAN}════════════════════════════════════════════${NC}"
    echo ""
}

# Main Execution
main() {
    check_deps
    banner
    
    while true; do
        main_menu
        read -p "Enter your choice (1-13): " choice
        
        case $choice in
            1) feature_user_info ;;
            2) feature_multiple_users ;;
            3) feature_compare ;;
            4) feature_favorites ;;
            5) feature_download_pic ;;
            6) feature_account_status ;;
            7) feature_random ;;
            8) feature_history ;;
            9) feature_clear_data ;;
            10) feature_auto_mode ;;
            11) feature_export ;;
            12) about ;;
            13) 
                echo -e "\n${GREEN}✅ Thanks for using Hacker Neer Tool!${NC}"
                echo -e "${GREEN}📺 Subscribe: https://youtube.com/@hackerneer${NC}"
                exit 0
                ;;
            *) echo -e "${RED}[!] Invalid option! Please choose 1-13${NC}" ;;
        esac
    done
}

main