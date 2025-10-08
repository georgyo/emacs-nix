{ writeShellScriptBin, emacs }:
writeShellScriptBin "e" ''
  export PATH="${emacs}/bin:$PATH"
  COMMAND=(emacsclient)
  if [ -z "$INSIDE_EMACS" ]; then
    COMMAND+=(--alternate-editor= --tty)
  fi
  exec "''${COMMAND[@]}" "''${@}"
''
