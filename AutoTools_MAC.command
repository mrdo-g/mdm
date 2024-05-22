#!/bin/bash
# Bash Menu Script Example
RED='\033[0;31m'
GRN='\033[0;32m'
BLU='\033[0;34m'
NC='\033[0m'
echo ""
echo -e "Auto Tools for MacOS"
echo ""
PS3='Please enter your choice: '
options=("Disable GateKeeper" "Enable GateKeeper" "Allow Single App To ByPass The GateKeeper" "Show Hidden Files Finder" "Hide Hidden File Finder" "Turn off MDM Notification" "Check MDM Enrollment" "Quit")
select opt in "${options[@]}"
do
	case $opt in
		"Disable GateKeeper")
			echo ""
			echo -e "${GRN}Start Disable GateKeeper${NC}"
			echo ""
			echo -e "${RED}Please Insert Your Password To Proceed${NC}"
			echo ""
			defaults write com.apple.frameworks.diskimages skip-verify -bool YES
			sudo spctl --master-disable
			break
			;;
		"Enable GateKeeper")
			echo ""
			echo -e "${GRN}Start Enable GateKeeper${NC}"
			echo ""
			echo -e "${RED}Please Insert Your Password To Proceed${NC}"
			echo ""
			defaults write com.apple.frameworks.diskimages skip-verify -bool NO
			sudo spctl --master-enable
			break
			;;
		"Allow Single App To ByPass The GateKeeper")
			echo ""
			echo -e "${GRN}Start Process Allow Single App To ByPass The GateKeeper${NC}"
			echo ""
			read -e -p "Drag & Drop The App Here Then Hit Return: " FILEPATH
			echo ""
			echo -e "${RED}Please Insert Your Password To Proceed${NC}"
			echo ""
			sudo xattr -rd com.apple.quarantine "$FILEPATH"
			break
			;;								
		"Show Hidden Files Finder")
			echo ""
			echo -e "${GRN}Completed Show Hidden Files Finder${NC}"
			echo ""
			defaults write com.apple.Finder AppleShowAllFiles true
			killall Finder
			;;
		"Hide Hidden File Finder")
			echo ""
			echo -e "${GRN}Completed Hide Hidden File Finder${NC}"
			echo ""
			defaults write com.apple.Finder AppleShowAllFiles false
			killall Finder
			;;
		"Turn off MDM Notification")
			echo ""
			echo -e "${GRN}Start process to Turn off MDM Notification${NC}"
			echo ""
			echo -e "${RED}Please Insert Your Password To Proceed${NC}"
			echo ""
			sudo bash -c 'echo " " >> /etc/hosts'
			sudo bash -c 'echo "# Turn off MDM Notification by Tefivn.com" >> /etc/hosts'
			sudo bash -c 'echo "0.0.0.0 deviceenrollment.apple.com" >> /etc/hosts'
			sudo bash -c 'echo "0.0.0.0 mdmenrollment.apple.com" >> /etc/hosts'
			sudo bash -c 'echo "0.0.0.0 iprofiles.apple.com" >> /etc/hosts'
			sudo bash -c 'echo " " >> /etc/hosts'
			break
			;;
		"Check MDM Enrollment")
			echo ""
			echo -e "${GRN}Check MDM Enrollment. Error is success${NC}"
			echo ""
			echo -e "${RED}Please Insert Your Password To Proceed${NC}"
			echo ""
			sudo profiles show -type enrollment
			break
			;;	
		"Quit")
			break
			;;
		*) echo "Invalid option $REPLY";;
	esac
done