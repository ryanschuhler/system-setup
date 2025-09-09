#!/bin/bash

NOTES_DIR="$HOME/notes"

# Create the notes directory if it doesn't exist
if [ ! -d "$NOTES_DIR" ]; then
	mkdir -p "$NOTES_DIR"
fi

edit_note() {
	local note_path="$1"
	if command -v vim >/dev/null 2>&1; then
		vim "$note_path"
	elif command -v vi >/dev/null 2>&1; then
		vi "$note_path"
	else
		echo "Error: Neither vim nor vi is installed. Cannot edit notes."
		exit 1
	fi
}

case "$1" in
	a | add)
		if [ -z "$2" ]; then
			echo "Usage: $0 add <note-name> [initial-content]"
			exit 1
		fi
		NOTE_NAME="$2"
		NOTE_FILE="$NOTES_DIR/$NOTE_NAME.md"
		if [ -f "$NOTE_FILE" ]; then
			echo "Error: Note '$NOTE_NAME' already exists."
			exit 1
		fi
		shift 2
		CONTENT="$@"
		echo "# $NOTE_NAME" > "$NOTE_FILE"
		echo "" >> "$NOTE_FILE"
		if [ -n "$CONTENT" ]; then
			echo "$CONTENT" >> "$NOTE_FILE"
		fi
		echo "Note '$NOTE_NAME' created at $NOTE_FILE."
		edit_note "$NOTE_FILE"
		;;
	l | list)
		if [ -z "$(ls -A "$NOTES_DIR")" ]; then
			echo "No notes found in $NOTES_DIR."
		else
			ls -1 "$NOTES_DIR" | sed 's/\.md$//'
		fi
		;;
	e | edit)
		if [ -z "$2" ]; then
			echo "Usage: $0 edit <note-name>"
			exit 1
		fi
		NOTE_NAME="$2"
		NOTE_FILE="$NOTES_DIR/$NOTE_NAME.md"
		if [ ! -f "$NOTE_FILE" ]; then
			echo "Error: Note '$NOTE_NAME' not found."
			exit 1
		fi
		edit_note "$NOTE_FILE"
		;;
	d | delete)
		if [ -z "$2" ]; then
			echo "Usage: $0 rm <note-name>"
			exit 1
		fi
		NOTE_NAME="$2"
		NOTE_FILE="$NOTES_DIR/$NOTE_NAME.md"
		if [ ! -f "$NOTE_FILE" ]; then
			echo "Error: Note '$NOTE_NAME' not found."
			exit 1
		fi
		echo "Are you sure you want to delete the note '$NOTE_NAME'? (y/n)"
		read -r answer
		if [ "$answer" = "y" ]; then
			rm "$NOTE_FILE"
			echo "Note '$NOTE_NAME' deleted."
		else
			echo "Delete operation cancelled."
		fi
		;;
	*)
		echo "Usage: $0 {add|list|edit|delete}"
		exit 1
		;;
esac
