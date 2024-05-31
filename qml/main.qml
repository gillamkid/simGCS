import QtLocation 5.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Window 2.15
import QFlightMode 1.0

// An app that lets the user view the location of a UAS on a map, view some
// status data like battery and speed, and send command to the UAS to 
// launch, land, hold, or move to a selected coordinate.
//
// Tested on Ubuntu 22 Desktop and Android 12 x86_64 emulator (Galaxy Nexus)
Window {
    id: root

    // this is were we get a reference to the UAS model that is getting constantly
    // updated by the c++ backend
    property var vehicle: telemetrySimContextProp

    // mimic a landscape phone when running on Linux. On Android the 
    // app will fill the screen whatever size it may be
    width: 640
    height: 360

    visible: true
    title: qsTr("Sim GCS")
    Material.theme: Material.Dark

    M_Rect {
        id: titleBanner
        width: parent.width
        height: title.height + 20

        Label {
            id: title
            anchors.centerIn: parent
            text: "Sim GCS"
        }
        // toggle Light/Dark mode button
        M_Button {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "images/darkLightToggle.png"
            icon.width: 20
            icon.height: 20
            icon.color: Material.theme == Material.Dark ? "white" : "black"
            Material.background: "transparent"
            onClicked: root.Material.theme = Material.theme == Material.Dark ? Material.Light : Material.Dark
        }
    }

    Rectangle {
        id: titleBannerBtmBorder
        y: titleBanner.height
        width: parent.width
        height: 1
        color: Material.color(Material.Grey, Material.Shade300)
    }

    M_Map {
        id: map
       
        anchors.top: titleBannerBtmBorder.bottom
        width: parent.width
        height: parent.height
        zoomLevel: 17

        // GoTo marker
        MapQuickItem {
            visible: vehicle.flightMode == QFlightMode.GOTO
            anchorPoint.x: sourceItem.width / 2
            anchorPoint.y: sourceItem.height
            coordinate: vehicle.goToTarget
            sourceItem: Image {
                source: "images/mapMarker.png"
                width: 30
                height: width
            }
        }

        // vehicle icon
        MapQuickItem {
            anchorPoint.x: sourceItem.width / 2
            anchorPoint.y: sourceItem.height / 2
            coordinate: vehicle.location
            sourceItem: Image {
                id: vehicleMarkerImg
                source: "images/FirestormArrowWhiteLeft.png"
                width: 80
                height: width
                transform: Rotation {
                    origin.x: vehicleMarkerImg.width/2
                    origin.y: vehicleMarkerImg.width/2
                    angle: 90 + vehicle.heading_deg - map.bearing
                }
            }
        }

        // Handle clicks when setting GoTo
        MouseArea {
            visible: selectGoToBanner.visible
            anchors.fill: parent
            onClicked: {
                var coord = map.toCoordinate(Qt.point(mouse.x, mouse.y));
                vehicle.goTo(coord)
                selectGoToBanner.visible = false
            }
        }

    }

    M_Shadow {
        targetRect: selectGoToBanner
    }
    M_Rect {
        id: selectGoToBanner
        y: titleBanner.height + 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: goToBannerContents.width + 32
        height: goToBannerContents.height + 12
        radius: 5
        visible: false

        Row {
            id: goToBannerContents
            anchors.centerIn: parent
            spacing: 32
            M_Text {
                text: "Select GoTo target on map"
                anchors.verticalCenter: parent.verticalCenter
            }
            M_Button {
                id: cancelBtn
                text: "Cancel"
                onClicked: selectGoToBanner.visible = false
                Material.background: "transparent"
                Material.foreground: Material.color(Material.Blue, Material.theme == Material.Dark ? Material.Shade200 : Material.Shade900)
            }
        }
    }

    M_Shadow {
        targetRect: dashboard
    }
    M_Rect {
        id: dashboard
        y: titleBanner.height + 8
        width: dashContent.width + 16
        height: dashContent.height + 16
        visible: !selectGoToBanner.visible
        property double cellWidth: 100

        Column {
            id: dashContent
            anchors.centerIn: parent
            spacing: 8

            Grid {
                id: dbKeyValues
                columns: root.width > root.height ? 2 : 1
                spacing: 8

                KeyValue { 
                    keyText: "Battery" 
                    valueText: vehicle.batteryPercent.toFixed(1)
                    suffixText: " %"
                }
                KeyValue { 
                    keyText: "Altitude"
                    valueText: vehicle.location.altitude.toFixed(1)
                    suffixText: " m"
                }

                KeyValue { 
                    keyText: "Latitude"
                    valueText: vehicle.location.latitude.toFixed(5)
                    suffixText: " °" 
                    floorSuffixWithVal: false
                }
                KeyValue { 
                    keyText: "Longitude"
                    valueText: vehicle.location.longitude.toFixed(5)
                    suffixText: " °" 
                    floorSuffixWithVal: false
                }

                KeyValue { 
                    keyText: "Speed"
                    valueText: vehicle.speed_mps.toFixed(1)
                    suffixText: " m/s"
                }
                KeyValue { 
                    keyText: "Flight Mode"
                    valueText: QFlightMode.toString(vehicle.flightMode)
                }
           }

            // line divider
            Rectangle {
                color: Material.foreground
                opacity: 0.2
                height: 1
                width: dbKeyValues.width
            }

           Grid {
                columns: root.width > root.height ? 2 : 1
                columnSpacing: 8

                // exactly one of these 3 buttons is always shown at any given time
                M_Button {
                    text: "Takeoff"
                    visible: vehicle.flightMode == QFlightMode.GROUND
                    width: dashboard.cellWidth
                    onClicked: vehicle.takeoff()
                }
                M_Button {
                    text: "Land"
                    visible: vehicle.flightMode == QFlightMode.HOLD
                    width: dashboard.cellWidth
                    onClicked: vehicle.land()
                }
                M_Button {
                    text: "Hold"
                    visible: vehicle.flightMode == QFlightMode.GOTO || vehicle.flightMode == QFlightMode.TAKEOFF || vehicle.flightMode == QFlightMode.LAND
                    width: dashboard.cellWidth
                    onClicked: vehicle.hold()
                    Material.background: Material.color(Material.Amber, Material.Shade100)
                    Material.foreground: Qt.darker(Material.color(Material.Amber, Material.Shade900), 1.3)
                }

                // always shown, but disabled when appropriate
                M_Button {
                    id: goToBtn
                    text: "Go to"
                    enabled: vehicle.flightMode == QFlightMode.HOLD
                    width: dashboard.cellWidth
                    onClicked: selectGoToBanner.visible = true
                    Material.background: Material.color(Material.Blue, Material.Shade100)
                    Material.foreground: Material.color(Material.Blue, Material.Shade900)

                }
            }
        }
    }

    // Shows the name of a property and the property's value. Follows design described 
    // here: https://design.mindsphere.io/patterns/key-value.html
    component KeyValue: Column {
        required property string keyText
        required property string valueText
        property string suffixText: ""
        property bool floorSuffixWithVal: true

        // give fixed width so columns are same width when in a table with other KeyValues
        width: dashboard.cellWidth
        spacing: 2

        M_Text {
            text: keyText
            font.pointSize: 12
            opacity: 0.5
        }
        Row {
            M_Text { 
                text: valueText 
            }
            M_Text { 
                text: suffixText 
                y: floorSuffixWithVal ? 3 : 0
                font.pointSize: 12
            }
        }
    }
}
