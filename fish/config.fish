# Executa apenas em sessões interativas
if status --is-interactive

    # Inicia tmux automaticamente se não estiver dentro de uma sessão tmux
    if not set -q TMUX
        # tenta anexar a sessão 'default', se não existir cria uma nova
        # o comando tmux é executado em segundo plano para que o restante do config.fish seja carregado
        tmux attach -t default 2>/dev/null; or tmux new -s default 2>/dev/null
        # retorna para continuar carregando Starship, vi mode e cursor
    end

    # Ativa Starship como prompt
    eval (starship init fish)

    # Ativa o vi mode
    fish_vi_key_bindings

    # Configura o cursor como no Vim
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_replace underscore
    set fish_cursor_external line
    set fish_cursor_visual block

    # Run obstudio
    alias obs="flatpak run com.obsproject.Studio"

end
fish_add_path $HOME/.local/bin
