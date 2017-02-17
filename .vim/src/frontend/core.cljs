(ns ^:figwheel-always
 frontend.core
  (:require-macros [reagent.ratom :refer [reaction]])
  (:require
   [goog.crypt.base64 :as b64]
   [reagent.core :as reagent :refer [atom]]
   [re-com.core :refer
    [modal-panel v-box border title input-text button]]
   [ajax.core :refer [GET POST]]
   [frontend.login :as l]
   [frontend.signup :as s]
   [frontend.stripe :as stripe]))

(defonce app-db (atom {:ready? false}))

(defn navbar []
  [:nav {:class "navbar navbar-default navbar-static-top"}
   [:div {:class "container"}
    [:div {:class "navbar-header"}
     [:a {:class "navbar-brand"}
      "GHFL"]]
    [:div {:class "navbar-collapse collapse"}
     [:ul {:class "nav navbar-nav navbar-right"}
      [s/signup-link app-db]
      (if (:logged-in @app-db)
        [l/logout-link app-db]
        [l/login-link app-db])]]]])

(defn body [app-db]
  (if (:logged-in app-db)
    [[:p "Logged in!"]
     [:p "test"]]
    [[:div "HI " "FOO"]
      [:div "BYE " "BARZ"]]))
(defn main-panel []
  [:div
   [navbar]
   [:div {:class "container-fluid"}
    (if (:ready? @app-db)
      [:div {:class "jumbotron"}
       (body app-db)
       ]
      [:div {:class "jumbotron"}
       [:div "INITIALIZING"]])]])

(defn initialize []
  (swap! app-db assoc
         :ready? true
         :display-signup? false
         :signup-form-data {:email ""
                            :password ""
                            :expiry-month (+ 1 (.getMonth (new js/Date)))
                            :expiry-year (.getFullYear (new js/Date))
                            :ccn ""
                            :cvc ""}
         :display-login? false))

(defn main []
  (reagent/render [main-panel]
                  (.getElementById js/document "app"))
  (if-not (:ready? @app-db)
    (initialize)))

(main)
