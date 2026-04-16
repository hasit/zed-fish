; Explicitly use the primary editor foreground color for words.
; This is required for words (e.g., a file path) inside command substitutions
; that are wrapped in double-quoted strings.
(word) @primary

[(double_quote_string) (single_quote_string)] @string
(escape_sequence) @string.escape

(comment) @comment

[(integer) (float)] @number

[
  "not"
  "!"
  "and"
  "or"
  "&&"
  "||"
  (file_redirect)
  (stream_redirect)
] @operator

; Operators that end a command
(pipe ["|" "2>|" "&|"] @keyword)
[";" "&"] @keyword

; Commands
(command name: (word) @function)
(command argument: (word) @constant (#match? @constant "^-."))
(command argument: (concatenation . (word) @constant (#match? @constant "^-.")))

; match operators of test command
(command
  name: (word) @function (#eq? @function "test")
  argument: (word) @constant (#match? @constant "^(-[A-Za-z]+|!?=|!)$"))

; match operators of [ command
(command
  name: (word) @punctuation.bracket (#eq? @punctuation.bracket "[")
  argument: (word) @constant (#match? @constant "^(-[A-Za-z]+|!?=|!)$"))

[(variable_expansion) (list_element_access)] @variable.special

(command_substitution "$" @punctuation.special)

; Brace expansion and globbing.
; Note: (glob) matches "*" but not "?".
["{" "}" "," (home_dir_expansion) (glob)] @operator

; Conditionals
(if_statement ["if" "end"] @keyword)
(switch_statement ["switch" "end"] @keyword)
(case_clause ["case"] @keyword)
(else_clause ["else"] @keyword)
(else_if_clause ["else" "if"] @keyword)

; Loops/Blocks
(while_statement ["while" "end"] @keyword)
(for_statement ["for" "in" "end"] @keyword)
(begin_statement ["begin" "end"] @keyword)

; Functions
(function_definition ["function" "end"] @keyword)
(function_definition option: (word) @constant (#match? @constant "^-."))
(function_definition option: (concatenation . (word) @constant (#match? @constant "^-.")))

; Keywords
[(return) (break) (continue)] @keyword

; Errors
(ERROR) @hint
