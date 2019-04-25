@ECHO OFF
SET VERS=1.5
mode con: cols=42 lines=25
SETLOCAL EnableDelayedExpansion
IF NOT "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /b)
SET DNSName=
SET "PLDNSNAME=Private-LockerDNS"
SET "PLDNS1=47.51.161.66"
SET "PLDNS2="
SET "GOOGLEDNSNAME=GoogleDNS"
SET "GOOGLEDNS1=8.8.8.8"
SET "GOOGLEDNS2=8.8.4.4"
SET "CLOUDFLAREDNSNAME=CloudFlareDNS"
SET "CLOUDFLAREDNS1=1.1.1.1"
SET "CLOUDFLAREDNS2=1.0.0.1"

REM Set AUTOMATE to 1 for BASHBUNNY/AUTOMATED One-Click Execution.
REM Set AUTOMATE to 0 for Menu-Based DNS Changer.
SET AUTOMATE=0

REM Custom DNS Addresses
SET DNSAddress=
SET DNSAddress2=

REM Use Private-LockerDNS (YES/NO) (I.E. - Overwrites all Settings)
SET USEPL=YES

REM Use CloudFlareDNS (YES/NO)
SET USECF=YES

REM Use GoogleDNS (YES/NO)
SET USEGD=NO

IF "%AUTOMATE%" EQU "0" (
	GOTO MENU1
)
IF "%USEPL%" EQU "YES" (
	SET DNSName=%PLDNSNAME%
	SET DNSAddress=%PLDNS1%
	IF "%PLDNS2%" NEQ "" SET DNSAddress2=%PLDNS2%
)
IF "%USEGD%" EQU "YES" IF "%USECF%" EQU "YES" GOTO ERROR
IF "%DNSAddress%" EQU "" IF "%USECF%" EQU "NO" IF "%USEGD%" EQU "NO" GOTO ERROR2
IF "%USECF%" EQU "YES" IF "%DNSAddress%" EQU "" (
	SET DNSName=!!CLOUDFLAREDNSNAME!!
	SET DNSAddress=!!CLOUDFLAREDNS1!!
	SET DNSAddress2=!!CLOUDFLAREDNS2!!
)
IF "%USEGD%" EQU "YES" IF "%DNSAddress%" EQU "" (
	SET DNSName=!!GOOGLEDNSNAME!!
	SET DNSAddress=!!GOOGLEDNS1!!
	SET DNSAddress2=!!GOOGLEDNS2!!
)	
IF "%DNSAddress%" NEQ "" IF "%DNSAddress2%" EQU "" (
	IF "!!USEGD!!" EQU "YES" IF "!!USECF!!" EQU "YES" GOTO ERROR
	IF "!!USEGD!!" EQU "YES" IF "!!USECF!!" EQU "NO" SET DNSAddress2=!!GOOGLEDNS2!!
	IF "!!USECF!!" EQU "YES" IF "!!USEGD!!" EQU "NO" SET DNSAddress2=!!CLOUDFLAREDNS2!!
)
:START
ECHO.
ECHO Detecting active Internet Connection Adapter.
ECHO.
for /f "tokens=2,3*" %%i in ('netsh int show interface') do (
    ECHO.
	if %%i equ Connected (
        ECHO Changing DNS Servers for Adapter - "%%k" 
		ECHO  - DNS Server 1: %DNSAddress%
		IF "%DNSAddress2%" NEQ "" ECHO  - DNS Server 2: %DNSAddress2%
        netsh int ipv4 set dns name="%%k" static %DNSAddress% primary validate=no
		IF "%DNSAddress2%" NEQ "" netsh int ipv4 add dns name="%%k" %DNSAddress2% index=2 validate=no
		ECHO Done^^!
    )
)
ECHO.
ECHO.
ECHO Flushing DNS to allow full effect of System Changes.
ECHO Please Wait...
ECHO.
ipconfig /release >NUL
ipconfig /renew>NUL
ipconfig /flushdns >NUL
ECHO Finished.
ECHO.
ECHO.
FOR /F "tokens=14 delims=: " %%a in ('IPCONFIG /all ^|find "DNS Servers"') do set DNSFinal=%%a
ECHO.
IF "%DNSFinal%" EQU "%DNSAddress%" (
	ECHO DNS Successfully changed.
) ELSE (
	ECHO DNS Failed to Change.
)
ECHO.
ECHO.
ECHO.
GOTO EXIT

