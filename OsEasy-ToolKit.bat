@echo off
chcp 65001 >nul
title OsEasy-ToolKit v1.0
color 0A
cls

echo ============================================
echo       OsEasy-ToolKit v1.0
echo             By NyxFox
echo ============================================
echo.
echo  本工具用于解锁噢易学生端的各类限制
echo ============================================
echo.

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] 检测到未以管理员身份运行
    echo.
    echo 正在自动请求管理员权限...
    timeout /t 2 /nobreak >nul
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

echo [√] 管理员权限检查通过
echo.

:main_menu
cls
echo ============================================
echo           主菜单
echo ============================================
echo.
echo  [1] 一键解锁所有限制（推荐）
echo      └─ 同时解锁网络、控屏、键鼠、USB
echo.
echo  [2] 单独解锁网络限制
echo      └─ 停止网络服务 + 终止网络相关进程
echo.
echo  [3] 单独解锁控屏限制
echo      └─ 终止屏幕广播进程 + 删除控屏程序
echo.
echo  [4] 单独解锁键盘鼠标锁
echo      └─ 删除键盘锁驱动 + 终止相关进程
echo.
echo  [5] 单独解锁USB限制
echo      └─ 删除USB管控服务 + 解锁USB设备
echo.
echo  [6] 服务管理（单独停止服务）
echo      └─ 选择并停止指定服务
echo.
echo  [7] 进程管理（单独终止进程）
echo      └─ 选择并终止指定进程
echo.
echo  [8] 挂起/恢复学生端进程
echo      └─ 暂停或恢复 Student.exe 运行
echo.
echo  [9] 查看当前运行状态
echo      └─ 显示学生端相关服务和进程
echo.
echo  [0] 退出程序
echo.
echo ============================================
set /p choice="请输入选项 (0-9): "

if "%choice%"=="1" goto unlock_all
if "%choice%"=="2" goto unlock_network
if "%choice%"=="3" goto unlock_screen
if "%choice%"=="4" goto unlock_keyboard
if "%choice%"=="5" goto unlock_usb
if "%choice%"=="6" goto service_manager
if "%choice%"=="7" goto process_manager
if "%choice%"=="8" goto suspend_student
if "%choice%"=="9" goto show_status
if "%choice%"=="0" goto exit_program

echo [错误] 无效选项，请重新输入！
timeout /t 2 /nobreak >nul
goto main_menu

:: ============================================
:: 一键解锁所有限制
:: ============================================
:unlock_all
cls
echo ============================================
echo       一键解锁所有限制
echo ============================================
echo.
echo 即将执行以下操作：
echo  1. 停止网络限制服务
echo  2. 终止屏幕广播进程
echo  3. 删除键盘锁驱动
echo  4. 解锁USB限制
echo  5. 清理所有相关进程
echo.
echo 10秒后自动开始执行，按任意键立即开始...
timeout /t 10 /nobreak >nul

echo.
echo [1/5] 正在解锁网络限制...
call :do_unlock_network
echo [√] 网络限制解锁完成
echo.

echo [2/5] 正在解锁控屏限制...
call :kill_screen_processes
echo [√] 控屏限制解锁完成
echo.

echo [3/5] 正在解锁键盘鼠标锁...
call :remove_keyboard_lock
echo [√] 键盘鼠标锁解锁完成
echo.

echo [4/5] 正在解锁USB限制...
call :unlock_usb_devices
echo [√] USB限制解锁完成
echo.

echo [5/5] 正在清理残留进程...
call :kill_all_student_processes
echo [√] 进程清理完成
echo.

echo ============================================
echo       [√] 所有限制已解锁！
echo ============================================
echo.
echo 提示：
echo - 网络限制已解除，可以正常上网
echo - 控屏程序已终止，不会被远程控制
echo - 键盘鼠标锁已删除，输入设备已恢复
echo - USB限制已解除，可以正常使用U盘
echo.
echo 注意：学生端可能会自动重启，如需保持解锁状态，
echo       请使用"进程管理"功能持续监控。
echo.
pause
goto main_menu

:: ============================================
:: 单独解锁网络限制
:: ============================================
:unlock_network
cls
echo ============================================
echo       解锁网络限制
echo ============================================
echo.
echo 10秒后自动开始执行，按任意键立即开始...
timeout /t 10 /nobreak >nul
call :do_unlock_network
echo.
echo ============================================
echo       [√] 网络限制已解锁！
echo ============================================
echo.
pause
goto main_menu

