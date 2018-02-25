(function() {
  var $mosaique = document.getElementById('mosaique');
  if (!$mosaique) return;

  var polygonsString = "";
  var i = 0;

  function nextData() {
    var data = dataHeroA;
    var polygons = data.polygons;

    if (i >= polygons.length) i = 0;

    return {
      newCycle: (i === 0),
      polygon: data.polygons[i++],
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

    $mosaique.innerHTML = "" +
    "<svg xmlns='http://www.w3.org/2000/svg' version='1.2' width='"+ meta.width +"' height='"+ meta.height +"'>" +
    "<rect x='0' y='0' width='"+ meta.width +"' height='"+ meta.height +"' fill='"+ meta.background +"' fill-opacity='1' />," +
    "["+ polygonsString +"]" +
    "</svg>";
  }, 100);

})();
