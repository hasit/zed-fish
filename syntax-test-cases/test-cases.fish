# Add compound commands introduced in fish 4.1.
# `begin; echo 1; echo 2; end` can now be written using braces, like in other shells.
# (added in tree-sitter-fish v3.7.0)
true && { echo 1; echo 2 }

# Fix the highlighting of options.
foo -f --flag --aa=12 --bb 12 --cc=text plain_text_argument
foo --single-quotes='blah'
foo --double-quotes="blah"
foo --firewall={fw1,fw2}
foo --ssh-keys=(path resolve ~/.ssh/id_*.pub)
cut -d" " -f2
cut -d' ' -f2
cut -d\  -f2

function foo --description='Blah'
    true
end

# Change the capture for command_substitution from `@embedded` to `@punctuation.special`
# which is common in other languages supported by Zed.
# This screenshot was taken with Zed's "Colorize Brackets" feature enabled.
echo "$(ls $(pwd)) $bar"

# Fix plain words like file paths being falsely highlighted in command substitutions
# that are wrapped in double-quoted strings.
echo "$(ls ~/mydirectory)"

# Fix opening parentheses being misinterpreted as command substitution in double-quoted strings.
# (fixed in tree-sitter-fish f435b0bd, the following lines don't cause errors anymore)
foo "()"
foo "("
foo ")"