:: ============================================
:: 单独解锁控屏限制
:: ============================================
:unlock_screen
cls
echo ============================================
echo       解锁控屏限制
echo ============================================
echo.
echo 10秒后自动开始执行，按任意键立即开始...
timeout /t 10 /nobreak >nul

echo [步骤 1/2] 正在终止屏幕广播进程...
call :kill_screen_processes
echo [√] 屏幕广播进程已终止
echo.

echo [步骤 2/2] 正在删除控屏锁定程序...
:: 自动检测噢易安装路径
if not defined OEPATH (
    if exist "C:\Program Files (x86)\Os-Easy\os-easy multicast teaching system" (
        set "OEPATH=C:\Program Files (x86)\Os-Easy\os-easy multicast teaching system"
    ) else if exist "C:\Program Files\Os-Easy\os-easy multicast teaching system" (
        set "OEPATH=C:\Program Files\Os-Easy\os-easy multicast teaching system"
    )
)
if defined OEPATH (
    echo   └─ 删除 ScreenRender.exe...
    if exist "%OEPATH%\ScreenRender.exe" (
        taskkill /f /im ScreenRender.exe >nul 2>&1
        rename "%OEPATH%\ScreenRender.exe" "ScreenRender.exe.bak" >nul 2>&1
    echo   └─ [√] ScreenRender.exe 已重命名备份
    ) else (
        echo   └─ [!] 未找到 ScreenRender.exe
    )
) else (
    echo   └─ [!] 未找到噢易安装目录，跳过
)
echo [√] 控屏锁定程序已处理
echo.

echo ============================================
echo       [√] 控屏限制已解锁！
echo ============================================
echo.
pause
goto main_menu

:: ============================================
:: 单独解锁键盘鼠标锁
:: ============================================
:unlock_keyboard
cls
echo ============================================
echo       解锁键盘鼠标锁
echo ============================================
echo.
echo 10秒后自动开始执行，按任意键立即开始...
timeout /t 10 /nobreak >nul

echo [步骤 1/2] 正在终止键鼠控制进程并删除驱动文件...
call :remove_keyboard_lock
echo [√] 键鼠控制进程及驱动文件已处理
echo.

echo [步骤 2/2] 正在删除网络限制相关文件...
if defined OEPATH (
    echo   └─ 删除 OeNetLimit 文件...
    del /F /Q "%OEPATH%\OeNetLimitSetup.exe" >nul 2>&1
    del /F /Q "%OEPATH%\OeNetLimit.sys" >nul 2>&1
    del /F /Q "%OEPATH%\OeNetLimit.inf" >nul 2>&1
    echo [√] 网络限制相关文件已删除
) else (
    echo   └─ [!] 未找到噢易安装目录，跳过
)
echo.

echo ============================================
echo       [√] 键盘鼠标锁已解锁！
echo ============================================
echo.
pause
goto main_menu

:: ============================================
:: 单独解锁USB限制
:: ============================================
:unlock_usb
cls
echo ============================================
echo       解锁USB限制
echo ============================================
echo.
echo 10秒后自动开始执行，按任意键立即开始...
timeout /t 10 /nobreak >nul

echo [步骤 1/2] 正在删除USB管控服务...
echo   └─ 停止 easyusbflt 服务...
sc stop easyusbflt >nul 2>&1
echo   └─ 删除 easyusbflt 服务...
sc delete easyusbflt >nul 2>&1
echo [√] USB管控服务已删除
echo.

echo [步骤 2/2] 正在解锁USB设备...
echo [√] USB设备已解锁
echo.

echo ============================================
echo       [√] USB限制已解锁！
echo ============================================
echo.
pause
goto main_menu

:: ============================================
:: 服务管理
:: ============================================
:service_manager
cls
echo ============================================
echo           服务管理
echo ============================================
echo.
echo 请选择要操作的服务：
echo.
echo  [1] MMPC          - 学生端根服务
echo  [2] OeNetlimit    - 网络限制服务
echo  [3] easyusbflt    - USB管控服务
echo.
echo  [4] 停止所有服务
echo  [5] 返回主菜单
echo  [0] 退出程序
echo.
echo ============================================
set /p svc_choice="请输入选项 (0-5): "

if "%svc_choice%"=="1" call :manage_service "MMPC"
if "%svc_choice%"=="2" call :manage_service "OeNetlimit"
if "%svc_choice%"=="3" call :manage_service "easyusbflt"
if "%svc_choice%"=="4" call :stop_all_services
if "%svc_choice%"=="5" goto main_menu
if "%svc_choice%"=="0" goto exit_program

echo [错误] 无效选项！
timeout /t 2 /nobreak >nul
goto service_manager

