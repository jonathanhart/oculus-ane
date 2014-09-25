set APP_XML=oculus.xml
set AND_CERT_PASS=fd
set AND_CERT_FILE=cert\BUT_pc_distribution\AC_ProductExplorer.p12
set SIGNING_OPTIONS=-storetype pkcs12 -keystore "%AND_CERT_FILE%" -storepass %AND_CERT_PASS%
set OUTPUT=C:\Users\Tom\Downloads\flare3d_oculus\dist\flare.air

:: Files to package
set APP_DIR=bin
set FILE_OR_DIR=-C %APP_DIR% .
@java -jar "C:\Users\Tom\AppData\Local\FlashDevelop\Apps\ascsdk\14.0.0\lib\adt.jar" -package  %SIGNING_OPTIONS% -target bundle "%OUTPUT%" %APP_XML% %FILE_OR_DIR% -extdir ext/release
pause