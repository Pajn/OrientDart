part of OrientDart;

abstract class Sql {
  const Sql();

  InsertQuery insert() {
    return new InsertQuery(this);
  }

  SelectQuery select([List<String> projections = const []]) {
    return new SelectQuery(this, projections);
  }

  UpdateQuery update(String projection) {
    return new UpdateQuery(this, projection);
  }

  Future<List<Map>> sql(String sql, {Map<String, dynamic> parameters: const {}});
}

abstract class Query<T extends Query> {
  final Sql _db;
  var _parameters = {};

  Query(this._db);

  /**
   * Executes the query and return all records
   */
  Future<List<Map>> all([Map<String, dynamic> parameters = const {}]) {
    _parameters.addAll(parameters);

    return _db.sql(toString(), parameters: _parameters);
  }

  /**
   * Executes the query and return the first record in the result
   *
   * NOTE: This does NOT limit the query, do that with the limit method on [Filter] queries
   */
  Future<Map> one([Map<String, dynamic> parameters = const {}]) =>
    all(parameters)
      .then((result) => (result.length > 0) ? result.first : null);

  /**
   * Executes the query and return the results in [column]
   *
   * NOTE: This does NOT alter the projections of the query, do that with the projections argument
   * on [SelectQuery] constructor
   */
  Future<List<dynamic>> column(String column, [Map<String, dynamic> parameters = const {}]) =>
    all(parameters)
      .then((result) => result.map(_column(column)).toList());

  /**
   * Executes the query and return the result in the first record in [column]
   *
   * If [column] is not specified the first column will be used.
   * NOTE: This does NOT limit nor alter the projections of the query, do that with the limit
   * method on [Filter] queries and projections argument on [SelectQuery] constructor
   */
  Future<dynamic> scalar({Map<String, dynamic> parameters: const {}, String column}) =>
    one(parameters)
      .then(_column(column));

  T copy();
  String toString();

  _column(String column) => (Map row) =>
    row[column != null ? column : row.keys.firstWhere((c) => (c == RID && !row[RID].startsWith('#-')) || !c.startsWith('@'))];
}

abstract class Filter<T extends Filter> {
  var _where = {};
  var _whereClause;
  var _limit;

  /**
   * Filter the query to records that have the specified properties
   *
   * Overrides [whereClause]
   */
  T where(Map<String, dynamic> properties) {
    _where.addAll(properties);
    return this;
  }

  /// Specify a custom WHERE clause
  T whereClause(String clause) {
    _whereClause = clause;
    return this;
  }

  /// Limit the result to [amount] number of records
  T limit(int amount) {
    _limit = amount;
    return this;
  }

  _writeWhere(StringBuffer sb, Map parameters) {
    if (_whereClause != null) {
      sb.writeAll([' WHERE ', _whereClause]);
    } else if (_where.isNotEmpty) {
      sb.write(' WHERE ');

      var index = 0;
      var stop = _where.keys.length;
      _where.forEach((key, value) {
        sb.writeAll([key, ' = :_Where_', key]);
        parameters['_Where_$key'] = value;

        index++;
        if (index < stop) {
          sb.write(' AND ');
        }
      });
    }
  }

  _writeLimit(StringBuffer sb) {
    if (_limit != null) {
      sb.writeAll([' LIMIT ', _limit]);
    }
  }
}

abstract class WriteQuery<T extends WriteQuery> extends Query <T> {
  var _content;

  WriteQuery(Sql db) : super(db);

  /// Set the new content of the record
  T content(Map<String, dynamic> fields) {
    _content = fields;
    return this;
  }
}

class InsertQuery extends WriteQuery<InsertQuery> {
  var _into;
  var _cluster;
  var _returns;

  InsertQuery(Sql db) : super(db);

  /// Specify the class of the new record
  InsertQuery into(String className) {
    _into = className;
    return this;
  }

  /// Specify the cluster where the new record should be located
  InsertQuery cluster(String cluster) {
    _cluster = cluster;
    return this;
  }

  /// Specify what should be returned. Usually used with [RID] to get the new rid or [THIS] to
  /// return the new record
  InsertQuery returns(String expression) {
    _returns = expression;
    return this;
  }

