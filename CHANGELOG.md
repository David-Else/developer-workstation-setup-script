30th June 2023

- Create `debian12` branch

12th May 2023 v4.1

- Rewrite the README from scratch
- Add Fedora 38 compatibility
- Update scripts to use new repositories, remove binaries, and fix things that have changed
- Update dependencies

29th Jan 2023 v4

- Rewrite install script in Ansible

5th Jan 2022: v3.1

- Archive Neovim and replace with Helix
- Update binaries
- Add tt terminal based typing test
- Improve and tweak config files

10th July 2022: v3.0

- Compatible with RHEL 9 and clones, not backwards compatible with 8
- Everything refactored and improved

13th May 2022: v2.2

- New Neovim 0.7 config re-written in Lua
- New Neovim shortcuts and plugins

31st March 2022: v2.1

- Add [todo.txt](https://github.com/todotxt/todo.txt) file type
- Use new Neovim 0.6.1 EPEL8 version instead of appimage for RHEL8 clones
- Automatically install Neovim plugins before first run
- Fix Neovim giving error without adding dictionary file
- Update Neovim plugins pinned commits
- Update binaries
- Update `nnn` repo to Fedora 35 from 34
- Improve user messages

24th Feb 2022: v2.0

- All software updated
- Massive refactoring. Functions split out into modules and shared among install
  and setup scripts
- New script for installing binaries that also uses `GitHub CLI`
- More integration in the tools. For example, `Delta` diff viewer works for
  `Lazygit` and `fzf.vim`.
- Frozen the Neovim plugins until Neovim 0.7 comes out. They are stable now.
