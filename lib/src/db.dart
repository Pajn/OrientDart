part of OrientDart;

class OrientDb extends Sql implements Gremlin {
  final String name;
  final OrientServer server;

  Graph get g => new Graph(this);

  const OrientDb(this.name, this.server);

  Future<List> gremlin(String gremlin, [Map<String, dynamic> parameters = const {}]) =>
    server.post('/command/$name/gremlin', gremlin)
      .then(_result);

  Future<List> sql(String sql, {Map<String, dynamic> parameters: const {}, int limit}) =>
    server.post('/command/$name/sql', prepare(sql, parameters))
      .then(_result);

  _result(Map response) {
    List result = response['result'];

    if (result.length > 0) {
      var keys = result.first.keys.where((key) => !key.startsWith('@'));

      if (keys.length == 1 && keys.first == 'value') {
        result = result.map((value) => value['value']).toList();
      }
    }

    return result;
  }
}
