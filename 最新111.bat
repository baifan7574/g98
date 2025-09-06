@echo off
chcp 65001 >nul
echo ✅ 当前终端编码设置为 UTF-8（防止中文乱码）

REM === 进入 generator 文件夹，执行图片生成 ===
cd /d "%~dp0generator"
echo 🖼️ 正在批量生成图片...
call run_generator_autopath.bat

REM === 返回主目录，执行网页生成+SEO结构 ===
cd ..
echo 🌐 正在执行网页生成 + SEO 插入...
call run_all.bat

REM === 插入广告 ===
echo 💰 正在插入广告...
python ads_apply_all.py

REM === SEO修复（v4） ===
echo 🔧 正在执行SEO修复...
python seo_fixer_v4.py

REM === 补丁（内容补全 + canonical/JSON-LD 统一） ===
echo 🩹 正在执行补丁...
python v4_content_patch.py

REM === 上传到 GitHub（你已经配置了 SSH 公钥） ===
echo 🚀 正在上传到 GitHub 仓库...
python auto_git_push.py

REM === 自动 Ping 地图（域名从 config.json 里读取） ===
for /f "usebackq tokens=* delims=" %%i in (`powershell -NoProfile -Command ^
  "(Get-Content '%~dp0config.json' -Raw | ConvertFrom-Json).domain"`) do set DOMAIN=%%i

set "SITEMAP_URL=%DOMAIN%/sitemap.xml"
echo 🌍 正在通知搜索引擎抓取：%SITEMAP_URL%

powershell -Command "Invoke-WebRequest -Uri ('https://www.google.com/ping?sitemap=' + [uri]::EscapeDataString('%SITEMAP_URL%')) | Out-Null"
powershell -Command "Invoke-WebRequest -Uri ('https://www.bing.com/ping?sitemap=' + [uri]::EscapeDataString('%SITEMAP_URL%')) | Out-Null"

echo ✅ 全部流程执行完毕！
pause
