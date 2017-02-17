(ns api.handlers.core
  (:require
   [api.system.core :refer [system db]]
   [api.routes.core :refer
    [authenticated-routes unauthenticated-routes]]
   [api.middleware.basic-auth :refer
    [wrap-basic-auth basic-auth]]
   [ring.middleware.resource :refer [wrap-resource]]
   [ring.middleware.json :refer [wrap-json-params wrap-json-response]]
   [ring.middleware.keyword-params :refer [wrap-keyword-params]]
   [compojure.core :refer [routes GET]]))

(defn wrap-routes [handler routes]
  (fn [req]
    (let [res (routes req)]
      (if (nil? res)
        (handler req)
        res))))

(def api-handler 
  (-> authenticated-routes
      (wrap-basic-auth
       (basic-auth db)
       (constantly {:status 401 :body "Unauthorized"
                    :headers
                    {"WWW-Authenticate" "Basic realm=\"Acuitas\""}}))
      (wrap-routes unauthenticated-routes)
      (wrap-resource "public")
      (wrap-keyword-params)
      (wrap-json-params)
      (wrap-json-response)))
