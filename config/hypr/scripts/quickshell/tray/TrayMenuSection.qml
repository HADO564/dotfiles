import QtQuick
import Quickshell

// One level of a tray menu. Loads itself by URL for submenus, so nesting depth
// is whatever the app hands us over dbusmenu rather than a fixed guess.
//
// Sizing flows one way and never reads a `width` to produce a width:
//   row.implicitWidth (text + padding only)
//     -> section.naturalWidth  (max over rows, via remeasure())
//       -> the popup sizes itself
//         -> section.width -> rows stretch back out.
// The delegate is inline rather than a shared Component because a Component
// declared out here would not see the delegate's own ids.
Item {
    id: section

    // The QsMenuHandle whose children this level renders.
    property var menuHandle: null
    property var theme: null
    property int depth: 0
    property real scaleFactor: 1.0

    // Emitted when any descendant entry fires, so the popup can close itself.
    signal entryTriggered()

    function s(val) { return Math.round(val * section.scaleFactor); }

    readonly property int indent: depth * s(12)
    readonly property int padLeft: s(10) + indent
    readonly property int padRight: s(10)
    readonly property int gap: s(8)

    // Widest row at this level, including anything an open submenu contributes.
    property real naturalWidth: 0

    // Rescans rather than accumulating a max, so the menu also shrinks back
    // when a submenu collapses or the app rewrites its menu.
    function remeasure() {
        var m = 0;
        for (var i = 0; i < col.children.length; ++i) {
            var c = col.children[i];
            if (c && c.implicitWidth > m)
                m = c.implicitWidth;
        }
        section.naturalWidth = m;
    }

    onMenuHandleChanged: remeasure()

    implicitWidth: naturalWidth
    implicitHeight: col.height
    height: implicitHeight

    QsMenuOpener {
        id: opener
        menu: section.menuHandle
    }

    Column {
        id: col

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 0

        onChildrenChanged: section.remeasure()

        Repeater {
            model: opener.children

            delegate: Item {
                id: entryRoot

                required property var modelData
                readonly property var entry: entryRoot.modelData
                readonly property bool isSeparator: entry ? entry.isSeparator : false
                property bool submenuOpen: false

                width: col.width

                implicitWidth: isSeparator
                    ? section.padLeft + section.padRight
                    : Math.max(row.implicitWidth, subWrap.implicitWidth)
                implicitHeight: isSeparator
                    ? section.s(9)
                    : row.height + subWrap.height
                height: implicitHeight

                onImplicitWidthChanged: section.remeasure()
                Component.onCompleted: section.remeasure()

                // -------------------------------------------------------------
                // SEPARATOR
                // -------------------------------------------------------------
                Rectangle {
                    visible: entryRoot.isSeparator
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: section.padLeft
                    anchors.rightMargin: section.padRight
                    height: 1
                    color: section.theme
                        ? Qt.rgba(section.theme.text.r, section.theme.text.g, section.theme.text.b, 0.10)
                        : "#333333"
                }

                // -------------------------------------------------------------
                // ENTRY ROW
                // -------------------------------------------------------------
                Rectangle {
                    id: row

                    visible: !entryRoot.isSeparator
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: entryRoot.isSeparator ? 0 : section.s(32)
                    radius: section.s(9)

                    readonly property bool interactive: entryRoot.entry ? entryRoot.entry.enabled : false
                    readonly property bool highlighted: mouse.containsMouse && interactive

                    readonly property int indicatorW: entryRoot.entry && entryRoot.entry.buttonType !== QsMenuButtonType.None
                        ? section.s(15) : 0
                    readonly property int iconW: entryRoot.entry && entryRoot.entry.icon ? section.s(16) : 0
                    readonly property int chevronW: entryRoot.entry && entryRoot.entry.hasChildren
                        ? section.s(10) + section.gap : 0

                    implicitWidth: section.padLeft
                        + indicatorW + (indicatorW > 0 ? section.gap : 0)
                        + iconW + (iconW > 0 ? section.gap : 0)
                        + label.width
                        + chevronW
                        + section.padRight

                    color: {
                        if (!section.theme) return "transparent";
                        if (entryRoot.submenuOpen)
                            return Qt.rgba(section.theme.surface1.r, section.theme.surface1.g, section.theme.surface1.b, 0.85);
                        if (highlighted)
                            return Qt.rgba(section.theme.blue.r, section.theme.blue.g, section.theme.blue.b, 0.85);
                        return "transparent";
                    }

                    Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }

                    // Hovered rows slide in slightly; the pill alone was too
                    // quiet to register as a hover state.
                    property int hoverShift: highlighted ? section.s(5) : 0
                    Behavior on hoverShift {
                        NumberAnimation { duration: 190; easing.type: Easing.OutBack }
                    }

                    // Accent bar on the left edge, growing out of nothing.
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: section.indent + section.s(3)
                        width: section.s(3)
                        height: row.highlighted ? row.height * 0.5 : 0
                        radius: width / 2
                        color: section.theme ? section.theme.base : "#000000"
                        opacity: row.highlighted ? 0.55 : 0
                        Behavior on height { NumberAnimation { duration: 190; easing.type: Easing.OutBack } }
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: section.padLeft + row.hoverShift
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: section.gap

                        // Checkbox / radio indicator, only for entries that carry one.
                        Item {
                            anchors.verticalCenter: parent.verticalCenter
                            width: row.indicatorW
                            height: section.s(15)
                            visible: width > 0

                            Rectangle {
                                id: indicator
                                anchors.centerIn: parent
                                width: section.s(14)
                                height: section.s(14)
                                radius: entryRoot.entry && entryRoot.entry.buttonType === QsMenuButtonType.RadioButton
                                    ? width / 2 : section.s(4)

                                readonly property bool on: entryRoot.entry
                                    ? entryRoot.entry.checkState === Qt.Checked : false

                                color: on && section.theme ? section.theme.blue : "transparent"
                                border.width: 1
                                border.color: section.theme
                                    ? (on ? section.theme.blue
                                          : Qt.rgba(section.theme.text.r, section.theme.text.g, section.theme.text.b, 0.35))
                                    : "#555555"

                                Text {
                                    anchors.centerIn: parent
                                    visible: indicator.on
                                    text: ""
                                    font.family: "Iosevka Nerd Font"
                                    font.pixelSize: section.s(9)
                                    color: section.theme ? section.theme.base : "#000000"
                                }
                            }
                        }

                        // App-supplied icon, when the entry has one.
                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            source: (entryRoot.entry && entryRoot.entry.icon) || ""
                            fillMode: Image.PreserveAspectFit
                            sourceSize: Qt.size(section.s(16), section.s(16))
                            width: row.iconW
                            height: section.s(16)
                            visible: width > 0
                            opacity: row.interactive ? 1.0 : 0.4
                        }

                        Text {
                            id: label
                            anchors.verticalCenter: parent.verticalCenter
                            // dbusmenu labels carry GTK-style mnemonics; strip them.
                            text: ((entryRoot.entry && entryRoot.entry.text) || "").replace(/_([^_])/g, "$1")
                            font.family: "JetBrains Mono"
                            font.pixelSize: section.s(12)
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            width: Math.min(implicitWidth, section.s(280))
                            color: {
                                if (!section.theme) return "#cccccc";
                                if (!row.interactive) return section.theme.subtext0;
                                if (row.highlighted) return section.theme.base;
                                return section.theme.text;
                            }
                        }
                    }

                    // Submenu chevron, pinned right and rotating when expanded.
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: section.padRight - row.hoverShift
                        visible: row.chevronW > 0
                        text: ""
                        font.family: "Iosevka Nerd Font"
                        font.pixelSize: section.s(10)
                        color: row.highlighted && section.theme
                            ? section.theme.base
                            : (section.theme ? section.theme.subtext0 : "#888888")
                        rotation: entryRoot.submenuOpen ? 90 : 0
                        Behavior on rotation { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: row.interactive
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (entryRoot.entry.hasChildren) {
                                entryRoot.submenuOpen = !entryRoot.submenuOpen;
                            } else {
                                entryRoot.entry.triggered();
                                section.entryTriggered();
                            }
                        }
                    }
                }

                // -------------------------------------------------------------
                // SUBMENU
                // Expanded inline. A flyout would need a second Wayland popup
                // parented to this one; inline keeps positioning reliable.
                // -------------------------------------------------------------
                Item {
                    id: subWrap

                    anchors.top: row.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    clip: true

                    implicitWidth: subLoader.item ? subLoader.item.implicitWidth : 0
                    height: entryRoot.submenuOpen && subLoader.item ? subLoader.item.height : 0
                    visible: height > 0

                    Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                    // Loaded by URL rather than as an inline component: QML rejects
                    // a file that instantiates its own type statically, but a
                    // runtime Loader source is fine and still terminates, because
                    // dbusmenu trees are finite.
                    Loader {
                        id: subLoader
                        width: parent.width
                        // Stays loaded once opened so reopening does not re-round-trip dbus.
                        active: entryRoot.submenuOpen || item !== null
                        source: active ? Qt.resolvedUrl("TrayMenuSection.qml") : ""

                        onLoaded: {
                            item.menuHandle = entryRoot.entry;
                            item.depth = section.depth + 1;
                            item.theme = Qt.binding(function() { return section.theme; });
                            item.scaleFactor = Qt.binding(function() { return section.scaleFactor; });
                            item.entryTriggered.connect(section.entryTriggered);
                        }
                    }
                }
            }
        }
    }
}
