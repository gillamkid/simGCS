
import QtQuick.Controls.Material 2.15
import QtLocation 5.15

// A QtQuick::Map that supports Material.Light and Material.Dark mode 
Map {
    id: map
    plugin: Plugin { name: "osm" }
    activeMapType: map.supportedMapTypes[Material.theme == Material.Dark ? 4 : 0]

    onHeightChanged: {
        // QtQuick::Map has a bug where its coordinate positioned items will not have their
        // position updated when the map is resized (noticed in android: vehicle map icon would
        // not update if screen was rotated). This onHeightChanged callback patches the
        // issue. Note: issue only seems to be with height resizing (no issue in width resizing)
        pan(1, 1)
        pan(-1, -1)
    }
}