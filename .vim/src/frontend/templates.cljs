(ns frontend.templates)

(defn text-input [app-db element-id element-label source-path change-fn & {:keys [password?]}]
  [:div {:class "form-group"}
   [:label {:for element-id}
    element-label]
   [:input
       {:value (get-in @app-db source-path)
        :on-change change-fn
        :type (if password? "password" "text")
        :id element-id
        :class "form-control"
        :change-on-blur? false}]])

