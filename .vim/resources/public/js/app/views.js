define([], function() {
    
    function SignupView () {
        this.template = Handlebars.compile($("#signup-template").html());
        this.signupformhtml = this.template({});
    }

    SignupView.prototype.setDelegate = function(delegate) {
        self.delegate = delegate;
    };

    SignupView.prototype.setup = function (delegate) {
        Stripe.setPublishableKey('pk_test_0mAKHJItxHg59pIfBpjNb4Fc');
        this.container.html(this.signupformhtml);
        form = $("#signup-form");
        form.submit(function(e) {
            form.find('button').prop('disabled', true);
            Stripe.card.createToken(form, this.stripeResponseHandler);
            return false;
        });
    };

    SignupView.prototype.teardown = function () {
        this.container.children().remove();
    };

    SignupView.prototype.stripeResponseHandler = function (status, response) {
        var $form = $("#signup-form");
        var token = response.id;
        var error = response.error;
        
        if (error){
            $form.find(".payment-errors").text(response.error.message);
            $form.find("button").prop("disabled", false);
        } else {
            $form.append($('<input type="hidden" name="stripeToken" />').val(token));
            this.delegate.signup("firstname", "lastname", "e@mail.com", token);
        }
    };

    function LoginView() {
        this.template = Handlebars.compile($("#login-template").html());
        this.content = this.template({});
    }

    LoginView.prototype.setDelegate = function(delegate) {
        self.delegate = delegate;
    };

    LoginView.prototype.setup = function(delegate) {
        this.container.html(this.loginformhtml);
        form = $("#login-form");
        form.submit(function(e) {
            email = this.find("#email-input").val();
            password = this.find("#password-input").val();
            return false;
        });
    };

    LoginView.prototype.teardown = function() {
        this.container.children().remove();
    };

    var exports = {};
    exports.LoginView = LoginView;
    exports.SignupView = SignupView;
    return exports;
});
