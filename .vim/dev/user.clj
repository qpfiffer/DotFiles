(ns user
  (:require [api.main :as m]
            [api.system.core :as sys :refer [system config db]]
            [api.system.wrappers :as wrappers]
            [datomic.api :as d]
            [api.data.schema :refer [schema]]
            [clojure.tools.namespace.repl :refer [refresh-all]]
            [clojure.test :as test :refer [run-tests]]))

(defn prepare-datomic [conn-str]
  (println "creating empty database from schema")
  (if (d/create-database conn-str)
    (d/transact (d/connect conn-str) schema)))

(defn init
  []
  (reset! sys/config (assoc m/config :datomic-uri
                          "datomic:mem://acuitas-dev"))
  (prepare-datomic (:datomic-uri @sys/config))
  :initialized)

(defn start
  []
  (let [system (wrappers/make-system @sys/config)]
    (println (str "Running on http://localhost:" (:port @sys/config)))
    (reset! sys/system
            (assoc system
                   :stop-server!
                   ((:start-server! system))))))

(defn stop
  []
  (when (contains? @sys/system :stop-server!)
    ((:stop-server! @sys/system))))

(defn go
  []
  (init)
  (start))

(defn reset
  []
  (stop)
  (refresh-all :after 'user/go))

(defn test-project []
  (let [test-list ['api.test.data.user-tests]]
    (map run-tests test-list)
    ))

