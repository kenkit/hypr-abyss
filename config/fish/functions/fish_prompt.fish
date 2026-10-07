function fish_prompt
    # Color azul/cian para el directorio actual
    set_color cyan
    echo -n (prompt_pwd)

    # Flecha en verde brillante
    set_color green
    echo -n " ❯ "

    # Restaurar color normal para lo que escribes
    set_color normal
end
