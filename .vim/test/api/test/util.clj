(ns api.test.util
  (require [datomic.api :as d]
           [api.data.schema :refer [schema]]))

(def datomic-test-uri "datomic:mem://api-test")
(defonce datomic-conn nil)

(defn datomic-fixture [f]
  (d/create-database datomic-test-uri)
  (intern 'api.test.util 'datomic-conn
          (d/connect datomic-test-uri))
  (d/transact datomic-conn schema)
  (f)
  (d/delete-database datomic-test-uri)
  (intern 'api.test.util 'datomic-conn
          nil))
