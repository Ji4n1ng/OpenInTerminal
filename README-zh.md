 # OpenInTerminal

一个可以在终端（[`iTerm`](https://www.iterm2.com/) 或 [`Hyper`](https://github.com/zeit/hyper)）中打开当前目录的访达工具栏应用程序。

## 如何使用 🚀

### 1) 在终端中打开当前目录

![run](./screenshots/run.gif)

### 2) 在终端中打开选择的文件夹

![run2](./screenshots/run2.gif)

### 3) 设置默认终端

在第一次运行应用的时候，你需要选择默认终端。

![selector](./screenshots/selector.png)

当你设置了默认终端之后，选择框将不会再出现。如果你想要重新设置默认终端，请在终端中输入以下命令。然后重新运行应用。

```
defaults remove wang.jianing.OpenInTerminal OIT_TerminalBundleIdentifier
```

## 如何安装 🖥

1. 从 [release](https://github.com/Ji4n1ng/OpenInTerminal/releases) 中下载。
2. 将应用移动到 `应用程序` 文件夹.
3. 按住 `Cmd` 键，然后将应用拖到访达工具栏中。
4. 完成。

>  ⚠️ 当您第一次运行应用程序时，macOS 将要求访问 `访达` 和 `终端`（或 `iTerm`）的权限。请给予应用程序权限。

![toolbar](./screenshots/drag_to_toolbar.gif)

### 如果你正在使用深色模式 (Dark Mode)

我在 release 中提供了几个图标。 您可以右键单击该应用程序并选择 `显示简介`。 拖动图标进行更改。

![change_icon](./screenshots/change_icon-zh.gif)
