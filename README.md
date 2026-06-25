# psychonauts2_client
A Psychonauts 2 Archipelago Client
## Setup Instructions

### UE4SS setup
Install UE4SS (experimental release) as described [here](https://docs.ue4ss.com/dev/installation-guide.html)

Once extracted into your game folder, clone this repo into the Mods folder. Add this line to the `mods.txt` file after the last mod name but before the Keybinds line:
```
psychonauts2_client: 1
```
If you named your folder containing this repo something different you can change the above line to match the folder name you chose.

Grab the file `ue4ss\CustomGameConfigs\Psychonauts 2\VtableLayout.ini` and move it to the `ue4ss` folder.

Open `ue4ss\UE4SS-settings.ini`, look for the `[EngineVersionOverride]` section and set `MajorVersion = 4` and `MinorVersion = 26`

Press `F10` in game and in the command line type example: `/conn localhost:38281 Razputin` with your appropriate AP server credentials to connect.