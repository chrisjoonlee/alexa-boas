// @flow

{
    "use strict";

    const logger = require("./autowinston.js").winston;
    const Alexa = require("alexa-sdk");

    exports.handler = function (event: any, context: any, callback: any) {
        var alexa = Alexa.handler(event, context);
    // alexa.appId = 'amzn1.ask.skill.cd3b2003-235d-41c0-a43a-7eac2b98b408';
        alexa.registerHandlers(handlers);
        alexa.execute();
    };

    var handlers = {
        "HelloWorldIntent": function (): void {
            this.emit(":tell", "Hello World!");
        },

        "ByeWorldIntent": function (): void {
            this.emit(":tell", "Bye World!");
        }
    };
}
