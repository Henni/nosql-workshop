CREATE CONSTRAINT ON (n:User) ASSERT n.id IS UNIQUE;

CREATE CONSTRAINT ON (n:Composer) ASSERT n.id IS UNIQUE;

CREATE CONSTRAINT ON (n:Piece) ASSERT n.id IS UNIQUE;

CREATE CONSTRAINT ON (n:Type) ASSERT n.id IS UNIQUE;

LOAD CSV WITH HEADERS FROM "file:///piece_node.csv" AS r FIELDTERMINATOR ';'
CREATE (p:Piece {
  id: toInteger(r.`id:ID(Piece)`),
  work: r.work,
  location: r.location,
  year: toInteger(r.date),
  key: r.key
});

LOAD CSV WITH HEADERS FROM "file:///type_node.csv" AS r FIELDTERMINATOR ';'
CREATE (p:Type {
  id: toInteger(r.`id:ID(Type)`),
  name: r.name
});

LOAD CSV WITH HEADERS FROM "file:///type_rels.csv" AS r FIELDTERMINATOR ';'
MATCH (p:Piece {id: toInteger(r.`:START_ID(Piece)`)}), (t:Type {id: toInteger(r.`:END_ID(Type)`)})
CREATE (p)-[:HAS_TYPE]->(t);
