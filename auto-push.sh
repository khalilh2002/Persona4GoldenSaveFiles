#!/bin/bash

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

PROJECT_DIR="/home/khalil/Public/automated/Persona4GoldenSaveFiles"
LAST_PUSH_FILE="$PROJECT_DIR/.last_push_info"
TODAY_DATE=$(date +%Y-%m-%d)

# Check internet connection
if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo "Pas de connexion WiFi, arrêt du script."
    notify-send "Alert Auto-Commit" "no internet for github"
    exit 1
fi

# Get today's limit and count from file, or initialize
if [ -f "$LAST_PUSH_FILE" ]; then
    read STORED_DATE STORED_COUNT STORED_LIMIT < "$LAST_PUSH_FILE"
else
    STORED_DATE=""
    STORED_COUNT=0
    STORED_LIMIT=0
fi

# If it's a new day, reset count and generate new limit (e.g. 0–3)
if [ "$STORED_DATE" != "$TODAY_DATE" ]; then
    STORED_COUNT=0
    STORED_LIMIT=$(( RANDOM % 3 + 1 ))
    echo "[$TODAY_DATE] Nouveau jour : Limite de push = $STORED_LIMIT"
fi

# Stop if the limit is already reached
if [ "$STORED_COUNT" -ge "$STORED_LIMIT" ]; then
    echo "Limite de push atteinte pour aujourd'hui ($STORED_COUNT/$STORED_LIMIT)."
    exit 0
fi

# Perform the push
cd "$PROJECT_DIR" || exit

echo "Mise à jour du README - $TODAY_DATE #$((STORED_COUNT + 1))" >> README.md

LOG_FILE="$PROJECT_DIR/cron_log.txt"

git add README.md || { echo "Error: Failed to stage files at $(date)" >> "$LOG_FILE"; exit 1; }
git commit -m "Commit message" || { echo "Error: Commit failed at $(date)" >> "$LOG_FILE"; exit 1; }
git push origin main || { echo "Error: Push failed at $(date)" >> "$LOG_FILE"; exit 1; }


# Update the tracking file
STORED_COUNT=$((STORED_COUNT + 1))
echo "$TODAY_DATE $STORED_COUNT $STORED_LIMIT" > "$LAST_PUSH_FILE"

# Log
echo "Push #$STORED_COUNT effectué à $(date)"
echo "Script exécuté à $(date)" >> "$PROJECT_DIR/cron_log.txt"

notify-send "Alert" "Push to git: number of commits = $STORED_COUNT / $STORED_LIMIT."


exit 0

