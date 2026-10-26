import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root

    property int selectedIndex: 0
    property int currentPage: 0
    readonly property int pageSize: 9
    readonly property int pageCount: Math.max(1, Math.ceil(themes.length / pageSize))
    readonly property int pageStart: currentPage * pageSize
    readonly property var visibleThemes: themes.slice(pageStart, Math.min(pageStart + pageSize, themes.length))
    readonly property string activeTheme: Quickshell.env("THEME_PICKER_ACTIVE")
    readonly property var themes: [
        { key: "obsidian-rose", name: "Obsidian Rose", subtitle: "Noir profond · vert acide", image: Quickshell.env("THEME_PICKER_OBSIDIAN_ROSE_WALLPAPER") || "/home/Ugzher/Pictures/Wallpapers/dragon.jpg", colors: ["#0d0911", "#c7f36b", "#b48ead", "#78dba9"] },
        { key: "catppuccin-mocha", name: "Catppuccin Mocha", subtitle: "Doux · mauve · nocturne", image: Quickshell.env("THEME_PICKER_CATPPUCCIN_MOCHA_WALLPAPER") || "/home/Ugzher/Pictures/Wallpapers/catppuccin.png", colors: ["#1e1e2e", "#cba6f7", "#f38ba8", "#89b4fa"] },
        { key: "gruvbox-soft-dark", name: "Gruvbox Dark", subtitle: "Chaud · sombre · organique", image: Quickshell.env("THEME_PICKER_GRUVBOX_SOFT_DARK_WALLPAPER") || "/home/Ugzher/Pictures/Wallpapers/gruvbox_dark.jpg", colors: ["#32302f", "#d79921", "#d65d0e", "#689d6a"] },
        { key: "melange-dark", name: "Melange Dark", subtitle: "Terre · ambre · feutré", image: Quickshell.env("THEME_PICKER_MELANGE_DARK_WALLPAPER") || "/home/Ugzher/Pictures/Wallpapers/gruvbox_dark.jpg", colors: ["#292522", "#e49b5d", "#78997a", "#7f91b2"] },
        { key: "gruvbox-soft-light", name: "Gruvbox Light", subtitle: "Sable · doré · lumineux", image: Quickshell.env("THEME_PICKER_GRUVBOX_SOFT_LIGHT_WALLPAPER") || "/home/Ugzher/Pictures/Wallpapers/gruvbox_light.jpg", colors: ["#f2e5bc", "#b57614", "#af3a03", "#79740e"] },
        { key: "nord", name: "Nord", subtitle: "Polaire · feutré · bleuté", image: Quickshell.env("THEME_PICKER_NORD_WALLPAPER") || "/home/Ugzher/Pictures/Wallpapers/catppuccin.png", colors: ["#2e3440", "#88c0d0", "#81a1c1", "#b48ead"] },
        { key: "platinum-night", name: "Platinum Night", subtitle: "Sora · argent · nocturne", image: Quickshell.env("THEME_PICKER_PLATINUM_NIGHT_WALLPAPER") || "/home/Ugzher/Pictures/Wallpapers/setup-exe.jpg", colors: ["#0e1018", "#80c8e0", "#8898b8", "#d4b878"] },
        { key: "oxocarbon", name: "Oxocarbon", subtitle: "IBM · industriel · électrique", image: Quickshell.env("THEME_PICKER_OXOCARBON_WALLPAPER") || "/home/Ugzher/Pictures/Wallpapers/catppuccin.png", colors: ["#161616", "#78a9ff", "#3ddbd9", "#ff7eb6"] },
        { key: "seoul256-dark", name: "Seoul256 Dark", subtitle: "Charbon · pastel · feutré", image: Quickshell.env("THEME_PICKER_SEOUL256_DARK_WALLPAPER") || "/home/Ugzher/Pictures/Wallpapers/gruvbox_dark.jpg", colors: ["#4b4b4b", "#96bbdc", "#e07798", "#e0bb71"] },
        { key: "cool-panda", name: "Cool Panda", subtitle: "Noir · turquoise · électrique", image: Quickshell.env("THEME_PICKER_COOL_PANDA_WALLPAPER") || "/home/Ugzher/Pictures/Wallpapers/catppuccin.png", colors: ["#212121", "#14dbc4", "#e6789e", "#92a3ff"] }
    ]
    readonly property var uiTheme: {
        for (let index = 0; index < themes.length; index++) {
            if (themes[index].key === activeTheme)
                return themes[index]
        }

        return themes.length > 0 ? themes[selectedIndex] : null
    }
    readonly property color uiBaseColor: uiTheme ? uiTheme.colors[0] : "#14141c"
    readonly property color uiAccentColor: uiTheme ? uiTheme.colors[1] : "#c7c7d6"
    readonly property bool uiIsLight: uiBaseColor.r * 0.299 + uiBaseColor.g * 0.587 + uiBaseColor.b * 0.114 > 0.58
    readonly property color uiPrimaryColor: uiIsLight ? "#241f18" : "#f4f1ff"
    readonly property color uiSecondaryColor: uiIsLight ? "#62594b" : "#a9a9bb"
    readonly property color uiPanelColor: Qt.rgba(uiBaseColor.r, uiBaseColor.g, uiBaseColor.b, 0.96)
    readonly property color uiBorderColor: Qt.rgba(uiAccentColor.r, uiAccentColor.g, uiAccentColor.b, 0.42)
    readonly property color uiToolbarColor: Qt.rgba(uiPrimaryColor.r, uiPrimaryColor.g, uiPrimaryColor.b, 0.10)
    readonly property color uiToolbarHoverColor: Qt.rgba(uiAccentColor.r, uiAccentColor.g, uiAccentColor.b, 0.20)

    function applySelected() {
        if (themes.length === 0)
            return

        const theme = themes[selectedIndex]
        Quickshell.execDetached(["/home/Ugzher/.local/bin/apply-theme", theme.key])
        Qt.quit()
    }

    function selectTheme(index) {
        if (themes.length === 0)
            return

        selectedIndex = Math.max(0, Math.min(index, themes.length - 1))
        currentPage = Math.floor(selectedIndex / pageSize)
    }

    function move(delta) {
        if (themes.length === 0)
            return

        selectTheme((selectedIndex + delta + themes.length) % themes.length)
    }

    function changePage(delta) {
        if (themes.length === 0)
            return

        const nextPage = (currentPage + delta + pageCount) % pageCount
        const positionOnPage = selectedIndex % pageSize
        selectTheme(Math.min(nextPage * pageSize + positionOnPage, themes.length - 1))
    }

    Component.onCompleted: {
        for (let index = 0; index < themes.length; index++) {
            if (themes[index].key === activeTheme) {
                selectTheme(index)
                break
            }
        }
    }

    component ToolbarButton: Rectangle {
        id: toolbarButton

        required property string label
        signal triggered()

        implicitWidth: toolbarLabel.implicitWidth + 16
        implicitHeight: 28
        radius: 14
        color: toolbarMouse.containsMouse ? root.uiToolbarHoverColor : "transparent"
        opacity: enabled ? 1 : 0.35

        Behavior on color { ColorAnimation { duration: 100 } }

        Text {
            id: toolbarLabel
            anchors.centerIn: parent
            text: toolbarButton.label
            color: root.uiPrimaryColor
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
        }

        MouseArea {
            id: toolbarMouse
            anchors.fill: parent
            enabled: toolbarButton.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: toolbarButton.triggered()
        }
    }

    PanelWindow {
        id: window
        screen: Quickshell.screens[0]
        visible: true
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "desktop-theme-picker"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Rectangle {
            anchors.fill: parent
            color: "#b0000000"

            MouseArea {
                anchors.fill: parent
                onClicked: Qt.quit()
            }
        }

        Item {
            id: keyboard
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: Qt.quit()
            Keys.onLeftPressed: root.move(-1)
            Keys.onRightPressed: root.move(1)
            Keys.onUpPressed: root.move(-3)
            Keys.onDownPressed: root.move(3)
            Keys.onTabPressed: root.move(1)
            Keys.onBacktabPressed: root.move(-1)
            Keys.onReturnPressed: root.applySelected()
            Keys.onEnterPressed: root.applySelected()
            Keys.onPressed: event => {
                if (event.key === Qt.Key_PageUp) {
                    root.changePage(-1)
                    event.accepted = true
                } else if (event.key === Qt.Key_PageDown) {
                    root.changePage(1)
                    event.accepted = true
                }
            }

            Rectangle {
                id: panel
                width: Math.min(parent.width - 80, 1180)
                height: Math.min(parent.height - 80, 720)
                anchors.centerIn: parent
                radius: 28
                color: root.uiPanelColor
                border.width: 1
                border.color: root.uiBorderColor

                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse => mouse.accepted = true
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 30
                    spacing: 22

                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            spacing: 4
                            Text {
                                text: "CHOISIR UNE AMBIANCE"
                                color: root.uiPrimaryColor
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 24
                                font.weight: Font.DemiBold
                                font.letterSpacing: 2
                            }
                            Text {
                                text: "Un preset de couleurs propre + son fond d’écran statique"
                                color: root.uiSecondaryColor
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            implicitWidth: toolbarRow.implicitWidth + 8
                            implicitHeight: 36
                            radius: 18
                            color: root.uiToolbarColor

                            Row {
                                id: toolbarRow
                                anchors.centerIn: parent
                                spacing: 2

                                ToolbarButton {
                                    label: "←"
                                    enabled: root.pageCount > 1
                                    onTriggered: root.changePage(-1)
                                }

                                ToolbarButton {
                                    label: "→"
                                    enabled: root.pageCount > 1
                                    onTriggered: root.changePage(1)
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: (root.currentPage + 1) + " / " + root.pageCount
                                    color: root.uiSecondaryColor
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    leftPadding: 5
                                    rightPadding: 5
                                }

                                ToolbarButton {
                                    label: "Appliquer"
                                    enabled: root.themes.length > 0
                                    onTriggered: root.applySelected()
                                }

                                ToolbarButton {
                                    label: "Fermer"
                                    onTriggered: Qt.quit()
                                }
                            }
                        }
                    }

                    Item {
                        id: themeGrid
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        readonly property real gap: 18
                        readonly property real cardWidth: (width - gap * 2) / 3
                        readonly property real cardHeight: (height - gap * 2) / 3

                        Repeater {
                            model: root.visibleThemes

                            Rectangle {
                                required property int index
                                required property var modelData
                                readonly property int themeIndex: root.pageStart + index

                                x: (index % 3) * (themeGrid.cardWidth + themeGrid.gap)
                                y: Math.floor(index / 3) * (themeGrid.cardHeight + themeGrid.gap)
                                width: themeGrid.cardWidth
                                height: themeGrid.cardHeight
                                radius: 18
                                clip: true
                                color: "#20212c"
                                border.width: root.selectedIndex === themeIndex ? 3 : 1
                                border.color: root.selectedIndex === themeIndex ? modelData.colors[1] : "#25ffffff"
                                scale: root.selectedIndex === themeIndex ? 1.025 : 1
                                Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                                Behavior on border.color { ColorAnimation { duration: 130 } }

                                Image {
                                    anchors.fill: parent
                                    source: "file://" + modelData.image
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        maskEnabled: true
                                        maskSource: imageMask
                                    }
                                }

                                Rectangle {
                                    id: imageMask
                                    anchors.fill: parent
                                    radius: parent.radius
                                    visible: false
                                    layer.enabled: true
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    gradient: Gradient {
                                        GradientStop { position: 0.20; color: "#08000000" }
                                        GradientStop { position: 0.62; color: "#78000000" }
                                        GradientStop { position: 1.00; color: "#ed090a10" }
                                    }
                                }

                                Rectangle {
                                    visible: root.activeTheme === modelData.key
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 12
                                    width: activeLabel.implicitWidth + 18
                                    height: 26
                                    radius: 13
                                    color: modelData.colors[1]
                                    Text {
                                        id: activeLabel
                                        anchors.centerIn: parent
                                        text: "ACTIF"
                                        color: modelData.colors[0]
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: "transparent"
                                    border.width: 3
                                    border.color: modelData.colors[1]
                                    antialiasing: true
                                    visible: root.selectedIndex === themeIndex
                                    z: 10
                                }

                                Column {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 16
                                    spacing: 7

                                    Text {
                                        text: modelData.name
                                        color: "#ffffff"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 16
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        text: modelData.subtitle
                                        color: "#c3c3cf"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                    }
                                    Row {
                                        spacing: 7
                                        Repeater {
                                            model: modelData.colors
                                            Rectangle {
                                                required property var modelData
                                                width: 22
                                                height: 8
                                                radius: 4
                                                color: modelData
                                                border.width: 1
                                                border.color: "#35ffffff"
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: root.selectTheme(themeIndex)
                                    onClicked: {
                                        root.selectTheme(themeIndex)
                                        root.applySelected()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
