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


;; Work around two issues in the compiled grammar.

; (1)
; Issue: the leading file descriptor in a redirection is missing.
; Expample: redirect stderr with 2> and the "2" won't get matched.
; Workaround: within a command, locate the last integer node preceding the
; redirect and mark that as @operator.
(command
    name: (concatenation _+ (integer) @operator .)
    redirect: _)

; (2)
; Issue: commands are not split into the fields (name) (arguments) (comment).
;
; The whole expression is wrapped in the field (name) which in turn consists
; either of one (word) or a (concatenation).
;
; The grammar doesn't mark trailing comments and we have to look for "#" and
; assign all following nodes ourselves. Parentheses within trailing commands
; are problematic as they start a command substitution and can't be matched
; by the wildcard node. Sigh.
;
; Workaround: use four rules to do the splitting:
; 1. capture commands with no arguments (word)
; 2. capture commands with arguments (concatenation)
; 3. capture command options (arguments starting with "-")
; 4. capture trailing comments (can't catch everything)

(command name: [
    ((word) @function)
    (concatenation . (word) @function)
    (concatenation (word) @constant (#match? @constant "^-"))
    (concatenation ("#" @comment _* @comment))
])

(function_definition name: [
    ((word) @function)
    (concatenation . (word) @function)
    (concatenation (word) @constant (#match? @constant "^-"))
    (concatenation ("#" @comment _* @comment))
])


;; Error
(ERROR) @hint
