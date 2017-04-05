module.exports = function (grunt) {

    grunt.initConfig({
        pkg: grunt.file.readJSON("package.json"),
        concat: {
            options: {
                separator: ";\n"
            },
            dist: {
                src: ["src/**/*.js"],
                dest: "dist/<%= pkg.name %>.js"
            }
        },
        uglify: {
            options: {
                banner: "/* <%= pkg.name %> \
                    <%= grunt.template.today(\"dd-mm-yyyy\") %> */\n"
            },
            dist: {
                files: {
                    "dist/<%= pkg.name %>.min.js": ["<%= concat.dist.dest %>"]
                }
            }
        },
        eslint: {
            options: {
                fix: true
            },
            test: ["Gruntfile.js", "src/**/*.js", "test/**/*.js"]
        },
        babel: {
            options: {
            },
            dist: {
                files: [
                    {
                        expand: true,
                        cwd: "test/",
                        src: ["**/*.js"],
                        dest: "src/"
                    }
                ]
            }
        },
        exec: {
            create_log: {
                command: 'npm run log-init'
            },
            pull: {
                command: 'git pull'
            },
        },
        watch: {
            files: ["<%= eslint.test %>"],
            tasks: ["exec: create_log", "babel", "eslint"]
        }
    });

    grunt.loadNpmTasks("grunt-contrib-uglify");
    grunt.loadNpmTasks("grunt-contrib-watch");
    grunt.loadNpmTasks("grunt-contrib-concat");
    grunt.loadNpmTasks("gruntify-eslint");
    grunt.loadNpmTasks("grunt-babel");
    grunt.loadNpmTasks("grunt-exec");

    grunt.registerTask("init", ["exec:create_log", "exec:pull"])
    grunt.registerTask("build", ["babel", "eslint"]);
    grunt.registerTask("produce", ["babel", "eslint", "concat", "uglify"]);

};
