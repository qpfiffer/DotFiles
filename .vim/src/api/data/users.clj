(ns api.data.users
  (:require [datomic.api :as d]
            [clojurewerkz.scrypt.core :as sc]))

(defn hash-fn [s]
  (sc/encrypt s 16384 8 1))

(defn create-user! [conn email password]
  (d/transact
    conn
    [{:db/id (d/tempid :db.part/user)
      :api.user/email email
      :api.user/id (d/squuid)
      :api.user/password_hash (hash-fn password)}]))

(defn all-users [db]
  (d/q '[:find ?email
         :in $
         :where
         [?e :api.user/email ?email]]
       db))

(defn get-user [db email]
  (ffirst (d/q '[:find ?e
          :in $ ?email
          :where
          [?e :api.user/email ?email]]
        db email)))

(defn password-valid? [db email password]
  (if-let [user-entid (get-user db email)]
    (let
        [user-entity (d/touch (d/entity db user-entid))
         i (:api.user/id user-entity)
         h (:api.user/password_hash user-entity)
         valid (and (not (nil? h)) (sc/verify password h))]
      (->
       {:valid valid}
       (assoc :id (if valid (str i) nil))))
    {:valid false
     :id nil}))
