var requirejs = require('requirejs');
var reporters = require('jasmine-reporters');
var jasmine = require('jasmine-node');

requirejs.config({
    packages: [
        {name: 'app',
         location: '../../resources/public/js/app/',
         main: 'app.js'}
    ]
});

requirejs(['spec/base-spec'], function () {
    jasmine.getEnv().addReporter(new jasmine.TerminalReporter({color:true}));
    jasmine.getEnv().execute();
});

global.define = requirejs;

for (key in jasmine) {
    if (jasmine[key] instanceof Function) {
        global[key] = jasmine[key];
    }
}
