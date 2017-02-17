(ns api.views.users
  (:require [api.data.users :refer [create-user! get-user password-valid?]]
            [api.stripe.core :refer [create-customer!]]
            [datomic.api :as d]))

(defn new [conn email password token]
  (if (get-user (d/db conn) email)
    {:status 409
     :body {:message "Email exists in our system already."}}
    (do
      (create-customer! email token)
      (create-user! conn email password)
      {:status 200})))

(defn retrieve [db email password]
  (if (password-valid? db email password)
    {:status 200}
    {:status 401}
    )
  )
