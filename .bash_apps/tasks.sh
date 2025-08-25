#!/bin/bash
#
# tasks.sh - A script to manage tasks and track time.
# Combines functionalities from todo.sh and crono.sh.
#

# --- Configuration ---
CONFIG_DIR="$HOME/.config/tasks"
CONFIG_FILE="$CONFIG_DIR/config"

# Default settings
DEFAULT_TASKS_DIR="$HOME/tasks"

# --- Colors ---
if tput setaf 1 >/dev/null 2>&1; then
    COLOR_GREEN=$(tput setaf 2)
    COLOR_YELLOW=$(tput setaf 3)
    COLOR_RED=$(tput setaf 1)
    COLOR_RESET=$(tput sgr0)
    COLOR_PRI_A=$(tput setaf 1) # Red for (A)
    COLOR_PRI_B=$(tput setaf 3) # Yellow for (B)
    COLOR_PRI_C=$(tput setaf 2) # Green for (C)
    COLOR_DONE=$(tput setaf 8)  # Grey for done items
else
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_RED=""
    COLOR_RESET=""
    COLOR_PRI_A=""
    COLOR_PRI_B=""
    COLOR_PRI_C=""
    COLOR_DONE=""
fi

# --- Helper Functions ---

# Initializes the configuration and data files.
setup() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Performing first-time setup for tasks.sh..."
        mkdir -p "$CONFIG_DIR"
        echo "# Configuration for tasks.sh" > "$CONFIG_FILE"
        echo "TASKS_DIR=\"$DEFAULT_TASKS_DIR\"" >> "$CONFIG_FILE"
        echo "Created config file at: $CONFIG_FILE"
    fi

    # shellcheck source=/dev/null
    source "$CONFIG_FILE"

    if [ ! -d "$TASKS_DIR" ]; then
        mkdir -p "$TASKS_DIR"
        echo "Created data directory at: $TASKS_DIR"
    fi

    # Define file paths based on config
    TODO_FILE="$TASKS_DIR/todo.txt"
    DONE_FILE="$TASKS_DIR/done.txt"
    LOG_FILE="$TASKS_DIR/log.csv"
    STATE_FILE="$TASKS_DIR/state"
    TMP_FILE="$TASKS_DIR/tasks.tmp"

    # Create data files if they don't exist
    touch "$TODO_FILE" "$DONE_FILE" "$LOG_FILE"

    # Add header to log file if it's empty
    if ! grep -q "StartDate,StartTime,Project,Comment,EndDate,EndTime,Duration" "$LOG_FILE"; then
        echo "StartDate,StartTime,Project,Comment,EndDate,EndTime,Duration" > "$LOG_FILE"
    fi
}

# Displays usage instructions.
usage() {
    echo "Usage: ./tasks.sh [command] [arguments]"
    echo ""
    echo "Task Management Commands:"
    echo "  add \"THING TO DO\"   Adds a new task."
    echo "  ls                    Lists all tasks."
    echo "  do NUMBER             Marks a task as done."
    echo "  archive               Moves completed tasks to done.txt."
    echo ""
    echo "Time Tracking Commands:"
    echo "  start [PROJECT] \"COMMENT\"  Starts the timer for a project."
    echo "  stop                       Stops the current timer."
    echo "  status                     Shows the status of the current timer."
    echo "  report [today|week|all]    Summarizes time spent."
    echo ""
    echo "Pomodoro Commands:"
    echo "  pomo [TASK_ID] [WORK_MINS] [BREAK_MINS]  Starts a Pomodoro timer for a task."
    echo ""
    echo "Other Commands:"
    echo "  help                  Shows this help message."
}

# --- Task Management Functions ---

# Adds a new task to the todo file.
add_task() {
    if [ -z "$1" ]; then
        echo "Error: 'add' requires a task description."
        usage
        exit 1
    fi
    echo "$@" >> "$TODO_FILE"
    echo "Task added."
}

# Lists all tasks, with line numbers and color-coded priorities.
list_tasks() {
    if [ ! -s "$TODO_FILE" ]; then
        echo "Todo list is empty."
        return
    fi

    nl -w2 -s'. ' "$TODO_FILE" | sed -E \
        -e "s/(\(A\))/${COLOR_PRI_A}\1${COLOR_RESET}/g" \
        -e "s/(\(B\))/${COLOR_PRI_B}\1${COLOR_RESET}/g" \
        -e "s/(\(C\))/${COLOR_PRI_C}\1${COLOR_RESET}/g" \
        -e "s/(x [0-9]{4}-[0-9]{2}-[0-9]{2})/${COLOR_DONE}\1${COLOR_RESET}/"
}

