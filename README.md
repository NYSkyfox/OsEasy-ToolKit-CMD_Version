# OsEasy-ToolKit v1.0

**噢易学生端综合解锁工具** | By NyxFox

---

## 简介

OsEasy-ToolKit 是一个针对噢易（OsEasy）学生端环境编写的批处理脚本，能够一键解锁网络限制、控屏限制、键盘鼠标锁及USB管控，并提供单独的服务/进程管理功能。

本工具基于 [OsEasy-ToolBox](https://github.com/ZiHaoSaMa66/OsEasy-ToolBox) 的 Python 源码逻辑重写为批处理脚本，方便直接在 Windows 环境下执行，无需 Python 运行环境。

---

## 功能一览

| 编号 | 功能 | 说明 |
|:---:|------|------|
| **1** | **一键解锁所有限制** | 同时解锁网络、控屏、键鼠、USB，含10秒倒计时 |
| **2** | **解锁网络限制** | 停止 MMPC / OeNetlimit 服务，终止 Student.exe / DeviceControl_x64.exe |
| **3** | **解锁控屏限制** | 终止 ScreenRender.exe / ScreenRender_Y.exe，重命名备份控屏程序 |
| **4** | **解锁键盘鼠标锁** | 终止 BlackSlient.exe / MultiClient.exe，删除 LockKeyboard.dll / LoadDriver.exe 等驱动文件 |
| **5** | **解锁USB限制** | 停止并删除 easyusbflt 服务 |
| **6** | **服务管理** | 单独停止/启动/重启/删除指定服务（MMPC、OeNetlimit、easyusbflt） |
| **7** | **进程管理** | 单独终止指定进程，或一键终止所有学生端进程，支持持续循环监控 |
| **8** | **挂起/恢复学生端** | 自动检测 Student.exe 状态，运行中则挂起，已挂起则恢复 |
| **9** | **查看运行状态** | 显示服务和进程的运行状态 |
| **0** | **退出程序** | - |

---

## 使用方法

### 运行方式

**双击 `OsEasy-ToolKit.bat`** 即可运行。脚本会自动请求管理员权限（弹出 UAC 对话框），请点击"是"。

### 操作流程

```
1. 双击运行脚本
2. 自动提权 → 显示主菜单
3. 输入数字选择功能（如输入 1 进入一键解锁）
4. 等待倒计时自动执行，或按任意键立即执行
5. 操作完成后按任意键返回主菜单
6. 输入 0 退出程序
```

### 等待机制

| 场景 | 等待时间 | 说明 |
|------|:--------:|------|
| 解锁功能（[1]~[5]） | **10秒** | 可按键跳过 |
| 服务/进程操作 | **5秒** | 可按键跳过 |
| 挂起操作 | **5秒 + 2秒** | 先5秒倒计时，再2秒后最小化执行 |
| 无效输入 | **2秒** | 自动重新显示菜单 |

---

## 技术原理

### 路径自动检测
脚本会自动检测噢易学生端的安装路径（支持 x64 和 x86 两种 Program Files 目录），检测成功后设置 `%OEPATH%` 变量供后续文件操作使用。

### 键盘锁解锁逻辑
严格对齐 Python 源码的 `delLockExeAndLogout` 函数：
1. 终止 `BlackSlient.exe` / `MultiClient.exe` 进程
2. 删除 `LockKeyboard.dll` / `LoadDriver.exe` / `BlackSlient.exe` 等驱动文件
3. 删除 `OeNetLimitSetup.exe` / `OeNetLimit.sys` / `OeNetLimit.inf` 限制文件
4. 删除 `LISSNetInfoSniffer.exe` 嗅探程序

### 挂起/恢复逻辑
通过 PowerShell 检测 `Student.exe` 的线程状态：
- 运行中 → 最小化窗口 → 后台等待 → 执行 `Suspend()` 挂起
- 已挂起 → 直接执行 `Resume()` 恢复

### 进程列表
```
Student.exe, MultiClient.exe, ScreenRender.exe, ScreenRender_Y.exe,
DeviceControl_x64.exe, BlackSlient.exe, OELogSystem.exe, OEUpdate.exe,
OEProtect.exe, ProcessProtect.exe, RunClient.exe, ServerOSS.exe,
wfilesvr.exe, tvnserver.exe, updatefilesvr.exe
```

### 服务列表
| 服务名 | 作用 |
|--------|------|
| MMPC | 学生端根服务 |
| OeNetlimit | 网络限制服务 |
| easyusbflt | USB管控服务 |

---

## 注意事项

### ⚠️ 重要
1. **必须用管理员身份运行**（脚本会自动提权）
2. 适用于噢易学生端 **V10.8.2.4411** 及以上版本
3. **Windows 7 及以上系统**均可运行
4. 学生端可能会自动重启进程，如需保持解锁状态请使用持续监控模式

### ⚠️ 免责声明
本工具仅供**教育研究**和**技术学习**目的，禁止用于任何非法用途。使用者需自行承担所有操作风险。

---

## 相关文件

| 文件 | 说明 |
|------|------|
| `OsEasy-ToolKit.bat` | 主程序 |
| `src/remain.py` | 原Python工具箱核心逻辑 |
| `src/REmainv3.py` | 原Python工具箱UI界面 |
| `src/Fake_SCR.py` | 假ScreenRender拦截程序 |

---
# 有种生物叫小强，他令人难以对付
