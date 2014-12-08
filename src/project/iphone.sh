NDLL="../ndll/iPhone/"
HXCPP="haxelib run hxcpp Build.xml"
HXCPP_IPHONEOS=$HXCPP" -Diphoneos"
DEBUG="-Ddebug -Dfulldebug"
VERSION="-Dmiphoneos-version-min=7.0"
VERBOSE="-verbose"
GCC="-DHXCPP_GCC"
ARC="-DOBJC_ARC"
LIB="mloader"
DELAY="0.5"

cleanup()
{
	rm -rf "obj"
	rm -rf "all_objs"
}

armv6()
{
	echo "\n\n\\033[1;32mCompiling for armv6"
	sleep $DELAY
	rm -rf NDLL"lib"LIB"-debug.iphoneos.a"
	rm -rf NDLL"lib"LIB".iphoneos.a"
	$HXCPP_IPHONEOS $VERBOSE $DEBUG $ARC $GCC
	sleep $DELAY
	$HXCPP_IPHONEOS $VERBOSE $ARC $GCC
	sleep $DELAY
}

armv7()
{
	echo "\n\n\\033[1;32mCompiling for armv7"
	rm -rf NDLL"lib"LIB"-debug.iphoneos-v7.a"
	rm -rf NDLL"lib"LIB".iphoneos-v7.a"

	$HXCPP_IPHONEOS -DHXCPP_ARMV7 $VERBOSE $DEBUG $VERSION $ARC $GCC
	sleep $DELAY
	$HXCPP_IPHONEOS -DHXCPP_ARMV7 $VERBOSE $VERSION $ARC $GCC
	sleep $DELAY
}

simulator()
{
	echo "\n\n\033[1;32mCompiling for simulator"
	rm -rf NDLL"lib"LIB"-debug.iphonesim.a"
	rm -rf NDLL"lib"LIB".iphonesim.a"
	$HXCPP -Diphonesim $VERBOSE $DEBUG $ARC $VERSION $GCC
	sleep $DELAY
	$HXCPP -Diphonesim -DHXCPP_ARMV7 $VERBOSE $VERSION $ARC $GCC
	sleep $DELAY
}

case "$1" in
	"v6")
		cleanup
		armv6
	;;
	"v7")
		cleanup
		armv7
	;;
	"simulator")
		cleanup
		simulator
	;;
	*)
		cleanup
		armv6
		armv7
		simulator
	;;
esac

cleanup
