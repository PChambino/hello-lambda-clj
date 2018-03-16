(ns hello.lambda
  (:require [uswitch.lambada.core :refer [deflambdafn]]
            [clojure.data.json :as json]
            [clojure.java.io :as io]))

(defn handle-event
  [event]
  (println "Got the following event: " (pr-str event))
  {:statusCode 200
   :headers {}
   :body (str "Got the following event: " (pr-str event))})

(deflambdafn hello.lambda.Handler
  [in out ctx]
  (let [event (json/read (io/reader in))
        res (handle-event event)]
    (with-open [w (io/writer out)]
      (json/write res w))))
