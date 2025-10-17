#!/bin/bash
# Downsample exercise images in the widget asset catalog to appropriate sizes
# Widget displays images at 32x32 points, so we need:
# - 1x: 32px (small)
# - 2x: 64px (medium)
# - 3x: 96px (max)

EXERCISES_DIR="/Users/andrewcoyle/DialedIn/WorkoutSessionActivity/Assets.xcassets/Exercises"

echo "🎨 Starting exercise image downsampling for widget..."
echo "📁 Directory: $EXERCISES_DIR"
echo ""

if [ ! -d "$EXERCISES_DIR" ]; then
    echo "❌ Error: Exercise assets directory not found!"
    exit 1
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

# Process each imageset
for imageset in "$EXERCISES_DIR"/*.imageset; do
    if [ ! -d "$imageset" ]; then
        continue
    fi
    
    imageset_name=$(basename "$imageset")
    echo "📸 Processing $imageset_name..."
    
    # Process each PNG file in the imageset
    for img in "$imageset"/*.png; do
        if [ ! -f "$img" ]; then
            continue
        fi
        
        filename=$(basename "$img")
        original_size=$(get_file_size "$img")
        
        # Determine target size based on filename
        target_size=""
        if [[ "$filename" == *"small"* ]]; then
            target_size=32
            scale="1x"
        elif [[ "$filename" == *"medium"* ]]; then
            target_size=64
            scale="2x"
        elif [[ "$filename" == *"max"* ]]; then
            target_size=96
            scale="3x"
        fi
        
        if [ -z "$target_size" ]; then
            echo "  ⚠️  Skipping $filename (unknown size variant)"
            continue
        fi
        
        # Create temporary file
        temp_file="${img}.tmp"
        
        # Use sips to resize the image
        sips -Z "$target_size" "$img" --out "$temp_file" >/dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            # Replace original with resized
            mv "$temp_file" "$img"
            
            new_size=$(get_file_size "$img")
            saved=$((original_size - new_size))
            total_savings=$((total_savings + saved))
            
            original_kb=$(format_size $original_size)
            new_kb=$(format_size $new_size)
            reduction=$(echo "scale=1; ($saved * 100) / $original_size" | bc)
            
            echo "  ✓ $filename ($scale): ${original_kb}KB → ${new_kb}KB (${reduction}% reduction)"
            total_processed=$((total_processed + 1))
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

