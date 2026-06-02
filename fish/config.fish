# Executa apenas em sessões interativas
if status is-interactive
    fish_add_path $HOME/.local/bin

    # Tmux: sessão persistente "default" (anexa ou cria). Aliases em conf.d/tmux.fish;
    # fish_tmux_autostart fica false de propósito — o autostart é só aqui.
    set -l __term_prog (string lower -- "$TERM_PROGRAM")
    if begin
            not set -q TMUX
            and command -v tmux >/dev/null
            and test -t 0
            and test -z "$VIM"
            and test -z "$NVIM"
            and not contains -- "$__term_prog" vscode zed cursor
            and test -z "$VSCODE_RESOLVING_ENVIRONMENT"
            and test -z "$INTELLIJ_ENVIRONMENT_READER"
            and test "$TERMINAL_EMULATOR" != JetBrains-JediTerm
        end
        exec tmux new-session -As default
    end

    starship init fish | source

    fish_vi_key_bindings

    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_replace underscore
    set fish_cursor_external line
    set fish_cursor_visual block

    alias obs="flatpak run com.obsproject.Studio"
end
