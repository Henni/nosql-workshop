# README

## Model

### Nodes

* `Piece`
* `Composer`
* `Type`
* `User`

### Relationships

* `(:Composer)-[:COMPOSED {role:"some role"}]->(:Movie)`
* `(:Piece)-[:HAS_TYPE]->(:TYPE)`
* `(:User)-[:RATED {rating:"1-5"}]->(:Piece)`

## Database Setup
### Docker Setup
This is the recommended way and should work similarly on Windows.

* Run the Neo4j Docker Container
```
docker run \
    --publish=7474:7474 --publish=7687:7687 \
    --volume=$HOME/neo4j/data:/data \
    --volume=$HOME/neo4j/import:/var/lib/neo4j/import \
    --name neo4j \
    neo4j
```
* Copy the csv files into the import directory:
```
cp csv/*.csv $HOME/neo4j/import
```
* Initialize the database:
```
docker exec -i neo4j bin/cypher-shell -u neo4j -p neo < ./setup.cql
```

### Local Install
As an alternative to Docker you can also install Neo4j locally
* [Download Neo4j Community Edition: .tar Version](https://neo4j.com/download/other-releases/)
* Set your `NEO4J_HOME` variable: `export NEO4J_HOME=/path/to/neo4j-community`
* From this project's root directory, run the import script:

```
docker exec -i my-neo4j bin/neo4j-admin import \
--nodes:Piece /var/lib/neo4j/import/piece_node.csv \
--nodes:User /var/lib/neo4j/import/users_node.csv \
--nodes:Type /var/lib/neo4j/import/type_node.csv \
--relationships:TYPE "/var/lib/neo4j/import/type_rels.csv" \
--delimiter ";" --array-delimiter "|" --id-type INTEGER
$NEO4J_HOME/bin/neo4j-import --into $NEO4J_HOME/data/databases/graph.db --nodes:Person csv/person_node.csv --nodes:Movie csv/movie_node.csv --nodes:Genre csv/genre_node.csv --nodes:Keyword csv/keyword_node.csv --relationships:ACTED_IN csv/acted_in_rels.csv --relationships:DIRECTED csv/directed_rels.csv --relationships:HAS_GENRE csv/has_genre_rels.csv --relationships:HAS_KEYWORD csv/has_keyword_rels.csv --relationships:PRODUCED csv/produced_rels.csv --relationships:WRITER_OF csv/writer_of_rels.csv --delimiter ";" --array-delimiter "|" --id-type INTEGER
```

If you see `Input error: Directory 'neo4j-community-3.0.3/data/databases/graph.db' already contains a database`, delete the `graph.db` directory and try again.

* Add [constraints](https://neo4j.com/docs/developer-manual/current/cypher/#query-constraints) to your database: `$NEO4J_HOME/bin/neo4j-shell < setup.cql -path $NEO4J_HOME/databases/graph.db`
* Start the database: `$NEO4J_HOME/bin/neo4j start`


### Windows

[Download Neo4j Community Edition](https://neo4j.com/download/)

`neo4j-import` does not come with Neo4j-Desktop (`.exe` on Windows, `.dmg` on OSX).
To get around this issue (especially for this small database) you can enter the cypther commands in the Neo4j [browser](http://localhost:7474/browser/).
The commands are provided in the [setupCypherCommands.txt](./setupCypherCommands.txt) file.

* Use the GUI to select and start your database.
* Run a test script to make sure everything is working:
```
// test
LOAD CSV WITH HEADERS FROM "file:///person_node.csv" AS r FIELDTERMINATOR ';'
WITH r LIMIT 10 WHERE r.`id:ID(Person)` IS NOT NULL
RETURN r.`id:ID(Person)`, r.name, r.`born:int`, r.poster_image
```
The most common error at this point is in finding the csv files.
A simple solution is to copy the csv files into the default `/import` location noted in the error message.
If everything runs corretly you should get the following:

  ![image of movie model](./img/neo4jBrowser_CypherCmd.png)

* continue running each of the scripts (each deliniated by a semicolon) found in [setupCypherCommands.txt](./setupCypherCommands.txt).  You can verify everything loaded correctly form the neo4j browser by clicking on the Node labels.

## Workshop
Let's start with taking a look at the current state of the database.
Therefore open the Neo4j [browser](http://localhost:7474/browser/).

Take a look at all currently existing Pieces in the database, by entering this command:
```
MATCH (n:Piece) RETURN n;
```
We can also find out which Pieces are Quartetts:
```
MATCH (n:Piece)-[:TYPE]->(:Type {name: 'Quartett'}) RETURN n;
```

Moving on we can also create a new node ourselves. Let's add `Mozart` as a `Composer` to our database:
```
CREATE (n:Composer {name:'Mozart'}) RETURN n;
```

As all the Pieces in the database where composed by Mozart, connect them with a `COMPOSED` relationship:
```
MATCH (m:Composer {name:"Mozart"}), (p:Piece)
CREATE (m)-[COMPOSED]->(p)
```

As described one of the strength of Graph Databases is the Traversal over its paths. This can be used for recommendation systems, for example.

To set this up let's create a few users:
```
LOAD CSV WITH HEADERS FROM "file:///users_node.csv" AS r FIELDTERMINATOR ';'
CREATE (p:User {
  id: toInteger(r.`id:ID(User)`),
  name: r.name
});
```

Also create a few ratings:
```
MATCH (u:User), (p:Piece)
WITH u, p
WHERE rand() < 0.1
CREATE (u)-[:RATED]->(p)
```
and assign rating scores:
```
MATCH (:User)-[r:RATED]->(:Piece)
SET r.rating = floor(rand()*6)
```

Your task is now to develop an approach to recommend Pieces to a user, based on all information currently stored in the database.
