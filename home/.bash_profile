# Note: I need to review this .bash_profile in light of
#       http://rabexc.org/posts/pitfalls-of-ssh-agents

# Note: ~/.ssh/environment should not be used, as it
#       already has a different purpose in SSH.

env=~/.ssh/agent.env

# Note: Don't bother checking SSH_AGENT_PID. It's not used
#       by SSH itself, and it might even be incorrect
#       (for example, when using agent-forwarding over SSH).

agent_is_running() {
    if [ "$SSH_AUTH_SOCK" ]; then
        # ssh-add returns:
        #   0 = agent running, has keys
        #   1 = agent running, no keys
        #   2 = agent not running
        ssh-add -l >/dev/null 2>&1 || [ $? -eq 1 ]
    else
        false
    fi
}

agent_has_keys() {
    ssh-add -l >/dev/null 2>&1
}

agent_load_env() {
    . "$env" >/dev/null
}

agent_start() {
    (umask 077; ssh-agent >"$env")
    . "$env" >/dev/null
}

if ! agent_is_running; then
    agent_load_env
fi

# if your keys are not stored in ~/.ssh/id_rsa.pub or ~/.ssh/id_dsa.pub, you'll need
# to paste the proper path after ssh-add
if ! agent_is_running; then
    agent_start
    ssh-add
elif ! agent_has_keys; then
    ssh-add
fi

unset env

flac_cover() {
    orig_name=$(youtube-dl -o '%(uploader)s - %(playlist_index)s - %(title)s.flac' --get-filename $1)
    echo "Working on $orig_name"
    metaflac --import-picture-from "${orig_name/.flac/.jpg}" "$orig_name"
    rm $orig_name
}

youtube-dl-audio() {
    youtube-dl -f bestaudio --extract-audio --audio-format flac --write-thumbnail --add-metadata -o '%(uploader)s - %(playlist_index)s - %(title)s.%(ext)s' $1
    orig_name=$(youtube-dl -o '%(uploader)s - %(playlist_index)s - %(title)s.flac' --get-filename $1)
    while read -r orig_name; do
        echo "Working on $orig_name"
        thum_name=${orig_name/.flac/.jpg}
        metaflac --import-picture-from "${orig_name/.flac/.jpg}" "$orig_name"
        rm "$thum_name"
    done <<< "$orig_name"
}

# Note: It's cls in CMD and clear in BASH. Let's just make it the same.
alias cls='clear'
alias youtube-dl-thumb="youtube-dl --write-thumbnail --skip-download -o '%(uploader)s - %(playlist_index)s - %(title)s.%(ext)s'"
alias youtube-dl-video="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --add-metadata -o '%(uploader)s - %(title)s.%(ext)s' --merge-output-format mp4"

# alias scons3="/usr/bin/env python3 $(which scons)"

PATH=$PATH:"/c/Users/terryn/AppData/Local/Programs/Microsoft VS Code/"

# Note: Allow git to discovery repositories in different file systems, such as /c/
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

# Note: Add user-specific bin directory to path if exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

source ~/qmk_utils/activate_msys2.sh