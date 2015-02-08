library sql_utils;

import 'dart:convert';

final PARAMS = new RegExp(r'([^A-Za-z0-9]:([A-Za-z_][A-Za-z0-9_@-]*))');
final CARRIAGE_RETURN = new RegExp(r'\r');
final NEW_LINE = new RegExp(r'\n');
final STRING = new RegExp(r'([^"\\]*(?:\\.[^"\\]*)*)"');

/**
 * Prepare a query.
 *
 * @param {String} query The query to prepare.
 * @param {Object} params The bound parameters for the query.
 * @return {String} The prepared query.
 */
String prepare(String query, Map<String, dynamic> parameters) {
  if (parameters.isEmpty) {
    return query;
  } else {
    return prepareObject(query, parameters);
  }
}

String prepareObject(String query, Map<String, dynamic> parameters) =>
  query.replaceAllMapped(PARAMS, (match) {
    var all = match.group(0);
    var param = match.group(2);
    if (param != null && parameters.containsKey(param)) {
      return all[0] + encode(parameters[param]);
    } else {
      return all;
    }
  });

/**
 * Encode a value for use in a query, escaping and quoting it if required.
 *
 * @param {Mixed} value The value to encode.
 * @return {Mixed} The encoded value.
 */
encode(value) {
  if (value == null) {
    return 'null';
  } else if (value is num) {
    return value;
  } else if (value is bool) {
    return value;
  } else if (value is String) {
    //return '"${escape(value)}"';
    return JSON.encode(value);
//  } else if (value is DateTime) {
//    return 'date("' + getOrientDbUTCDate(value) + '", "yyyy-MM-dd HH:mm:ss", "UTC")';
//  }
//  else if (value is Rid) {
//    return value.toString();
//  }
  } else if (value is List) {
    return '[' + value.map(encode) + ']';
  } else if (value is Map) {
    var offset = 0;
    var length = value.keys.length;

    if (length > 0 && value['@type'] == null) {
      offset = 1;
    }

    var parts = [];
    var key, i;

    if (offset) {
      parts[0] = '"@type":"d"';
    }

    for (i = offset; i < length + offset; i++) {
      key = value.keys[i - offset];
      parts[i] = '${JSON.encode(key)}:${encode(value[key])}';
    }

    return '{'+parts.join(',')+'}';
  } else {
    throw 'Unsuported type';
  }
}

///**
// * Escape the given input for use in a query.
// *
// * > NOTE: Because of a fun quirk in OrientDB's parser, this function can only be safely
// * used on SQL segments that are enclosed in DOUBLE QUOTES (") not single quotes (').
// *
// * @param {String} input The input to escape.
// * @return {String} The escaped input.
// */
//escape(String input) =>
//  input
//    .replaceAll(CARRIAGE_RETURN, r'\\r')
//    .replaceAll(NEW_LINE, r'\\n')
//    .replaceAllMapped(STRING, (match) => '${match.group(1)}\\"');
