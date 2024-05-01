((command
  name: (word) @_command
  .
  argument: (word) @_verb
  argument: (single_quote_string) @content)
  (#eq? @_command "string")
  (#any-of? @_verb "match" "replace")
  (#set! "language" "regex"))

((command
  name: (word) @_command
  argument: (single_quote_string) @content)
  (#any-of? @_command "grep" "egrep" "rg" "sed")
  (#set! "language" "regex"))
