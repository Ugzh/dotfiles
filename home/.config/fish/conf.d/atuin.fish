# Load Atuin only in interactive Fish sessions.  Ctrl-R searches history and
# the Up key searches it from the current prompt; inside tmux use a popup.
if status is-interactive
    atuin init fish | source
    set -gx ATUIN_TMUX_POPUP true
    set -gx ATUIN_TMUX_POPUP_WIDTH "90%"
    set -gx ATUIN_TMUX_POPUP_HEIGHT "70%"
end
