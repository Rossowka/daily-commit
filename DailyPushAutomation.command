#!/usr/bin/env bash

SCRIPTS=~/.scripts
LOGFILE=PushLog.txt
SCRIPTFILE=GitPushAutomation.sh
GITREPO="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LOGFILEPATH="$GITREPO/$LOGFILE"
SCRIPTFILEPATH="$SCRIPTS/$SCRIPTFILE"

greetings () {
    printf "\n\nHello $USER, I'm your Git Robot!\n"
}

checkGitInit () {
    cd "$GITREPO"

    if [[ "$GITREPO" == "$(git rev-parse --show-toplevel 2>/dev/null)" ]]; then
        echo "• Found a git repo, alright!"
    else
        echo "$GITREPO"
        echo "You are here: $(pwd)"
        echo "Please move that script to a git repository that you would like to commit to daily."
        exit
    fi
}

checkScriptsFolder () {
    printf "• Checking if ~/.scripts folder exists..."

    if [ -d "$SCRIPTS" ]; then 
        echo "Yes, good!"
    else 
        mkdir "$SCRIPTS"
        echo "Now it does ;)"
    fi
}


createLog () {
    touch "$LOGFILEPATH"
    echo "This file is a push automation for Git!" > "$LOGFILEPATH"
}

createScript () {
    touch "$SCRIPTFILEPATH"
    chmod +x "$SCRIPTFILEPATH"
    cat<<EOF > $SCRIPTFILEPATH 
#!/usr/bin/env bash
cd "$GITREPO"
echo $(date) >> $LOGFILE
git add "$LOGFILE"
git commit -m "Daily commit"
git push
EOF
}

createCronEntry () {
    while : ; do
    printf "Please enter your daily commit time (HH:MM): "
    read TIME
    TIMECOUNT=${#TIME}
    HOUR=${TIME/:??/}
    MINUTE=${TIME/??:/}

    if ((HOUR >= 0 && HOUR < 24 && MINUTE >= 0 && MINUTE < 60 && TIMECOUNT == 5)); then
        crontab -l | { cat; echo "$((MINUTE)) $((HOUR)) * * * bash $SCRIPTFILEPATH"; } | crontab -
        if [[ "$?" == "0" ]]; then
            printf "OK, your daily push is scheduled at %02d:%02d Uhr!\n\n" $HOUR $MINUTE
            printf "You are all set up, $USER. Have a good day and keep coding!\n"
        else 
            echo "Please contact your favorite IT support, he is called Stefan ;P"
        fi
        break
    else
        printf "That's not a valid time! Did you forget the ':'?\n\n"
    fi
    done
}


greetings
checkGitInit
checkScriptsFolder
createLog
createScript
createCronEntry 
