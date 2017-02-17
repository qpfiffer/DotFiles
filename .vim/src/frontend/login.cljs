(ns frontend.login
  (:require
   [goog.crypt.base64 :as b64]
   [re-com.core :refer
    [v-box input-text button border modal-panel]]
   [frontend.templates :refer [text-input]]
   [ajax.core :refer [GET POST]]))

(defn login [app-db]
  (let [our-data (:login-form-data @app-db)
        e (:email our-data)
        p (:password our-data)
        ]
    (POST "/users"
         {:format :json
          :params {"email" e "password" p}
          :headers {"authorization" (str "Basic " (b64/encodeString (str e ":" p)))}
          :handler (fn [e] (swap! app-db assoc :logged-in true :display-login? false)
                           (swap! app-db assoc-in [:login-form-data :login-failed] false))
          :error-handler (fn [e] (swap! app-db assoc :logged-in false)
                                 (swap! app-db assoc-in [:login-form-data :login-failed] true)
          )})))


(defn handle-login
  [db [action form-data]]
  (let [e (:email @form-data)
        p (:password @form-data)]
    (assoc db
           :email e
           :password p)))

(defn login-form [app-db]
  [v-box :class "form-group"
   :children
   [[:p
        (if (get-in @app-db [:login-form-data :login-failed])
          "Login failed."
          "")
     ]
    [:form {:on-submit (fn [e]
                          (login app-db)
                          (.preventDefault e)) }
     [text-input app-db "login-email" "Email:" [:login-form-data :email]
      #(swap! app-db assoc-in [:login-form-data :email]
              (-> %
                  .-target
                  .-value))]
     [text-input app-db "login-password" "Password:" [:login-form-data :password]
      #(swap! app-db assoc-in [:login-form-data :password]
              (-> %
                  .-target
                  .-value))
      :password? true]
     [button
       :label "Log In"
       :class "btn-primary"]]]])

(defn logout-link [app-db]
  [:li
    [:a {:on-click
        (fn [e]
          (swap! app-db assoc :logged-in false)
          (.stopPropagation e))}
     "Logout"]
  ])

(defn login-link [app-db]
  [:li
   [:a {:on-click
        (fn [e]
          (swap! app-db assoc :display-login? true)
          (.stopPropagation e))}
    "Login"]
   (when (:display-login? @app-db)
     [border
      :border "1px solid #eee"
      :child
      [v-box
       :padding "10px"
       :children [[modal-panel
                   :backdrop-on-click #(swap! app-db assoc :display-login? false)
                   :child [login-form app-db]]]]])])
