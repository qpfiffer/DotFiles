(ns api.test.data.user-tests
  (:require [clojure.test :refer [deftest is use-fixtures]]
            [datomic.api :as d]
            [api.test.util :refer
             [datomic-fixture datomic-conn]]
            [api.data.users :as u]
            [clojure.test.check.clojure-test :refer [defspec]]
            [clojure.test.check.properties :as prop :refer
             [for-all]]
            [clojure.test.check.generators :as gen :refer
              [sample fmap tuple such-that
               string-alphanumeric elements]]))

(use-fixtures :once datomic-fixture)

(def num-tests 666)

(def email-generator
  (tuple (gen/not-empty string-alphanumeric)
         (elements
          ["gmail.com" "survantjames.com" "ghfl.com"])))

(def password-generator
  string-alphanumeric)

(deftest vanilla-user-creation
  (let [e "foo@bar.com"
        p "nixondidnothingwrong"]
    (u/create-user! datomic-conn e p)))

(deftest create-duplicate-users
  (let [e "foo@bar.com"
        p "nixondidnothingwrong"]
    (u/create-user! datomic-conn e p)
    (u/create-user! datomic-conn e "regenerativecooling")
    (is (= 1
           (count (u/all-users (d/db datomic-conn)))))
    (is (true? (:valid? (u/password-valid? (d/db datomic-conn) e p))))
    (is (false? (:valid? (u/password-valid? (d/db datomic-conn) e "regenerativecooling"))))))

(defspec test-user-creation 1
  (for-all
   [e-parts email-generator
    p password-generator]
   (let [e (str (first e-parts) "@" (second e-parts))
         u (u/create-user! datomic-conn e p)
         db (d/db datomic-conn)
         found 
         (d/touch (d/entity db (u/get-user (d/db datomic-conn) e)))]
     (is (= (:api.user/email found)
            e))
     (is (true? (:valid (u/password-valid? db e p)))))))

(deftest empty-db-has-no-users
  (let [c-s (str "datomic:mem://"(gensym))
        _     (d/create-database c-s)
        db (d/db (d/connect c-s))]
    (is (= nil
           (u/get-user (d/with db api.data.schema/schema) "foo@bar.com")))))

