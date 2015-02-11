library gremlin_tests;

import 'package:guinness/guinness.dart';
import '../helpers.dart';

main() {
  describe('Gremlin', () {
    describe('Graph', () {
      it('should have getter for every vertex', () =>
        GRATEFUL_DEAD_CONCERTS.g.V.count()
          .then((count) => expect(count).toEqual(809)));

      it('should have getter for every edge', () =>
        GRATEFUL_DEAD_CONCERTS.g.E.count()
          .then((count) => expect(count).toEqual(8049)));

      it('should have getter for a single vertex', () =>
        GRATEFUL_DEAD_CONCERTS.g.v('9:4').first()
          .then((vertex) {
            expect(vertex).toBeA(Map);
            expect(vertex['song_type']).toEqual('original');
          }));

      it('should have getter for a single edge', () =>
        GRATEFUL_DEAD_CONCERTS.g.e('11:5').first()
          .then((edge) {
            expect(edge).toBeA(Map);
            expect(edge['@class']).toEqual('followed_by');
          }));
    });

    describe('Pipe', () {
      it('should be able to get the next n objects', () =>
        GRATEFUL_DEAD_CONCERTS.g.V.next(3)
          .then((vertices) {
            expect(vertices.length).toEqual(3);

            vertices.forEach((vertex) => expect(vertex).toBeA(Map));
          }));
    });

    describe('Element', () {
      it('should be able to transform to a map', () =>
        GRATEFUL_DEAD_CONCERTS.g.v('9:4').map.first()
          .then((map) {
            expect(map).toBeA(Map);
            expect(map['song_type']).toEqual('original');
          }));

      it('should be able to get a list of keys', () =>
        GRATEFUL_DEAD_CONCERTS.g.v('9:4').keys().first()
          .then((keys) {
            expect(keys).toEqual(['song_type', 'name', 'type', 'performances']);
          }));

      it('should be able to get a list of values', () =>
        GRATEFUL_DEAD_CONCERTS.g.v('9:4').values().first()
          .then((keys) {
            expect(keys).toEqual(['original', 'BERTHA', 'song', 394]);
          }));

      describe('has', () {
        it('should be able to filter elements by property existence', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('name').count()
            .then((count) => expect(count).toEqual(808)));

        it('should be able to filter elements by a property value', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('name', eq('BERTHA')).count()
            .then((count) => expect(count).toEqual(1)));

        it('should be able to filter elements by not equal to a property value', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('name', neq('BERTHA')).count()
            .then((count) => expect(count).toEqual(808)));

        it('should be able to filter elements by greater than', () =>
        GRATEFUL_DEAD_CONCERTS.g.V.has('performances', gt(550)).count()
        .then((count) => expect(count).toEqual(6)));

        it('should be able to filter elements by greater than or equal to', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('performances', gte(550)).count()
            .then((count) => expect(count).toEqual(7)));

        it('should be able to filter elements by less than', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('performances', lt(2)).count()
            .then((count) => expect(count).toEqual(156)));

        it('should be able to filter elements by less than or equal to', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('performances', lte(2)).count()
            .then((count) => expect(count).toEqual(192)));

        it('should be able to filter elements by inlusion in a list', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('performances', isIn([394, 397])).count()
            .then((count) => expect(count).toEqual(3)));

        it('should be able to filter elements by absence in a list', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('performances', notIn([394, 397])).count()
            .then((count) => expect(count).toEqual(806)));
      });

      describe('hasNot', () {
        it('should be able to filter elements by property absence', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.hasNot('name')
            .then((vertices) {
              expect(vertices.length).toEqual(1);
              expect(vertices.first.containsKey('performances')).toBeFalse();
            }));
      });

      it('should be able to filter elements by a property interval', () =>
        GRATEFUL_DEAD_CONCERTS.g.V.interval('performances', 395, 400)
          .then((vertices) {
            expect(vertices.length).toEqual(1);
            expect(vertices.first['performances']).toEqual(397);
          }));
    });

    describe('Vertex', () {
//      it('should be able to get incoming vertices', () =>
//        VEHICLE_HISTORY_GRAPH.g.v('15:613').inV
//          .then((vertices) {
//            expect(vertices).toBeA(List);
//            print(vertices);
//          }));

//        it('should be able to get outgoing vertices', () =>
//          VEHICLE_HISTORY_GRAPH.g.v('15:613').outV
//            .then((vertices) {
//              expect(vertices).toBeA(List);
//              print(vertices);
//            }));

//      it('should be able to get vertices coming from any direction', () =>
//        VEHICLE_HISTORY_GRAPH.g.v('15:613').bothV
//          .then((vertices) {
//            expect(vertices).toBeA(List);
//            print(vertices);
//          }));

      it('should be able to get incoming edges', () =>
        GRATEFUL_DEAD_CONCERTS.g.v('9:4').inE
          .then((edges) {
            expect(edges).toBeA(List);
            expect(edges.length).toEqual(76);
            expect(edges.first['@class']).toEqual('followed_by');
          }));

      it('should be able to get outgoing edges', () =>
        GRATEFUL_DEAD_CONCERTS.g.v('9:4').outE
          .then((edges) {
            expect(edges).toBeA(List);
            expect(edges.length).toEqual(55);
            expect(edges.first['@class']).toEqual('sung_by');
          }));

      it('should be able to get edges coming from any direction', () =>
        GRATEFUL_DEAD_CONCERTS.g.v('9:4').bothE
          .then((edges) {
            expect(edges).toBeA(List);
            expect(edges.length).toEqual(131);
            expect(edges.first['@class']).toEqual('followed_by');
            expect(edges.last['@class']).toEqual('followed_by');
          }));
    });

    describe('Edge', () {
      it('should be able to get the label', () =>
        GRATEFUL_DEAD_CONCERTS.g.e('11:5').label.first()
          .then((label) {
            expect(label).toEqual('followed_by');
          }));

      it('should be able to get the incoming vertex', () =>
        GRATEFUL_DEAD_CONCERTS.g.e('11:5').inV.first()
          .then((vertex) {
            expect(vertex).toBeA(Map);
            expect(vertex['name']).toEqual('JACK STRAW');
          }));

        it('should be able to get the outgoing vertex', () =>
          GRATEFUL_DEAD_CONCERTS.g.e('11:5').outV.first()
            .then((vertex) {
              expect(vertex).toBeA(Map);
              expect(vertex['name']).toEqual('IM A MAN');
            }));

      it('should be able to get both vertices', () =>
        GRATEFUL_DEAD_CONCERTS.g.e('11:5').bothV
          .then((vertices) {
            expect(vertices).toBeA(List);
            expect(vertices.length).toEqual(2);
          }));
    });

    describe('Filters', () {
      it('should be able to filter using a gremlin closure', () =>
        GRATEFUL_DEAD_CONCERTS.g.V.filter('it.name == "JACK STRAW"')
          .then((vertices) => expect(vertices.length).toEqual(1)));

      it('should be able to randomly pick objects', () =>
        expect(GRATEFUL_DEAD_CONCERTS.g.V.random(0.5).toString()).toEqual('g.V.random(0.5)'));

      describe('dedup', () {
        it('should be able to deduplicate', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('performances').order(by: 'performances')
            .getProperty('performances').dedup().next(5)
            .then((performances) {
              expect(performances.first).toEqual([0, 1, 2, 3, 4]);
            }));

        it('should be able to deduplicate on property', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('performances').order(by: 'performances')
            .dedup('performances').next(5)
            .then((vertices) {
              expect(vertices.map((vertex) => vertex['performances'])).toEqual([0, 1, 2, 3, 4]);
            }));
      });

      it('should be able to return objects in a range', () =>
        GRATEFUL_DEAD_CONCERTS.g.V.range(2, 5)
          .then((vertices) => expect(vertices.length).toEqual(4)));

      it('should be able to return a specific object', () =>
        GRATEFUL_DEAD_CONCERTS.g.V[5].first()
          .then((vertex) => expect(vertex).toBeA(Map)));
    });

    describe('Transformers', () {
//      it('should be able to pick only the id', () =>
//        VEHICLE_HISTORY_GRAPH.g.v('15:613').id.first()
//          .then((id) => expect(id).toEqual('15:613')));

      it('should be able to shuffle a pipe', () =>
        expect(GRATEFUL_DEAD_CONCERTS.g.V.shuffle.toString()).toEqual('g.V.shuffle'));

      it('should be able to get a specific property', () =>
        GRATEFUL_DEAD_CONCERTS.g.v('9:4').getProperty('name').first()
          .then((name) => expect(name).toEqual('BERTHA')));

      describe('order', () {
        it('should be able to order a pipe', () =>
          GRATEFUL_DEAD_CONCERTS.g.v('9:4').inE.outV.getProperty('name').order().next(5)
            .then((models) {
              models = models.first;
              expect(models.length).toEqual(5);
              expect(models).toEqual([
                'ALTHEA',
                'AROUND AND AROUND',
                'ATTICS OF MY LIFE',
                'BABY BLUE',
                'BIG RIVER'
              ]);
            }));

        it('should be able to order a pipe with a direction', () =>
          GRATEFUL_DEAD_CONCERTS.g.v('9:4').inE.outV.getProperty('name')
            .order(direction: Direction.DESCENDING).next(5)
            .then((models) {
              models = models.first;
              expect(models.length).toEqual(5);
              expect(models).toEqual([
                'WHY DONT WE DO IT IN THE ROAD',
                'WEREWOLVES OF LONDON',
                'WALKING BLUES',
                'WALKIN THE DOG',
                'VICTIM OR THE CRIME'
              ]);
            }));

        it('should be able to order a pipe on a property', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('performances').order(by: 'performances').next(5)
            .then((models) {
              expect(models.length).toEqual(5);
              models.forEach((model) => expect(model['performances']).toBeLessThan(1));
            }));

        it('should be able to order a pipe on a property with a direction', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('performances')
            .order(by: 'performances', direction: Direction.DESCENDING).next(5)
            .then((models) {
              expect(models.length).toEqual(5);
              models.forEach((model) => expect(model['performances']).toBeGreaterThan(581));
            }));

        it('should be able to order a pipe by a gremlin closure', () =>
          GRATEFUL_DEAD_CONCERTS.g.V.has('performances')
            .orderGremlin('-it.a.performances <=> -it.b.performances').next(5)
            .then((models) {
              expect(models.length).toEqual(5);
              models.forEach((model) => expect(model['performances']).toBeGreaterThan(581));
            }));
      });

      it('should be able to transform a pipe by a gremlin closure', () =>
        GRATEFUL_DEAD_CONCERTS.g.V.has('name')
          .transform('it.name[0..2]').order(direction: Direction.DESCENDING).next(5)
          .then((name) {
            name = name.first;
            expect(name).toEqual(['ins', 'YOU', 'YOU', 'YOU', 'YOU']);
          }));
    });

//    describe('Edges', () {
//      it('should be able to filter by label', () =>
//        VEHICLE_HISTORY_GRAPH.g.E('isMake').first()
//          .then((count) => expect(count).toEqual(500)));
//    });
  });
}
