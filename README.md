# 🚀 Quickshell Dynamic Island (Cyberpunk / Hacker Aesthetic)

Dynamic Island minimalista y semitransparente estilo frosted glass desarrollada en **QML (QtQuick)** y **Quickshell** para **Hyprland** en Arch Linux.

---

## 🎨 Características de Diseño y Estética

- **Formato Cápsula Flotante (Dynamic Island)**: Centrada en el margen superior (`anchors.top`, `anchors.horizontalCenter`).
- **Frosted Glass Semitransparente**: Fondo con tintado profundo (`#aa0d1117` / variable Pywal al 75% de opacidad), desenfoque Wayland (`BackgroundEffect` y `layerrule`) y esquinas redondeadas (`radius: 20`).
- **Animaciones Fluidas**: Expansión y contracción suaves controladas por `NumberAnimation` con curvas `Easing.OutQuad`.
- **Sincronización Dinámica con Pywal**: Lee y vigila reactivamente `~/.cache/wal/colors.json`. Cambia automáticamente la paleta de colores y el borde al actualizar el wallpaper.
- **Click-Through Inteligente**: La ventana utiliza una máscara de clic (`mask: Region { item: island }`), permitiendo interactuar con cualquier ventana detrás de la barra fuera de la cápsula.

---

## 🧩 Módulos Integrados

1. **Workspaces Cyberpunk / Pacman (Hyprland)**:
   - Los números se han sustituido por el icónico carácter **`ᗧ`** cuando hay al menos una aplicación abierta en el espacio de trabajo.
   - Los espacios vacíos muestran un punto minimalista `·`.
   - Resplandor y animación neón reactiva en el espacio enfocado.
   - Clic directo para cambiar de espacio y soporte para rueda del ratón (`workspace e-1` / `workspace e+1`).

2. **Reloj Estilizado**:
   - Cápsula integrada con micro-icono `󰥔`, tipografía `JetBrainsMono Nerd Font` y dos puntos parpadeantes.
   - Al pasar el cursor o hacer clic, despliega la fecha formateada (`DOM 4 OCT`).

3. **Módulo de Hardware y Conectividad (Sin RAM)**:
   - **CPU**: Consumo discreto en tiempo real (`󰻠 08%`).
   - **WiFi**: Icono dinámico según la calidad de la señal (`󰤨`), con visualización del SSID al pasar el cursor.
   - **Bluetooth**: Estado activo (`󰂯`) o inactivo (`󰂲`) con nombre del dispositivo conectado.
   - **Batería**: Porcentaje (`100%`), icono inteligente (`󰁹` / `󰂄` en carga) y colores dinámicos (Verde > 30%, Ámbar 15-30%, Rojo < 15%).

4. **Media / Audio (MPRIS Dynamic Island)**:
   - Se activa automáticamente cuando hay música reproduciéndose (Spotify, mpv, Firefox, etc.).
   - Expande fluidamente la cápsula para revelar:
     - **Ecualizador animado de 4 barras** con ritmo visual.
     - Título y artista de la pista con elipsis limpia.
     - Controles interactivos: `⏮` Anterior, `⏯` Play/Pause, `⏭` Siguiente.
     - Indicador y control de volumen con soporte para rueda del ratón y clic en la barra.

---

## 📂 Estructura de Archivos

```
~/.config/quickshell/
├── shell.qml                     # Entrada principal, capa Wayland y multi-monitor
├── Theme.qml                     # Motor de temas y sincronización con Pywal
├── components/
│   ├── DynamicIsland.qml         # Cápsula principal con animación y layout dinámico
│   ├── Workspaces.qml            # Indicadores de workspaces para Hyprland
│   ├── ClockWidget.qml           # Reloj y fecha monospace
│   ├── HackerStats.qml           # Medidor de CPU y RAM
│   └── MediaIsland.qml           # Módulo de música MPRIS y volumen
├── scripts/
│   └── stats.sh                  # Script optimizado en bash/awk para métricas
├── examples/
│   └── colors.json               # Paleta de muestra Pywal cyberpunk
└── README.md
```

---
IMAGENES
<img width="1920" height="1080" alt="screenshot_2026-10-06_22-25-47" src="https://github.com/user-attachments/assets/2d47f0a6-040b-474f-bede-ac51774917f2" />
<img width="903" height="443" alt="swappy-20261006_222611" src="https://github.com/user-attachments/assets/ae1ca7f2-4d8c-41b5-9ddd-638c1028c9f2" />
<img width="1920" height="1080" alt="swappy-20261006_222627" src="https://github.com/user-attachments/assets/87444f2d-24e4-4782-9be4-60b6bc2f8c61" />
<img width="1920" height="1080" alt="swappy-20261006_222646" src="https://github.com/user-attachments/assets/9035749a-27b5-4801-93ab-318d8ba9b04c" />
<img width="1138" height="212" alt="swappy-20261006_222717" src="https://github.com/user-attachments/assets/f2044b39-2071-4240-9543-69cfcbb362ca" />



## ⚡ Ejecución y Pruebas

Para ejecutar la Dynamic Island en primer plano y verificar registros:
```bash
quickshell
```

O especificando el directorio explícitamente:
```bash
quickshell -p ~/.config/quickshell
```

### Autostart en Hyprland
Ya configurado en `~/.config/hypr/autostart.lua`:
```lua
hl.exec_cmd("quickshell")
```

### Desenfoque en Hyprland (Frosted Glass)
Añadido a `~/.config/hypr/rules.lua`:
```lua
hl.exec_cmd("hyprctl keyword layerrule 'blur, quickshell'")
hl.exec_cmd("hyprctl keyword layerrule 'ignorezero, quickshell'")
```
