(ns api.test.middleware.basic-auth
  (:require [clojure.test :refer [deftest is]]
            [api.middleware.basic-auth :refer
             [wrap-basic-auth parse-authorization-header-value]]))

(def handlers
  (wrap-basic-auth
   (fn [req] {:status 200 :body (str "Private to user " (:user-id req) "!")})
   (fn [req user pass]
     (when (and (= "valid-user" user) (= "valid-pass" pass))
       (assoc req :user-id "123")))
   (constantly {:status 401})))

(deftest parses-auth-header-values
  (is (= ["asdf" "jklol"]  (parse-authorization-header-value "Basic YXNkZjpqa2xvbA=="))))

(deftest returns-nil-for-bogus-auth-header-values
  (is (= nil (parse-authorization-header-value "fooobar")))
  (is (= nil (parse-authorization-header-value "BasicYXNkZjpqa2xvbA==")))
  (is (= nil (parse-authorization-header-value "Basic asdf:jklol"))))

(deftest returns-401-for-requests-missing-Authorization-header
  (is (= {:status 401}
         (handlers {:method :get :uri "/" :headers {}})))
  (is (= {:status 401}
         (handlers {:method :get :uri "/" :headers {"authorization" "foobar"}})))
  (is (= {:status 401}
         (handlers {:method :get :uri "/" :headers {"authorization" "BasicYXNkZjpqa2xvbA=="}})))
  (is (= {:status 401}
         (handlers {:method :get :uri "/" :headers {"authorization" "Basic asdf:jklol"}}))))
