(ns api.main
  (:require
   [api.system.wrappers :as wrappers]
   [api.data.schema :refer [schema]]
   [datomic.api :as d]
   [api.handlers.core :refer [api-handler]]))

(defn start! [system]
  ((:start-server! system)))

(defn env [key default]
  (get (System/getenv) key default))

(def config
  {:port (Integer/parseInt (env "PORT" "5000"))
   :datomic-uri (env "DATOMIC_URI" nil)
   :handlers #'api-handler
   :stripe {:secret-key
            (env "STRIPE_SECRET_KEY" "sk_test_cx2DuEQlvst8aVoD3IoP9Pk6")
            :publishable-key
            (env "STRIPE_PUBLISHABLE_KEY" "pk_test_0mAKHJItxHg59pIfBpjNb4Fc")}})

(defn -main []
  (let [d-uri (:datomic-uri (config))]
    (if (d/create-database d-uri)
      (d/transact (d/connect d-uri) schema)))
  (start! (wrappers/make-system config)))
