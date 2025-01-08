#!/bin/bash

# Check if the input file is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <input-file>"
  exit 1
fi

INPUT_FILE=$1
OUTPUT_FILE="${INPUT_FILE%.json}.converted.json"

# Process the JSON
jq '
  map(
    if .type == "Text" then
      .content.body |= split("\n")
    else
      .
    end
  )
' "$INPUT_FILE" > "$OUTPUT_FILE"

# Success message
if [ $? -eq 0 ]; then
  echo "Converted JSON saved to $OUTPUT_FILE"
else
  echo "Failed to process the JSON."
fi
