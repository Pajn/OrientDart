part of OrientDart;

class OrientServer {
  final String host;
  final int port;
  final String username;
  final String password;

  get _auth =>
    {'authorization': 'Basic ${CryptoUtils.bytesToBase64(UTF8.encode("$username:$password"))}'};

  const OrientServer({
    this.host: '127.0.0.1',
    this.port: 2480,
    this.username: 'root',
    this.password: 'root'
  });

  /// Creates a database
  Future<OrientDb> create(String databaseName, {
    DatabaseStorage storage: DatabaseStorage.PLOCAL,
    DatabaseType type: DatabaseType.GRAPH
  }) => post('/database/$databaseName/${_storage(storage)}/${_type(type)}')
    .then((_) => new OrientDb(databaseName, this));

  /// Checks if a database exists
  Future<bool> exists(String databaseName) =>
    get('/database/$databaseName')
      .then((_) => true)
      .catchError((_) => false);

  /// Drops a database
  Future drop(String databaseName) =>
    delete('/database/$databaseName')
      .then((_) => true);

  /// Lists databases on the server
  Future<List<OrientDb>> list() =>
    get('/listDatabases')
      .then((response) => response['databases'].map((database) => new OrientDb(database, this)));

  Future delete(String path) =>
    http.delete('http://$host:$port$path', headers: _auth);

  Future get(String path) =>
    http.get('http://$host:$port$path', headers: _auth)
      .then((response) => JSON.decode(response.body));

  Future post(String path, [body]) =>
    http.post('http://$host:$port$path', body: body, headers: {
        'Accept-Encoding': 'gzip,deflate'
    }..addAll(_auth))
      .then((response) {
        print(body);
        if (response.statusCode == 200) {
          return JSON.decode(response.body);
        } else if (response.statusCode >= 400) {
          throw response.body;
        } else {
          return response.body;
        }
      });
}

String _storage(DatabaseStorage storage) {
  switch (storage) {
    case DatabaseStorage.PLOCAL: return 'plocal';
    case DatabaseStorage.MEMORY: return 'memory';
  }
  throw 'Unsuported storage';
}

String _type(DatabaseType type) {
  switch (type) {
    case DatabaseType.GRAPH: return 'graph';
    case DatabaseType.DOCUMENT: return 'document';
  }
  throw 'Unsuported type';
}

enum DatabaseStorage {
  PLOCAL, MEMORY
}

enum DatabaseType {
  GRAPH, DOCUMENT
}
