(ns frontend.test-runner
  (:require [cljs.test :as test :include-macros true]
            [frontend.core-test]
            [figwheel.client :as fw]))

(enable-console-print!)

(defn test-runner []
  (test/run-tests 'frontend.core-test))

(fw/start {:websocket-url "ws://localhost:3449/figwheel-ws"
           :build-id "test"
           :on-jsload (fn [] (test-runner))})
