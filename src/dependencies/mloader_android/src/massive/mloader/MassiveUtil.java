package massive.mloader;

import android.util.Log;

public class MassiveUtil
{
	public static void trace(String s)
	{
		::if (DEBUG)::
		Log.w(TAG, s);
		::end::
	}

	static String TAG = "MassiveLoader";
}
