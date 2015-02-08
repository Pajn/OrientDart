part of OrientDart;

class ComparisonOperator {
  final String operator;
  final String value;

  const ComparisonOperator(this.operator, this.value);
}

/// Equal to
ComparisonOperator eq(object) => new ComparisonOperator('T.eq', JSON.encode(object));
/// Not equal to
ComparisonOperator neq(object) => new ComparisonOperator('T.neq', JSON.encode(object));
/// Greater than
ComparisonOperator gt(num number, [String type = '']) =>
  new ComparisonOperator('T.gt', '$number$type');
/// Greater than or equal to
ComparisonOperator gte(num number, [String type = '']) =>
  new ComparisonOperator('T.gte', '$number$type');
/// Less than
ComparisonOperator lt(num number, [String type = '']) =>
  new ComparisonOperator('T.lt', '$number$type');
/// Less than or equal to
ComparisonOperator lte(number, [String type = '']) =>
  new ComparisonOperator('T.lte', '"$number$type"');
/// Contained in list
ComparisonOperator isIn(Iterable list) => new ComparisonOperator('T.in', JSON.encode(list));
/// Not equal to
ComparisonOperator notIn(Iterable list) => new ComparisonOperator('T.notIn', JSON.encode(list));

enum Direction {
  ASCENDING, DESCENDING
}

abstract class Gremlin {
  Future gremlin(String gremlin, [Map<String, dynamic> parameters = const {}]);
}

abstract class GremlinQuery {
  final Gremlin _db;
  var _sb = new StringBuffer();

  GremlinQuery(this._db);
  GremlinQuery._(this._db, this._sb);

  String toString() => _sb.toString();
}

/// Filter steps decide whether to allow an object to pass to the next step or not.
abstract class Filters<T> implements GremlinQuery {

  /// Allows an element if it matches all filters
  Pipe<T> and(filters(T)) {
    return this;
  }

  /// Allows an element if it matches any filter
  Pipe<T> or(filters(T)) {
    return this;
  }

  /// Decide whether to allow an object to pass. Return true from the gremlin closure to allow an object to pass.
  Pipe<T> filter(String gremlin) {
    _sb.write('.filter{$gremlin}');
    return this;
  }

  /// Emits the incoming object if biased coin toss is heads.
  Pipe<T> random(num bias) {
    _sb.write('.random($bias)');
    return this;
  }

  /// Go back to the results of a named step.
  Pipe<T> back(String name) {
    _sb.write('.back(${JSON.encode(name)})');
    return this;
  }

  /// Allows only elements that have not been seen before with an optional property to check on.
  Pipe<T> dedup([String property]) {
    if (property == null) {
      _sb.write('.dedup()');
    } else {
      _sb.write('.dedup{it.$property}');
    }
    return this;
  }

  /// A range filter that emits the objects within a range. Both start and end are inclusive
  Pipe<T> range(num start, num end) {
    _sb.write('[$start..$end]');
    return this;
  }

  /// A index filter that emits the particular indexed object.
  Pipe<T> operator [](num index) {
    _sb.write('[$index]');
    return this;
  }
}

/// Side Effect steps pass the object, but yield some kind of side effect while doing so.
abstract class SideEffect<T extends SideEffect> implements GremlinQuery {
  /// Emits input, but adds input in [collection], where provided closure processes input prior to
  /// insertion (greedy). In being "greedy", 'aggregate' will exhaust all the items that come to it
  /// from previous steps before emitting the next element.
  T aggregate(String collection) {
    _sb.write('.aggregate(${JSON.encode(collection)})');
    return this;
  }
  /// Emits input, but names the previous step.
  T as(String name) {
    _sb.write('.as(${JSON.encode(name)})');
    return this;
  }

  /// Behaves similar to [back] except that it does not filter.
  /// It will go down a particular path and back up to where it left off. As such, its useful for
  /// yielding a side-effect down a particular branch.
  T optional(String name) {
    _sb.write('.optional(${JSON.encode(name)})');
    return this;
  }
}

/// Transform steps take an object and emit a transformation of it.
abstract class Transformers<T> implements GremlinQuery {
  Pipe<String> get id {
    _sb.write('.id');
    return new Pipe._(_db, _sb);
  }

  Pipe<T> get shuffle {
    _sb.write('.shuffle');
    return this;
  }

  Pipe getProperty(String property) {
    _sb.write('.$property');
    return new Pipe._(_db, _sb);
  }

  /// Order the items in the stream [by] the property if provided.
  /// If no property is provided, then a default sort order is used.
  Pipe<T> order({String by, Direction direction: Direction.ASCENDING}) {
    var a = direction == Direction.ASCENDING ? 'a' : 'b';
    var b = direction == Direction.ASCENDING ? 'b' : 'a';
    var property = by != null ? '.${by}' : '';
    return orderGremlin('it.$a$property <=> it.$b$property');
  }

  /// Order the items in the stream according to the closure if provided.
  /// If no closure is provided, then a default sort order is used.
  Pipe<T> orderGremlin(String gremlin) {
    _sb.write('.order{$gremlin}');
    return this;
  }

  /// Transform emits the result of a gremlin closure.
  Pipe<T> transform(String gremlin) {
    _sb.write('.transform{$gremlin}');
    return this;
  }
}

class Pipe<T> extends GremlinQuery with Filters<T>, Transformers<T> implements Future<T> {
  Pipe._(db, sb) : super._(db, sb);

  Future execute() => _db.gremlin(_sb.toString());

  /**
   * Get the first object on the pipe
   *
   * NOTE: This does NOT limit the query, do that with the [next] method
   */
  Future first() => execute().then((result) => result.first);

