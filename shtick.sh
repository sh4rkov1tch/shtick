#!/bin/sh

exists() {
	command -v "$1" >/dev/null 2>&1
}

RED='\033[0;31m'
NC='\033[0m'

greet=$(cat << EOF
 ::::::::  :::    ::: ::::::::::: :::::::::::  ::::::::  :::    ::: 
:+:    :+: :+:    :+:     :+:         :+:     :+:    :+: :+:   :+:  
+:+        +:+    +:+     +:+         +:+     +:+        +:+  +:+   
+#++:++#++ +#++:++#++     +#+         +#+     +#+        +#++:++    
       +#+ +#+    +#+     +#+         +#+     +#+        +#+  +#+   
#+#    #+# #+#    #+#     #+#         #+#     #+#    #+# #+#   #+#  
 ########  ###    ###     ###     ###########  ########  ###    ### 
EOF
)

echo -e $RED
echo "$greet"
echo "		    TikTok video downloader"
echo -e $NC

check_dep=( $(exists jq) + $(exists curl) )

if [[ -z $check_dep ]]; then
	echo "Please install jq and curl, these are the only dependencies required for shtick to function properly."
	exit
fi

if [[ -z $1 ]]; then
	echo "USAGE: $0 [URL] (PATH)"
	exit
fi

path="$(pwd)"

if [[ -n $2 ]]; then
	path=$2
fi

useragent='com.ss.android.ugc.trill/494+Mozilla/5.0+(Linux;+Android+12;+2112123G+Build/SKQ1.211006.001;+wv)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Version/4.0+Chrome/107.0.5304.105+Mobile+Safari/537.36'

id="None"
tiktok_url=$1
if [[ $tiktok_url =~ (vm.tiktok.com) ]]; then
	tiktok_url=$(curl -s -i https://vm.tiktok.com/ZMFUsh1et -L | grep 'Location: ' | cut -d' ' -f2)
fi

if [[ $tiktok_url =~ (tiktok.com) && $tiktok_url =~ [0-9]{19} ]]; then
	id=${BASH_REMATCH[*]}
fi

if [[ $id -eq "None" ]]; then
	echo "Error: Invalid Link"
	exit
fi

url="https://api.tiktokv.com/aweme/v1/feed/?aweme_id=$id&iid=6165993682518218889&device_id=$(shuf -i $(( 10**3 ))-$((9*10**10)) -n1 )&aid=1180"

json=$(curl -s -H "User-Agent: $useragent" $url > /dev/null) 

video_url=$(echo $json | jq -r .aweme_list[0].video.play_addr.url_list[0])

complete_path="$path/[shtick]_$id.mp4"

curl -s "$video_url" --output $complete_path > /dev/null
echo "Download complete @ $complete_path"