:: ============================================
:: 进程管理
:: ============================================
:process_manager
cls
echo ============================================
echo           进程管理
echo ============================================
echo.
echo 请选择要操作的进程：
echo.
echo  [1] MultiClient.exe       - 学生端主进程
echo  [2] ScreenRender.exe      - 屏幕广播进程
echo  [3] ScreenRender_Y.exe    - 屏幕广播辅助
echo  [4] DeviceControl_x64.exe - 设备控制进程
echo  [5] BlackSlient.exe       - 黑屏安静进程
echo  [6] Student.exe           - 学生端主程序
echo  [7] OEProtect.exe         - 保护进程
echo  [8] ProcessProtect.exe    - 进程保护
echo  [9] RunClient.exe         - 运行客户端
echo.
echo  [10] 终止所有学生端进程
echo  [11] 持续监控模式（循环终止）
echo  [12] 返回主菜单
echo  [0]  退出程序
echo.
echo ============================================
set /p proc_choice="请输入选项 (0-12): "

if "%proc_choice%"=="1" call :kill_process "MultiClient.exe"
if "%proc_choice%"=="2" call :kill_process "ScreenRender.exe"
if "%proc_choice%"=="3" call :kill_process "ScreenRender_Y.exe"
if "%proc_choice%"=="4" call :kill_process "DeviceControl_x64.exe"
if "%proc_choice%"=="5" call :kill_process "BlackSlient.exe"
if "%proc_choice%"=="6" call :kill_process "Student.exe"
if "%proc_choice%"=="7" call :kill_process "OEProtect.exe"
if "%proc_choice%"=="8" call :kill_process "ProcessProtect.exe"
if "%proc_choice%"=="9" call :kill_process "RunClient.exe"
if "%proc_choice%"=="10" call :kill_all_wrapper
if "%proc_choice%"=="11" goto monitor_mode
if "%proc_choice%"=="12" goto main_menu
if "%proc_choice%"=="0" goto exit_program

echo [错误] 无效选项！
timeout /t 2 /nobreak >nul
goto process_manager

:: ============================================
:: 持续监控模式
:: ============================================
:monitor_mode
cls
echo ============================================
echo       持续监控模式
echo ============================================
echo.
echo 正在进入循环监控模式...
echo 按 Ctrl+C 可退出循环
echo.
echo 监控以下进程：
echo - MultiClient.exe
echo - ScreenRender.exe
echo - DeviceControl_x64.exe
echo - Student.exe
echo.
pause

:monitor_loop
cls
echo [%time%] 正在监控进程状态...
taskkill /f /im Student.exe >nul 2>&1
taskkill /f /im MultiClient.exe >nul 2>&1
taskkill /f /im ScreenRender.exe >nul 2>&1
taskkill /f /im DeviceControl_x64.exe >nul 2>&1
timeout /t 2 /nobreak >nul
goto monitor_loop

:: ============================================
:: 查看当前状态
:: ============================================
:show_status
cls
echo ============================================
echo       当前运行状态
echo ============================================
echo.

echo [服务状态]
echo --------------------------------------------
call :check_service "MMPC"
call :check_service "OeNetlimit"
call :check_service "easyusbflt"
echo.

echo [进程状态]
echo --------------------------------------------
call :check_process "Student.exe"
call :check_process "MultiClient.exe"
call :check_process "ScreenRender.exe"
call :check_process "ScreenRender_Y.exe"
call :check_process "DeviceControl_x64.exe"
call :check_process "BlackSlient.exe"
call :check_process "OEProtect.exe"
call :check_process "ProcessProtect.exe"
call :check_process "RunClient.exe"
echo.

echo ============================================
echo 说明：[运行中] 表示服务/进程正在运行
echo       [未运行] 表示服务/进程已停止
echo ============================================
echo.
pause
goto main_menu

:: ============================================
:: 挂起/恢复学生端进程
:: ============================================
:suspend_student
cls
echo ============================================
echo       挂起/恢复学生端进程
echo ============================================
echo.

:: 先检测状态，决定操作类型
powershell -WindowStyle Hidden -Command "
$proc = Get-Process Student -ErrorAction SilentlyContinue;
if (-not $proc) {
    exit 2;
}

$isSuspended = $false;
foreach ($thread in $proc.Threads) {
    if ($thread.ThreadState -eq 'Wait' -and $thread.WaitReason -eq 'Suspended') {
        $isSuspended = $true;
        break;
    }
}

if ($isSuspended) {
    # 已挂起，执行恢复
    $proc | ForEach-Object { $_.Resume() };
    exit 0;
} else {
    # 运行中，需要挂起，返回特殊代码
    exit 1;
}"

