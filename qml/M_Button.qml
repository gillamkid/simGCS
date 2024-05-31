import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

// An adaptation of QtQuick::Button to make it more similar to
// Google's v3 Material button design 
Button {
    id: root
    Material.background: Material.color(Material.Blue, Material.Shade500)
    Material.foreground: "white"
    font.capitalization: Font.MixedCase

    height: 48

    background: Rectangle {
        color: Material.background
        opacity: root.enabled ? 1 : 0.2
        radius: 24

        // Overlay to darken the button when pressed
        Rectangle {
            anchors.fill: parent
            opacity: .1
            color: "black"
            visible: parent.parent.pressed 
            radius: 24
        }
    }
}