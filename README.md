# macOS dotfiles

这是一套基于 chezmoi 的 macOS 配置，用来恢复 shell、应用配置、Homebrew 软件、Mac App Store 软件和常用系统偏好。

仓库根目录通过 `.chezmoiroot` 指向 `home/`，所以主要源文件都在 `home/` 下。机器专属配置放在本机的 `~/.config/chezmoi/chezmoi.toml`，仓库里只保存通用配置和安装清单。

## 目录说明

- `setup.sh`：新机入口脚本，安装 Homebrew 和 chezmoi，生成本机 `chezmoi.toml`，然后执行 `chezmoi init --apply SakuraToErii`。
- `backup.sh`：把当前机器上的偏好和配置备份到 iCloud。
- `home/.chezmoidata/packages.yml`：Homebrew taps、formulae、casks 清单。
- `home/.chezmoidata/mas.yml`：Mac App Store 应用清单。
- `home/run_onchange_01-mac-brew-install.sh.tmpl`：安装 Homebrew 软件。
- `home/run_onchange_02-mac-mas-install.sh.tmpl`：安装 Mac App Store 软件。
- `home/run_once_after_99-setup.sh.tmpl`：首次新机初始化，恢复偏好并写入 macOS defaults。

## Profile

安装清单按 profile 分组，默认每台机器都会启用 `base`。

- `base`：所有 Mac 共用的基础环境，包含 CLI 工具、shell 工具、浏览器、终端、字体、Miniforge、OrbStack、CC Switch 等。
- `work`：文字办公、论文、会议和资料管理，包含 Office、Zotero、Obsidian、Xournal++、Deskflow 等。
- `dev`：开发或实验环境，包含 MuJoCo、Zulu 21 等。

本机 profile 写在：

```toml
[data]
packageProfiles = ["base", "work", "dev"]
runInitialSetup = false
```

文件位置：

```text
~/.config/chezmoi/chezmoi.toml
```

`runInitialSetup` 控制是否运行首次初始化脚本。新机 setup 会写成 `true`，首次初始化脚本跑完后会改回 `false`。

## 新机配置顺序

1. 登录 Apple ID，打开 iCloud Drive，等待 iCloud 目录可用。
2. 安装 Xcode Command Line Tools：

```bash
xcode-select --install
```

3. 下载或复制本仓库的 `setup.sh`，运行：

```bash
bash setup.sh
```

4. 根据提示选择 profile：

```text
base：自动启用
work：办公和写作机器启用
dev：开发机器启用
```

5. setup 会生成：

```text
~/.config/chezmoi/chezmoi.toml
```

内容类似：

```toml
[data]
packageProfiles = ["base", "work", "dev"]
runInitialSetup = true
```

6. 按提示先登录 Mac App Store，然后回到终端按 Enter。
7. chezmoi 开始执行脚本，顺序是：

```text
01-mac-brew-install.sh
02-mac-mas-install.sh
99-setup.sh
```

8. `99-setup.sh` 执行完后会把 `runInitialSetup` 改成 `false`。
9. 重启或注销再登录，让系统偏好、键盘、触控板、Dock、菜单栏和 shell 环境完全生效。

## 脚本执行逻辑

`run_onchange_01-mac-brew-install.sh.tmpl` 会把 `packages.yml` 渲染成临时 Brewfile，并执行：

```bash
brew bundle --file=/dev/stdin --quiet
```

`run_onchange_02-mac-mas-install.sh.tmpl` 会读取 `mas.yml`，先用 `mas list` 检查已安装应用，再逐个安装缺失的 App Store 应用。

`run_once_after_99-setup.sh.tmpl` 只在 `runInitialSetup = true` 时渲染为实际脚本。它会：

- 恢复 iCloud 备份里的应用偏好。
- 写入语言、地区、键盘、触控板、Dock、Finder、软件更新等 macOS defaults。
- 用 `dockutil` 重建 Dock 固定项目。
- 重启 SystemUIServer、Dock、NotificationCenter、ControlCenter。
- 将 `runInitialSetup` 改回 `false`。

## 备份

当前备份目录：

```text
~/Library/Mobile Documents/com~apple~CloudDocs/Backup
```

应用偏好备份目录：

```text
~/Library/Mobile Documents/com~apple~CloudDocs/Backup/AppPreferences
```

备份脚本会导出常用应用的 plist。新机初始化脚本会从这里恢复已存在的备份文件，缺失文件只提示并跳过。

## 注意事项

- `setup.sh` 只给新机使用。日常机器运行 `chezmoi apply` 前，确认 `runInitialSetup = false`。
- Mac App Store 安装依赖已登录的 Apple ID。脚本会在 setup 阶段提醒先登录 App Store。
- `TencentMeeting` 的 MAS ID 在当前 US storefront 下可能查不到，换区或 Apple ID 地区不同会影响安装。
- `mactex-no-gui` 很大，首次安装耗时较长。
- `orbstack` 安装后需要打开 App 完成初始化。
- `miniforge` 通过 Homebrew cask 安装，路径是 `/opt/homebrew/Caskroom/miniforge/base`。
- Dock 固定项目由 `dockutil` 设置，当前会设置为 Apps、Downloads 和 Applications。
- `runInitialSetup` 必须保持在 `chezmoi.toml` 最后一行，`99-setup.sh` 会用最后一行替换的方式把它改回 `false`。

## 常用命令

查看将要执行的内容：

```bash
chezmoi apply --dry-run --verbose
```

只看脚本：

```bash
chezmoi apply --dry-run --verbose --include scripts
```

应用配置：

```bash
chezmoi apply
```

查看模板数据：

```bash
chezmoi data
```

手动检查 Homebrew 清单：

```bash
chezmoi execute-template < home/run_onchange_01-mac-brew-install.sh.tmpl
```
