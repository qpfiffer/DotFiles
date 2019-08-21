define([], function() {
    function APIClient () {
        this.logged_in = false;
        this.EP = "localhost:5000";
    }

    APIClient.prototype.get_logged_inedness = function() {
        return this.logged_in;
    };

    APIClient.prototype.signup = function(firstname, lastname, email, password, stripe_token, callback) {
        // $.post(self.EP + "/users",
        //        {email: email, password: password, stripe_token: stripe_token},
        //        callback);
        console.log(email, password, stripe_token);
        callback();
    };

    APIClient.prototype.login = function (email, password) {
        console.log(email, password);
    };

    var exports = {};
    exports.APIClient = APIClient;
    return exports;
});