:MENU1
FOR /F "tokens=14 delims=: " %%a in ('IPCONFIG /all ^|find "DNS Servers"') do set CURRDNS=%%a
CLS
SET "CREDS=REDD of Private-Locker"
ECHO *****************************************
ECHO **      Private-Locker DNS Changer     **
ECHO *****************************************
ECHO           Version: %VERS% 
ECHO           By: %CREDS%
ECHO.
ECHO *****************************************
ECHO *** Current DNS: %CURRDNS%
ECHO *****************************************
ECHO   1. %PLDNSNAME%
ECHO   2. %CLOUDFLAREDNSNAME%
ECHO   3. %GOOGLEDNSNAME%
ECHO   4. Flush DNS
ECHO   5. Exit
ECHO.
ECHO.

SET /P "PROMPT1=Please choose a # and press ENTER? (1-5)" 
IF "%PROMPT1%" EQU "1" (
	GOTO PLMENU
)
IF "%PROMPT1%" EQU "2" (
	GOTO CFMENU
)
IF "%PROMPT1%" EQU "3" (
	GOTO GDMENU
)
IF "%PROMPT1%" EQU "4" (
	GOTO FLUSH1
)
IF "%PROMPT1%" EQU "5" (
	GOTO EXIT
)
GOTO MENU1

:PLMENU
CLS
ECHO.
ECHO.
ECHO Change DNS to:
ECHO    %PLDNSNAME%
ECHO  - %PLDNS1%
IF "%PLDNS2%" NEQ "" ECHO  - %PLDNS2%
ECHO.
SET /P "CONF=Are you sure you want this? (Y/n)"
IF "%CONF%"=="" (
	SET DNSAddress=%PLDNS1%
	IF "%PLDNS2%" NEQ "" SET DNSAddress2=%PLDNS2%
	for /f "tokens=2,3*" %%i in ('netsh int show interface') do (
		ECHO.
		if %%i equ Connected (
			ECHO Changing DNS Servers for Adapter - "%%k" 
			ECHO  - DNS Server 1: !!DNSAddress!!
			IF "!!DNSAddress2!!" NEQ "" ECHO  - DNS Server 2: !!DNSAddress2!!
			netsh int ipv4 set dns name="%%k" static !!DNSAddress!! primary validate=no
			IF "!!DNSAddress2!!" NEQ "" netsh int ipv4 add dns name="%%k" !!DNSAddress2!! index=2 validate=no
			ECHO Done^^!
		)
	)
	TIMEOUT /T 2 /NOBREAK>NUL
	GOTO MENU1
)
IF "%CONF%" EQU "y" (
	SET DNSAddress=%PLDNS1%
	IF "%PLDNS2%" NEQ "" SET DNSAddress2=%PLDNS2%
	for /f "tokens=2,3*" %%i in ('netsh int show interface') do (
		ECHO.
		if %%i equ Connected (
			ECHO Changing DNS Servers for Adapter - "%%k" 
			ECHO  - DNS Server 1: !!DNSAddress!!
			IF "!!DNSAddress2!!" NEQ "" ECHO  - DNS Server 2: !!DNSAddress2!!
			netsh int ipv4 set dns name="%%k" static !!DNSAddress!! primary validate=no
			IF "!!DNSAddress2!!" NEQ "" netsh int ipv4 add dns name="%%k" !!DNSAddress2!! index=2 validate=no
			ECHO Done^^!
		)
	)
	TIMEOUT /T 2 /NOBREAK>NUL
	GOTO MENU1
)
IF "%CONF%" EQU "Y" (
	SET DNSAddress=%PLDNS1%
	IF "%PLDNS2%" NEQ "" SET DNSAddress2=%PLDNS2%
	for /f "tokens=2,3*" %%i in ('netsh int show interface') do (
		ECHO.
		if %%i equ Connected (
			ECHO Changing DNS Servers for Adapter - "%%k" 
			ECHO  - DNS Server 1: !!DNSAddress!!
			IF "!!DNSAddress2!!" NEQ "" ECHO  - DNS Server 2: !!DNSAddress2!!
			netsh int ipv4 set dns name="%%k" static !!DNSAddress!! primary validate=no
			IF "!!DNSAddress2!!" NEQ "" netsh int ipv4 add dns name="%%k" !!DNSAddress2!! index=2 validate=no
			ECHO Done^^!
		)
	)
	TIMEOUT /T 2 /NOBREAK>NUL
	GOTO MENU1
)
IF "%CONF%" EQU "N" (
GOTO MENU1
)
IF "%CONF%" EQU "n" (
GOTO MENU1
)
GOTO PLMENU

