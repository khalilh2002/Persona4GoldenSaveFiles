#!/bin/bash

# Exit the script if any command fails
set -e

# Get the current date in dd-mm-yy format
DATE=$(date +%d-%m-%y)

# Define variables
ARCHIVE_NAME="p5r-data-save-$DATE.7z"
GIT_REPO="$HOME/Public/automated/Persona4GoldenSaveFiles/Persona5Royal/"
SAVE_FILES="$HOME/.local/share/citron/nand/user/save/0000000000000000/CCC8D59AB30C4DA596149053E15873C9/01005CA01580E000/"


# Check if save files directory exists
if [ ! -d "$SAVE_FILES" ]; then
    echo "Error: Save files directory $SAVE_FILES does not exist."
    notify-send "Error" "Save files directory $SAVE_FILES does not exist."
    exit 1
fi

cd "$SAVE_FILES" || { echo "Error: Failed to navigate to $SAVE_FILES."; exit 1; }

# Check if 7z is installed
if ! command -v 7z &>/dev/null; then
    echo "Error: 7z is not installed. Install it using your package manager."
    notify-send "Error" "7z is not installed. Please install it."
    exit 1
fi

# Ensure the git repository directory exists
if [ ! -d "$GIT_REPO" ]; then
    echo "Error: Git repository directory $GIT_REPO does not exist."
    notify-send "Error" "Git repository directory $GIT_REPO does not exist."
    exit 1
fi

# Compress all files in the current directory
echo "Compressing files into $ARCHIVE_NAME..."
7z a "$ARCHIVE_NAME" * || { echo "Error: Failed to create archive."; exit 1; }

# Move the archive to the git repository
echo "Moving $ARCHIVE_NAME to $GIT_REPO..."
mv "$ARCHIVE_NAME" "$GIT_REPO" || { echo "Error: Failed to move archive."; exit 1; }

# Navigate to the git repository
cd "$GIT_REPO" || { echo "Error: Failed to navigate to $GIT_REPO."; exit 1; }

# Stage and commit changes
echo "Adding and committing changes to the repository..."
git add . || { echo "Error: Failed to stage changes."; exit 1; }
git commit -m "Persona5Royal save data on $DATE" || { echo "Error: Commit failed."; exit 1; }

# Test internet connection before pushing
echo "Checking internet connection..."
if ! ping -c 1 github.com &>/dev/null; then
    echo "Error: Internet connection is not available. Changes will not be pushed."
    notify-send "Error" "No internet connection. Git changes are not pushed."
    exit 1
fi

# Push the changes to the repository
echo "Pushing changes to the repository..."
git push || { echo "Error: Failed to push changes."; notify-send "Error" "Failed to push changes."; exit 1; }

echo "Save data successfully added to the repository on $DATE."
notify-send "Success" "Save data successfully added to the repository on $DATE."
