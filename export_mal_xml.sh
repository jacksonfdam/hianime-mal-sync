#!bash

# MyAnimeList OAuth2 access token (replace with your actual token)
ACCESS_TOKEN="your_access_token"

# JSON file path
JSON_FILE="export.json"
XML_FILE="export.xml"

# Ensure jq is installed
if ! command -v jq &>/dev/null; then
    echo "❌ jq is not installed. Please install it using: brew install jq"
    exit 1
fi

# Start XML file
echo '<?xml version="1.0" encoding="UTF-8"?>' > "$XML_FILE"
echo '<myanimelist>' >> "$XML_FILE"
echo '	<myinfo>' >> "$XML_FILE"
echo '		<user_export_type>1</user_export_type>' >> "$XML_FILE"
echo '	</myinfo>' >> "$XML_FILE"

# Loop through all categories in the JSON
jq -r 'keys[]' "$JSON_FILE" | while read -r category; do
    echo "📂 Processing category: $category"

    # Map the category to MAL's status
    case "$category" in
        "Watching") mal_status="Watching" ;;
        "Completed") mal_status="Completed" ;;
        "On-Hold") mal_status="On-Hold" ;;
        "Plan to watch") mal_status="Plan to Watch" ;;
        "Dropped") mal_status="Dropped" ;;
        *) mal_status="" ;;
    esac

    if [[ -z "$mal_status" ]]; then
        echo "❌ Skipping unknown category: $category"
        continue
    fi

    # Extract anime list for this category
    jq -c --arg category "$category" '.[$category][]' "$JSON_FILE" | while read -r anime; do
        link=$(echo "$anime" | jq -r '.link')
        name=$(echo "$anime" | jq -r '.name')

        # Extract MyAnimeList ID from the link
        mal_id=$(echo "$link" | grep -oE '[0-9]+$')

        if [[ -z "$mal_id" ]]; then
            echo "❌ Skipping $name (Invalid MAL URL)"
            continue
        fi

        # Fetch anime data from MAL API
        url="https://api.myanimelist.net/v2/anime/$mal_id?fields=num_episodes,my_list_status"

        echo "📡 Fetching anime data for '$name' (ID: $mal_id).."

        response=$(curl -s -X GET "$url" \
            -H "Authorization: Bearer $ACCESS_TOKEN")

        if echo "$response" | jq -e . >/dev/null 2>&1; then
            echo "✅ Successfully fetched data for '$name'"

            # Extract total episodes and watched episodes
            total_episodes=$(echo "$response" | jq -r '.num_episodes')
            watched_episodes=$(echo "$response" | jq -r '.my_list_status.num_watched_episodes')

            # If total episodes is null, set it to 0
            total_episodes=${total_episodes:-0}
            watched_episodes=${watched_episodes:-0}

            echo "✅ '$name' has $total_episodes episodes, watched: $watched_episodes"

            # Append to XML file
            {
                echo "	<anime>"
                echo "		<series_animedb_id>$mal_id</series_animedb_id>"
                echo "		<series_title><![CDATA[ $name ]]></series_title>"
                echo "		<my_watched_episodes>$watched_episodes</my_watched_episodes>"
                echo "		<my_status>$mal_status</my_status>"
                echo "		<update_on_import>1</update_on_import>"
                echo "	</anime>"
            } >> "$XML_FILE"

        else
            echo "❌ Failed to fetch data for '$name'"
        fi

        echo "------------------------------------"
        echo
    done
done

# Close XML file
echo '</myanimelist>' >> "$XML_FILE"

echo "✅ Export completed: $XML_FILE"