# !/bin/bash
# Author: Gilles Biagomba
# Program: Git_links.sh
# Description: This script is a fork of Git_Mngr, it goes into every local repo directory\n
#  	       and pulls the URL of the repo then send it to a file.\n
# 	       Theo bjective was to find which ofthe repors  I use were still live/valide.\n

GITPATHTEMP=($(ls -d */ | sort | uniq))
for repo in ${GITPATHTEMP[*]}; do
    cd $PWD/$repo
    CurGitPrj=($(git remote -v | cut -d ":" -f 2 | cut -d " " -f 1))
    PrjSiteStatus=$(curl -o /dev/null -k --silent --get --write-out "%{http_code} https:$CurGitPrj\n" "https:$CurGitPrj" | cut -d " " -f 1)
    PrjDiskStatus=$(echo https:$CurGitPrj | cut -d "/" -f 5)      
    if [ "$PrjSiteStatus" != "404" ] && [ "$PrjDiskStatus" != "$(ls | grep -o "$PrjDiskStatus")" ]; then
        echo "----------------------------------------------------------"
        echo "You are updating this Git repo:"
        echo $repo
        echo "----------------------------------------------------------"
        git remote -v | cut -d ":" -f 2 | cut -d "(" -f 1 | sort | uniq | tee -a ../Git_Links.txt
    elif [ "$PrjSiteStatus" == "404" ]; then
        echo "$(date +%c): The project $PrjDiskStatus (link: https:$CurGitPrj) is no longer exists or has been moved" | tee -a $PWD/Git_Mngr.log
    fi
    cd ..
done
