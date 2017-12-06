
var gMapMarkers = [];
var map;
var socket = io('http://52.15.199.76:8080');

function initMapWithMarkers(markers) {
  var center = markers.length > 0 ? markers[0] : {
      lat: 40.6179997,
      lng: -73.9344151
    };
  map = new google.maps.Map(document.getElementById('location-map'), {
    zoom: 6,
    center: center
  });

  if(markers && markers.length > 0) {
    for( var i = 0; i < markers.length; i++ ) {
      var marker_data = markers[i];
      var content = marker_data.title || '';
      var position = new google.maps.LatLng(marker_data.lat, marker_data.lng);
      var marker = new google.maps.Marker({
        position: position,
        map: map,
        title: content
      });
      marker.setVisible(true);
      gMapMarkers.push(marker);
    }
  }

  socket.on('update_positions', updatePositions);
}