library sql_OUsers;

import 'package:guinness/guinness.dart';
import '../helpers.dart';

main() {
  describe('SQL', () {
    OrientDb db;

    beforeEach(createTestDb('Testdb_dbapi_query', (_db) => db = _db));
    afterEach(deleteTestDb('Testdb_dbapi_query'));

    describe('Query::one()', () {
      it('should return one record', () =>
        db.select()
          .from('OUser')
          .limit(1)
          .one()
          .then((user) {
            expect(user).toBeA(Map);
            expect(user.containsKey('name')).toBeTrue();
          }));

      it('should return one record with parameters', () =>
        db.select()
          .from('OUser')
          .whereClause('name = :name')
          .limit(1)
          .one({'name': 'reader'})
          .then((user) {
            expect(user).toBeA(Map);
            expect(user['name']).toEqual('reader');
          }));
    });

    describe('Query::all()', () {
      it('should return all the records', () =>
        db.select()
          .from('OUser')
          .limit(2)
          .all()
          .then((users) {
            expect(users).toBeA(List);
            expect(users.length).toEqual(2);
          }));

      it('should return all the records with parameters', () =>
        db.select()
          .from('OUser')
          .whereClause('name = :name')
          .all({'name': 'reader'})
          .then((users) {
            expect(users).toBeA(List);
            expect(users.length).toEqual(1);
            expect(users[0]['name']).toEqual('reader');
          }));
    });

    describe('Query::scalar()', () {
      it('should return the scalar result', () =>
        db.select(['count(*)'])
          .from('OUser')
          .scalar()
          .then((response) {
            expect(response).toEqual(3);
          }));

      it('should return the scalar result, even when many columns are selected', () =>
        db.select(['count(*), max(count(*))'])
          .from('OUser')
          .scalar()
          .then((response) {
            expect(response).toEqual(3);
          }));

      it('should return the scalar result with parameters', () =>
        db.select(['name'])
          .from('OUser')
          .whereClause('name = :name')
          .scalar(parameters: {'name': 'reader'})
          .then((name) {
            expect(name).toEqual('reader');
          }));
    });

//    describe('Query::transform()', () {
//      it('should apply a single transform function', () =>
//        db.select().from('OUser').transform((user) {
//          user.wat = true;
//          return user;
//        }).limit(1).one().then((user) {
//          user.wat.should.be.tru( );
//        }));
//
//      it('should transform values according to an object', () =>
//        db.select().from('OUser').transform({
//            '@rid': String, 'name': (name) {
//              return name.toUpperCase( );
//            }
//        }).where({
//            'name': 'reader'
//        }).limit(1).one().then((user) {
//          expect(user['@rid']).toBeA(String);
//          user.name.should.equal('READER');
//        }));
//
//      it('should apply multiple transforms in order', () =>
//        db.select().from('OUser').transform((user) {
//          user.wat = true;
//          return user;
//        }).transform({
//            '@rid': String, 'name': (name) {
//              return name.toUpperCase( );
//            }
//        }).where({
//            'name': 'reader'
//        }).limit(1).one().then((user) {
//          user.wat.should.be.tru( );
//          expect(user['@rid']).toBeA(String);
//          user.name.should.equal('READER');
//        });
//      });
//    });

    describe('Query::column()', () {
      it('should return a specific column', () =>
        db.select(['name'])
          .from('OUser')
          .column('name')
          .then((names) {
            expect(names.length).toBeGreaterThan(2);
            expect(names[0]).toBeA(String);
            expect(names[1]).toBeA(String);
            expect(names[2]).toBeA(String);
          }));

      it('should return two columns', () =>
        db.select(['name', 'status'])
          .from('OUser')
          .all()
          .then((results) {
            expect(results.length).toBeGreaterThan(2);

            results.forEach((result) {
              expect(result.keys.length).toBeGreaterThan(1);
              expect(result.containsKey('name')).toBeTrue();
              expect(result.containsKey('status')).toBeTrue();
            });
          }));
    });

//    describe('Query::alias()', () {
//      it('should alias columns to different names', () =>
//        db.select()
//          .from('OUser')
//          .alias({'name': 'nom', 'status': 'stat'})
//          .all()
//          .then((results) {
//            expect(results.length).toBeGreaterThan(2);
//            results.forEach((result) {
//              expect(result.keys.length).toEqual(2);
//              expect(result.containsKey('nom')).toBeTrue();
//              expect(result.containsKey('stat')).toBeTrue();
//            });
//          }));
//    });

//    describe('Query::defaults()', () {
//      it('should apply the given default values', () =>
//        db.select()
//         .from('OUser')
//         .defaults({'name': 'NEVER_MATCHES', 'nonsense': true})
//         .where({'name': 'reader'})
//         .limit(1)
//         .one()
//         .then((user) {
//           expect(user['name']).toEqual('reader');
//           expect(user['nonsense']).toBeTrue();
//         }));
//
//      it('should apply the given default values to many records', () =>
//        db.select()
//          .from('OUser')
//          .defaults({'name': 'NEVER_MATCHES', 'nonsense': true})
//          .all()
//          .then((users) {
//            expect(users.length).toBeGreaterThan(0);
//            users.forEach((user) {
//              expect(user['name']).not.toEqual('NEVER_MATCHES');
//              expect(user['nonsense']).toBeTrue();
//            });
//          }));
//
//      it('should apply the given default values to many records before returning a single column', () =>
//        db.select()
//          .from('OUser')
//          .defaults({'name': 'NEVER_MATCHES', 'nonsense': true})
//          .column(['nonsense'])
//          .all()
//          .then((names) {
//            expect(names.length).toBeGreaterThan(0);
//            names.forEach((name) {
//              expect(name).not.toEqual('NEVER_MATCHES');
//            });
//          }));
//
//      it('should apply the given default values to many records before returning2 columns', () =>
//        db.select()
//          .from('OUser')
//          .defaults({'name': 'NEVER_MATCHES', 'nonsense': true})
//          .column(['name', 'nonsense'])
//          .all()
//          .then((users) {
//            expect(users.length).toBeGreaterThan(0);
//            users.forEach((user) {
//              expect(user['name']).not.toEqual('NEVER_MATCHES');
//              expect(user['nonsense']).toBeTrue();
//            });
//          }));
//    });

    describe('Db::select()', () {
      it('should select a user', () =>
        db.select()
          .from('OUser')
          .where({'name': 'reader'})
          .one()
          .then((user) {
            expect(user['name']).toEqual('reader');
          }));

      it('should select a record by its RID', () =>
        db.select()
          .from('OUser')
          .where({'@rid': '#5:0'})
          .one()
          .then((user) {
            expect(user).toBeA(Map);
            expect(user['name']).toEqual('admin');
          }));

      it('should select a user with a fetch plan', () =>
        db.select()
          .from('OUser')
          .where({'name': 'reader'})
          .fetch({'roles': 3})
          .one()
          .then((user) {
            expect(user['name']).toEqual('reader');
            expect(user['roles'].length).toBeGreaterThan(0);
            expect(user['roles'].first['@class']).toEqual('ORole');
          }));

      it('should select a user with multiple fetch plans', () =>
        db.select()
          .from('OUser')
          .where({'name': 'reader'})
          .fetch({'roles': 3, '*': -1})
          .one()
          .then((user) {
            expect(user['name']).toEqual('reader');
            expect(user['roles'].length).toBeGreaterThan(0);
            expect(user['roles'].first['@class']).toEqual('ORole');
          }));
    });

//    describe('Db::traverse()', () {
//      it('should traverse a user', () =>
//        db.traverse()
//          .from('OUser')
//          .where({'name': 'reader'})
//          .all()
//          .then((rows) {
//            expect(rows).toBeA(List);
//            rows.length.should.be.above(1);
//          }));
//    });

    describe('Db::insert()', () {
      it('should insert a user', () =>
        db.insert()
          .into('OUser')
          .content({'name': 'OUser', 'password': 'OUserpasswordgoeshere', 'status': 'ACTIVE'})
          .one()
          .then((user) {
            expect(user['name']).toEqual('OUser');
          }));

      it('should support returning the inserted rid', () =>
        db.insert()
          .into('OUser')
          .content({'name': 'OUser', 'password': 'OUserpasswordgoeshere', 'status': 'ACTIVE'})
          .returns(RID)
          .scalar()
          .then((rid) {
            expect(RID_PATTERN.hasMatch(rid)).toBeTrue();
          }));
    });

    describe('Db::update()', () {
      it('should update a user', () =>
        db.update('OUser')
          .set({'foo': 'bar'})
          .where({'name': 'reader'})
          .limit(1)
          .scalar()
          .then((count) {
            expect(count).toEqual(1);
          }));
    });

    describe('Db::query()', () {
      it('should execute a create class query', () =>
        db.sql('create class Test'));

      it('should execute an insert query', () =>
        db.sql('insert into OUser (name, password, status) values (:name, :password, :status)',
          parameters: {
            'name': 'Samson', 'password': 'mypassword', 'status': 'active'
          })
        .then((response){
          expect(response[0]['name']).toEqual('Samson');
        }));

      it('should exec a raw select command', () =>
        db.sql('select from OUser where name=:name', parameters: {
          'name': 'reader'
        }).then((result){
          expect(result).toBeA(List);
          expect(result.length).toBeGreaterThan(0);
        }));

//      it('should execute a script command', () =>
//        db.sql('123456;', parameters: {
//          'language': 'javascript', 'class': 's'
//        }).then((response) {
//          response.results.length.should.equal(1);
//        }));

      it('should execute a select query string', () =>
        db.sql('select from OUser where name=:name', parameters: {
          'name': 'reader'
        }, limit: 1)
          .then((result){
            expect(result).toBeA(List);
            expect(result.length).toBeGreaterThan(0);
            expect(result.first['@class']).toEqual('OUser');
          }));

      it('should execute a delete query', () =>
        db.sql('delete from OUser where name=:name', parameters: {
          'name': 'writer'
        }).then((response){
          expect(response.first['value']).toEqual(1);
        }));
    });
  });
}
