import QtQuick
import Quickshell
import Quickshell.Hyprland

// Themed replacement for QsMenuAnchor, which renders a native (unstyled) Qt
// widget menu. This draws the same dbusmenu tree in QML using the matugen
// palette, so tray menus match the bar instead of looking like stock Qt.
PopupWindow {
    id: root

    // Set by the caller before open(): the SystemTrayItem's `menu` handle.
    property var menuHandle: null
    // The bar item to hang the popup off of.
    property Item anchorItem: null
    property var theme: null
    property real scaleFactor: 1.0
    // Windows that should not dismiss the menu when clicked (the bar itself,
    // so a second right-click on the tray icon toggles rather than reopens).
    property var passthroughWindows: []

    function s(val) { return Math.round(val * root.scaleFactor); }

    function open() {
        if (!root.menuHandle) return;
        root.visible = true;
    }

    function close() {
        root.visible = false;
    }

    function toggle() {
        if (root.visible) root.close();
        else root.open();
    }

    anchor.item: root.anchorItem
    anchor.rect.y: root.anchorItem ? root.anchorItem.height + root.s(10) : 0
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom | Edges.Left
    // Slide along the screen edge rather than falling off it.
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY

    // Padding sits outside the card so the drop shadow has room to breathe.
    readonly property int pad: s(6)

    implicitWidth: Math.max(s(160), card.implicitWidth) + pad * 2
    implicitHeight: card.implicitHeight + pad * 2

    color: "transparent"
    visible: false

    // Dismiss on click-outside / focus loss. Hyprland-specific, matching the
    // rest of this config.
    HyprlandFocusGrab {
        id: grab
        windows: [root].concat(root.passthroughWindows)
        active: root.visible
        onCleared: root.close()
    }

    Item {
        anchors.fill: parent

        // Soft shadow, faked with stacked translucent rounded rects so this
        // needs no QtQuick.Effects / graphics pipeline assumptions.
        Repeater {
            model: 4
            delegate: Rectangle {
                required property int index
                anchors.centerIn: card
                width: card.width + index * 2
                height: card.height + index * 2
                radius: card.radius + index
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(0, 0, 0, 0.10 - index * 0.02)
                opacity: card.opacity
            }
        }

        Rectangle {
            id: card

            anchors.centerIn: parent
            width: parent.width - root.pad * 2
            height: parent.height - root.pad * 2

            implicitWidth: section.implicitWidth + root.s(12)
            implicitHeight: section.height + root.s(12)

            radius: root.s(14)
            color: root.theme
                ? Qt.rgba(root.theme.base.r, root.theme.base.g, root.theme.base.b, 0.96)
                : "#12121a"
            border.width: 1
            border.color: root.theme
                ? Qt.rgba(root.theme.text.r, root.theme.text.g, root.theme.text.b, 0.10)
                : "#2a2a35"

            // Matches the bar's entrance feel.
            opacity: root.visible ? 1 : 0
            scale: root.visible ? 1 : 0.94
            transformOrigin: Item.Top
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

            TrayMenuSection {
                id: section

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: root.s(6)
                anchors.leftMargin: root.s(6)
                anchors.rightMargin: root.s(6)

                menuHandle: root.menuHandle
                theme: root.theme
                scaleFactor: root.scaleFactor

                onEntryTriggered: root.close()
            }
        }
    }
}
