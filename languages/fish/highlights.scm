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
  "|"
  "&"
  (direction)
  (stream_redirect)
] @operator

; match operators of test command
(command
  name: (word) @function (#match? @function "^test$")
  argument: (word) @operator (#match? @operator "^(!?=|-[a-zA-Z]+)$"))

; match operators of [ command
(command
  name: (word) @punctuation.bracket (#match? @punctuation.bracket "^\\[$")
  argument: (word) @operator (#match? @operator "^(!?=|-[a-zA-Z]+)$"))

[(variable_expansion) (list_element_access)] @constant

(command_substitution ["$" "(" ")"]) @punctuation.bracket

; Brace expansion and globbing.
; Note: (glob) matches "*" but not "?". It's in the grammar and we can't
; query it differently.
["{" "}" "," (home_dir_expansion) (glob)] @operator

; Conditionals
(if_statement ["if" "end"] @keyword)
(switch_statement ["switch" "end"] @keyword)
(case_clause ["case"] @keyword)
(else_clause ["else"] @keyword)
(else_if_clause ["else" "if"] @keyword)

; Loops/Blocks
(while_statement ["while" "end"] @keyword)
(for_statement ["for" "end"] @keyword)
(begin_statement ["begin" "end"] @keyword)

; Functions
(function_definition ["function" "end"] @keyword)

; Keywords
[
 "in"
 ";"
 "return"
 (break)
 (continue)
] @keyword

; Treat "&" as a background operator only if it's preceded by a command.
; Note that an expression like `echo _&_` contains a background operator
; prior to fish 3.5 and that's how it's handled here.
((command) "&" @keyword)
