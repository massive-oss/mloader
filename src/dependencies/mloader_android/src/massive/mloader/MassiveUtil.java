package massive.mloader;

import android.util.Log;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public class MassiveUtil
{
	public static void trace(String s)
	{
		::if (DEBUG)::
		callLogger("i", TAG, s);
		::end::
	}

	public static void error(String s)
	{
		::if (DEBUG)::
		Log.e(TAG, s);
		::end::
	}

	final static int depth = 4;
	static String TAG = "MassiveChromecast";

	@SuppressWarnings("rawtypes")
	public static void callLogger(String methodName, String tag, String message)
	{
		final StackTraceElement[] ste = Thread.currentThread().getStackTrace();
		try
		{
			Class cls = Class.forName("android.util.Log");
			Method method = cls.getMethod(methodName, String.class, String.class);
			method.invoke(null, tag, getTrace(ste) + message);
		}
		catch (ClassNotFoundException
			| IllegalArgumentException
			| IllegalAccessException
			| InvocationTargetException
			| NoSuchMethodException
			| SecurityException e)
		{
			e.printStackTrace();
		}
	}

	public static String getTrace(StackTraceElement[] ste)
	{
		return getClassName(ste) + ".java:" + getLineNumber(ste) + ": ";
	}

	public static String getClassPackage(StackTraceElement[] ste)
	{
		return ste[depth].getClassName();
	}

	public static String getClassName(StackTraceElement[] ste)
	{
		String[] temp = ste[depth].getClassName().split("\\.");
		return temp[temp.length - 1];
	}

	public static String getMethodName(StackTraceElement[] ste)
	{
		return ste[depth].getMethodName();
	}

	public static int getLineNumber(StackTraceElement[] ste)
	{
		return ste[depth].getLineNumber();
	}
}
