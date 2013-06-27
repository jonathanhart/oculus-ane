del OculusANE.ane
del OculusANE.swc
del mac /Q
del win /Q

md mac
md win

7z e ../ane/bin/OculusANE.swc -y
copy library.swf mac
copy library.swf win
xcopy "..\ane\bin\OculusANE.swc" ".\OculusANE.swc"

xcopy "../mac/OculusANE/build/Release" "mac\" /S
xcopy "../windows/OculusANE/Release" "win\"
call "C:/Program Files (x86)/FlashDevelop/Tools/flexsdk/bin/adt" -package -target ane OculusANE.ane extension.xml -swc OculusANE.swc -platform MacOS-x86 -C mac . -platform Windows-x86 -C win . 
PAUSE