import os


def get_color_names(folder_path):
    color_names = []
    for filename in os.listdir(folder_path):
        # Check for both colorset files and folders
        if filename.endswith(".colorset") or os.path.isdir(os.path.join(folder_path, filename)):
            if filename.endswith(".colorset"):
                # Extract color name from subfolder name (assuming format "color_name.colorset")
                color_name = filename.split(".")[0]
                color_names.append(color_name)
            else:
                # Recursively explore subfolders (groups)
                subfolder_path = os.path.join(folder_path, filename)
                subfolder_colors = get_color_names(subfolder_path)
                color_names.extend(subfolder_colors)
    return color_names


def check_xib_for_color(xib_file, custom_colors):
    with open(xib_file, 'r') as f:
        xib_content = f.read()  # Convert content to lowercase for case-insensitive search
    print(f"File: {xib_content}")

    color_counts = {color: 0 for color in custom_colors}  # Initialize counter for each custom color

    # Check for presence of any color-related terms (modify as needed)
    for color in custom_colors:
        if color in xib_content:
            color_counts[color] += xib_content.count(color)  # Count occurrences of each color term

    # Print only if at least one custom color found
    if any(count > 0 for count in color_counts.values()):
        print("  Found custom colors:")
        for color, count in color_counts.items():
            if count > 0:
                print(f"    - '{color}': {count} occurrences")

    return color_counts  # Return the color counts dictionary


# Path to the colors.xcassets folder (replace with yours)
colors_folder = "/Users/thanhnv58it/Desktop/Test Color/Test Color/colors.xcassets"

# Get color names from colors.xcassets
if os.path.isdir(colors_folder):
    custom_colors = get_color_names(colors_folder)
    print("Extracted color names:")
    for name in custom_colors:
        print(name)
else:
    print(f"Error: '{colors_folder}' is not a directory or does not exist.")

# Get the project root directory (replace with your actual path)
project_root = "/Users/thanhnv58it/Desktop/Test Color"

# Total color counts across all files
total_color_counts = {color: 0 for color in custom_colors}

# Iterate through all .xib and .storyboard files in the project
for root, _, files in os.walk(project_root):
    for filename in files:
        if filename.endswith(".xib") or filename.endswith(".storyboard"):
            xib_file = os.path.join(root, filename)
            color_counts = check_xib_for_color(xib_file, custom_colors)
            # Update total counts for each color
            for color, count in color_counts.items():
                total_color_counts[color] += count

print(f"Finished searching for custom colors.")
print(f"Total occurrences of each custom color across all files:")
for color, count in total_color_counts.items():
    print(f"  - '{color}': {count}")
