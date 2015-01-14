#ifndef HttpLoader_H
#define HttpLoader_H

#include <hx/CFFI.h>

class HttpLoader
{
	public:
		static const char* create(const char* url);
		// static HttpLoader* getLoaderByTask(const char* taskId);
		static void setUrl(const char* taskId, const char* url);
		static void close(const char* taskId);
		static void setVariable(const char* taskId, const char* key, const char* value);
		static void configure(const char* taskId, const char* methodValue, const char* dataValue);
		static void setHeader(const char* taskId, const char* key, const char* value);
		static void setBody(const char* taskId, const char* value);
		static void load(const char* taskId);
		static void setSuccessListener(const char* taskId, AutoGCRoot *value);
		static void setFailureListener(const char* taskId, AutoGCRoot *value);

		HttpLoader(const char* url, const char* taskId);
		~HttpLoader();

		void execute();
		void closeRequest();
		void setHttpHeader(const char* key, const char* value);
		void setHttpVariable(const char* key, const char* value);
		void setErrorListener(AutoGCRoot *listener);
		void setHttpMethod(const char* value);//
		void setHttpBody(const char *url);//
		void setListener(AutoGCRoot *listener);
		void configureUrl(const char *url);
		void setUrlVariable(const char* name, const char *value);

	private:
		const char* source;

};

#endif
