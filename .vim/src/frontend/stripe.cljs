(ns frontend.stripe)

(.setPublishableKey js/Stripe "pk_test_0mAKHJItxHg59pIfBpjNb4Fc")

(defn card-valid? [number]
  (js/Stripe.card.validateCardNumber number))

(defn cvc-valid? [cvc]
  (js/Stripe.card.validateCVC cvc))

(defn expiry-valid? [month year]
  (js/Stripe.card.validateExpiry month year))

(defn create-card-token! [ccn cvc month year handler]
  (if (and (card-valid? ccn)
           (cvc-valid? cvc)
           (expiry-valid? month year))
    (aget
     (js/Stripe.card.createToken
      (js-obj "number" ccn "cvc" cvc "exp_month" month "exp_year" year)
      handler)
     "id")
    nil))

(comment (create-card-token! 4242424242424242 666 12 2015 stripe-response-handler))
