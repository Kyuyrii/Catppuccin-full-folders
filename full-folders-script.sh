#!/bin/bash

set -e

# Default values
ICONS_DIR="/usr/share/icons"
FLAVORS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --path)
            ICONS_DIR="$2"
            shift 2
            ;;
        latte|frappe|macchiato|mocha)
            FLAVORS+=("$1")
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Capitalize flavors
FLAVORS=("${FLAVORS[@]^}")

# Use all flavors if none specified
if [ ${#FLAVORS[@]} -eq 0 ]; then
    FLAVORS=("Latte" "Frappe" "Macchiato" "Mocha")
fi

# Determine if sudo is needed
if [[ "$ICONS_DIR" == /usr/share/icons* ]] && [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
else
    SUDO=""
fi

echo "Installing flavors: ${FLAVORS[@]}"
echo "Using directory: $ICONS_DIR"

# 1. Check if Papirus exists
if [ ! -d "$ICONS_DIR/Papirus" ]; then
    echo "Error: Papirus not found in $ICONS_DIR"
    exit 1
fi

# Check if Papirus-Dark and Papirus-Light exist
PAPIRUS_DARK_EXISTS=false
PAPIRUS_LIGHT_EXISTS=false

if [ -d "$ICONS_DIR/Papirus-Dark" ]; then
    PAPIRUS_DARK_EXISTS=true
    echo "Found Papirus-Dark theme"
fi

if [ -d "$ICONS_DIR/Papirus-Light" ]; then
    PAPIRUS_LIGHT_EXISTS=true
    echo "Found Papirus-Light theme"
fi

# 2. Check for papirus-folders
if ! command -v papirus-folders &> /dev/null; then
    echo "Error: papirus-folders not found"
    exit 1
fi

# 3. Copy only selected flavors from full-folders
if [ -d "full-folders" ]; then
    echo "Copying Cat themes from full-folders..."
    for flavor in "${FLAVORS[@]}"; do
        # Find all Cat themes for this flavor in full-folders
        find "full-folders" -maxdepth 1 -type d -name "Cat-${flavor}-*" | while read theme_dir; do
            if [ -d "$theme_dir" ]; then
                theme=$(basename "$theme_dir")
                echo "  Copying: $theme"
                $SUDO cp -r "$theme_dir" "$ICONS_DIR/"
            fi
        done
    done
fi

# Function to create links in Dark/Light themes
create_dark_light_version() {
    local base_theme="$1"
    local suffix="$2"
    local base_path="$ICONS_DIR/$base_theme"
    local suffix_theme="${base_theme}${suffix}"
    local suffix_path="$ICONS_DIR/$suffix_theme"

    echo "  Creating $suffix version: $suffix_theme"

    # Determine which Papirus to use as base
    local papirus_base="Papirus"
    if [ "$suffix" = "-Dark" ] && [ "$PAPIRUS_DARK_EXISTS" = true ]; then
        papirus_base="Papirus-Dark"
    elif [ "$suffix" = "-Light" ] && [ "$PAPIRUS_LIGHT_EXISTS" = true ]; then
        papirus_base="Papirus-Light"
    fi

    echo "    Using $papirus_base as reference"

    # Process each item in the base theme
    for item in "$base_path"/*; do
        if [ -e "$item" ] && [ "$item" != "$base_path/index.theme" ]; then
            item_name=$(basename "$item")

            # If it's one of the sizes that contains places/ (22x22, 24x24, etc.)
            if [[ "$item_name" =~ ^(22x22|24x24|32x32|48x48|64x64)$ ]] && [ -d "$item/places" ]; then
                # Create own directory for this size
                $SUDO mkdir -p "$suffix_path/$item_name"

                # Create link ONLY for the places folder from base theme
                $SUDO ln -sf "../../$base_theme/$item_name/places" "$suffix_path/$item_name/places"

                # For other folders within this size (actions, apps, etc.)
                # Check if they are links in base theme and create equivalent links for Papirus-Dark/Papirus-Light
                for subitem in "$item"/*; do
                    if [ -e "$subitem" ] && [ "$subitem" != "$item/places" ]; then
                        subitem_name=$(basename "$subitem")

                        # If it's a link in the base theme
                        if [ -L "$subitem" ]; then
                            # Check if the corresponding folder exists in Papirus-Dark/Papirus-Light
                            if [ -d "$ICONS_DIR/$papirus_base/$item_name/$subitem_name" ]; then
                                # Link to the correct version of Papirus
                                $SUDO ln -sf "../../$papirus_base/$item_name/$subitem_name" "$suffix_path/$item_name/$subitem_name"
                            fi
                        fi
                    fi
                done
            # If it's 96x96 - create link for places to 48x48/places of the same theme
            elif [ "$item_name" = "96x96" ] && [ -d "$item" ]; then
                # Create own directory for 96x96
                $SUDO mkdir -p "$suffix_path/$item_name"

                # Create link for places to 48x48/places of the same theme
                $SUDO ln -sf "../../$base_theme/48x48/places" "$suffix_path/$item_name/places"

                # For other folders within 96x96, create links to Papirus-Dark/Papirus-Light
                if [ -d "$ICONS_DIR/$papirus_base/$item_name" ]; then
                    for subdir in "$ICONS_DIR/$papirus_base/$item_name"/*/; do
                        if [ -d "$subdir" ]; then
                            subname=$(basename "$subdir")
                            if [ "$subname" != "places" ] && [ ! -e "$suffix_path/$item_name/$subname" ]; then
                                $SUDO ln -sf "../../$papirus_base/$item_name/$subname" "$suffix_path/$item_name/$subname"
                            fi
                        fi
                    done
                fi
            # If it's 128x128 - create link for places to 64x64/places of the same theme
            elif [ "$item_name" = "128x128" ] && [ -d "$item" ]; then
                # Create own directory for 128x128
                $SUDO mkdir -p "$suffix_path/$item_name"

                # Create link for places to 64x64/places of the same theme
                $SUDO ln -sf "../../$base_theme/64x64/places" "$suffix_path/$item_name/places"

                # For other folders within 128x128, create links to Papirus-Dark/Papirus-Light
                if [ -d "$ICONS_DIR/$papirus_base/$item_name" ]; then
                    for subdir in "$ICONS_DIR/$papirus_base/$item_name"/*/; do
                        if [ -d "$subdir" ]; then
                            subname=$(basename "$subdir")
                            if [ "$subname" != "places" ] && [ ! -e "$suffix_path/$item_name/$subname" ]; then
                                $SUDO ln -sf "../../$papirus_base/$item_name/$subname" "$suffix_path/$item_name/$subname"
                            fi
                        fi
                    done
                fi
            # If it's a symbolic link (other sizes, scalable, etc.)
            elif [ -L "$item" ]; then
                local link_target=$(readlink "$item")

                # Extract the target item name
                local target_name=$(basename "$link_target")

                # Check if it exists in Papirus-Dark/Papirus-Light
                if [ -d "$ICONS_DIR/$papirus_base/$target_name" ] || [ -L "$ICONS_DIR/$papirus_base/$target_name" ]; then
                    # Link to the correct version of Papirus
                    $SUDO ln -sf "../$papirus_base/$target_name" "$suffix_path/$item_name"
                elif [ -d "$ICONS_DIR/$papirus_base/$item_name" ] || [ -L "$ICONS_DIR/$papirus_base/$item_name" ]; then
                    # Try with the same name
                    $SUDO ln -sf "../$papirus_base/$item_name" "$suffix_path/$item_name"
                fi
            # If it's another directory (not a link)
            elif [ -d "$item" ]; then
                # Check if it exists in Papirus-Dark/Papirus-Light
                if [ -d "$ICONS_DIR/$papirus_base/$item_name" ]; then
                    $SUDO ln -sf "../$papirus_base/$item_name" "$suffix_path/$item_name"
                # If it doesn't exist, check in normal Papirus
                elif [ -d "$ICONS_DIR/Papirus/$item_name" ]; then
                    $SUDO ln -sf "../Papirus/$item_name" "$suffix_path/$item_name"
                fi
            fi
        fi
    done

    # Also check for @2x links if they exist
    if [ -d "$ICONS_DIR/$papirus_base" ]; then
        for size_dir in "$ICONS_DIR/$papirus_base"/*@2x; do
            if [ -d "$size_dir" ]; then
                size_name=$(basename "$size_dir")
                # Check if this @2x size hasn't been created yet
                if [ ! -e "$suffix_path/$size_name" ]; then
                    $SUDO ln -sf "../$papirus_base/$size_name" "$suffix_path/$size_name"
                fi
            fi
        done
    fi
}

# 4. Process each Cat theme directory
for flavor in "${FLAVORS[@]}"; do
    # Find all Cat themes for this flavor that were copied
    find "$ICONS_DIR" -maxdepth 1 -type d -name "Cat-${flavor}-*" | while read theme_path; do
        theme=$(basename "$theme_path")

        # Skip -Dark and -Light versions (they will be processed separately)
        if [[ "$theme" == *-Dark ]] || [[ "$theme" == *-Light ]]; then
            continue
        fi

        echo "Setting up: $theme"

        # Get theme name lowercase for matching files
        theme_lower=$(echo "$theme" | tr '[:upper:]' '[:lower:]' | sed 's/^cat-//')

        # 5. For sizes that need places/ copied
        for size in 22x22 24x24 32x32 48x48 64x64; do
            size_path="$theme_path/$size"

            if [ -d "$ICONS_DIR/Papirus/$size/places" ]; then
                # Create size directory
                $SUDO mkdir -p "$size_path"

                # Copy places/ from Papirus
                echo "  Copying $size/places..."
                $SUDO cp -r "$ICONS_DIR/Papirus/$size/places" "$size_path/"

                # Copy matching files from src/ to places/
                if [ -d "src/$size/places" ]; then
                    find "src/$size/places" -name "*$theme_lower*" -type f | while read file; do
                        filename=$(basename "$file")
                        echo "    Adding: $filename"
                        $SUDO cp "$file" "$size_path/places/"
                    done
                fi

                # Create links to other Papirus subdirectories
                for subdir in "$ICONS_DIR/Papirus/$size"/*/; do
                    subname=$(basename "$subdir")
                    if [ "$subname" != "places" ] && [ -d "$subdir" ]; then
                        $SUDO ln -sf "../../Papirus/$size/$subname" "$size_path/$subname"
                    fi
                done

                # Create @2x link to self (NOT to Papirus)
                $SUDO ln -sf "$size" "$theme_path/${size}@2x"
            fi
        done

        # 6. Create 96x96 and 128x128 directories with special links
        echo "  Creating 96x96 and 128x128 directories..."

        # 96x96
        if [ -d "$ICONS_DIR/Papirus/96x96" ]; then
            $SUDO mkdir -p "$theme_path/96x96"
            # Create link for places to 48x48/places
            $SUDO ln -sf "../48x48/places" "$theme_path/96x96/places"
            # Create links for other subdirectories to Papirus
            for subdir in "$ICONS_DIR/Papirus/96x96"/*/; do
                if [ -d "$subdir" ]; then
                    subname=$(basename "$subdir")
                    if [ "$subname" != "places" ]; then
                        $SUDO ln -sf "../../Papirus/96x96/$subname" "$theme_path/96x96/$subname"
                    fi
                fi
            done
        fi

        # 128x128
        if [ -d "$ICONS_DIR/Papirus/128x128" ]; then
            $SUDO mkdir -p "$theme_path/128x128"
            # Create link for places to 64x64/places
            $SUDO ln -sf "../64x64/places" "$theme_path/128x128/places"
            # Create links for other subdirectories to Papirus
            for subdir in "$ICONS_DIR/Papirus/128x128"/*/; do
                if [ -d "$subdir" ]; then
                    subname=$(basename "$subdir")
                    if [ "$subname" != "places" ]; then
                        $SUDO ln -sf "../../Papirus/128x128/$subname" "$theme_path/128x128/$subname"
                    fi
                fi
            done
        fi

        # 7. Create links for ALL other directories found in Papirus
        echo "  Creating links for other Papirus directories..."

        # Get list of all directories in Papirus
        for item in "$ICONS_DIR/Papirus"/*; do
            if [ -d "$item" ]; then
                item_name=$(basename "$item")

                # Skip if already processed or is Papirus itself
                if [ "$item_name" = "Papirus" ]; then
                    continue
                fi

                # Check if this is a size we already processed
                already_processed=false
                for processed_size in 22x22 24x24 32x32 48x48 64x64 96x96 128x128; do
                    if [ "$item_name" = "$processed_size" ]; then
                        already_processed=true
                        break
                    fi
                done

                if [ "$already_processed" = false ]; then
                    # For regular sizes (8x8, 16x16, etc.) - link to Papirus
                    if [[ "$item_name" =~ ^[0-9]+x[0-9]+$ ]]; then
                        # Create link to Papirus size
                        $SUDO ln -sf "../Papirus/$item_name" "$theme_path/$item_name"

                        # Check if @2x version exists in Papirus
                        if [ -d "$ICONS_DIR/Papirus/${item_name}@2x" ]; then
                            # Link to Papirus @2x version
                            $SUDO ln -sf "../Papirus/${item_name}@2x" "$theme_path/${item_name}@2x"
                        fi
                    # For @2x versions that weren't caught above
                    elif [[ "$item_name" =~ @2x$ ]] && [[ "$item_name" =~ ^[0-9]+x[0-9]+@2x$ ]]; then
                        # Extract base size name (remove @2x)
                        base_size="${item_name%@2x}"
                        # Only create link if base size exists in Papirus and we didn't already process it
                        if [ -d "$ICONS_DIR/Papirus/$base_size" ]; then
                            base_processed=false
                            for processed_size in 22x22 24x24 32x32 48x48 64x64 96x96 128x128; do
                                if [ "$base_size" = "$processed_size" ]; then
                                    base_processed=true
                                    break
                                fi
                            done
                            if [ "$base_processed" = false ]; then
                                $SUDO ln -sf "../Papirus/$item_name" "$theme_path/$item_name"
                            fi
                        fi
                    # For other directories (scalable, symbolic, etc.)
                    else
                        $SUDO ln -sf "../Papirus/$item_name" "$theme_path/$item_name"
                    fi
                fi
            fi
        done

        # 8. Create -Dark and -Light versions
        create_dark_light_version "$theme" "-Dark"
        create_dark_light_version "$theme" "-Light"

        # 9. Apply papirus-folders only to main theme
        papirus_color="cat-${theme_lower}"
        papirus-folders -C "$papirus_color" --theme "$theme" 2>/dev/null || true
    done
done

echo "Done! Catppuccin themes installed in $ICONS_DIR"
