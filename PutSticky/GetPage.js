var GetPage = function() {};

GetPage.prototype = {
run: function(arguments) {
    arguments.completionFunction({"url": document.baseURI, "title": document.title});
},

finalize: function(arguments) {
    document.body.style.backgroundColor = "red"
}
};

var ExtensionPreprocessingJS = new GetPage();