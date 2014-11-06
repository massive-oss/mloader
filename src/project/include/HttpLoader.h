#ifndef HttpLoader_H
#define HttpLoader_H

#include <hx/CFFI.h>

class HttpLoader
{
	public:
		static HttpLoader* create(const char* url);
		HttpLoader(const char* url);
		~HttpLoader();
		void configure(const char* method, const char* data);
		void load();
		void setErrorListener(AutoGCRoot *listener);
		void setHeader(const char* key, const char* value);
		void setHttpBody(const char *url);
		void setListener(AutoGCRoot *listener);
		void setUrl(const char *url);
		void setUrlVariable(const char* name, const char *value);

	private:
		const char* source;

};

#endif