:GDMENU
CLS
ECHO.
ECHO.
ECHO Change DNS to:
ECHO    %GOOGLEDNSNAME%
ECHO  - %GOOGLEDNS1%
IF "%GOOGLEDNS2%" NEQ "" ECHO  - %GOOGLEDNS2%
ECHO.
SET /P "CONF=Are you sure you want this? (Y/n)"
IF "%CONF%"=="" (
	SET DNSAddress=%GOOGLEDNS1%
	IF "%GOOGLEDNS2%" NEQ "" SET DNSAddress2=%GOOGLEDNS2%
	for /f "tokens=2,3*" %%i in ('netsh int show interface') do (
		ECHO.
		if %%i equ Connected (
			ECHO Changing DNS Servers for Adapter - "%%k" 
			ECHO  - DNS Server 1: !!DNSAddress!!
			IF "!!DNSAddress2!!" NEQ "" ECHO  - DNS Server 2: !!DNSAddress2!!
			netsh int ipv4 set dns name="%%k" static !!DNSAddress!! primary validate=no
			IF "!!DNSAddress2!!" NEQ "" netsh int ipv4 add dns name="%%k" !!DNSAddress2!! index=2 validate=no
			ECHO Done^^!
		)
	)
	TIMEOUT /T 2 /NOBREAK>NUL
	GOTO MENU1
)
IF "%CONF%" EQU "y" (
	SET DNSAddress=%GOOGLEDNS1%
	IF "%GOOGLEDNS2%" NEQ "" SET DNSAddress2=%GOOGLEDNS2%
	for /f "tokens=2,3*" %%i in ('netsh int show interface') do (
		ECHO.
		if %%i equ Connected (
			ECHO Changing DNS Servers for Adapter - "%%k" 
			ECHO  - DNS Server 1: !!DNSAddress!!
			IF "!!DNSAddress2!!" NEQ "" ECHO  - DNS Server 2: !!DNSAddress2!!
			netsh int ipv4 set dns name="%%k" static !!DNSAddress!! primary validate=no
			IF "!!DNSAddress2!!" NEQ "" netsh int ipv4 add dns name="%%k" !!DNSAddress2!! index=2 validate=no
			ECHO Done^^!
		)
	)
	TIMEOUT /T 2 /NOBREAK>NUL
	GOTO MENU1
)
IF "%CONF%" EQU "Y" (
	SET DNSAddress=%GOOGLEDNS1%
	IF "%GOOGLEDNS2%" NEQ "" SET DNSAddress2=%GOOGLEDNS2%
	for /f "tokens=2,3*" %%i in ('netsh int show interface') do (
		ECHO.
		if %%i equ Connected (
			ECHO Changing DNS Servers for Adapter - "%%k" 
			ECHO  - DNS Server 1: !!DNSAddress!!
			IF "!!DNSAddress2!!" NEQ "" ECHO  - DNS Server 2: !!DNSAddress2!!
			netsh int ipv4 set dns name="%%k" static !!DNSAddress!! primary validate=no
			IF "!!DNSAddress2!!" NEQ "" netsh int ipv4 add dns name="%%k" !!DNSAddress2!! index=2 validate=no
			ECHO Done^^!
		)
	)
	TIMEOUT /T 2 /NOBREAK>NUL
	GOTO MENU1
)
IF "%CONF%" EQU "N" (
GOTO MENU1
)
IF "%CONF%" EQU "n" (
GOTO MENU1
)
GOTO GDMENU

