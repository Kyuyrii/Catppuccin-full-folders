# Catppuccin-full-folders

<h3 align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/logos/exports/1544x1544_circle.png" width="200" alt="Logo"/><br/>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
	Catppuccin for <a href="https://github.com/PapirusDevelopmentTeam/papirus-icon-theme">Papirus Folders</a>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
</h3>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/papirus-folders/main/assets/folders.png"/>
</p>

## Previews

<details>
<summary>🌻 Latte</summary>
  <img src="https://raw.githubusercontent.com/catppuccin/papirus-folders/main/assets/folders-latte.png"/>
</details>
<details>
<summary>🪴 Frappé</summary>
  <img src="https://raw.githubusercontent.com/catppuccin/papirus-folders/main/assets/folders-frappe.png"/>
</details>
<details>
<summary>🌺 Macchiato</summary>
  <img src="https://raw.githubusercontent.com/catppuccin/papirus-folders/main/assets/folders-macchiato.png"/>
</details>
<details>
<summary>🌿 Mocha</summary>
  <img src="https://raw.githubusercontent.com/catppuccin/papirus-folders/main/assets/folders-mocha.png"/>
</details>

## Usage

#### To generate the folders with papirus-folders, follow these instructions:

1. Clone this repository and change to cloned directory:
    ```
    git clone https://github.com/catppuccin/papirus-folders.git && cd papirus-folders
    ```
2. Install `papirus-folders` script from [Papirus Icon Theme](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme):
    ```
    curl -LO https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders && chmod +x ./papirus-folders
    ```
3. Download the catpuccin-full-folders files to the papirus-folders folder
    ```
    git clone https://github.com/Kyuyrii/Catppuccin-full-folders.git && chmod +x Catppuccin-full-folders/full-folders-script.sh && mv Catppuccin-full-folders/full-folders* .
    ```
4. Run the script choosing the flavor and location of Papirus (If you don't choose anything, it will create all variations and search for Papirus in /usr/share/icons):
    ```
    ./full-folders-script.sh frappe --path $HOME/.local/share/icons/
    ```
    
# If you use Snap apps, install the Snap version of the Papirus icon theme and Catppuccin-Full-Folders:

```
sudo snap install icon-theme-papirus && sudo snap install icon-theme-cat
```

## Important information

This repository is to facilitate the use of the Catppuccin icon theme, I made folders for each available variation, but to generate them, it is necessary to use files from Papirus and Catppuccin repositories.

The original repository is here: https://github.com/catppuccin/papirus-folders