  InsertQuery copy() =>
    new InsertQuery(_db)
      .._into = _into
      .._cluster = _cluster
      .._returns = _returns
      .._content = _content;

  String toString() {
    var sb = new StringBuffer('INSERT INTO ');

    if (_into == null && _cluster != null) {
      sb.writeAll(['cluster:', _cluster]);
    } else {
      sb.write(_into);

      if (_cluster != null) {
        sb.writeAll([' CLUSTER', _cluster]);
      }
    }
    sb.write(' CONTENT ');
    sb.write(JSON.encode(_content));

    if (_returns != null) {
      sb.write(' RETURN ');
      sb.write(_returns);
    }

    return sb.toString();
  }
}

class SelectQuery extends Query with Filter<SelectQuery> {
  final List<String> projections;
  var _from;
  var _fromAll;
  var _fetch;

  SelectQuery(Sql db, this.projections) : super(db);

  /**
   * Specify a target for this query, usually a class, a cluster or a RID
   *
   * Overrides [fromAll]
   */
  SelectQuery from(String target) {
    _from = target;
    return this;
  }

  /**
   * Specify multiple RIDs as target for this query
   */
  SelectQuery fromAll([List<String> rids]) {
    _fromAll = rids;
    return this;
  }

  /// Specify a fetchplan for this query
  SelectQuery fetch(Map<String, int> plan) {
    _fetch = plan;
    return this;
  }

//  SelectQuery alias(Map<String, String> columns) {
//    return this;
//  }
//
//  SelectQuery defaults(Map<String, dynamic> columns) {
//    return this;
//  }

  SelectQuery copy() =>
    new SelectQuery(_db, projections)
      .._from = _from
      .._fromAll = _fromAll
      .._fetch = _fetch
      .._where = _where
      .._whereClause = _whereClause
      .._limit = _limit;

  String toString() {
    var sb = new StringBuffer('SELECT ');
    sb.writeAll(projections, ', ');
    sb.write(' FROM ');

    if (_from != null) {
      sb.write(_from);
    } else {
      sb.writeAll(_fromAll, ', ');
    }

    _writeWhere(sb, _parameters);
    _writeLimit(sb);

    if (_fetch != null) {
      sb.write(' FETCHPLAN');
      _fetch.forEach((path, depth) => sb.writeAll([' ', path, ':', depth]));
    }

    return sb.toString();
  }
}

class UpdateQuery extends WriteQuery<UpdateQuery> with Filter<UpdateQuery> {
  final String projection;
  var _set = {};
  var _returning;
  var _returns;

  UpdateQuery(Sql db, this.projection) : super(db);

  /**
   * Specify fields to update
   *
   * NOTE: Overrides [content]
   */
  UpdateQuery set(Map<String, dynamic> fields) {
    _set.addAll(fields);
    return this;
  }

  /// Specify what should be returned and if it should be returned before or after the update
  UpdateQuery returns(UpdateReturning returning, String expression) {
    _returning = returning;
    _returns = expression;
    return this;
  }

  UpdateQuery copy() =>
    new UpdateQuery(_db, projection)
      .._set = _set
      .._returning = _returning
      .._returns = _returns
      .._where = _where
      .._whereClause = _whereClause
      .._limit = _limit;

  String toString() {
    var sb = new StringBuffer('Update ');
    sb.write(projection);

    if (_content != null) {
      sb.write(' CONTENT ');
      sb.write(JSON.encode(_content));
    } else {
      sb.write(' SET ');

      var index = 0;
      var stop = _set.keys.length;
      _set.forEach((key, value) {
        sb.writeAll([key, ' = :_Set_', key]);
        _parameters['_Set_$key'] = value;

        index++;
        if (index < stop) {
          sb.write(', ');
        }
      });
    }

    if (_returns != null) {
      sb.write(' RETURN ');
      if (_returning == UpdateReturning.AFTER) {
        sb.write('AFTER ');
      } else {
        sb.write('BEFORE ');
      }
      sb.write(_returns);
    }

    _writeWhere(sb, _parameters);
    _writeLimit(sb);

    return sb.toString();
  }
}

enum UpdateReturning {
  BEFORE, AFTER
}
