import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io 
import "../" 
import "../WindowRegistry.js" as Registry

PanelWindow {
    id: popupWindow

    // These properties are passed from Main.qml
    property var popupModel
    property real uiScale: 1.0

    // Fetch the registry properties dynamically based on the current screen width and uiScale
    property var layoutConfig: Registry.getPopupLayout(Screen.width, popupWindow.uiScale)

    WlrLayershell.namespace: "qs-popups"
    WlrLayershell.layer: WlrLayer.Overlay
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: popupWindow.layoutConfig.marginTop
        right: popupWindow.layoutConfig.marginRight
    }

    exclusionMode: ExclusionMode.Ignore
    focusable: false 
    color: "transparent"

    width: popupWindow.layoutConfig.w
    height: Math.min(popupList.contentHeight, Screen.height * 0.8)

    // Smoothly adjust window height so it doesn't instantly snap when popups are added/removed
    Behavior on height {
        NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
    }

    property bool dndEnabled: false

    // --- DND Polling Mechanism ---
    Process {
        id: dndPoller
        command: ["bash", "-c", "cat ~/.cache/qs_dnd 2>/dev/null || echo '0'"]
        stdout: StdioCollector {
            onStreamFinished: popupWindow.dndEnabled = (this.text.trim() === "1")
        }
    }
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: dndPoller.running = true
    }

    // --- WRAPPER ITEM FOR OPACITY FIX ---
    // Instead of fading the window, we fade the contents inside it.
    Item {
        id: contentWrapper
        anchors.fill: parent
        
        opacity: popupWindow.dndEnabled ? 0.0 : 1.0
        visible: opacity > 0.01 // Only hide completely when the fade out is basically done
        Behavior on opacity { NumberAnimation { duration: 300 } }

        MatugenColors { id: _theme }

        property var blobPalette1: [_theme.mauve, _theme.blue, _theme.peach, _theme.green, _theme.pink]
        property var blobPalette2: [_theme.sapphire, _theme.teal, _theme.maroon, _theme.yellow, _theme.red]

        property real globalOrbitAngle: 0
        NumberAnimation on globalOrbitAngle {
            from: 0; to: Math.PI * 2; duration: 25000; loops: Animation.Infinite; running: true
        }

        ListView {
            id: popupList
            anchors.fill: parent
            model: popupWindow.popupModel
            spacing: popupWindow.layoutConfig.spacing
            interactive: false 
            clip: false 

            add: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 400; easing.type: Easing.OutQuint }
                    NumberAnimation { property: "x"; from: popupWindow.width * 0.4; to: 0; duration: 500; easing.type: Easing.OutQuint }
                    NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 500; easing.type: Easing.OutQuint }
                }
            }
            
            remove: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; to: 0.0; duration: 350; easing.type: Easing.OutQuint }
                    NumberAnimation { property: "x"; to: popupWindow.width * 0.4; duration: 400; easing.type: Easing.OutQuint }
                    NumberAnimation { property: "scale"; to: 0.9; duration: 400; easing.type: Easing.OutQuint }
                }
            }

            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 450; easing.type: Easing.OutQuint }
            }

            delegate: Item {
                id: delegateRoot
                width: ListView.view.width
                height: contentCol.height + (popupWindow.layoutConfig.padding * 2)

                property string fullSummary: model.summary || ""
                property string fullBody: model.body || ""
                property int typeLenSum: 0
                property int typeLenBody: 0

                ParallelAnimation {
                    running: true
                    NumberAnimation { 
                        target: delegateRoot; property: "typeLenSum"; 
                        from: 0; to: fullSummary.length; 
                        duration: Math.min(fullSummary.length * 20, 600); 
                        easing.type: Easing.OutCubic 
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 150 }
                        NumberAnimation { 
                            target: delegateRoot; property: "typeLenBody"; 
                            from: 0; to: fullBody.length; 
                            duration: Math.min(fullBody.length * 15, 1200); 
                            easing.type: Easing.OutCubic 
                        }
                    }
                }

                Rectangle {
                    id: popupCard
                    anchors.fill: parent
                    radius: popupWindow.layoutConfig.radius
                    
                    color: _theme.base
                    border.color: _theme.surface1
                    border.width: 1
                    clip: true 
                    
                    property color blob1Color: contentWrapper.blobPalette1[index % 5]
                    property color blob2Color: contentWrapper.blobPalette2[index % 5]

                    // Hovering the X hands hover to dismissMa and takes it away
                    // from cardMa, so both have to count as "on the card".
                    property bool hovered: cardMa.containsMouse || dismissMa.containsMouse

                    Rectangle {
                        width: parent.width * 0.7; height: width; radius: width / 2
                        x: (parent.width / 2 - width / 2) + Math.cos(contentWrapper.globalOrbitAngle * 2 + index) * 60
                        y: (parent.height / 2 - height / 2) + Math.sin(contentWrapper.globalOrbitAngle * 2 + index) * 30
                        color: popupCard.blob1Color
                        opacity: 0.12
                    }
                    
                    Rectangle {
                        width: parent.width * 0.5; height: width; radius: width / 2
                        x: (parent.width / 2 - width / 2) + Math.sin(contentWrapper.globalOrbitAngle * 1.5 - index) * -50
                        y: (parent.height / 2 - height / 2) + Math.cos(contentWrapper.globalOrbitAngle * 1.5 - index) * -40
                        color: popupCard.blob2Color
                        opacity: 0.10
                    }

                    // Held while the pointer is on the card, so the popup can't
                    // expire out from under you as you reach for the X. Moving
                    // away restarts the full 5s rather than resuming the remainder.
                    Timer {
                        interval: 5000
                        running: !popupCard.hovered
                        onTriggered: masterWindow.removePopup(model.uid)
                    }

                    MouseArea {
                        id: cardMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            // 1. Intercept custom scripts and open the FOLDER natively in QML
                            if ((model.appName === "Screenshot" || model.appName === "Screen Recorder") && model.iconPath !== "") {
                                // Extract the folder path by cutting off everything after the last '/'
                                let folderPath = model.iconPath.substring(0, model.iconPath.lastIndexOf('/'))
                                Quickshell.execDetached(["xdg-open", folderPath])
                            } 
                            // 2. Standard Freedesktop action for regular apps
                            else {
                                if (model.notif && typeof model.notif.invokeAction === "function") {
                                    model.notif.invokeAction("default")
                                }
                            }

                            // 3. Clean up and close
                            if (model.notif && typeof model.notif.close === "function") {
                                model.notif.close()
                            }
                            masterWindow.removePopup(model.uid)
                        }
                        
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: _theme.surface0
                            opacity: parent.containsMouse ? 0.3 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 250 } }
                        }
                    }
                    // --- Dismiss (X) ---
                    // z keeps it above the card-wide MouseArea so clicking it
                    // dismisses instead of triggering the notification's action.
                    Rectangle {
                        id: dismissBtn
                        z: 10
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: popupWindow.layoutConfig.padding
                        width: 22 * popupWindow.uiScale
                        height: width
                        radius: width / 2
                        color: dismissMa.containsMouse ? Qt.alpha(_theme.red, 0.15) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: 12 * popupWindow.uiScale
                            text: "󰅖"
                            color: dismissMa.containsMouse ? _theme.red : _theme.overlay0
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        MouseArea {
                            id: dismissMa
                            // Negative margins give a comfortable hit target
                            // without enlarging the visible circle.
                            anchors.fill: parent
                            anchors.margins: -4 * popupWindow.uiScale
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: masterWindow.dismissNotification(model.uid)
                        }
                    }

                    ColumnLayout {
                        id: contentCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: popupWindow.layoutConfig.padding
                        spacing: 6 * popupWindow.uiScale

                        Text {
                            text: model.appName || "System"
                            font.family: "JetBrains Mono"
                            font.weight: Font.Medium
                            font.pixelSize: 12 * popupWindow.uiScale
                            color: _theme.overlay1
                            Layout.fillWidth: true
                            Layout.rightMargin: 26 * popupWindow.uiScale
                            elide: Text.ElideRight
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: hiddenSummary.implicitHeight

                            Text {
                                id: hiddenSummary
                                text: delegateRoot.fullSummary
                                width: parent.width
                                font.family: "JetBrains Mono"
                                font.weight: Font.Bold
                                font.pixelSize: 15 * popupWindow.uiScale
                                wrapMode: Text.Wrap
                                visible: false
                            }

                            Text {
                                anchors.fill: parent
                                text: delegateRoot.fullSummary.substring(0, delegateRoot.typeLenSum)
                                font: hiddenSummary.font
                                color: _theme.text
                                wrapMode: Text.Wrap
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: hiddenBody.implicitHeight
                            visible: delegateRoot.fullBody !== ""

                            Text {
                                id: hiddenBody
                                text: delegateRoot.fullBody
                                width: parent.width
                                font.family: "JetBrains Mono"
                                font.weight: Font.Medium
                                font.pixelSize: 13 * popupWindow.uiScale
                                wrapMode: Text.Wrap
                                textFormat: Text.PlainText
                                visible: false
                            }

                            Text {
                                anchors.fill: parent
                                text: delegateRoot.fullBody.substring(0, delegateRoot.typeLenBody)
                                font: hiddenBody.font
                                color: _theme.subtext0 
                                wrapMode: Text.Wrap
                                textFormat: Text.PlainText
                            }
                        }
                    }
                }
            }
        }
    }
}
