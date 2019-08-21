define(['app/views'], function(views) {

    function LoginController(vm) {
        this.vm = vm;
    }

    LoginController.prototype.loadView = function() {
        this.view = new views.LoginView();
        this.view.setDelegate(this);
        this.vm.setDelegate(this);
    };

    LoginController.prototype.viewWillAppear = function() {
        console.log("unimplemented");
    };

    LoginController.prototype.destroyView = function() {
        this.view.setDelegate(null);
        this.vm.setDelegate(null);
    };
    
    function SignupController(vm) {
        this.vm = vm;
    }

    SignupController.prototype.loadView = function() {
        this.view = new views.SignupView();
        this.view.setDelegate(this);
        this.vm.setDelegate(this);
    };

    SignupController.prototype.viewWillAppear = function() {
        console.log("unimplemented");
    };

    SignupController.prototype.destroyView = function() {
        this.view.setDelegate(null);
        this.vm.setDelegate(null);
    };

    SignupController.prototype.signup = function (firstname, lastname, password, email, stripe_token) {
        this.vm.signup(firstname, lastname, password, email, stripe_token);
    };

    var exports = {};
    exports.SignupController = SignupController;
    exports.LoginController = LoginController;
    return exports;
});
