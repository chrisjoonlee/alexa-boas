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