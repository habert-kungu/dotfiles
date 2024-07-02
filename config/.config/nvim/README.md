# starter
Starter config for NvChad

Added a personal touch of my configs 

if you want to use this just follow this steps you'll be done in no time :

Ensure you have the Latest Nvim:
    [https://github.com/neovim/neovim/blob/master/INSTALL.md]
    
1. Backup initial config
   ```bash
    mv ~/.config/nvim{,.bak}
    mv ~/.local/share/nvim{,.bak}
    mv ~/.local/state/nvim{,.bak}
    mv ~/.cache/nvim{,.bak}
   ```
2. Remove the config
   ```bash
     #Linux
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim

    # Windows CMD
    rd -r ~\AppData\Local\nvim
    rd -r ~\AppData\Local\nvim-data

    # Window PowerShell
    rm -Force ~\AppData\Local\nvim
    rm -Force ~\AppData\Local\nvim-data

3. Paste this into you terminal
```bash
git clone https://github.com/habert-kungu/backup.git  ~/.config/nvim
```
4. (Optional) Remove the Git Folder
```bash
    rm -rf ~/.config/nvim/.git
```
5. Start Nvim
```bash
  nvim
```
