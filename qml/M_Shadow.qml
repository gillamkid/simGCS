import QtQuick 2.15
import QtQuick.Controls.Material 2.15

// Creates a shadow for a targetRect, such as a card to give it elevation. The 
// Shadow{} should have the same parent as its target Rectangle{} and be declared
// first so it will be properly centered under the target. 
//
// note: This was made an alternative to QtQuick::DropShadow, which wasn't working
// for me when i tried it with an android emulator (but worked fine on Linux).
// Adding a border to a rectangle with a radius also gave me troubles in Android
// emulator, but worked fine on Linux.
Rectangle {
    required property var targetRect

    property double shadowRadius: 6

    visible: targetRect.visible
    radius: targetRect.radius + shadowRadius
    x: targetRect.x - shadowRadius
    y: targetRect.y - shadowRadius
    width: targetRect.width + shadowRadius*2
    height: targetRect.height + shadowRadius*2
    color: Material.foreground
    opacity: Material.theme == Material.Dark ? 0.1 : 0.04

    // Shadow is composed of three overlappin Rectangles, where the upper rectangles
    // are smaller and darker to create the visual effect of a tappering shadow.
    Rectangle {
        color: parent.color
        x: shadowRadius/3
        y: shadowRadius/3
        width: parent.width - shadowRadius*2/3
        height: parent.height - shadowRadius*2/3
        radius: targetRect.radius + shadowRadius*2/3

        Rectangle {
            color: parent.color
            x: shadowRadius/3
            y: shadowRadius/3
            width: parent.width - shadowRadius*2/3
            height: parent.height - shadowRadius*2/3
            radius: targetRect.radius + shadowRadius/3
        }
    }

}