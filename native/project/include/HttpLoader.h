#ifndef HttpLoader_H
#define HttpLoader_H

#include <hx/CFFI.h>

class HttpLoader
{
	public:
		static HttpLoader* create(const char* url);
		HttpLoader(const char* url);
		~HttpLoader();
		void setListener(AutoGCRoot *listener);
		void load();
		void setUrlVariable(const char* name, const char *value);

	private:
		const char* source;

};

#endif
