var webpack = require("webpack"),
    path = require("path"),
    fileSystem = require("fs"),
    env = require("./utils/env"),
    CleanWebpackPlugin = require("clean-webpack-plugin").CleanWebpackPlugin,
    CopyWebpackPlugin = require("copy-webpack-plugin"),
    HtmlWebpackPlugin = require("html-webpack-plugin"),
    WriteFilePlugin = require("write-file-webpack-plugin");

// load the secrets
var alias = {};

var secretsPath = path.join(__dirname, ("secrets." + env.NODE_ENV + ".js"));

var fileExtensions = ["jpg", "jpeg", "png", "gif", "eot", "otf", "svg", "ttf", "woff", "woff2"];

if (fileSystem.existsSync(secretsPath)) {
    alias["secrets"] = secretsPath;
}

var options = {
    mode: process.env.NODE_ENV || "development",
    entry: {
        devtools: path.join(__dirname, "src", "devtools.js"),
        inspector: path.join(__dirname, "src", "inspector.js")
    },
    output: {
        path: path.join(__dirname, "build"),
        filename: "[name].bundle.js"
    },
    module: {
        rules: [
            {
                test: /\.css$/,
                loader: "style-loader!css-loader",
                exclude: /node_modules/
            },
            {
                test: new RegExp('.(' + fileExtensions.join('|') + ')$'),
                loader: "file-loader?name=[name].[ext]",
                exclude: /node_modules/
            },
            {
                test: /\.html$/,
                loader: "html-loader",
                exclude: /node_modules/
            }
        ]
    },
    resolve: {
        alias: alias
    },
    plugins: [
        // clean the build folder
        new CleanWebpackPlugin(),
        // expose and write the allowed env vars on the compiled bundle
        new webpack.EnvironmentPlugin(["NODE_ENV"]),
        new CopyWebpackPlugin([{
            from: "src/manifest.json",
            transform: function (content, path) {
                // generates the manifest file using the package.json informations
                return Buffer.from(JSON.stringify({
                    description: process.env.npm_package_description,
                    version: process.env.npm_package_version,
                    ...JSON.parse(content.toString())
                }))
            }
        }]),
        new CopyWebpackPlugin([{
            from: 'src/content.js'

    // "content_scripts": [
    //     {
    //         "matches": [
    //             "http://*/*",
    //             "https://*/*"
    //         ],
    //         "js": ["content.js"]
    //     }
    // ],
        }]),
        new CopyWebpackPlugin([{
            from: 'src/background.js'
        }]),
        new HtmlWebpackPlugin({
            template: path.join(__dirname, "src", "devtools.html"),
            filename: "devtools.html",
            chunks: ["devtools"]
        }),
        new HtmlWebpackPlugin({
            template: path.join(__dirname, "src", "inspector.html"),
            filename: "inspector.html",
            chunks: ["inspector"]
        }),
        new CopyWebpackPlugin([{
            from: 'src/main.wasm'
        }]),
        new WriteFilePlugin()
    ]
};

if (env.NODE_ENV === "development") {
    options.devtool = "cheap-module-eval-source-map";
}

module.exports = options;
