#!/bin/sh

# Will prompt for a single answer from an ai model at the provided remote.
# $1 remote
# $2 model name
# $3 message
# $4 api key (optional)

content="$(echo "$3" | jq -Rs .)"
response=$(curl -s "$1/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $4" \
  -d "{
    \"model\": \"$2\",
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": $content
      }
    ]
  }")

#echo "raw: $response"
echo "$response" | jq -r '.choices[0].message.content'
