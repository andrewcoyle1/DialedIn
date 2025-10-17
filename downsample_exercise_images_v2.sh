#!/bin/bash
# Downsample exercise images in the widget asset catalog
# Creates three sizes from high-res source images:
# - 1x: 32px
# - 2x: 64px
# - 3x: 96px

EXERCISES_DIR="/Users/andrewcoyle/DialedIn/WorkoutSessionActivity/Assets.xcassets/Exercises"

echo "🎨 Starting exercise image downsampling for widget..."
echo "📁 Directory: $EXERCISES_DIR"
echo ""

if [ ! -d "$EXERCISES_DIR" ]; then
    echo "❌ Error: Exercise assets directory not found!"
    exit 1
fi

# Check if jq is available for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not found, using grep/sed for JSON parsing"
    USE_JQ=false
else
    USE_JQ=true
fi

total_processed=0
total_savings=0

# Function to get file size in bytes
get_file_size() {
    stat -f%z "$1" 2>/dev/null || echo "0"
}

# Function to format bytes to KB
format_size() {
    echo "scale=1; $1 / 1024" | bc
}

# Function to extract filename for a given scale from Contents.json
get_filename_for_scale() {
    local json_file="$1"
    local scale="$2"
    
    if [ "$USE_JQ" = true ]; then
        jq -r ".images[] | select(.scale == \"$scale\") | .filename" "$json_file"
    else
        # Fallback parsing without jq
        grep -A 2 "\"scale\" : \"$scale\"" "$json_file" | grep "filename" | sed 's/.*"filename" : "\(.*\)".*/\1/'
    fi
}

# Process each imageset
for imageset in "$EXERCISES_DIR"/*.imageset; do
    if [ ! -d "$imageset" ]; then
        continue
    fi
    
    imageset_name=$(basename "$imageset")
    json_file="$imageset/Contents.json"
    
    if [ ! -f "$json_file" ]; then
        echo "⚠️  Skipping $imageset_name (no Contents.json)"
        continue
    fi
    
    echo "📸 Processing $imageset_name..."
    
    # Get filenames for each scale from Contents.json
    file_1x=$(get_filename_for_scale "$json_file" "1x")
    file_2x=$(get_filename_for_scale "$json_file" "2x")
    file_3x=$(get_filename_for_scale "$json_file" "3x")
    
    if [ -z "$file_1x" ] || [ -z "$file_2x" ] || [ -z "$file_3x" ]; then
        echo "  ⚠️  Could not parse all filenames from Contents.json"
        continue
    fi
    
    # Use any of the source files (they're all the same high-res image)
    source_file="$imageset/$file_3x"
    
    if [ ! -f "$source_file" ]; then
        echo "  ⚠️  Source file not found: $source_file"
        continue
    fi
    
    original_size=$(get_file_size "$source_file")
    original_kb=$(format_size $original_size)
    
    # Process each scale
    for scale_info in "1x:32:$file_1x" "2x:64:$file_2x" "3x:96:$file_3x"; do
        IFS=':' read -r scale size filename <<< "$scale_info"
        
        target_file="$imageset/$filename"
        temp_file="${target_file}.tmp"
        
        # Resize using sips
        sips -Z "$size" "$source_file" --out "$temp_file" >/dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            mv "$temp_file" "$target_file"
            
            new_size=$(get_file_size "$target_file")
            new_kb=$(format_size $new_size)
            reduction=$(echo "scale=1; (($original_size - $new_size) * 100) / $original_size" | bc)
            
            echo "  ✓ $filename ($scale, ${size}px): ${original_kb}KB → ${new_kb}KB (${reduction}% reduction)"
            total_processed=$((total_processed + 1))
            total_savings=$((total_savings + original_size - new_size))
        else
            echo "  ✗ Error processing $filename"
            rm -f "$temp_file"
        fi
    done
    echo ""
done

# Summary
total_savings_mb=$(echo "scale=2; $total_savings / 1024 / 1024" | bc)
echo "============================================================"
echo "✅ Complete! Processed $total_processed images"
echo "💾 Total space saved: ${total_savings_mb}MB"
echo "============================================================"

