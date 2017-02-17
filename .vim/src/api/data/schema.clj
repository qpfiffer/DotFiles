(ns api.data.schema
  (:require [datomic.api :as d]))

(def schema
  [{:db/id #db/id[:db.part/db]
    :db/ident :api.user/id
    :db/valueType :db.type/uuid
    :db/unique :db.unique/identity
    :db/cardinality :db.cardinality/one
    :db.install/_attribute :db.part/db}
   {:db/id #db/id[:db.part/db]
    :db/ident :api.user/email
    :db/valueType :db.type/string
    :db/unique :db.unique/value
    :db/cardinality :db.cardinality/one
    :db.install/_attribute :db.part/db}
   {:db/id #db/id[:db.part/db]
    :db/ident :api.user/password_hash
    :db/valueType :db.type/string
    :db/cardinality :db.cardinality/one
    :db.install/_attribute :db.part/db}])
