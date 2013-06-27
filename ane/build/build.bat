del ../bin

REM // delete the previous build stuff
md ..\bin
md mac
md win

REM // unzip the swc library file
7z e ../as3/bin/OculusANE.swc -y

REM // copy the library into the specific implementation folder (mac, win)
copy library.swf mac
copy library.swf win

REM // copy the swc here
xcopy "..\as3\bin\OculusANE.swc" "." /Y

REM // copy the mac build files here
xcopy "..\osx-xcode\build\Release" "mac\" /S /Y

REM // copy the windows build files here
xcopy "..\win-visualstudio\Release" "win\" /S /Y

REM // call the build script on adt
call "C:/Program Files (x86)/FlashDevelop/Tools/flexsdk/bin/adt" -package -target ane ../bin/OculusANE.ane extension.xml -swc OculusANE.swc -platform MacOS-x86 -C mac . -platform Windows-x86 -C win . 

del OculusANE.swc
del catalog.xml
rd mac /S /Q
rd win /S /Q

PAUSE