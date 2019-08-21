requirejs.config({
    baseUrl: '/js'
});

requirejs(['app/core/app', 'app/core/apiclient', 'app/controllers'], function(app, apiclient, controllers){
    var client = new apiclient.APIClient();
    var currentController;
    var appContainer = $("#app");

    var swapControllers = function(controller) {

        if (currentController) {
            currentController.destroyView();
        }

        currentController = controller;

        currentController.loadView();
        currentController.viewWillAppear();
        appContainer.empty().append(currentController.view.content);
    };

    var routes = {
        "/login": function()
        { swapControllers(new controllers.LoginController(new app.LoginViewModel(client))); },
        "/signup": function()
        { swapControllers(new controllers.SignupController(new app.SignupViewModel(client))); }
    };

    var router = Router(routes);
    router.init();
});
