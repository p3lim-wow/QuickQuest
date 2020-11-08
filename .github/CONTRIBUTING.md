# How to contribute

## Translations

If you want to help translate this project, please see the files located in the [locale directory](https://github.com/p3lim-wow/QuickQuest/tree/master/locale), these contain the strings for each language supported.

To propose a change, open up any of these files and follow [this guide](https://docs.github.com/en/free-pro-team@latest/github/managing-files-in-a-repository/editing-files-in-another-users-repository) on how to edit them and submitting the change.

All strings (text in quotation marks, e.g. `'words'` or `"words"`) in these files can be modified.

Notes:
- The string on the left side of the `=` sign is the english source, don't touch this
- The string on the right is the translation, this is what you can change
- Lines commented out (starts with `--`) are incomplete/missing
	- remove the comment (`--`) in front of them when translating
- Keep symbols like `%s` or `|r` like they are
	- same goes for colors (e.g. `|cff112233`)
- Do not translate the name of the addon or mentions of `/`-commands.

Don't be afraid of making mistakes, I will review the changes before they're added in :).

## Features / bugs

If you want to add a feature or fix an existing bug, please feel free to [fork](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo) the project and submit a [pull request](https://docs.github.com/en/free-pro-team@latest/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork) with the changes. When suggesting a feature, it's a good idea to first open a [feature request](https://github.com/p3lim-wow/QuickQuest/issues/new/choose) to discuss the feature before committing a lot of time into making it.

Try to keep within the style of the existing code, and test your code well before submitting.
