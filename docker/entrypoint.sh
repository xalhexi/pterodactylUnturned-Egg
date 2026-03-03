#!/bin/bash
sleep 2

cd /home/container

cp /.pteroignore /home/container/.pteroignore

if [ "${GAME_AUTOUPDATE}" == "1" ]; then
    ./steam/steamcmd.sh +@sSteamCmdForcePlatformBitness 64 +login anonymous +force_install_dir /home/container +app_update 1110390 +quit
fi

if [ "${PTERODACTYL_UNTURNED_AUTO_UPDATE}" == "1" ]; then
    curl -L -s -o PterodactylUnturned.zip https://github.com/RestoreMonarchy/PterodactylUnturned/releases/latest/download/PterodactylUnturned.zip
    unzip -o -q PterodactylUnturned.zip -d Modules && rm PterodactylUnturned.zip
fi

if [ "${FRAMEWORK}" == "vanilla" ]; then
    if [ -d "Modules/Rocket.Unturned" ]; then
        rm -rf Modules/Rocket.Unturned
        echo "Rocket.Unturned has been removed from modules because Vanilla is selected as the framework."
    fi
fi

if [ "${FRAMEWORK}" == "rocket" ]; then
    if [ "${FRAMEWORK_AUTOUPDATE}" == "1" ] || [ ! -d "Modules/Rocket.Unturned" ]; then
        cp -r Extras/Rocket.Unturned Modules/
    fi
fi

mkdir -p .steam/sdk64
cp -f steam/linux64/steamclient.so .steam/sdk64/steamclient.so

mkdir -p Unturned_Headless_Data/Plugins/x86_64
cp -f steam/linux64/steamclient.so Unturned_Headless_Data/Plugins/x86_64/steamclient.so

# Create steam_appid.txt file if it doesn't exist with content: 304930
if [ ! -f steam_appid.txt ]; then
    echo "304930" > steam_appid.txt
fi

ulimit -n 2048
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/Unturned_Headless_Data/Plugins/x86_64/

MODIFIED_STARTUP=$(eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g'))
echo ":/home/container$ ${MODIFIED_STARTUP}"

${MODIFIED_STARTUP}