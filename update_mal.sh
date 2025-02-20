#!bash

# MyAnimeList OAuth2 access token (replace with your actual token)
ACCESS_TOKEN="your_access_token"

# JSON file path
JSON_FILE="export.json"

# Ensure jq is installed
if ! command -v jq &>/dev/null; then
    echo "❌ jq is not installed. Please install it using: brew install jq"
    exit 1
fi

# Define a function to update the anime status
update_mal_status() {
    local mal_id="$1"
    local status="$2"
    local watched_episodes="$3"

    url="https://api.myanimelist.net/v2/anime/$mal_id/my_list_status"

    echo "🔄 Updating MAL status for Anime ID: $mal_id -> $status ($watched_episodes episodes)"

    response=$(curl -s -X PUT "$url" \
        -d "status=$status" \
        -d "num_watched_episodes=$watched_episodes" \
        -H "Authorization: Bearer $ACCESS_TOKEN")

    if echo "$response" | jq -e . >/dev/null 2>&1; then
        echo "✅ Successfully updated anime $mal_id"
    else
        echo "❌ Failed to update anime $mal_id"
        echo "Response: $response"
    fi

    echo "------------------------------------"
}

# Loop through all categories in the JSON
jq -r 'keys[]' "$JSON_FILE" | while read -r category; do
    echo "📂 Processing category: $category"

    # Map the category to MAL's status
    case "$category" in
        "Watching") mal_status="watching" ;;
        "Completed") mal_status="completed" ;;
        "On-Hold") mal_status="on_hold" ;;
        "Plan to watch") mal_status="plan_to_watch" ;;
        "Dropped") mal_status="dropped" ;;
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

        # Make a request to fetch the anime data
        url="https://api.myanimelist.net/v2/anime/$mal_id?fields=?fields=id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status,num_episodes,start_season,broadcast,source,average_episode_duration,rating,pictures,background,related_anime,related_manga,recommendations,studios,statistics"

        echo "📡 Fetching anime data for '$name' (ID: $mal_id).."

        export response=$(curl -s -X GET "$url" \
            -H "Authorization: Bearer $ACCESS_TOKEN")

        if echo "$response" | jq -e . >/dev/null 2>&1; then
            echo "✅ Successfully fetched data for '$name'"


            # Extract total episodes and watched episodes
            total_episodes=$(echo "$response" | jq -r '.num_episodes')
            watched_episodes=$(echo "$response" | jq -r '.my_list_status.num_watched_episodes')

            echo "✅ '$name' has $total_episodes episodes"

            # If total episodes is null, set it to 0
            total_episodes=${total_episodes:-0}

            # Determine the correct number of watched episodes
            if [[ "$mal_status" == "completed" ]]; then
                watched_episodes="$total_episodes"
            elif [[ "$mal_status" == "watching" && "$watched_episodes" -eq 0 ]]; then
                watched_episodes=1  # Start with at least 1 episode
            fi

            # Update the anime status on MAL
            update_mal_status "$mal_id" "$mal_status" "$watched_episodes"
        else
            echo "❌ Failed to fetch data for '$name'"
        fi

        echo "------------------------------------"
        echo
    done
done