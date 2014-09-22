rmdir /s /q ext\debug\OculusANE.ane
xcopy "C:\git\oculus-ane\ane\bin\OculusANE.ane" "ext\release" /S /Y
7z x ext/release/OculusANE.ane -y -oext/debug/OculusANE.ane
::pause