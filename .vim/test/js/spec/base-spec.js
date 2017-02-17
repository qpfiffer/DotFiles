'use strict';

define(['app/core/app'], function(app) {

    describe("another suite", function() {
        it("should pass", function() {
            expect(true).toBe(true);
        });

        it("should import something", function() {
            expect(app.LoginViewModel).toBeDefined();
        });
    });
});
