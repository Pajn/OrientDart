library server_tests;

import 'package:guinness/guinness.dart';
import '../helpers.dart';

main() {
  describe('Server', () {
    describe('create()', () {
      it('should create a new database', () =>
        TEST_SERVER.create('testdb_server', storage: DatabaseStorage.MEMORY)
          .then((db) {
            expect(db).toBeA(OrientDb);
            expect(db.name).toEqual('testdb_server');
          }));
    });

//    describe('Server::freeze()', () {
//      it('should freeze', () {
//        return TEST_SERVER.freeze('testdb_server')
//        .then((response) {
//          expect(response).toBeTrue();
//        });
//      });
//    });
//
//    describe('Server::release()', () {
//      it('should release', () {
//        return TEST_SERVER.release('testdb_server')
//        .then((response) {
//          expect(response).toBeTrue();
//        });
//      });
//    });

    describe('list()', () {
      it('should list the existing databases', () =>
        TEST_SERVER.list()
          .then((dbs) {
            expect(dbs.length).toBeGreaterThan(0);
            dbs.forEach((db) {
              expect(db).toBeA(OrientDb);
            });
          }));
    });

    describe('exists()', () {
      it('should confirm an existing database exists', () =>
        TEST_SERVER.exists('testdb_server')
          .then((exists) {
            expect(exists).toBeTrue();
          }));

      it('should confirm a missing database does not exist', () =>
        TEST_SERVER.exists('a_missing_database')
          .then((exists) {
            expect(exists).toBeFalse();
          }));
    });

    describe('delete()', () {
      it('should delete a database', () =>
        TEST_SERVER.exists('testdb_server')
          .then((exists) => expect(exists).toBeTrue())
          .then((_) => TEST_SERVER.drop('testdb_server'))
          .then((response) {
            expect(response).toBeTrue();
          })
          .then((_) => TEST_SERVER.exists('testdb_server'))
          .then((exists) => expect(exists).toBeFalse()));
    });

//    describe('Server::config.list', () {
//      it('should list the server config', () =>
//        TEST_SERVER.config.list()
//        .then((config) {
//          config.should.have.property('db.pool.min');
//        }));
//    });
//
//    describe('Server::config.get', () {
//      it('should get a server config key', () =>
//        TEST_SERVER.config.get('db.pool.min')
//        .then((value) {
//          value.should.have.type('string');
//        }));
//    });
  });
}