# Marks a specific task as done.
complete_task() {
    local task_num=$1
    if [ -z "$task_num" ]; then
        echo "Error: 'do' requires a task number."
        usage
        exit 1
    fi

    # Validate that it's a number
    if ! [[ "$task_num" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid task number '$task_num'."
        exit 1
    fi

    # Get the task from the file
    local task
    task=$(sed -n "${task_num}p" "$TODO_FILE")

    if [ -z "$task" ]; then
        echo "Error: Task $task_num does not exist."
        exit 1
    fi

    # Mark as done with completion date
    local completed_task="x $(date '+%Y-%m-%d') $task"

    # Replace the original line with the completed one
    sed -i.bak "${task_num}s/.*/${completed_task}/" "$TODO_FILE"
    rm "$TODO_FILE.bak" # Clean up backup file on success

    echo "Completed task $task_num: $task"
}

# Moves all completed tasks to the done.txt file.
archive_tasks() {
    # Find lines starting with 'x ', append them to done.txt
    grep '^x ' "$TODO_FILE" >> "$DONE_FILE"

    # If grep found any, remove them from todo.txt
    if [ $? -eq 0 ]; then
        # Use a temporary file for safety
        grep -v '^x ' "$TODO_FILE" > "$TMP_FILE"
        mv "$TMP_FILE" "$TODO_FILE"
        echo "Archived completed tasks to $DONE_FILE."
    else
        echo "No completed tasks to archive."
    fi
}

# --- Time Tracking Functions ---

# Starts a new timer.
start_timer() {
    if [ -s "$STATE_FILE" ]; then
        echo "${COLOR_RED}Error: A timer is already running. Use 'tasks.sh stop' first.${COLOR_RESET}"
        echo "---"
        show_status
        exit 1
    fi

    local project=$1
    local comment=$2

    if [ -z "$project" ]; then
        echo "${COLOR_RED}Error: 'start' requires a project name.${COLOR_RESET}"
        usage
        exit 1
    fi

    local start_time
    start_time=$(date +%s) # Unix timestamp for calculations
    local start_date_human
    start_date_human=$(date '+%Y-%m-%d')
    local start_time_human
    start_time_human=$(date '+%H:%M:%S')

    # Save state: start_timestamp,start_date,start_time,project,comment
    echo "$start_time,$start_date_human,$start_time_human,$project,\"$comment\"" > "$STATE_FILE"

    echo "${COLOR_GREEN}Timer started for project '$project' at $start_time_human.${COLOR_RESET}"
}

# Stops the current timer and logs it.
stop_timer() {
    if [ ! -s "$STATE_FILE" ]; then
        echo "${COLOR_YELLOW}No timer is currently running.${COLOR_RESET}"
        exit 0
    fi

    # Read state
    local state_data
    state_data=$(cat "$STATE_FILE")
    IFS=',' read -r start_time start_date_human start_time_human project comment <<< "$state_data"

    # Get end time info
    local end_time
    end_time=$(date +%s)
    local end_date_human
    end_date_human=$(date '+%Y-%m-%d')
    local end_time_human
    end_time_human=$(date '+%H:%M:%S')

    # Calculate duration
    local duration_seconds=$((end_time - start_time))
    local duration_human
    duration_human=$(printf "%02d:%02d:%02d" $((duration_seconds/3600)) $((duration_seconds%3600/60)) $((duration_seconds%60)))

    # Append to log file (CSV format)
    echo "$start_date_human,$start_time_human,$project,$comment,$end_date_human,$end_time_human,$duration_human" >> "$LOG_FILE"

    # Clear the state file
    rm "$STATE_FILE"

    echo "${COLOR_GREEN}Timer stopped. Logged entry for project $project.${COLOR_RESET}"
    echo "Duration: $duration_human"
}

# Shows the status of the current timer.
show_status() {
    if [ ! -s "$STATE_FILE" ]; then
        echo "No timer is currently running."
        return
    fi

    local state_data
    state_data=$(cat "$STATE_FILE")
    IFS=',' read -r start_time start_date_human start_time_human project comment <<< "$state_data"

    local current_time
    current_time=$(date +%s)
    local elapsed_seconds=$((current_time - start_time))
    local elapsed_human
    elapsed_human=$(printf "%02d:%02d:%02d" $((elapsed_seconds/3600)) $((elapsed_seconds%3600/60)) $((elapsed_seconds%60)))

    echo "Timer is running for:"
    echo "  Project: $project"
    echo "  Comment: ${comment//"/}" # Remove quotes for display
    echo "  Started: $start_date_human at $start_time_human"
    echo "  Elapsed: ${COLOR_YELLOW}$elapsed_human${COLOR_RESET}"
}

# Generates a report of time spent.
generate_report() {
    local period=${1:-today}
    local filter_date

    case "$period" in
        "today")
            filter_date=$(date '+%Y-%m-%d')
            ;; 
        "week")
            # This is a simple filter for the last 7 days, more complex logic is possible
            echo "Report for the last 7 days:"
            filter_date=$(for i in {0..6}; do date -v-${i}d '+%Y-%m-%d'; done | tr '\n' '|')
            filter_date=${filter_date%|} # Remove trailing pipe
            ;; 
        "all")
            filter_date=".*" # Match any date
            ;; 
        *)
            echo "${COLOR_RED}Error: Unknown report period '$period'. Use 'today', 'week', or 'all'.${COLOR_RESET}"
            exit 1
            ;; 
    esac

    echo "--- Time Report for $period ---"
    # Use awk to parse CSV, filter by date, sum durations, and print a nice report
    tail -n +2 "$LOG_FILE" | awk -F, -v filter="$filter_date" ' 
    BEGIN {
        total_seconds = 0;
    }
    $1 ~ filter {
        # Split duration HH:MM:SS into seconds
        split($7, time, ":");
        seconds = time[1]*3600 + time[2]*60 + time[3];
        project_seconds[$3] += seconds;
        total_seconds += seconds;
    }
    END {
        if (total_seconds == 0) {
            print "No entries found for this period.";
            exit;
        }

        # Print header
        printf "% -20s | %s\n", "Project", "Total Time";
        printf "----------------------------------------\n";

        # Print per-project summary
        for (project in project_seconds) {
            s = project_seconds[project];
            h = int(s/3600);
            m = int((s%3600)/60);
            s = s%60;
            printf "% -20s | %02d:%02d:%02d\n", project, h, m, s;
        }

        # Print total
        h = int(total_seconds/3600);
        m = int((total_seconds%3600)/60);
        s = total_seconds%60;
        printf "----------------------------------------\n";
        printf "% -20s | %s%02d:%02d:%02d%s\n", "Total", "'""$COLOR_YELLOW""'", h, m, s, "'""$COLOR_RESET""'"
    } 
    '
}

