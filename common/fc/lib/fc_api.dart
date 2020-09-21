abstract class FcHttpRequest {
  String get path;
  String get url;
  String get method;
  Map<String, String> get headers;
  Future<String> getBodyString();
}

typedef FcRequestHandler = void Function(FcHttpRequest request);

abstract class FcHttpFunction {}

abstract class FcHttp {
  FcHttpFunction onRequest(FcRequestHandler handler);
}

abstract class FcHttpContext {}

abstract class FcHttpResponse {
  Future sendString(String body);

  void setHeader(String name, String value);

  void setStatusCode(int statusCode);
}

typedef FcHttpHandler = dynamic Function(
    FcHttpRequest request, FcHttpResponse response, FcHttpContext context);

/// Abstract factory
abstract class AliyunFunctionCompute {
  /// Can be calledly once
  void exportHttpHandler(FcHttpHandler handler, {String name = 'handler'});
}

// HTTP trigger interface format
//- Nodejs runtime:
//function(request, response, context)
//Request structure
//- headers: Map type, stores the key-value pairs from the HTTP client.
//- path: String type, the HTTP URL.
//- queries: Map type, stores the key-value pairs from the HTTP URL’s query section. The
//57Function Compute
//User Guide
//values can be strings or arrays.
//- method: String type, the HTTP method.
//- clientIP: String type, the IP address of the client.
//- url: String type, the URL of the request.
//Get HTTP body: Requests in HTTP triggers are compatible with HTTP requests. HTTP triggers use the
//bodies in HTTP requests directly. No additional field is provided for bodies.
//// Example
//var getRawBody = require('raw-body')
//getRawBody(request, function(err, data){
//var body = data
//})
//Note: The following fields in the Headers key are ignored. Function Compute contains these
//fields and does not support user-defined settings. Keys that start with x-fc- are also ignored.
//- accept-encoding
//- connection
//- keep-alive
//- proxy-authorization
//- te
//- trailer
//- transfer-encoding
//Response methods
//- response.setStatusCode(statusCode): Sets the status code.
//●
//param statusCode : (required, type integer)
//- response.setHeader(headerKey, headerValue): Sets the header.
//● param headerKey : (required, type string)
//● param headerValue : (required, type string)
//- response.deleteHeader(headerKey): Deletes the header.
//●
//param headerKey: (required, type string)
//- response.send(body): Sends the body.
//●
//param body: (required, typeBuffer or a string or a stream.Readable)
//Note: The following fields in the Headers key are ignored. Function Compute contains these
//fields and does not support user-defined settings. Keys that start with x-fc- are also ignored.
//- connection
//- content-length
//- content-encoding
//- date
//58Function Compute
//User Guide
//- keep-alive
//- proxy-authenticate
//- server
//- trailer
//- transfer-encoding
//- upgrade
//Limits for requests
//If the following limits are exceeded, the system throws a 400 status code and InvalidArgument error
//code.
//Headers size: The total size of all keys and values in the headers cannot exceed 4 KB.
//Path size: In each query parameter, the path size cannot exceed 4 KB.
//Body size: The HTTP body size cannot exceed 6 MB.
//Limits for responses
//If the following limits are exceeded, the system throws a 502 status code and BadResponse error
//code.
//Headers size: The total size of all keys and values in the headers cannot exceed 4 KB.
//Body size: The HTTP body size cannot exceed 6 MB.
