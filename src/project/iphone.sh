rm -rf "obj"
rm -rf "all_objs"
rm -rf "../ndll/iPhone/libmloader.iphonesim.a"

echo "compiling for armv6"
haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_GCC -verbose -DOBJC_ARC
haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_GCC -verbose -Ddebug -Dfulldebug -DOBJC_ARC
echo "compiling for armv7"
haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_ARMV7 -DHXCPP_GCC -verbose -Dmiphoneos-version-min=7.0 -DOBJC_ARC
haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_ARMV7 -DHXCPP_GCC -verbose -Ddebug -Dfulldebug -Dmiphoneos-version-min=7.0 -DOBJC_ARC
# echo "compiling for simulator"
# haxelib run hxcpp Build.xml -Diphonesim -DHXCPP_GCC -verbose -Ddebug -Dfull_debug -DOBJC_ARC

echo "Done ! \n"
rm -rf "obj"
rm -rf "all_objs"
