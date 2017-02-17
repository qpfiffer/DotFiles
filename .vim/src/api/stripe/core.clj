(ns api.stripe.core
  (:require [clj-http.client :as client]
            [api.system.core :refer [stripe-secret]]))

(defonce +endpoint+ "https://api.stripe.com/v1")

(defn create-customer! [email source]
  (let [ep (str +endpoint+ "/customers")]
    (client/post ep {:basic-auth (stripe-secret)
                     "description" "ghfl dummy user"
                     "email" email})))
