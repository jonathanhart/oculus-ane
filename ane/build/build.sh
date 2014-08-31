rm OculusANE.ane
rm OculusANE.swc
cp ../as3/bin/OculusANE.swc .
unzip -o OculusANE.swc
rm -r -f mac
mkdir mac
cp -L -R "../osx-xcode/DerivedData/OculusANE/Build/Products/Debug/" mac
cp library.swf mac
mkdir windows
cp library.swf windows
cp ../win-visualstudio/Release/* windows
"/Applications/Adobe Flash Builder 4.7/eclipse/plugins/com.adobe.flash.compiler_4.7.0.349722/AIRSDK/bin/adt" -package -target ane OculusANE.ane extension.xml -swc OculusANE.swc -platform MacOS-x86 -C mac . -platform Windows-x86 -C windows .
