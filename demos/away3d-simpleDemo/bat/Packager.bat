@echo off
if not exist %CERT_FILE% goto certificate

:: AIR output
if not exist %AIR_PATH% md %AIR_PATH%
set OUTPUT=%AIR_PATH%\%AIR_NAME%%AIR_TARGET%.air

:: Package
echo.
echo Packaging %AIR_NAME%%AIR_TARGET%.air using certificate %CERT_FILE%...

call adt -package %OPTIONS% %SIGNING_OPTIONS% -target bundle %OUTPUT% %APP_XML% %FILE_OR_DIR% -extdir ext/
::echo adt -package %OPTIONS% %SIGNING_OPTIONS% %OUTPUT% %APP_XML% %FILE_OR_DIR%
::call adt -package -tsa none  -storetype pkcs12 -keystore "bat\away3dsimpleDemo.p12" storepass fd air\away3dsimpleDemo-captive-runtime.air application.xml -C bin .
::call adt -package  -storetype pkcs12 -keystore "cert\BUT_pc_distribution\AC_ProductExplorer.p12" -storepass fd -target bundle "dist\ProductExplorer.air" application-desktop.xml -C bin . -C "icons/android" . -extdir ext/

if errorlevel 1 goto failed
goto end

:certificate
echo.
echo Certificate not found: %CERT_FILE%
echo.
echo Troubleshooting: 
echo - generate a default certificate using 'bat\CreateCertificate.bat'
echo.
if %PAUSE_ERRORS%==1 pause
exit

:failed
echo AIR setup creation FAILED.
echo.
echo Troubleshooting: 
echo - did you build your project in FlashDevelop?
echo - verify AIR SDK target version in %APP_XML%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:end
echo.