REM // delete the previous build stuff
rmdir /s /q ..\bin\

md ..\bin
md mac
md win

REM // unzip the swc library file
7z e ..\as3\bin\OculusANE.swc -y

REM // copy the library into the specific implementation folder (mac, win)
copy library.swf mac
copy library.swf win

REM // copy the swc here
xcopy "..\as3\bin\OculusANE.swc" "." /Y

REM // copy the mac build files here
xcopy "..\osx-xcode\DerivedData\OculusANE\Build\Products\Release" "mac\" /S /Y

REM // copy the windows build files here
xcopy "..\native\bin\OculusANE.dll" "win" /S /Y

REM // call the build script on adt
REM // if you need to change this path, i strongly encourage you to download the latest flashdevelop
REM // they have this great software installer you can find under "tools/install software" 
REM // it allows you to install the latest SDK's right from the IDE
call "%LOCALAPPDATA%\FlashDevelop\Apps\ascsdk\14.0.0\bin\adt" -package -target ane ..\bin\OculusANE.ane extension.xml -swc OculusANE.swc -platform MacOS-x86 -C mac . -platform Windows-x86 -C win . 

REM // Cleanup your mess
del OculusANE.swc
del catalog.xml
del library.swf
rd mac /S /Q
rd win /S /Q

::PAUSE