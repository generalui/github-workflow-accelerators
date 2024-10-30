# Linting and Formatting

## Requirements

- [Markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) `DavidAnson.vscode-markdownlint`

  - Markdownlint must be installed as an extension for local markdown linting to work within VS Code or Cursor on save.
  - Or run in directly using [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2).

    ```sh
    markdownlint-cli2 "**/*.md"
    ```

## Configuration

MarkdownLint uses [`.markdownlint.json`](./.markdownlint.json) to configure the markdown linting rules and
[`.markdownlintignore`](./.markdownlintignore) to ignore linting for specific files and paths.
