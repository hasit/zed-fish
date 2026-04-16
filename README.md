# zed-fish

Fish language support in Zed

## Releasing

This repository publishes GitHub releases automatically when the version in
`extension.toml` changes on `main`.

1. Update the `version` field in `extension.toml`.
2. Merge the version bump to `main`.
3. GitHub Actions creates the matching `v<version>` tag and a GitHub Release.

You can also run the workflow manually from the Actions tab to create a release
for the current version when the tag does not exist yet.

If you need to do the same thing manually, run:

```sh
version="$(sed -nE 's/^version = "([^"]+)"$/\1/p' extension.toml | head -n1)"
git tag "v$version"
git push origin "v$version"
gh release create "v$version" --generate-notes
```

This only creates the GitHub tag and release for this repository. To publish the
updated extension in Zed's extension registry, you still need to open or update
the matching PR in `zed-industries/extensions`.

## Credits

- [vscode-fish](https://github.com/bmalehorn/vscode-fish)
- [tree-sitter-fish](https://github.com/ram02z/tree-sitter-fish)
