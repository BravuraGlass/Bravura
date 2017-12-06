
var gMapMarkers = [];
var map;

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

var socket = io('http://192.168.88.55:8080/');

function updatePositions(positions) {

    console.log('---------updated positions -----------', positions);

    markers.forEach((item, index) => {
      var data = positions[item.user_id];
      if (data.lat != item.lat || data.lng != item.lng) {
        markers[index].lat = data.lat;
        markers[index].lng = data.lng;

        var marker_data = markers[index];
        var position = new google.maps.LatLng(marker_data.lat, marker_data.lng);
        var content = marker_data.title || '';

        var marker = gMapMarkers[index]

        marker.setPosition(position);
      }
    });
  }