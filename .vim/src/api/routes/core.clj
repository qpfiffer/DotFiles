(ns api.routes.core
  (:require
   [api.system.core :refer [conn db]]
   [api.views.users :as u]
   [compojure.core :refer [defroutes GET POST]]
   [compojure.route :refer [not-found]]
   [datomic.api :as d]))

(defroutes unauthenticated-routes
  (POST "/users/new" [email password token]
        (u/new (conn) email password token))
  (GET "/" [] {:body "Public" :headers {} :status 200}))

(defroutes authenticated-routes
  (POST "/users" [email password]
       (u/retrieve (db) email password))
  (not-found "nothing to see here, move along now."))
