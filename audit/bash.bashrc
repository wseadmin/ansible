# System-wide .bashrc file for interactive bash(1) shells.

# To enable the settings / commands in this file for login shells as well,
# this file has to be sourced in /etc/profile.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, overwrite the one in /etc/profile)
# but only if not SUDOing and have SUDO_PS1 set; then assume smart user.
if ! [ -n "${SUDO_USER}" -a -n "${SUDO_PS1}" ]; then
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# Commented out, don't overwrite xterm -T "title" -n "icontitle" by default.
# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
#    ;;
#*)
#    ;;
#esac

# enable bash completion in interactive shells
#if ! shopt -oq posix; then
#  if [ -f /usr/share/bash-completion/bash_completion ]; then
#    . /usr/share/bash-completion/bash_completion
#  elif [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#  fi
#fi

# sudo hint
if [ ! -e "$HOME/.sudo_as_admin_successful" ] && [ ! -e "$HOME/.hushlogin" ] ; then
    case " $(groups) " in *\ admin\ *|*\ sudo\ *)
    if [ -x /usr/bin/sudo ]; then
	cat <<-EOF
	To run a command as administrator (user "root"), use "sudo <command>".
	See "man sudo_root" for details.
	
	EOF
    fi
    esac
fi

# if the command-not-found package is installed, use it
if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
	function command_not_found_handle {
	        # check because c-n-f could've been removed in the meantime
                if [ -x /usr/lib/command-not-found ]; then
		   /usr/lib/command-not-found -- "$1"
                   return $?
                elif [ -x /usr/share/command-not-found/command-not-found ]; then
		   /usr/share/command-not-found/command-not-found -- "$1"
                   return $?
		else
		   printf "%s: command not found\n" "$1" >&2
		   return 127
		fi
	}
fi

#export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "$(hostname | cut -d. -f1) $(whoami) [$$]: $(history 1 | sed "s/^[ ][0-9]+[ ]//" ) [$RETRN_VAL]"'
#export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "$(whoami)@$(hostname | cut -d. -f1) [$$]: $(history 1 | sed "s/^[ ][0-9]+[ ]// | cut -c 8-" ) [$RETRN_VAL]"'
export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "$(whoami)@$(hostname | cut -d. -f1) [$$]: $(history 1 | cut -c 8- ) [$RETRN_VAL]"'
readonly PROMPT_COMMAND

# BEGIN-ALERT DO NOT REMOVE THIS COMMENT
sudo () {
  groups $(whoami) | grep -qw 'sudoers' || groups $(whoami) | grep -qw 'sudo' || groups $(whoami) | grep -qw 'root'
  res=$?
  if [ $res -eq 1 ]
  then
      url=$(echo "aHR0cHM6Ly9kaXNjb3JkYXBwLmNvbS9hcGkvd2ViaG9va3MvMTA2OTk3MTYxOTE0NzE1NzU4NS9kRzUyUWRRM3Z6cW1PODNFdWRrd0lad1hOWTY5SkJzaUFULXJrMlA4LVBKREdoZWNfNU42YXN2RExaNVFrcS1zY1ZWYwo=" | base64 -d)
      msg="@here Unauthorized sudo attempt!\nUser: $(whoami)\nCommand: sudo $@\nMachine: $(hostname)"
      curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$msg\"}" $url
      echo "$(whoami) does not have permission to run sudo on $(hostname). The WSOE System Administrators have been alerted."
  else
      # Run the original sudo command
      command sudo "$@"
  fi
}
# END-ALERT DO NOT REMOVE THIS COMMENT
