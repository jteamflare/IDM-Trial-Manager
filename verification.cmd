@echo off
net session >nul 2>&1
if %errorLevel% neq 0 exit /b
attrib -r %windir%\System32\drivers\etc\hosts >nul 2>&1
findstr /c:"registeridm.com" "%windir%\System32\drivers\etc\hosts" >nul 2>&1
if %errorLevel% neq 0 (
    echo 127.0.0.1 registeridm.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 www.registeridm.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 secure.registeridm.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 www.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 secure.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 mirror.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 mirror2.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 mirror3.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 tonec.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 www.tonec.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 www.internetdownloadmanager.info >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 internetdownloadmanager.info >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 secure.internetdownloadmanager.info >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 cdn.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 download.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 www.internetdownloadmanager.co.uk >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 internetdownloadmanager.co.uk >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 www.idm.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 idm.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 www.tonec.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 tonec.net >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 www.tonec.net >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 update.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 updates.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 auth.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 activation.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 license.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 server.internetdownloadmanager.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 www.idm-support.com >> %windir%\System32\drivers\etc\hosts
    echo 127.0.0.1 idm-support.com >> %windir%\System32\drivers\etc\hosts
)
attrib +r %windir%\System32\drivers\etc\hosts >nul 2>&1