  /// Calls Pipe.next for all objects in the pipe.
  Future iterate() {
    _sb.write('.iterate()');

    return execute();
  }

  /// Gets the next object in the pipe or the next [n] objects.
  Future next([int n = 1]) {
    if (n == 1) {
      _sb.write('.next()');
    } else {
      _sb.write('.next($n)');
    }

    return execute();
  }

  Future<num> count() {
    _sb.write('.count()');
    return first();
  }

  Future then(onValue(T value), {Function onError}) =>
    execute().then(onValue, onError: onError);

  Future catchError(Function onError, {bool test(Object error)}) =>
    execute().catchError(onError, test: test);

  Future<T> whenComplete(action()) =>
    execute().whenComplete(action);

  Stream<T> asStream() => execute().asStream();

  Future timeout(Duration timeLimit, {onTimeout()}) =>
    execute().timeout(timeLimit, onTimeout: onTimeout);
}

abstract class Element<T extends Element> extends Pipe<T> {
  Element._(db, sb) : super._(db, sb);

  Pipe<Map> get map {
    _sb.write('.map');
    return new Pipe._(_db, _sb);
  }

  /// Get the property keys of an element.
  Pipe<List<String>> keys() {
    _sb.write('.keys()');
    return new Pipe._(_db, _sb);
  }

  /// Get the property values of an element.
  Pipe<List> values() {
    _sb.write('.values()');
    return new Pipe._(_db, _sb);
  }

  /// Remove an element from the graph.
  Future remove() {
    _sb.write('.remove()');
  }

  /// Allows an element if it has a particular property.
  T has(String property, [ComparisonOperator operator]) {
    if (operator == null) {
      _sb.write('.has(${JSON.encode(property)})');
    } else {
      _sb.write('.has(${JSON.encode(property)}, ${operator.operator}, ${operator.value})');
    }
    return this;
  }

  /// Allows an element if it does not have a particular property.
  T hasNot(String property) {
    _sb.write('.hasNot(${JSON.encode(property)})');
    return this;
  }

  /// Allow elements to pass that have their property in the provided start and end interval.
  T interval(String property, num start, num end) {
    _sb.write('.interval(${JSON.encode(property)}, $start, $end)');
    return this;
  }
}

class Vertex extends Element<Vertex> {
  Vertex get inV {
    _sb.write('.inV');
    return new Vertex._(_db, _sb);
  }

  Vertex get outV {
    _sb.write('.outV');
    return new Vertex._(_db, _sb);
  }

  Vertex get bothV {
    _sb.write('.bothV');
    return new Vertex._(_db, _sb);
  }

  Edge get inE {
    _sb.write('.inE');
    return new Edge._(_db, _sb);
  }

  Edge get outE {
    _sb.write('.outE');
    return new Edge._(_db, _sb);
  }

  Edge get bothE {
    _sb.write('.bothE');
    return new Edge._(_db, _sb);
  }

  Vertex._(Gremlin db, sb) : super._(db, sb);
}

class Edge extends Element {
  Pipe<String> get label {
    _sb.write('.label');
    return new Pipe._(_db, _sb);
  }

  Vertex get inV {
    _sb.write('.inV');
    return new Vertex._(_db, _sb);
  }

  Vertex get outV {
    _sb.write('.outV');
    return new Vertex._(_db, _sb);
  }

  Vertex get bothV {
    _sb.write('.bothV');
    return new Vertex._(_db, _sb);
  }

  Edge._(db, sb) : super._(db, sb);
}

//class Vertices extends Vertex with Filterable<Vertices>, Filters<Vertices, Vertex> implements Function {
//  Vertices._(db, sb) : super._(db, sb);
//
//  Vertices call([String edgeLabel]) {
//    _sb.write('(${JSON.encode(edgeLabel)})');
//    return this;
//  }
//}
//
//class Edges extends Edge with Filterable<Edges>, Filters<Edges, Edge> implements Function {
//  Edges._(db, sb) : super._(db, sb);
//
//  Edges call([String label]) {
//    _sb.write('(${JSON.encode(label)})');
//    return this;
//  }
//}

class Graph extends GremlinQuery {
  Vertex get V {
    _sb.write('g.V');
    return new Vertex._(_db, _sb);
  }

  Edge get E {
    _sb.write('g.E');
    return new Edge._(_db, _sb);
  }

  Graph(Gremlin db) : super(db);
  Graph._(db, sb) : super._(db, sb);

  Vertex v(String id) {
    if (!RID_PATTERN.hasMatch(id)) {
      throw 'invalid id';
    }
    _sb.write('g.v(${JSON.encode(id)})');
    return new Vertex._(_db, _sb);
  }

  Edge e(String id) {
    if (!RID_PATTERN.hasMatch(id)) {
      throw 'invalid id';
    }
    _sb.write('g.e(${JSON.encode(id)})');
    return new Edge._(_db, _sb);
  }

  /// Adds an edge to the graph.
  Future addEdge(String startVertexId, String endVertexId, String label, [Map properties]) {
    if (!RID_PATTERN.hasMatch(startVertexId)) {
      throw 'invalid startVertexId';
    }
    if (!RID_PATTERN.hasMatch(endVertexId)) {
      throw 'invalid endVertexId';
    }
  }

  /// Remove an edge.
  Future removeEdge(String id) {
    if (!RID_PATTERN.hasMatch(id)) {
      throw 'invalid id';
    }
  }

  /// Adds a vertex to the graph.
  Future addVertex([Map properties]) {

  }

  /// Remove a vertex.
  Future removeVertex(String id) {
    if (!RID_PATTERN.hasMatch(id)) {
      throw 'invalid id';
    }
  }
}
