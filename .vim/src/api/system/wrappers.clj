(ns api.system.wrappers
  (:require
   [api.handlers.core :as handlers]
   [org.httpkit.server :refer [run-server]]
   [datomic.api :as d]))

(defn with-server [system config]
  (assoc
   system
   :start-server! (fn []
                    (run-server
                     (:handlers config)
                     {:port (Integer. (:port config)) :join? false}))))

(defn get-connection [connection-string]
  (try
    (d/connect connection-string)
    (catch Exception e
      (do
        (.printStackTrace e)
        (println "FATAL: Could not connect to Datomic.")
        nil))))

(defn with-datomic [system config]
  (-> system
      (assoc :db-connection (get-connection (:datomic-uri config))
             :db-uri (:datomic-uri config))))

(defn make-system [config]
  (->
   {}
   (with-datomic config)
   (with-server config)))
