#!/bin/bash
# Claude Code Stop Hook - Notify with task info

read -r input

transcript_path=$(echo "$input" | jq -r '.transcript_path')

if [ -f "$transcript_path" ]; then
  # Get the last human message from the transcript
  # Format: {"type": "user", "message": {"role": "user", "content": "string"}}
  # Skip tool results where content is an array
  task=$(tac "$transcript_path" 2>/dev/null | \
    while read -r line; do
      msg_type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)
      if [ "$msg_type" = "user" ]; then
        content_type=$(echo "$line" | jq -r '.message.content | type' 2>/dev/null)
        if [ "$content_type" = "string" ]; then
          # Extract content and strip system reminders
          echo "$line" | jq -r '.message.content // empty' 2>/dev/null | \
            sed 's/<system-reminder>.*//g' | \
            tr '\n' ' ' | \
            sed 's/^[[:space:]]*//' | \
            cut -c1-100
          break
        fi
      fi
    done)

  if [ -n "$task" ]; then
    notify-send "Claude Done" "$task" -u normal -t 5000
  else
    notify-send "Claude Done" "Task completed" -u normal -t 5000
  fi
else
  notify-send "Claude Done" "Task completed" -u normal -t 5000
fi

exit 0
