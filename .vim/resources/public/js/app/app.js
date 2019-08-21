define([], function(views, controllers) {
    function LoginViewModel(client) {
        this.client = client;
    }

    LoginViewModel.prototype.setDelegate = function(delegate) {
        this.delegate = delegate;
    };

    LoginViewModel.prototype.login = function(email, password) {
        this.client.login(email, password);
        // take the result of this and do something to the delegate with it
    };

    function SignupViewModel(client) {
        this.client = client;
        console.log("newed up the signup view model");
    }

    SignupViewModel.prototype.setDelegate = function(delegate) {
        this.delegate = delegate;
    };

    SignupViewModel.prototype.signup = function (firstname, lastname, email, password, stripe_token, callback) {
        this.client.signup(firstname, lastname, email, password, stripe_token, callback);
        // do something to the delegate with the result of the above call
    };

    var exports = {};
    exports.LoginViewModel = LoginViewModel;
    exports.SignupViewModel = SignupViewModel;
    return exports;
});
