(function() {
  var $mosaique = document.getElementById('mosaique');
  if (!$mosaique) return;

  var polygonsString = "";
  var mosaiqueCounter = 0;

  function nextData() {
    var data = dataHeroA;
    var polygons = data.polygons;

    if (mosaiqueCounter >= polygons.length) mosaiqueCounter = 0;

    return {
      newCycle: (mosaiqueCounter === 0),
      polygon: data.polygons[mosaiqueCounter++],
      meta: {
        width: data.meta.width,
        height: data.meta.height,
        background: data.meta.background,
      }
    }
  }

  setInterval(function() {
    var data = nextData();
    var polygon = data.polygon;
    var meta = data.meta;

    if (data.newCycle) {
      polygonsString = "";
      $mosaique.style.height = (meta.height * 2) + 'px';
    }

    polygonsString += "<polygon points='"+ polygon.p +"' fill='"+ polygon.f +"' fill-opacity='"+ polygon.o +"' />,";

    if (mosaiqueCounter % 10) return;

    $mosaique.innerHTML = "" +
    "<svg xmlns='http://www.w3.org/2000/svg' version='1.2' width='"+ meta.width +"' height='"+ meta.height +"'>" +
    "<rect x='0' y='0' width='"+ meta.width +"' height='"+ meta.height +"' fill='"+ meta.background +"' fill-opacity='1' />," +
    "["+ polygonsString +"]" +
    "</svg>";
  }, 10);

})();
