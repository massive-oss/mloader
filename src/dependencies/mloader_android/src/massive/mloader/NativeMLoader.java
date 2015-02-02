package massive.mloader;

import android.util.Log;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.NetworkResponse;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import junit.framework.Assert;

import org.haxe.lime.HaxeObject;

import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import org.haxe.extension.Extension;

public class NativeMLoader implements Response.Listener<String>,
		Response.ErrorListener
{
	static final RequestQueue queue = Volley.newRequestQueue(Extension.mainContext);

	HaxeObject listener;
	MLoaderStringRequest request;
	String requestMethod;
	String sourceUrl;
	String taskId;
	String httpBody;
	String contentType;
	HashMap<String, String> headers;
	HashMap<String, String> variables;

	NativeMLoader()
	{

	}

	@Override
	public void onResponse(final String response)
	{
		Assert.assertNotNull(listener);
		Runnable runnable = new Runnable()
		{
			@Override
			public void run()
			{
				try
				{
					listener.call1("onDatasFromJava", response);
				}
				catch (Exception exception)
				{
					MassiveUtil.trace("exception = " + exception);
				}
			}
		};
		Extension.callbackHandler.post(runnable);
	}

	@Override
	public void onErrorResponse(VolleyError error)
	{
		final NetworkResponse networkResponse = error.networkResponse;

		try
		{
			String body = null;
			if (networkResponse != null && networkResponse.data != null)
			{
				body = new String(networkResponse.data, "utf-8");
			}

			final String responseBody = body;
			final int code = networkResponse != null ? networkResponse.statusCode : -1;
			Runnable runnable = new Runnable()
			{
				@Override
				public void run()
				{
					listener.call2("onError", code, responseBody);
				}
			};
			Extension.callbackHandler.post(runnable);
		}
		catch (UnsupportedEncodingException exception)
		{

		}
	}

	public void setHttpContentType(String value)
	{
		if (value != null) contentType = value;
	}

	public void setListener(HaxeObject value)
	{
		Assert.assertNotNull("The callback listener object should not be null", value);
		listener = value;
	}

	public void setMethod(String value)
	{
		Assert.assertNotNull(value);
		requestMethod = value;
	}

	public void load()
	{
		Assert.assertNotNull(sourceUrl);
		int method = translateMethod();
		request = new MLoaderStringRequest(method, sourceUrl, this, this);
		request.setParams(variables);
		request.setBody(httpBody);
		request.setHeaders(headers);
		request.setContentType(contentType);
		request.setRetryPolicy(new DefaultRetryPolicy(20 * 1000, 3, 1.0f));

		queue.add(request);
	}

	int translateMethod()
	{
		int result = -1;
		if (requestMethod.equals("GET")) result =  Request.Method.GET;
		else if (requestMethod.equals("POST")) result = Request.Method.POST;
		else if (requestMethod.equals("PUT")) result = Request.Method.PUT;
		else if (requestMethod.equals("DELETE")) result = Request.Method.DELETE;
		else if (requestMethod.equals("HEAD")) result = Request.Method.HEAD;
		else if (requestMethod.equals("OPTIONS")) result = Request.Method.OPTIONS;
		else if (requestMethod.equals("TRACE")) result = Request.Method.TRACE;
		else if (requestMethod.equals("PATCH")) result = Request.Method.PATCH;

		Assert.assertNotSame("Incompatible request method", -1, result);

		return result;
	}
	
	public void setUrl(String url)
	{
		Assert.assertNotNull(url);
		sourceUrl = url;
	}

	public void setTaskId(String id)
	{
		taskId = id;
	}

	public void close()
	{
		if (request != null) request.cancel();
		request = null;
		listener = null;
	}

	public void setHttpBody(String value)
	{
		Assert.assertNotNull(value);
		httpBody = value;
	}

	public void setHttpHeader(String key, String value)
	{
		Assert.assertNotNull(key);
		Assert.assertNotNull(value);
		if (headers == null) headers = new HashMap<String, String>();
		headers.put(key, value);
	}

	public void setHttpVariable(String key, String value)
	{
		Assert.assertNotNull(key);
		Assert.assertNotNull(value);
		if (variables == null) variables = new HashMap<String, String>();
		variables.put(key, value);
	}

	static public NativeMLoader create()
	{
		return new NativeMLoader();
	}
}
