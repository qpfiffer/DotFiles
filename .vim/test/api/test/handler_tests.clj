(ns api.test.handler-tests
  (:require [clojure.test :refer [deftest is]]
            [api.handlers.core :refer [api-handler]]))

(deftest displays-root-with-no-auth
  (is (= {:status 200 :headers {} :body "Public"}
         (api-handler {:request-method :get :uri "/"}))))
