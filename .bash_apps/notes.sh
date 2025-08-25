#!/bin/bash

NOTES_FILE="notes.txt"

# Create the notes file if it doesn't exist
if [ ! -f "$NOTES_FILE" ]; then
    touch "$NOTES_FILE"
fi

case "$1" in
    add)
        if [ -z "$2" ]; then
            echo "Usage: $0 add <note>"
            exit 1
        fi
        echo "$(date): $2" >> "$NOTES_FILE"
        echo "Note added."
        ;;
    list)
        if [ -s "$NOTES_FILE" ]; then
            cat "$NOTES_FILE"
        else
            echo "No notes found."
        fi
        ;;
    clear)
        > "$NOTES_FILE"
        echo "Notes cleared."
        ;;
    *)
        echo "Usage: $0 {add|list|clear}"
        exit 1
        ;;
esac
