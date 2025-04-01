@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul
echo 正在生成index.md文件和gallery-group-main.txt...

REM 保存当前路径并自动确定图片路径
set "currentPath=%cd%"
REM 自动查找 /img 或 \img 目录
for %%a in ("%currentPath%") do set "folderName=%%~nxa"
set "parentPath=%currentPath%"
set "imgPath="

:FIND_IMG_PATH
REM 检查当前目录名是否为img
if "%folderName%"=="img" (
    set "imgPath=!parentPath:~0!"
    goto :FOUND_PATH
)

REM 提取父目录
for %%a in ("!parentPath!\.") do set "parentPath=%%~dpa"
set "parentPath=!parentPath:~0,-1!"
for %%a in ("!parentPath!") do set "folderName=%%~nxa"

REM 如果到达了根目录，停止查找
if "!parentPath!"=="!parentPath::\=!" goto :USE_RELATIVE

REM 继续查找
goto :FIND_IMG_PATH

:FOUND_PATH
REM 提取 /img 及之后的部分
set "blogRoot=!imgPath:~0,-4!"
set "imgPath=!currentPath:%blogRoot%=!"
set "imgPath=!imgPath:\=/!"
goto :CONTINUE

:USE_RELATIVE
REM 使用相对路径
set "imgPath=/img/%folderName%"

:CONTINUE
echo 图片路径：%imgPath%

REM 获取当前日期时间
for /f "tokens=2 delims==." %%a in ('wmic os get localdatetime /value') do set "dt=%%a"
set "year=!dt:~0,4!"
set "month=!dt:~4,2!"
set "day=!dt:~6,2!"
set "hour=!dt:~8,2!"
set "minute=!dt:~10,2!"
set "second=!dt:~12,2!"
set "datetime=!year!-!month!-!day! !hour!:!minute!:!second!"

REM 创建gallery-group-main.txt文件头部
if exist "gallery-group-main.txt" del /f /q "gallery-group-main.txt"
echo ^<div class="gallery-group-main"^>> gallery-group-main.txt

REM 遍历每个子文件夹
for /d %%d in (*) do (
    echo 正在处理: %%d
    
    REM 删除旧的index.md
    if exist "%%d\index.md" del /f /q "%%d\index.md"
    
    REM 创建索引文件的开头
    echo --->> "%%d\index.md"
    echo title: %%d>> "%%d\index.md"
    echo date: !datetime!>> "%%d\index.md"
    echo ^{%% gallery %%^}>> "%%d\index.md"
    echo.>> "%%d\index.md"
    
    REM 获取已经处理过的文件列表（防止重复）
    set "processed="
    set "count=0"
    set "thumbnail="
    
    REM 直接处理JPG文件（不区分大小写）
    for %%f in ("%%d\*.jpg" "%%d\*.JPG") do (
        REM 从完整路径中提取文件名
        set "filename=%%~nf%%~xf"
        
        REM 检查此文件是否已处理过
        set "duplicate=0"
        for %%p in (!processed!) do if /i "%%p"=="!filename!" set "duplicate=1"
        
        REM 如果未处理过此文件，则处理
        if !duplicate!==0 (
            echo ^^^!^[%%d^]^(%imgPath%/%%d/!filename!^)>> "%%d\index.md"
            set /a count+=1
            set "processed=!processed! !filename!"
            
            REM 保存第一个图片作为缩略图
            if "!thumbnail!"=="" set "thumbnail=!filename!"
        )
    )
    
    REM 直接处理JPEG文件（不区分大小写）
    for %%f in ("%%d\*.jpeg" "%%d\*.JPEG") do (
        REM 从完整路径中提取文件名
        set "filename=%%~nf%%~xf"
        
        REM 检查此文件是否已处理过
        set "duplicate=0"
        for %%p in (!processed!) do if /i "%%p"=="!filename!" set "duplicate=1"
        
        REM 如果未处理过此文件，则处理
        if !duplicate!==0 (
            echo ^^^!^[%%d^]^(%imgPath%/%%d/!filename!^)>> "%%d\index.md"
            set /a count+=1
            set "processed=!processed! !filename!"
            
            REM 保存第一个图片作为缩略图（如果JPG没找到）
            if "!thumbnail!"=="" set "thumbnail=!filename!"
        )
    )
    
    REM 直接处理PNG文件（不区分大小写）
    for %%f in ("%%d\*.png" "%%d\*.PNG") do (
        REM 从完整路径中提取文件名
        set "filename=%%~nf%%~xf"
        
        REM 检查此文件是否已处理过
        set "duplicate=0"
        for %%p in (!processed!) do if /i "%%p"=="!filename!" set "duplicate=1"
        
        REM 如果未处理过此文件，则处理
        if !duplicate!==0 (
            echo ^^^!^[%%d^]^(%imgPath%/%%d/!filename!^)>> "%%d\index.md"
            set /a count+=1
            set "processed=!processed! !filename!"
            
            REM 保存第一个图片作为缩略图（如果JPG/JPEG没找到）
            if "!thumbnail!"=="" set "thumbnail=!filename!"
        )
    )
    
    REM 直接处理GIF文件（不区分大小写）
    for %%f in ("%%d\*.gif" "%%d\*.GIF") do (
        REM 从完整路径中提取文件名
        set "filename=%%~nf%%~xf"
        
        REM 检查此文件是否已处理过
        set "duplicate=0"
        for %%p in (!processed!) do if /i "%%p"=="!filename!" set "duplicate=1"
        
        REM 如果未处理过此文件，则处理
        if !duplicate!==0 (
            echo ^^^!^[%%d^]^(%imgPath%/%%d/!filename!^)>> "%%d\index.md"
            set /a count+=1
            set "processed=!processed! !filename!"
            
            REM 保存第一个图片作为缩略图（如果其他格式没找到）
            if "!thumbnail!"=="" set "thumbnail=!filename!"
        )
    )
    
    REM 添加结尾
    echo.>> "%%d\index.md"
    echo ^{%% endgallery %%^}>> "%%d\index.md"
    
    echo 成功创建: %%d\index.md ^(包含!count!张图片^)
    
    REM 向gallery-group-main.txt添加此文件夹的条目
    if !count! gtr 0 (
        if "!thumbnail!"=="" (
            echo ^^^{%% galleryGroup '自定义名称' '%%d' '%imgPath%/%%d/' /img/default.jpg %%^^^}>> gallery-group-main.txt
        ) else (
            echo ^^^{%% galleryGroup '自定义名称' '%%d' '%imgPath%/%%d/' %imgPath%/%%d/!thumbnail! %%^^^}>> gallery-group-main.txt
        )
    )
)

REM 添加gallery-group-main.txt文件的尾部
echo ^</div^>>> gallery-group-main.txt

echo 所有index.md文件已生成完毕！
echo gallery-group-main.txt文件已生成完毕！
pause