:CFMENU
CLS
ECHO.
ECHO.
ECHO Change DNS to:
ECHO    %CLOUDFLAREDNSNAME%
ECHO  - %CLOUDFLAREDNS1%
IF "%CLOUDFLAREDNS2%" NEQ "" ECHO  - %CLOUDFLAREDNS2%
ECHO.
SET /P "CONF=Are you sure you want this? (Y/n)"
IF "%CONF%"=="" (
	SET DNSAddress=%CLOUDFLAREDNS1%
	IF "%CLOUDFLAREDNS2%" NEQ "" SET DNSAddress2=%CLOUDFLAREDNS2%
	for /f "tokens=2,3*" %%i in ('netsh int show interface') do (
		ECHO.
		if %%i equ Connected (
			ECHO Changing DNS Servers for Adapter - "%%k" 
			ECHO  - DNS Server 1: !!DNSAddress!!
			IF "!!DNSAddress2!!" NEQ "" ECHO  - DNS Server 2: !!DNSAddress2!!
			netsh int ipv4 set dns name="%%k" static !!DNSAddress!! primary validate=no
			IF "!!DNSAddress2!!" NEQ "" netsh int ipv4 add dns name="%%k" !!DNSAddress2!! index=2 validate=no
			ECHO Done^^!
		)
	)
	TIMEOUT /T 2 /NOBREAK>NUL
	GOTO MENU1
)
IF "%CONF%" EQU "y" (
	SET DNSAddress=%CLOUDFLAREDNS1%
	IF "%CLOUDFLAREDNS2%" NEQ "" SET DNSAddress2=%CLOUDFLAREDNS2%
	for /f "tokens=2,3*" %%i in ('netsh int show interface') do (
		ECHO.
		if %%i equ Connected (
			ECHO Changing DNS Servers for Adapter - "%%k" 
			ECHO  - DNS Server 1: !!DNSAddress!!
			IF "!!DNSAddress2!!" NEQ "" ECHO  - DNS Server 2: !!DNSAddress2!!
			netsh int ipv4 set dns name="%%k" static !!DNSAddress!! primary validate=no
			IF "!!DNSAddress2!!" NEQ "" netsh int ipv4 add dns name="%%k" !!DNSAddress2!! index=2 validate=no
			ECHO Done^^!
		)
	)
	TIMEOUT /T 2 /NOBREAK>NUL
	GOTO MENU1
)
IF "%CONF%" EQU "Y" (
	SET DNSAddress=%CLOUDFLAREDNS1%
	IF "%CLOUDFLAREDNS2%" NEQ "" SET DNSAddress2=%CLOUDFLAREDNS2%
	for /f "tokens=2,3*" %%i in ('netsh int show interface') do (
		ECHO.
		if %%i equ Connected (
			ECHO Changing DNS Servers for Adapter - "%%k" 
			ECHO  - DNS Server 1: !!DNSAddress!!
			IF "!!DNSAddress2!!" NEQ "" ECHO  - DNS Server 2: !!DNSAddress2!!
			netsh int ipv4 set dns name="%%k" static !!DNSAddress!! primary validate=no
			IF "!!DNSAddress2!!" NEQ "" netsh int ipv4 add dns name="%%k" !!DNSAddress2!! index=2 validate=no
			ECHO Done^^!
		)
	)
	TIMEOUT /T 2 /NOBREAK>NUL
	GOTO MENU1
)
IF "%CONF%" EQU "N" (
GOTO MENU1
)
IF "%CONF%" EQU "n" (
GOTO MENU1
)
GOTO CFMENU

:FLUSH1
ECHO.
ECHO Flushing DNS to allow full effect of System Changes.
ECHO Please Wait...
ECHO.
ipconfig /release >NUL
ipconfig /renew>NUL
ipconfig /flushdns >NUL
ECHO Finished.
ECHO.
ECHO.
TIMEOUT /T 5 >NUL
GOTO MENU1

:ERROR
ECHO Error has occured during the process. Please contact REDD at redd@private-locker.com
PAUSE
GOTO EXIT

:ERROR2
ECHO Please Edit the Variables inside this Batch Script file.
ECHO.
ECHO USECF - Use CloudFlareDNS
ECHO USEGD - Use GoogleDNS 
ECHO.
ECHO   OR Add your own DNS into DNSAddress ^& DNSAddress2
ECHO.
PAUSE
GOTO EXIT

:EXIT
CLS
ECHO Thank you for using this Tool^!
ECHO     -REDD-
ECHO.
TIMEOUT /T 5 /NOBREAK>NUL
exit /B
