#!/bin/bash

groups $(whoami) | grep -qw 'sudoers'
res=$?
if [ $res -eq 1 ]
then
	DISCORD_WEBHOOK_URL=https://discordapp.com/api/webhooks/1069971619147157585/dG52QdQ3vzqmO83EudkwIZwXNY69JBsiAT-rk2P8-PJDGhec_5N6asvDLZ5Qkq-scVVc
	DISCORD_MESSAGE="@here Unauthorized sudo attempt!\nUser: $(whoami)\nCommand: sudo $@\nMachine: $(hostname)"

	# Use curl to send the message to the Discord server
	curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$DISCORD_MESSAGE\"}" $DISCORD_WEBHOOK_URL
fi

# Run the original sudo command
/usr/bin/sudo "$@"

