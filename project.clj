(defproject hello-lambda-clj "0.1.0-SNAPSHOT"
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [org.clojure/data.json "0.2.6"]
                 [uswitch/lambada "0.1.2"]]
  :profiles {:uberjar {:aot :all}}
  :uberjar-name "hello-lambda-clj.jar")
