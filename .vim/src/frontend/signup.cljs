(ns ^:figwheel-always
 frontend.signup
  (:require
   [re-com.core :refer
    [v-box button border modal-panel]]
   [ajax.core :refer [POST GET]]
   [frontend.templates :refer [text-input]]
   [frontend.stripe :as stripe]))

(declare signup)

(def success :signup-success)
(def failure :signup-failure)

(defn signup [e p t]
  (POST "/users/new"
    {:format :json
     :params {"email" e "password" p "token" t}
     :handler
     (fn [e]
       (swap! frontend.core/app-db assoc :display-signup? false)
       (swap! frontend.core/app-db assoc-in [:signup-form-data :signup-error] nil))
     :error-handler
     (fn [e] (let [error-message (get (:response e) "message")]
               (swap! frontend.core/app-db assoc-in [:signup-form-data :signup-error] error-message)))}))

(defn update-signup-form [db k v]
  (swap! db assoc-in [:signup-form-data k] v))

(defn stripe-response-handler [db]
  (fn [s r]
    (if (= 200 s)
      (let [token (aget r "id")
            our-data (:signup-form-data @db)
            email (:email our-data)
            password (:password our-data)]
        (swap! frontend.core/app-db assoc-in [:signup-form-data :token])
        (signup email password (:token (:signup-form-data @db))))
      (do (.log js/console "stripe creation failed:")
          (.log js/console (aget r "message"))))))

(defn create-stripe-token-and-signup! [db]
  (let [our-data (:signup-form-data @db)
        ccn (:ccn our-data)
        cvc (:cvc our-data)
        month (:expiry-month our-data)
        year (:expiry-year our-data)
        tok (:token (:signup-form-data @db))
        email (:email @db)
        password (:password @db)]
    (if tok
      (signup email password tok)
      (stripe/create-card-token!
       ccn cvc month year
       (stripe-response-handler db)))))

(defn signup-form [app-db]
  [v-box :class "form-group"
   :children
   [(let [signup-error (get-in @app-db [:signup-form-data :signup-error])]
      [:p
       {:class
        (if-not (nil? signup-error)
          "alert alert-danger"
          "")}
       (if-not (nil? signup-error)
         signup-error
         "")])
    [:form
     {:on-submit (fn [e]
                   (create-stripe-token-and-signup! app-db)
                   (.preventDefault e))}
     [text-input app-db "signup-email" "Email:" [:signup-form-data :email]
      #(update-signup-form
        app-db :email (-> %
                          .-target
                          .-value))]
     [text-input app-db "signup-password" "Password:" [:signup-form-data :password]
      #(update-signup-form
        app-db :password (-> %
                             .-target
                             .-value))
      :password? true]
     [:div {:class
            (if (stripe/card-valid? (:ccn (:signup-form-data @app-db)))
              "form-group has-success"
              "form-group has-error")}
      [:label {:for "signup-ccn"
               :class "control-label"} "Credit Card Number:"]
      [:input
       {:value (:ccn (:signup-form-data @app-db))
        :on-change #(update-signup-form
                     app-db :ccn (-> %
                                     .-target
                                     .-value))
        :type "text"
        :id "signup-ccn"
        :class "form-control"
        :change-on-blur? false}]]
     [:div {:class (if (stripe/cvc-valid? (:cvc (:signup-form-data @app-db)))
                     "form-group has-success"
                     "form-group has-error")}
      [:label {:for "signup-cvc"
               :class "control-label"} "CVC:"]
      [:input
       {:value (:cvc (:signup-form-data @app-db))
        :on-change #(update-signup-form
                     app-db :cvc (-> %
                                     .-target
                                     .-value))
        :type "text"
        :id "signup-cvc"
        :class "form-control"
        :change-on-blur? false}]]
     [:div {:class (if (stripe/expiry-valid? (:expiry-month (:signup-form-data @app-db)) (:expiry-year (:signup-form-data @app-db)))
                     "form-group has-success"
                     "form-group has-error")}
      [:label {:for "signup-expiry-month"
               :class "control-label"} "Credit card expiration month:"]
      [:select {:class "form-control"
                :value (:expiry-month (:signup-form-data @app-db))
                :on-change #(update-signup-form
                             app-db :expiry-month
                             (-> %
                                 .-target
                                 .-value))}
       (for [i (range 12)] [:option {:key (gensym)}
                            (+ 1 i)])]]
     [:div {:class (if (stripe/expiry-valid? (:expiry-month (:signup-form-data @app-db)) (:expiry-year (:signup-form-data @app-db)))
                     "form-group has-success"
                     "form-group has-error")}
      [:label {:for "signup-expiry-year"
               :class "control-label"} "Credit card expiration year:"]
      [:input {:value (:expiry-year (:signup-form-data @app-db))
               :type "number"
               :id "signup-expiry-year"
               :class "form-control"
               :on-change #(update-signup-form
                            app-db :expiry-year
                            (-> %
                                .-target
                                .-value))}]]
     [button
      :label "Sign Up"
      :class "form-control"
      :class "btn-primary"
      :attr {:id "signup-submit"}]]]])

(defn signup-link [app-db]
  [:li
   [:a {:on-click
        (fn [e]
          (swap! app-db assoc :display-signup? true)
          (.stopPropagation e))}
    "Signup"]
   (when (:display-signup? @app-db)
     [border
      :border "1px solid #eee"
      :child
      [v-box :padding "10px"
       :children [[modal-panel
                   :backdrop-on-click #(swap! app-db assoc :display-signup? false)
                   :child [signup-form app-db]]]]])])
