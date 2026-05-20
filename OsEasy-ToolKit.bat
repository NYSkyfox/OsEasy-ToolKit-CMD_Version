@echo off
title OsEasy-ToolKit v1.0
color 0A
cls

echo ============================================
echo                OsEasy-ToolKit v1.0
echo                    By NyxFox
echo ============================================
echo       本工具用于解锁噢易学生端的各类限制
echo ============================================
echo                      主菜单
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