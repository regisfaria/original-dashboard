(function(chrome, $, mdash, graph) {
  "use strict";
  
  chrome.storage.local.get({
    data: "",
    sync: false
  }, function(items) {
    if (items.sync && items.data !== "") {
      //Chama a visualização da tela apropriada
      console.log("listOfActions");
      var listOfActions = mdash.listOfActions(items.data);
      console.log(listOfActions);
      
      $(".mdl-card__title-text", "#card-graph").html("Ações");
      $("#card-graph > .mdl-card__supporting-text").html();

      graph.Bubble({
        data: listOfActions,
        context: "#card-graph > .mdl-card__supporting-text",
        diameter: 400
      });

      $("#card-graph").show();
    }
  });
})(this.chrome, this.jQuery, this.mdash, this.graph);