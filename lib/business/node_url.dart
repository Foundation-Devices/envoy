const String TCP_PREFIX = "tcp://";
const String SSL_PREFIX = "ssl://";

const String TCP_SUFFIX = ":t";
const String SSL_SUFFIX = ":s";

const String TCP_PORT = ":50001";
const String SSL_PORT = ":50002";

String parseNodeUrl(String nodeUrl) {
  if (nodeUrl.startsWith(TCP_PREFIX) || nodeUrl.startsWith(SSL_PREFIX)) {
    return nodeUrl;
  } else {
    if (nodeUrl.endsWith(SSL_SUFFIX)) {
      return SSL_PREFIX +
          nodeUrl.substring(0, nodeUrl.length - SSL_SUFFIX.length);
    }

    if (nodeUrl.endsWith(TCP_SUFFIX)) {
      return TCP_PREFIX +
          nodeUrl.substring(0, nodeUrl.length - TCP_SUFFIX.length);
    }

    if (nodeUrl.endsWith(SSL_PORT)) {
      return SSL_PREFIX + nodeUrl;
    }

    if (nodeUrl.endsWith(TCP_PORT)) {
      return TCP_PREFIX + nodeUrl;
    }
  }

  return nodeUrl;
}
