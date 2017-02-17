(ns api.middleware.basic-auth
  (:require
   [clojure.data.codec.base64 :as b64]
   [api.data.users :refer [password-valid?]]))

(defn parse-authorization-header-value [a]
  (when (and a (re-matches #"\s*Basic\s+(.+)" a))
    (if-let [[[_ username password]]
             (try
               (-> (re-matches #"\s*Basic\s+(.+)" a)
                   ^String second
                   (.getBytes "UTF-8")
                   b64/decode
                   (String. "UTF-8")
                   (#(re-seq #"([^:]*):(.*)" %)))
               (catch Exception e nil))]
      [username password])))

(defn geti [m k]
  (let [ks (keys m)
        kvs (map #(identity {(.toLowerCase %) (get m %)}) ks)
        downcased (reduce #(merge %1 %2) {} kvs)]
    (get downcased k nil)))

(defn basic-auth [db]
  (fn [req user pass]
    (when (and user pass)
      (let [auth (password-valid? (db) user pass)]
        (when (:valid auth)
          (assoc req :user auth))))))

(defn wrap-basic-auth [routes authentication-fn failure-handler]
  (fn [req]
    (let [header-value (geti (:headers req) "authorization")
          [user pass] (parse-authorization-header-value header-value)
          authd-req (authentication-fn req user pass)]
      (if (nil? authd-req)
        (failure-handler req)
        (routes authd-req)))))
