(ns api.system.core
  (:require [datomic.api :as d]))

(defonce config (atom {}))
(defonce system (atom {}))

(defn conn []
  (:db-connection @system))

(defn db []
  (d/db (conn)))

(defn stripe-secret []
  (:secret-key (:stripe @config)))

(defn stripe-publishable []
  (:publishable-key (:stripe @config)))