set "ps_result=%errorlevel%"

if %ps_result% equ 2 (
    echo.
    echo [!] Student.exe 未在运行
    pause
    goto main_menu
)

if %ps_result% equ 0 (
    echo [*] Student.exe 当前已挂起，正在恢复...
    echo [√] Student.exe 已恢复运行
    echo.
    echo ============================================
    echo       操作完成！
    echo ============================================
    echo.
    pause
    goto main_menu
)

echo [*] 5秒后自动执行，按任意键立即执行...
timeout /t 5 /nobreak >nul

echo [*] 窗口将在2秒后最小化并执行挂起
timeout /t 2 /nobreak >nul

:: 最小化当前窗口
powershell -WindowStyle Hidden -Command "Add-Type @'
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport(\"user32.dll\")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
}
'@;
$hwnd = (Get-Process -Id $PID).MainWindowHandle;
[WinAPI]::ShowWindowAsync($hwnd, 2);
"

echo [*] 正在后台执行挂起...
timeout /t 2 /nobreak >nul

:: 执行挂起
powershell -WindowStyle Hidden -Command "
$proc = Get-Process Student -ErrorAction SilentlyContinue;
if ($proc) {
    $proc | ForEach-Object { $_.Suspend() };
}
"

echo [√] Student.exe 已挂起
echo [*] 正在恢复窗口...

