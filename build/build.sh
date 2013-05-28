rm OculusANE.ane
cp ../ane/bin/OculusANE.swc .
unzip -o OculusANE.swc
rm -r -f mac
mkdir mac
cp -L -R "../mac/OculusANE/build/Release/" mac
cp library.swf mac
"/Applications/Adobe Flash Builder 4.7/eclipse/plugins/com.adobe.flash.compiler_4.7.0.349722/AIRSDK/bin/adt" -package -target ane OculusANE.ane extension.xml -swc OculusANE.swc -platform MacOS-x86 -C mac . 
