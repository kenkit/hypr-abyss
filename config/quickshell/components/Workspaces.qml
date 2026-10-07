import QtQuick
import Quickshell
import Quickshell.Hyprland

/**
 * Workspaces.qml
 * Indicadores minimalistas estilo Pacman / Cyberpunk para Hyprland.
 * - Renderizado vectorial nítido de Pacman (ᗧ) inmune a fuentes faltantes y escalado 1.5x.
 * - Aparece Pacman 'ᗧ' únicamente en los espacios de trabajo que tienen aplicaciones abiertas.
 * - Los espacios vacíos muestran un punto '·' sutil y limpio.
 * - El espacio activo se ilumina con acento neón y resplandor.
 */
Item {
    id: root

    property var theme
    implicitHeight: 22
    implicitWidth: wsRow.implicitWidth

    readonly property var baseWorkspaces: [1, 2, 3, 4, 5]

    function getWorkspace(wsId) {
        if (!Hyprland.workspaces || !Hyprland.workspaces.values) return null;
        var list = Hyprland.workspaces.values;
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === wsId) {
                return list[i];
            }
        }
        return null;
    }

    function hasApp(wsId) {
        var ws = getWorkspace(wsId);
        if (!ws) return false;
        if (ws.windows !== undefined) {
            return ws.windows > 0;
        }
        return true;
    }

    function isFocused(wsId) {
        return Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId;
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) {
                Hyprland.dispatch("workspace e-1");
            } else if (wheel.angleDelta.y < 0) {
                Hyprland.dispatch("workspace e+1");
            }
        }
    }

    Row {
        id: wsRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Repeater {
            model: root.baseWorkspaces

            delegate: Item {
                id: wsItem
                readonly property int wsId: modelData
                readonly property bool focused: root.isFocused(wsId)
                readonly property bool appOpen: root.hasApp(wsId)
                readonly property bool hovered: dotMouse.containsMouse

                width: appOpen ? 16 : (focused ? 10 : 6)
                height: 18
                anchors.verticalCenter: parent.verticalCenter

                Behavior on width {
                    NumberAnimation {
                        duration: root.theme ? root.theme.animDurationFast : 160
                        easing.type: Easing.OutQuad
                    }
                }

                // ==========================================
                // Pacman Vectorial ᗧ (App Abierta)
                // ==========================================
                Canvas {
                    id: pacman
                    anchors.centerIn: parent
                    visible: wsItem.appOpen
                    width: 14
                    height: 14
                    antialiasing: true

                    property color pacColor: {
                        if (wsItem.focused) {
                            return root.theme ? root.theme.accent : "#00ffcc";
                        }
                        if (wsItem.hovered) {
                            return root.theme ? root.theme.accentAlt : "#bd93f9";
                        }
                        return root.theme ? root.theme.text : "#f0f6fc";
                    }

                    onPacColorChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.fillStyle = pacColor;
                        ctx.beginPath();
                        // Dibuja el cuerpo de Pacman con la boca abierta hacia la derecha
                        ctx.arc(7, 7, 5.5, 0.22 * Math.PI, 1.78 * Math.PI, false);
                        ctx.lineTo(7, 7);
                        ctx.closePath();
                        ctx.fill();
                    }
                }

                // ==========================================
                // Pac-Dot Minimalista '·' (Espacio Vacío)
                // ==========================================
                Rectangle {
                    anchors.centerIn: parent
                    visible: !wsItem.appOpen
                    width: wsItem.focused ? 6 : (wsItem.hovered ? 5 : 3.5)
                    height: width
                    radius: width / 2

                    color: {
                        if (wsItem.focused) {
                            return root.theme ? root.theme.accent : "#00ffcc";
                        }
                        if (wsItem.hovered) {
                            return root.theme ? root.theme.accentGlow : Qt.rgba(0, 1, 0.8, 0.5);
                        }
                        return root.theme ? root.theme.textDim : "#6e7681";
                    }

                    opacity: wsItem.focused ? 1.0 : (wsItem.hovered ? 0.85 : 0.4)

                    Behavior on width {
                        NumberAnimation { duration: 140; easing.type: Easing.OutQuad }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 140 }
                    }
                }

                // Área de clic
                MouseArea {
                    id: dotMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        Hyprland.dispatch("workspace " + wsItem.wsId);
                    }
                }
            }
        }
    }
}