# --- Pomodoro Function ---

# Starts a Pomodoro timer for a specific task.
start_pomodoro() {
    if [ -s "$STATE_FILE" ]; then
        echo "${COLOR_RED}Error: A timer is already running. Use 'tasks.sh stop' first.${COLOR_RESET}"
        echo "---"
        show_status
        exit 1
    fi

    local task_id=$1
    local work_minutes=${2:-25}
    local break_minutes=${3:-5}

    if [ -z "$task_id" ]; then
        echo "${COLOR_RED}Error: 'pomo' requires a task ID.${COLOR_RESET}"
        list_tasks
        exit 1
    fi

    local task_desc
    task_desc=$(sed -n "${task_id}p" "$TODO_FILE")

    if [ -z "$task_desc" ]; then
        echo "${COLOR_RED}Error: Task $task_id not found.${COLOR_RESET}"
        exit 1
    fi

    echo "${COLOR_GREEN}Starting Pomodoro for task: $task_desc${COLOR_RESET}"
    echo "Work for $work_minutes minutes."

    # Start timer for the task
    start_timer "Pomodoro" "Work on task $task_id: $task_desc"

    # Work timer
    sleep $((work_minutes * 60))

    # Notification for break
    echo "${COLOR_YELLOW}Work session finished! Time for a $break_minutes minute break.${COLOR_RESET}"
    # Simple notification, can be replaced with notify-send
    # notify-send "Pomodoro Finished" "Time for a $break_minutes minute break."

    # Stop timer
    stop_timer

    # Break timer
    sleep $((break_minutes * 60))

    # Notification for returning to work
    echo "${COLOR_GREEN}Break is over! Time to get back to work.${COLOR_RESET}"
    # notify-send "Break Over" "Time to get back to work."
}

# --- Main Script Logic ---

setup

COMMAND=$1
shift || true

case "$COMMAND" in
    "add" | "a")
        add_task "$@"
        ;; 
    "ls" | "list" | "") # Default to 'ls' if no command
        list_tasks
        ;; 
    "do")
        complete_task "$1"
        ;; 
    "archive")
        archive_tasks
        ;; 
    "start")
        start_timer "$1" "$2"
        ;; 
    "stop")
        stop_timer
        ;; 
    "status")
        show_status
        ;; 
    "report")
        generate_report "$1"
        ;; 
    "pomo")
        start_pomodoro "$1" "$2" "$3"
        ;; 
    "help")
        usage
        ;; 
    *)
        echo "Error: Unknown command '$COMMAND'"
        usage
        exit 1
        ;; 
esac

exit 0
