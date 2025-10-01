{ writeShellScriptBin, emacs }:
writeShellScriptBin "e" ''
  export PATH="${emacs}/bin:$PATH"

  exec emacsclient -a "" -nw "''${@}"

''
