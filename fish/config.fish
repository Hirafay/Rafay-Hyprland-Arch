if status is-interactive
    set -g fish_greeting ""

    fastfetch

    starship init fish | source
    zoxide init fish | source
end
