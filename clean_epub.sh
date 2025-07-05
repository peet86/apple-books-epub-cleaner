#!/bin/bash

# Script to clean Apple epub packages by removing iTunesMetadata.plist
# Works with .epub directories (Apple packages), not regular epub files
# Usage: ./clean_epub.sh package1.epub package2.epub ...

# Function to clean a single epub package (directory)
clean_epub_package() {
    local epub_package="$1"
    local package_dir=$(dirname "$epub_package")
    local package_name=$(basename "$epub_package" .epub)
    local cleaned_name="${package_name}_cleaned.epub"
    local output_file="${package_dir}/${cleaned_name}"
    
    echo "Processing Apple package: $epub_package"
    
    # Remove iTunesMetadata.plist if it exists
    if [ -f "$epub_package/iTunesMetadata.plist" ]; then
        rm "$epub_package/iTunesMetadata.plist"
        echo "  ✓ Removed iTunesMetadata.plist"
    else
        echo "  ℹ No iTunesMetadata.plist found"
    fi
    
    # Change to package directory and create proper epub
    cd "$epub_package"
    
    # Create new epub with proper structure
    # First add mimetype without compression
    if [ -f "mimetype" ]; then
        zip -X -0 -q "$output_file" mimetype
    fi
    
    # Then add everything else with compression
    zip -X -r -q "$output_file" * -x mimetype
    
    echo "  ✓ Created cleaned epub: $cleaned_name"
    
    # Return to original directory
    cd - > /dev/null
    
    return 0
}

# Main processing
if [ $# -eq 0 ]; then
    echo "Usage: $0 package1.epub package2.epub ..."
    echo "This script cleans Apple epub packages by removing iTunesMetadata.plist"
    echo "Works with .epub directories (Apple packages), not regular epub files"
    exit 1
fi

# Display header
echo "┌─────────────────────────────────────────┐"
echo "│        Apple Books EPUB Cleaner        │"
echo "│   Converting packages to clean EPUBs   │"
echo "└─────────────────────────────────────────┘"
echo ""

processed=0
failed=0

for epub_file in "$@"; do
    if [[ "$epub_file" == *.epub ]]; then
        if [ -d "$epub_file" ]; then
            # It's an Apple package (directory) - process it
            if clean_epub_package "$epub_file"; then
                ((processed++))
            else
                ((failed++))
            fi
        elif [ -f "$epub_file" ]; then
            # It's already a legitimate epub file
            echo "Skipping $epub_file - already a legitimate epub file, no conversion needed"
        else
            echo "File not found: $epub_file"
            ((failed++))
        fi
    else
        echo "Skipping non-epub file: $epub_file"
    fi
done

echo ""
echo "Summary:"
echo "  Processed: $processed files"
echo "  Failed: $failed files"

# Show notification on macOS
if command -v osascript &> /dev/null; then
    osascript -e "display notification \"Processed $processed epub files\" with title \"EPUB Cleaner\""
fi 