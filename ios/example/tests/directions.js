
exports.title = 'Directions';
exports.run = function(UI, Map) {
    var win = UI.createWindow();
    
    var map = Map.createView({
        userLocation: true,
        mapType: Map.NORMAL_TYPE,
        animate: true,
        region: {latitude: 35.665213, longitude: 139.730011, latitudeDelta: 0.02, longitudeDelta: 0.02 }, //Roppongi
        top: '10%'
    });
    win.add(map);
    
    var directions = Map.createDirections({
        source: {
            latitude: 35.665213,
            longitude: 139.730011
        },
        destination: {
            latitude: 35.658987,
            longitude: 139.702776
        }
    });
    
    directions.addEventListener('success', function(e){
        var route = Map.createRoute({
            points: e.coordinates,
            color: 'blue',
            width: 5.0
        });
        
        map.addRoute(route);
    });
    
    directions.addEventListener('error', function(e){
        alert('Error');
    });
    
    win.open();
}
