package mloader;
import massive.munit.Assert;
import haxe.PosInfos;
class LoaderAssert
{

	/**
	 * Compares enum equality, ignoring any non enum parameters, so that:
	 *	Fail(IO("One thing happened")) == Fail(IO("Another thing happened"))
	 * 
	 * Also allows for wildcard matching by passing through <code>null</code> for
	 * any params, so that:
	 *  Fail(IO(null)) matches Fail(IO("Another thing happened"))
	 *
	 * @param expected the enum value to filter on
	 * @param actual the enum value being checked
	*/
	static public function assertEnumTypeEq(expected:EnumValue, actual:EnumValue, ?info:PosInfos)
	{
		if (expected == actual) return;

		var expectedType = Type.getEnum(expected);
		var actualType = Type.getEnum(actual);

		if(expectedType != actualType)
			Assert.fail("Enum type [" + actualType +"] was not equal to expected type [" + expectedType + "]", info);
	
		var expectedIndex = Type.enumIndex(expected);
		var actualIndex = Type.enumIndex(actual);

		if(expectedIndex != actualIndex)
			Assert.fail("Enum value [" + Type.getEnumConstructs(expectedType)[actualIndex] +"] was not equal to expected value [" + Type.getEnumConstructs(expectedType)[expectedIndex] + "]", info);


		var expectedParams = Type.enumParameters(expected);
		if (expectedParams.length == 0) return;
		var actualParams = Type.enumParameters(actual);

		for (i in 0...expectedParams.length)
		{
			var expectedParam = expectedParams[i];
			var actualParam = actualParams[i];

			if (expectedParam == null) continue;
			assertEnumParamTypeEq(expectedParam, actualParam, info);
		}
	}

	/**
	 * Compares object equality with special rules for enum values:
	 * 
	 * @param expected value
	 * @param actual value
	*/

	public static function assertEnumParamTypeEq(expected:Dynamic, actual:Dynamic, ?info:PosInfos)
	{
		

		switch(Type.typeof(expected))
		{
			case TEnum(e):
			{
				assertEnumTypeEq(cast expected, cast actual, info);
			}
			default:
			{
				if(expected != actual)
				{
					Assert.fail("Enum param [" + expected +"] was not equal to expected value [" + actual + "]", info);
				}
			}
		}
	}

}