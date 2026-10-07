//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "components"

/**
 * shell.qml
 * Punto de entrada principal para Quickshell.
 * - Dynamic Island centrada en la parte superior (se oculta automáticamente en pantalla completa Super + F).
 * - Selector de Fondos de Pantalla flotante inferior (Super + V).
 * - Centro de Control y Notificaciones Lateral Derecho (Super + N / Clic en Reloj).
 * - Soporte multi-monitor independiente mediante Variants dedicados.
 */
ShellRoot {
    id: root

    // Gestor global de tema sincronizado con Pywal
    Theme {
        id: globalTheme
    }

    // Control de apertura del selector de fondos (Super + V)
    property bool wallpaperOpen: false

    // Control de apertura del Centro de Control y Notificaciones (Super + N)
    property bool controlCenterOpen: false

    // Control de apertura del Menú de Energía y Apagado (Super + P)
    property bool powerMenuOpen: false

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            root.wallpaperOpen = !root.wallpaperOpen;
        }
        function open(): void {
            root.wallpaperOpen = true;
        }
        function close(): void {
            root.wallpaperOpen = false;
        }
    }

    IpcHandler {
        target: "controlcenter"

        function toggle(): void {
            root.controlCenterOpen = !root.controlCenterOpen;
        }
        function open(): void {
            root.controlCenterOpen = true;
        }
        function close(): void {
            root.controlCenterOpen = false;
        }
    }

    IpcHandler {
        target: "powermenu"

        function toggle(): void {
            root.powerMenuOpen = !root.powerMenuOpen;
        }
        function open(): void {
            root.powerMenuOpen = true;
        }
        function close(): void {
            root.powerMenuOpen = false;
        }
    }

    // ==========================================
    // 1. Barra Flotante Superior (Dynamic Island)
    // ==========================================
    Variants {
        id: topBarVariants
        model: Quickshell.screens

        PanelWindow {
            id: topPanel
            property var modelData
            screen: modelData

            // Detección reactiva de ventana en pantalla completa en el workspace enfocado
            readonly property bool isFullscreen: {
                if (!Hyprland.focusedWorkspace) return false;
                return Hyprland.focusedWorkspace.hasFullscreen;
            }

            // Anclaje al borde superior de la pantalla
            anchors {
                top: true
                left: true
                right: true
            }

            // Se oculta automáticamente y libera el espacio exclusivo en pantalla completa
            visible: !isFullscreen
            implicitHeight: isFullscreen ? 0 : (island.implicitHeight + 8)
            exclusiveZone: isFullscreen ? 0 : (island.implicitHeight + 4)

            // Capa superior en Wayland
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            // Fondo 100% transparente para lograr el efecto flotante
            color: "transparent"

            // MÁSCARA DE CLIC
            mask: Region {
                item: topPanel.isFullscreen ? null : island
            }

            // Efecto de desenfoque de fondo Wayland nativo
            BackgroundEffect.blurRegion: Region {
                item: topPanel.isFullscreen ? null : island
            }

            // Cápsula Dynamic Island flotante y centrada
            DynamicIsland {
                id: island
                theme: globalTheme

                anchors.top: parent.top
                anchors.topMargin: 4
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ==========================================
    // 2. Selector de Fondos de Pantalla Flotante Inferior (Super + V)
    // ==========================================
    Variants {
        id: wallpaperVariants
        model: Quickshell.screens

        PanelWindow {
            id: wallpaperPanel
            property var modelData
            screen: modelData

            anchors {
                bottom: true
                left: true
                right: true
            }

            implicitHeight: root.wallpaperOpen ? 245 : 0
            visible: implicitHeight > 0

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: root.wallpaperOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            color: "transparent"

            mask: Region {
                item: selectorContainer
            }

            BackgroundEffect.blurRegion: Region {
                item: selectorContainer
            }

            WallpaperSelector {
                id: selectorContainer
                theme: globalTheme
                isOpen: root.wallpaperOpen
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                onCloseRequested: root.wallpaperOpen = false
            }
        }
    }

    // ==========================================
    // 3. Centro de Control & Notificaciones Lateral (Super + N / Reloj)
    // ==========================================
    Variants {
        id: controlCenterVariants
        model: Quickshell.screens

        PanelWindow {
            id: controlCenterPanel
            property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                right: true
            }

            implicitWidth: root.controlCenterOpen ? 300 : 0
            visible: implicitWidth > 0

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: root.controlCenterOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            color: "transparent"

            mask: Region {
                item: ccContainer
            }

            BackgroundEffect.blurRegion: Region {
                item: ccContainer
            }

            ControlCenter {
                id: ccContainer
                theme: globalTheme
                isOpen: root.controlCenterOpen
                anchors.fill: parent
                onCloseRequested: root.controlCenterOpen = false
            }
        }
    }

    // Cooldown para evitar que el trigger del borde reabra el panel inmediatamente al cerrarse
    property bool edgeCooldown: false

    Timer {
        id: edgeCooldownTimer
        interval: 900
        repeat: false
        onTriggered: root.edgeCooldown = false
    }

    onControlCenterOpenChanged: {
        if (!controlCenterOpen) {
            root.edgeCooldown = true;
            edgeCooldownTimer.restart();
        }
    }

    // ==========================================
    // 4. Activador por Borde Derecho (Auto-reveal al pasar el ratón)
    // ==========================================
    Variants {
        id: edgeTriggerVariants
        model: Quickshell.screens

        PanelWindow {
            id: edgeTriggerPanel
            property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                right: true
            }

            implicitWidth: 3
            visible: !root.controlCenterOpen && !root.edgeCooldown

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            color: "transparent"

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    if (!root.edgeCooldown) {
                        root.controlCenterOpen = true;
                    }
                }
            }
        }
    }

    // ==========================================
    // 5. Menú de Energía y Apagado Flotante (Super + P)
    // ==========================================
    Variants {
        id: powerMenuVariants
        model: Quickshell.screens

        PanelWindow {
            id: powerMenuPanel
            property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            visible: root.powerMenuOpen

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: root.powerMenuOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            color: "transparent"

            BackgroundEffect.blurRegion: Region {
                item: powerMenuContainer.card
            }

            PowerMenu {
                id: powerMenuContainer
                theme: globalTheme
                isOpen: root.powerMenuOpen
                anchors.fill: parent
                onCloseRequested: root.powerMenuOpen = false
            }
        }
    }
}
