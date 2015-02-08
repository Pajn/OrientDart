library gremlin_tests;

import 'package:guinness/guinness.dart';
import '../helpers.dart';

main() {
  describe('Gremlin', () {
    describe('Graph', () {
      it('should have getter for every vertex', () =>
        VEHICLE_HISTORY_GRAPH.g.V.count()
          .then((count) => expect(count).toEqual(3486)));

      it('should have getter for every edge', () =>
        VEHICLE_HISTORY_GRAPH.g.E.count()
          .then((count) => expect(count).toEqual(2908)));

      it('should have getter for a single vertex', () =>
        VEHICLE_HISTORY_GRAPH.g.v('15:613').first()
          .then((vertex) {
            expect(vertex).toBeA(Map);
            expect(vertex['@class']).toEqual('Make');
          }));

      it('should have getter for a single edge', () =>
        VEHICLE_HISTORY_GRAPH.g.e('21:5186').first()
          .then((edge) {
            expect(edge).toBeA(Map);
            expect(edge['@class']).toEqual('Bought');
          }));
    });

    describe('Pipe', () {
      it('should be able to get the next n objects', () =>
        VEHICLE_HISTORY_GRAPH.g.V.next(3)
          .then((vertices) {
            expect(vertices.length).toEqual(3);

            vertices.forEach((vertex) => expect(vertex).toBeA(Map));
          }));
    });

    describe('Element', () {
      it('should be able to transform to a map', () =>
        VEHICLE_HISTORY_GRAPH.g.v('15:613').map.first()
          .then((map) {
            expect(map).toBeA(Map);
            expect(map['name']).toEqual('Audi');
          }));

      it('should be able to get a list of keys', () =>
        VEHICLE_HISTORY_GRAPH.g.v('15:613').keys().first()
          .then((keys) {
            expect(keys).toEqual(['name']);
          }));

      it('should be able to get a list of values', () =>
        VEHICLE_HISTORY_GRAPH.g.v('15:613').values().first()
          .then((keys) {
            expect(keys).toEqual(['Audi']);
          }));

      describe('has', () {
        it('should be able to filter elements by property existence', () =>
          VEHICLE_HISTORY_GRAPH.g.V.has('name').count()
            .then((count) => expect(count).toEqual(550)));

        it('should be able to filter elements by a property value', () =>
          VEHICLE_HISTORY_GRAPH.g.V.has('name', eq('Audi')).count()
            .then((count) => expect(count).toEqual(1)));

        it('should be able to filter elements by a property value', () =>
          VEHICLE_HISTORY_GRAPH.g.V.has('cityMPG', eq('19')).count()
            .then((count) => expect(count).toEqual(1)));
      });

      describe('hasNot', () {
        it('should be able to filter elements by property absence', () =>
          VEHICLE_HISTORY_GRAPH.g.V.hasNot('name').count()
            .then((count) => expect(count).toEqual(2936)));
      });

      it('should be able to filter elements by a property interval', () =>
        VEHICLE_HISTORY_GRAPH.g.V.interval('cityMPG', 15, 16).count()
          .then((count) => expect(count).toEqual(1)));
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
        VEHICLE_HISTORY_GRAPH.g.v('16:2113').inE
          .then((edges) {
            expect(edges).toBeA(List);
            expect(edges.length).toEqual(1);
            expect(edges.first['@class']).toEqual('isModel');
          }));

      it('should be able to get outgoing edges', () =>
        VEHICLE_HISTORY_GRAPH.g.v('16:2113').outE
          .then((edges) {
            expect(edges).toBeA(List);
            expect(edges.length).toEqual(1);
            expect(edges.first['@class']).toEqual('isMake');
          }));

      it('should be able to get edges coming from any direction', () =>
        VEHICLE_HISTORY_GRAPH.g.v('16:2113').bothE
          .then((edges) {
            expect(edges).toBeA(List);
            expect(edges.length).toEqual(2);
            expect(edges.first['@class']).toEqual('isMake');
            expect(edges.last['@class']).toEqual('isModel');
          }));
    });

    describe('Edge', () {
      it('should be able to get the label', () =>
        VEHICLE_HISTORY_GRAPH.g.e('25:1777').label.first()
          .then((label) {
            expect(label).toEqual('isMake');
          }));

      it('should be able to get the incoming vertex', () =>
        VEHICLE_HISTORY_GRAPH.g.e('25:1777').inV.first()
          .then((vertex) {
            expect(vertex).toBeA(Map);
            expect(vertex['@class']).toEqual('Make');
          }));

        it('should be able to get the outgoing vertex', () =>
          VEHICLE_HISTORY_GRAPH.g.e('25:1777').outV.first()
            .then((vertex) {
              expect(vertex).toBeA(Map);
              expect(vertex['@class']).toEqual('Model');
            }));

      it('should be able to get both vertices', () =>
        VEHICLE_HISTORY_GRAPH.g.e('25:1777').bothV
          .then((vertices) {
            expect(vertices).toBeA(List);
            expect(vertices.length).toEqual(2);
          }));
    });

    describe('Filters', () {
      it('should be able to filter using a grmlin closure', () =>
        VEHICLE_HISTORY_GRAPH.g.V.filter('it.name == "Audi"')
          .then((vertices) => expect(vertices.length).toEqual(1)));

      it('should be able to randomly pick objects', () =>
        expect(VEHICLE_HISTORY_GRAPH.g.V.random(0.5).toString()).toEqual('g.V.random(0.5)'));

      describe('dedup', () {
        it('should be able to deduplicate', () =>
          VEHICLE_HISTORY_GRAPH.g.v('15:613').inE.outV.getProperty('name').dedup().first()
            .then((models) {
              expect(models.length).toEqual(4);
            }));

        it('should be able to deduplicate on property', () =>
          VEHICLE_HISTORY_GRAPH.g.v('15:613').inE.outV.dedup('name')
            .then((models) {
              expect(models.length).toEqual(4);
            }));
      });

      it('should be able to return objects in a range', () =>
        VEHICLE_HISTORY_GRAPH.g.V.range(2, 5)
          .then((vertices) => expect(vertices.length).toEqual(4)));

      it('should be able to return a specific object', () =>
        VEHICLE_HISTORY_GRAPH.g.V[5].first()
          .then((vertex) => expect(vertex).toBeA(Map)));
    });

    describe('Transformers', () {
//      it('should be able to pick only the id', () =>
//        VEHICLE_HISTORY_GRAPH.g.v('15:613').id.first()
//          .then((id) => expect(id).toEqual('15:613')));

      it('should be able to shuffle a pipe', () =>
        expect(VEHICLE_HISTORY_GRAPH.g.V.shuffle.toString()).toEqual('g.V.shuffle'));

      it('should be able to get a specific property', () =>
        VEHICLE_HISTORY_GRAPH.g.v('15:613').getProperty('name').first()
          .then((name) => expect(name).toEqual('Audi')));

      describe('order', () {
        it('should be able to order a pipe', () =>
          VEHICLE_HISTORY_GRAPH.g.v('15:613').inE.outV.getProperty('name').order().first()
            .then((models) {
              expect(models.length).toEqual(5);
              expect(models).toEqual([
                  '5000S Wagon',
                  'A4 quattro',
                  'A4 quattro',
                  'TT Coupe quattro',
                  'TT Roadster'
              ]);
            }));

        it('should be able to order a pipe with a direction', () =>
          VEHICLE_HISTORY_GRAPH.g.v('15:613').inE.outV.getProperty('name')
            .order(direction: Direction.DESCENDING).first()
            .then((models) {
              expect(models.length).toEqual(5);
              expect(models).toEqual([
                  'TT Roadster',
                  'TT Coupe quattro',
                  'A4 quattro',
                  'A4 quattro',
                  '5000S Wagon'
              ]);
            }));


        it('should be able to order a pipe on a property', () =>
          VEHICLE_HISTORY_GRAPH.g.V.has('cityMPG').order(by: 'cityMPG').next(5)
            .then((models) {
              expect(models.length).toEqual(5);
              models.forEach((model) => expect(model['cityMPG']).toBeLessThan(12));
            }));

        it('should be able to order a pipe on a property with a direction', () =>
          VEHICLE_HISTORY_GRAPH.g.V.has('cityMPG')
            .order(by: 'cityMPG', direction: Direction.DESCENDING).next(5)
            .then((models) {
              expect(models.length).toEqual(5);
              models.forEach((model) => expect(model['cityMPG']).toBeGreaterThan(44));
            }));

        it('should be able to order a pipe by a gremlin closure', () =>
          VEHICLE_HISTORY_GRAPH.g.V.has('cityMPG')
            .orderGremlin('-it.a.cityMPG <=> -it.b.cityMPG').next(5)
            .then((models) {
              print(models);
              expect(models.length).toEqual(5);
              models.forEach((model) => expect(model['cityMPG']).toBeGreaterThan(44));
            }));
      });

      it('should be able to transform a pipe by a gremlin closure', () =>
        VEHICLE_HISTORY_GRAPH.g.V.has('cityMPG')
          .transform('it.highwayMPG - it.cityMPG').order().next(5)
          .then((diff) {
            diff = diff.first;
            expect(diff.length).toEqual(5);
            diff.forEach((diff) => expect(diff).toBeLessThan(3));
          }));
    });

//    describe('Edges', () {
//      it('should be able to filter by label', () =>
//        VEHICLE_HISTORY_GRAPH.g.E('isMake').first()
//          .then((count) => expect(count).toEqual(500)));
//    });
  });
}