:: 恢复窗口
powershell -WindowStyle Hidden -Command "
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport(\"user32.dll\")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport(\"user32.dll\")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
'@;
$hwnd = (Get-Process -Id $PID).MainWindowHandle;
[WinAPI]::ShowWindowAsync($hwnd, 1);
[WinAPI]::SetForegroundWindow($hwnd);
"

echo.
echo ============================================
echo       操作完成！
echo ============================================
echo.
pause
goto main_menu

:: ============================================
:: 退出程序
:: ============================================
:exit_program
cls
echo ============================================
echo       感谢使用 OsEasy-ToolKit
echo ============================================
echo.
echo 提示：如需恢复学生端，请手动重启相关服务。
echo.
timeout /t 3 /nobreak >nul
exit

:: ============================================
:: 子程序：停止网络服务
:: ============================================
:do_unlock_network
echo   └─ 停止 MMPC 服务...
sc stop MMPC >nul 2>&1
echo   └─ 停止 OeNetlimit 服务...
sc stop OeNetlimit >nul 2>&1
echo   └─ 终止 Student.exe...
taskkill /f /im Student.exe >nul 2>&1
echo   └─ 终止 DeviceControl_x64.exe...
taskkill /f /im DeviceControl_x64.exe >nul 2>&1
goto :eof

:: ============================================
:: 子程序：终止屏幕广播进程
:: ============================================
:kill_screen_processes
echo   └─ 终止 ScreenRender.exe...
taskkill /f /im ScreenRender.exe >nul 2>&1
echo   └─ 终止 ScreenRender_Y.exe...
taskkill /f /im ScreenRender_Y.exe >nul 2>&1
goto :eof

:: ============================================
:: 子程序：删除键盘锁（Python原逻辑）
:: ============================================
:remove_keyboard_lock
:: 先确定噢易安装路径
if not defined OEPATH (
    if exist "C:\Program Files (x86)\Os-Easy\os-easy multicast teaching system" (
        set "OEPATH=C:\Program Files (x86)\Os-Easy\os-easy multicast teaching system"
    ) else if exist "C:\Program Files\Os-Easy\os-easy multicast teaching system" (
        set "OEPATH=C:\Program Files\Os-Easy\os-easy multicast teaching system"
    )
)
echo   └─ 终止 BlackSlient.exe...
taskkill /f /im BlackSlient.exe >nul 2>&1
echo   └─ 终止 MultiClient.exe...
taskkill /f /im MultiClient.exe >nul 2>&1
if defined OEPATH (
    echo   └─ 删除键盘锁驱动文件...
    del /F /Q "%OEPATH%\LockKeyboard.dll" >nul 2>&1
    del /F /Q "%OEPATH%\LoadDriver.exe" >nul 2>&1
    del /F /Q "%OEPATH%\BlackSlient.exe" >nul 2>&1
    echo   └─ 删除 LISSNetInfoSniffer.exe...
    del /F /Q "%OEPATH%\x86\LISSNetInfoSniffer.exe" >nul 2>&1
) else (
    echo   └─ [!] 未找到噢易安装目录，跳过文件删除
)
goto :eof

:: ============================================
:: 子程序：解锁USB
:: ============================================
:unlock_usb_devices
echo   └─ 停止 easyusbflt 服务...
sc stop easyusbflt >nul 2>&1
echo   └─ 删除 easyusbflt 服务...
sc delete easyusbflt >nul 2>&1
goto :eof

:: ============================================
:: 子程序：终止所有学生端进程
:: ============================================
:kill_all_student_processes
set "PROCESS_LIST=Student.exe MultiClient.exe ScreenRender.exe ScreenRender_Y.exe DeviceControl_x64.exe BlackSlient.exe OELogSystem.exe OEUpdate.exe OEProtect.exe ProcessProtect.exe RunClient.exe ServerOSS.exe wfilesvr.exe tvnserver.exe updatefilesvr.exe"
for %%p in (%PROCESS_LIST%) do (
    taskkill /f /im "%%p" >nul 2>&1
)
goto :eof

:: 进程管理中调用-带5秒等待：
:kill_all_wrapper
echo 5秒后自动执行，按任意键立即执行...
timeout /t 5 /nobreak >nul
echo 正在终止所有学生端进程...
call :kill_all_student_processes
echo [√] 所有进程已终止
echo.
pause
goto process_manager

:: ============================================
:: 子程序：管理服务
:: ============================================
:manage_service
set "svc_name=%~1"
cls
echo ============================================
echo       管理服务: %svc_name%
echo ============================================
echo.
echo  [1] 停止服务
echo  [2] 启动服务
echo  [3] 重启服务
echo  [4] 删除服务
echo  [5] 返回上级菜单
echo.
set /p svc_op="请选择操作 (1-5): "

if "%svc_op%"=="1" (
    echo 5秒后自动执行，按任意键立即执行...
    timeout /t 5 /nobreak >nul
    echo 正在停止 %svc_name%...
    sc stop "%svc_name%" >nul 2>&1
    echo [√] 服务已停止
)
if "%svc_op%"=="2" (
    echo 5秒后自动执行，按任意键立即执行...
    timeout /t 5 /nobreak >nul
    echo 正在启动 %svc_name%...
    sc start "%svc_name%" >nul 2>&1
    echo [√] 服务已启动
)
if "%svc_op%"=="3" (
    echo 5秒后自动执行，按任意键立即执行...
    timeout /t 5 /nobreak >nul
    echo 正在重启 %svc_name%...
    sc stop "%svc_name%" >nul 2>&1
    timeout /t 1 /nobreak >nul
    sc start "%svc_name%" >nul 2>&1
    echo [√] 服务已重启
)
if "%svc_op%"=="4" (
    echo 5秒后自动执行，按任意键立即执行...
    timeout /t 5 /nobreak >nul
    echo 正在删除 %svc_name%...
    sc delete "%svc_name%" >nul 2>&1
    echo [√] 服务已删除
)
if "%svc_op%"=="5" goto service_manager

echo.
pause
goto service_manager

:: ============================================
:: 子程序：终止进程
:: ============================================
:kill_process
set "proc_name=%~1"
echo 5秒后自动执行，按任意键立即执行...
timeout /t 5 /nobreak >nul
echo 正在终止 %proc_name%...
taskkill /f /im "%proc_name%" >nul 2>&1
if %errorlevel% equ 0 (
    echo [√] %proc_name% 已终止
) else (
    echo [!] %proc_name% 未运行或终止失败
)
echo.
pause
goto process_manager

:: ============================================
:: 子程序：停止所有服务
:: ============================================
:stop_all_services
echo 5秒后自动执行，按任意键立即执行...
timeout /t 5 /nobreak >nul
echo 正在停止所有服务...
sc stop MMPC >nul 2>&1
sc stop OeNetlimit >nul 2>&1
sc stop easyusbflt >nul 2>&1
echo [√] 所有服务已停止
echo.
pause
goto service_manager

:: ============================================
:: 子程序：检查服务状态
:: ============================================
:check_service
set "svc_name=%~1"
sc query "%svc_name%" >nul 2>&1
if %errorlevel% equ 0 (
    sc query "%svc_name%" | findstr "RUNNING" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [运行中] %svc_name%
    ) else (
        echo [已停止] %svc_name%
    )
) else (
    echo [不存在] %svc_name%
)
goto :eof

:: ============================================
:: 子程序：检查进程状态
:: ============================================
:check_process
set "proc_name=%~1"
tasklist /FI "IMAGENAME eq %proc_name%" 2>nul | find /I "%proc_name%" >nul 2>&1
if %errorlevel% equ 0 (
    echo [运行中] %proc_name%
) else (
    echo [未运行] %proc_name%
)
goto :eof