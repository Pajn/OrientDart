import 'dart:async';

import 'package:OrientDart/orient.dart';
export 'package:OrientDart/orient.dart';

typedef Future Task();

const TEST_SERVER = const OrientServer();
const GRATEFUL_DEAD_CONCERTS = const OrientDb('GratefulDeadConcerts', TEST_SERVER);

Task createTestDb(name, cb) => () =>
  deleteTestDb(name)()
    .then((_) => TEST_SERVER.create(name, storage: DatabaseStorage.MEMORY))
    .then(cb);

Task deleteTestDb(name) => () =>
  TEST_SERVER.exists(name)
    .then((exists) {
      if (exists) {
        return TEST_SERVER.drop(name);
      } else {
        return new Future.value(false);
      }
    });
