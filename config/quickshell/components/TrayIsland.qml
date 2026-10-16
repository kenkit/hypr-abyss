import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

/**
 * TrayIsland.qml
 * Módulo de Bandeja del Sistema (System Tray) para la Dynamic Island.
 * - Detecta y muestra aplicaciones en segundo plano vía StatusNotifierItem (Zoom, Telegram, Discord, Steam, etc.).
 * - Se oculta automáticamente si no hay ninguna aplicación en segundo plano.
 * - Soporta clic izquierdo para activar/abrir y clic derecho para menú contextual.
 * - Muestra tooltip con el nombre de la aplicación al pasar el cursor.
 */
Item {
    id: root

    property var theme

    readonly property int itemCount: SystemTray.items && SystemTray.items.values ? SystemTray.items.values.length : 0
    readonly property bool hasItems: itemCount > 0

    implicitHeight: 22
    height: 22
    implicitWidth: hasItems ? (itemCount * 22 + Math.max(0, itemCount - 1) * 5) : 0
    width: implicitWidth
    visible: hasItems

    Row {
        id: contentRow
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Repeater {
            model: SystemTray.items ? SystemTray.items.values : []

            delegate: Rectangle {
                id: trayItemDelegate
                implicitWidth: 22
                implicitHeight: 22
                width: 22
                height: 22
                radius: 11
                color: itemMouse.containsMouse ? (root.theme ? root.theme.surfaceHover : Qt.rgba(1, 1, 1, 0.12)) : Qt.rgba(1, 1, 1, 0.05)
                border.width: 1
                border.color: itemMouse.containsMouse ? (root.theme ? root.theme.borderHover : "#00ffcc") : Qt.rgba(1, 1, 1, 0.08)

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                IconImage {
                    id: itemIcon
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    source: modelData.icon || ""
                    onStatusChanged: console.log("[TrayIsland] itemIcon status:", status, "source:", source, "Ready?", status === Image.Ready)
                    Component.onCompleted: console.log("[TrayIsland] itemIcon init status:", status, "source:", source, "Ready?", status === Image.Ready)
                }

                // Fallback si no hay icono visual cargado o falló
                Text {
                    anchors.centerIn: parent
                    visible: itemIcon.status !== Image.Ready
                    text: (modelData.title && modelData.title.length > 0) ? modelData.title.substring(0, 1).toUpperCase() : "●"
                    font.pixelSize: 10
                    font.bold: true
                    color: root.theme ? root.theme.accent : "#00ffcc"
                }

                // Menú contextual para DBusMenu / SNI
                QsMenuAnchor {
                    id: menuAnchor
                    menu: modelData.menu
                    anchor.item: trayItemDelegate
                }

                // Indicador de atención / activo
                Rectangle {
                    visible: modelData.status === Status.NeedsAttention
                    width: 5
                    height: 5
                    radius: 2.5
                    color: root.theme ? root.theme.accent : "#00ffcc"
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            modelData.activate();
                        } else if (mouse.button === Qt.RightButton) {
                            if (modelData.hasMenu && menuAnchor.menu) {
                                menuAnchor.open();
                            } else {
                                modelData.secondaryActivate();
                            }
                        }
                    }
                }

                // Tooltip Cyberpunk flotante
                Rectangle {
                    visible: itemMouse.containsMouse && tooltipText.text.length > 0
                    anchors.top: parent.bottom
                    anchors.topMargin: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    z: 99
                    height: 16
                    width: tooltipText.implicitWidth + 8
                    radius: 4
                    color: root.theme ? root.theme.backgroundSolid : "#0d1117"
                    border.width: 1
                    border.color: root.theme ? root.theme.border : Qt.rgba(0, 1, 0.8, 0.3)

                    Text {
                        id: tooltipText
                        anchors.centerIn: parent
                        text: modelData.tooltipTitle || modelData.title || modelData.id || ""
                        font.pixelSize: 8
                        font.bold: true
                        color: root.theme ? root.theme.text : "#f0f6fc"
                    }
                }
            }
        }
    }
}
