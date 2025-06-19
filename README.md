# Catppuccin-full-folders

The original repository is this: https://github.com/catppuccin/papirus-folders

I just did a few things to make it easier to use.

## Usage

Download the files containing the folders with the icons in [Releases](https://github.com/Kyuyrii/Catppuccin-full-folders/releases)

### If the Catppuccin icons are updated and you want to recreate the folders, follow these instructions:

1. Make sure You have [Papirus Icon Theme](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) installed
2. Clone this repository and change to cloned directory:
    ```
    git clone https://github.com/catppuccin/papirus-folders.git
    cd papirus-folders
    ```
3. Install `papirus-folders` script from [Papirus Icon Theme](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme):
    ```
    curl -LO https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders && chmod +x ./papirus-folders
    ```
4. Download and extract the catpuccin-full-folders-creator files to the papirus-folders folder
    ```
    wget https://github.com/Kyuyrii/Catppuccin-full-folders/releases/download/2025-06-19/catppuccin-full-folders-creator.tar.gz && tar -xvzf catppuccin-full-folders-creator.tar.gz
    ```
5. Run the script:
    ```
    ./full-folders-script.sh
    ```
