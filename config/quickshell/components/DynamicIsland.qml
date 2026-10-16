import QtQuick
import QtQuick.Layouts
import Quickshell

/**
 * DynamicIsland.qml
 * Cápsula flotante superior con estética Cyberpunk / Frosted Glass.
 * - Fondo semitransparente con desenfoque y esquinas redondeadas.
 * - Animación fluida de expansión y contracción horizontal (NumberAnimation, Easing.OutQuad).
 * - Módulos:
 *   1. Workspaces (Hyprland con ᗧ)
 *   2. Reproductor de Música MPRIS (expansible, con controles y ecualizador)
 *   3. Reloj Monospace
 *   4. System Tray (Apps en segundo plano como Zoom, Discord, Telegram)
 *   5. Hacker Stats (CPU, WiFi, Bluetooth, Batería)
 */
Item {
    id: root

    property var theme
    
    // Ancho y alto calculados reactivamente según el contenido
    implicitHeight: capsule.height
    implicitWidth: capsule.width

    // ==========================================
    // Cápsula Visual Principal
    // ==========================================
    Rectangle {
        id: capsule
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        // Altura compacta (30px)
        height: root.theme ? root.theme.capsuleHeightCompact : 30
        width: contentLayout.implicitWidth + ((root.theme ? root.theme.capsulePaddingH : 10) * 2)
        radius: root.theme ? root.theme.capsuleRadius : 15

        // Fondo frosted glass semitransparente
        color: root.theme ? root.theme.background : "#cc0d1117"

        // Borde neón sutil que brilla al pasar el ratón
        border.width: 1
        border.color: islandMouse.containsMouse 
                      ? (root.theme ? root.theme.borderHover : "#00ffcc")
                      : (root.theme ? root.theme.border : Qt.rgba(0, 1, 0.8, 0.3))

        // Animación fluida de anchura al expandir/contraer módulos
        Behavior on width {
            NumberAnimation {
                duration: root.theme ? root.theme.animDurationNormal : 300
                easing.type: Easing.OutQuad
            }
        }

        Behavior on border.color {
            ColorAnimation { duration: 180 }
        }

        // Resplandor de fondo sutil estilo cyberpunk
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: root.theme ? root.theme.accentGlow : Qt.rgba(0, 1, 0.8, 0.15)
            opacity: islandMouse.containsMouse ? 1.0 : 0.4

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

        // ==========================================
        // Área interactiva de fondo de la cápsula
        // ==========================================
        MouseArea {
            id: islandMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: true
        }

        // ==========================================
        // Contenido Modular de la Isla
        // ==========================================
        Row {
            id: contentLayout
            anchors.centerIn: parent
            spacing: 8

            // 1. Módulo Workspaces (Hyprland con ᗧ)
            Workspaces {
                id: wsModule
                theme: root.theme
                anchors.verticalCenter: parent.verticalCenter
            }

            // Separador 1 (Workspaces -> Siguiente)
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 10
                color: root.theme ? root.theme.borderSubtle : Qt.rgba(1, 1, 1, 0.12)
            }

            // 2. Módulo de Música / Audio (Se expande si hay música y se oculta automáticamente)
            MediaIsland {
                id: mediaModule
                theme: root.theme
                anchors.verticalCenter: parent.verticalCenter
            }

            // 3. Módulo Reloj y Fecha
            ClockWidget {
                id: clockModule
                theme: root.theme
                anchors.verticalCenter: parent.verticalCenter
            }

            // 4. Módulo de Bandeja del Sistema (Apps en segundo plano: Zoom, Telegram, Discord, etc.)
            Row {
                id: trayRow
                visible: trayModule.hasItems
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    implicitWidth: 1
                    height: 10
                    color: root.theme ? root.theme.borderSubtle : Qt.rgba(1, 1, 1, 0.12)
                }

                TrayIsland {
                    id: trayModule
                    theme: root.theme
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Separador previo a HackerStats
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 10
                color: root.theme ? root.theme.borderSubtle : Qt.rgba(1, 1, 1, 0.12)
            }

            // 5. Módulo Hacker Stats (CPU, WiFi, Bluetooth, Batería)
            HackerStats {
                id: statsModule
                theme: root.theme
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
