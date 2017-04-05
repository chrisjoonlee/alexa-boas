"use strict";

require("dotenv").config();

const winston = require("winston");
winston.configure({
    level: process.env.WINSTON_LEVEL,
    transports: [new winston.transports.File({
        filename: function () {
            let d = new Date();
            let today = d.getFullYear().toString() + "-" + ("0" + (d.getMonth() + 1)).slice(-2) + "-" + ("0" + d.getDate()).slice(-2);
            return "log/" + today + "/index.log";
        }(),
        handleExceptions: true,
        json: true
    })]
});

module.exports = {
    winston: winston
};
;
"use strict";

const logger = require("./autowinston.js").winston;
const Alexa = require("alexa-sdk");

exports.handler = function (event, context, callback) {
    var alexa = Alexa.handler(event, context);
    // alexa.appId = 'amzn1.ask.skill.cd3b2003-235d-41c0-a43a-7eac2b98b408';
    alexa.registerHandlers(handlers);
    alexa.execute();
};

var handlers = {
    "HelloWorldIntent": function () {
        console.log("will this show up?");
        logger.info("this is an info");
        this.emit(":tell", "Hello World!");
    },

    "ByeWorldIntent": function () {
        this.emit(":tell", "Bye World!");
    }
};
