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

(function_definition name: [(word) (concatenation)] @function)
(command name: (word) @function)

[
 "switch"
 "case"
 "in"
 "begin"
 "function"
 "if"
 "else"
 "end"
 "while"
 "for"
 "return"
 (break)
 (continue)
] @keyword
