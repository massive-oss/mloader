package massive.mloader;

import com.android.volley.AuthFailureError;
import com.android.volley.Response;
import com.android.volley.toolbox.StringRequest;

import java.util.HashMap;
import java.util.Map;

public class MLoaderStringRequest extends StringRequest
{
	Map<String, String> params;
	Map<String, String> headers;
	String requestBody;
	String contentType;

	public MLoaderStringRequest(int method, String url,
		Response.Listener<String> listener,
		Response.ErrorListener errorListener)
	{
		super(method, url, listener, errorListener);
	}

	public void setContentType(String value)
	{
		contentType = value;
	}

	@Override
	public String getBodyContentType()
	{
		String result;
		if (contentType == null)
			result = super.getBodyContentType();
		else
			result = contentType;
		return result;
	}

	public void setParams(HashMap<String, String> value)
	{
		params = value;
	}

	public void setBody(String value)
	{
		requestBody = value;
	}

	public void setHeaders(HashMap<String, String> value)
	{
		headers = value;
	}

	@Override
	public byte[] getBody() throws AuthFailureError
	{
		if (requestBody == null) return null;
		return requestBody.getBytes();
	}

	@Override
	public Map<String, String> getHeaders()
	{
		if (headers == null) headers = new HashMap<String, String>();
		return headers;
	}

	@Override
	protected Map<String, String> getParams()
	{
		if (params == null) params = new HashMap<String, String>();
		return params;
	}
}

