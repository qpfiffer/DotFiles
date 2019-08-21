-- Database: datomic

-- DROP DATABASE datomic;

CREATE DATABASE datomic
 WITH OWNER = postgres
      TEMPLATE template0
      ENCODING = 'UTF8'
      LC_COLLATE = 'en_US.UTF-8'
      LC_CTYPE = 'en_US.UTF-8'
      CONNECTION LIMIT = -1;

\c datomic

-- Table: datomic_kvs

-- DROP TABLE datomic_kvs;

CREATE TABLE datomic_kvs
(
 id text NOT NULL,
 rev integer,
 map text,
 val bytea,
 CONSTRAINT pk_id PRIMARY KEY (id )
)
WITH (
 OIDS=FALSE
);
ALTER TABLE datomic_kvs
 OWNER TO postgres;
GRANT ALL ON TABLE datomic_kvs TO postgres;
GRANT ALL ON TABLE datomic_kvs TO public;


-- DROP ROLE :datomic

CREATE ROLE datomic LOGIN PASSWORD 'datomic';

