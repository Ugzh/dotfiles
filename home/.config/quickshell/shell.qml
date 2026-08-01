//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Scope {
    id: root

    readonly property color bg: "#100814"
    readonly property color surface: "#1a0d20"
    readonly property color surfaceRaised: "#26122f"
    readonly property color fg: "#f8eaff"
    readonly property color accent: "#ff4fd8"
    readonly property color bright: "#b96cff"
    readonly property color border: "#4b245a"
    readonly property color muted: "#8f6498"
    readonly property color warning: "#ffd166"
    readonly property color critical: "#ff5c8a"
    readonly property string fontFamily: "GeistMono Nerd Font Mono"

    property var system: ({
        cpu: 0,
        memoryUsed: "0.0",
        memoryPercent: 0,
        batteryPresent: false,
        batteryCapacity: 0,
        batteryStatus: "",
        backlightPresent: false,
        backlightPercent: 0,
        vpnText: "",
        vpnClass: "inactive",
        vpnTooltip: "WireGuard désactivé",
        networkText: "󰤮",
        networkTooltip: "Réseau déconnecté"
    })
    property var workspaces: []
    property string updatesText: ""
    property var cavaLevels: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    readonly property var selectedPlayer: {
        let fallback = null;
        for (const player of Mpris.players.values) {
            const key = (player.desktopEntry + " " + player.identity).toLowerCase();
            if (key.includes("firefox") || key.includes("brave"))
                continue;
            if (player.isPlaying)
                return player;
            if (fallback === null && player.playbackState !== MprisPlaybackState.Stopped)
                fallback = player;
        }
        return fallback;
    }

    function workspacesFor(screenName) {
        const local = root.workspaces.filter(workspace => workspace.output === screenName);
        const chosen = local.length > 0 ? local : root.workspaces;
        return chosen.slice().sort((a, b) => a.idx - b.idx);
    }

    function run(command) {
        Quickshell.execDetached(command);
    }

    Process {
        id: systemProcess
        command: [Qt.resolvedUrl("scripts/status.sh").toString().replace("file://", "")]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.system = JSON.parse(text);
                } catch (error) {
                    console.warn("status.sh:", error);
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!systemProcess.running)
                systemProcess.running = true;
        }
    }

    Process {
        id: workspacesProcess
        command: ["niri", "msg", "-j", "workspaces"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.workspaces = JSON.parse(text);
                } catch (error) {
                    console.warn("niri workspaces:", error);
                }
            }
        }
    }

    Timer {
        interval: 800
        running: true
        repeat: true
        onTriggered: {
            if (!workspacesProcess.running)
                workspacesProcess.running = true;
        }
    }

    Process {
        id: updatesProcess
        command: [Qt.resolvedUrl("scripts/updates.sh").toString().replace("file://", "")]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.updatesText = text.trim()
        }
    }

    Timer {
        interval: 21600000
        running: true
        repeat: true
        onTriggered: {
            if (!updatesProcess.running)
                updatesProcess.running = true;
        }
    }

    Process {
        command: [Qt.resolvedUrl("scripts/cava.sh").toString().replace("file://", "")]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const values = data.trim().split(",").map(value => Number(value));
                if (values.length === 10 && values.every(value => !isNaN(value)))
                    root.cavaLevels = values;
            }
        }
        onExited: root.cavaLevels = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: bar
                required property var modelData
                property bool mediaPopupOpen: false
                screen: modelData

                anchors {
                    top: true
                    left: true
                    right: true
                }
                margins {
                    top: 6
                    left: 18
                    right: 18
                }

                implicitHeight: 40
                exclusiveZone: 48
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    color: root.bg
                    radius: 13
                    border.width: 1
                    border.color: root.border

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 8
                            rightMargin: 8
                            topMargin: 5
                            bottomMargin: 5
                        }
                        spacing: 7

                        Rectangle {
                            id: launcher
                            Layout.preferredWidth: 30
                            Layout.fillHeight: true
                            radius: 9
                            color: launcherMouse.containsMouse ? root.accent : root.surfaceRaised

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: launcherMouse.containsMouse ? root.bg : root.accent
                                font.family: root.fontFamily
                                font.pixelSize: 15
                                font.bold: true
                            }

                            MouseArea {
                                id: launcherMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton)
                                        root.run(["kitty"]);
                                    else
                                        root.run(["fuzzel"]);
                                }
                            }
                        }

                        Rectangle {
                            id: mediaPill
                            visible: root.selectedPlayer !== null
                            Layout.preferredWidth: visible ? 300 : 0
                            Layout.fillHeight: true
                            radius: 9
                            color: root.accent
                            clip: true

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: bar.mediaPopupOpen = !bar.mediaPopupOpen
                            }

                            RowLayout {
                                id: mediaRow
                                anchors {
                                    fill: parent
                                    leftMargin: 8
                                    rightMargin: 8
                                }
                                spacing: 6

                                Text {
                                    text: root.selectedPlayer && root.selectedPlayer.canGoPrevious ? "󰒮" : ""
                                    visible: text !== ""
                                    color: root.bg
                                    font.family: root.fontFamily
                                    font.pixelSize: 13
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: if (root.selectedPlayer) root.selectedPlayer.previous()
                                    }
                                }

                                Text {
                                    text: root.selectedPlayer && root.selectedPlayer.isPlaying ? "󰏤" : "󰐊"
                                    color: root.bg
                                    font.family: root.fontFamily
                                    font.pixelSize: 14
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: if (root.selectedPlayer && root.selectedPlayer.canTogglePlaying)
                                            root.selectedPlayer.togglePlaying()
                                    }
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: -2

                                    Text {
                                        width: parent.width
                                        text: root.selectedPlayer
                                            ? (root.selectedPlayer.trackTitle || root.selectedPlayer.identity)
                                            : ""
                                        color: root.bg
                                        font.family: root.fontFamily
                                        font.pixelSize: 10
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        text: root.selectedPlayer
                                            ? (root.selectedPlayer.trackArtist || root.selectedPlayer.trackAlbum || "Lecteur multimédia")
                                            : ""
                                        color: Qt.rgba(0.06, 0.03, 0.08, 0.68)
                                        font.family: root.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                }

                                Text {
                                    text: root.selectedPlayer && root.selectedPlayer.canGoNext ? "󰒭" : ""
                                    visible: text !== ""
                                    color: root.bg
                                    font.family: root.fontFamily
                                    font.pixelSize: 13
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: if (root.selectedPlayer) root.selectedPlayer.next()
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: visualizerPill
                            visible: root.selectedPlayer !== null
                            Layout.preferredWidth: visible ? 92 : 0
                            Layout.fillHeight: true
                            radius: 9
                            color: root.surfaceRaised
                            border.width: 1
                            border.color: Qt.rgba(1, 0.31, 0.85, 0.30)

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: bar.mediaPopupOpen = !bar.mediaPopupOpen
                            }

                            Row {
                                anchors.centerIn: parent
                                height: 20
                                spacing: 3

                                Repeater {
                                    model: root.cavaLevels

                                    Item {
                                        required property real modelData
                                        width: 5
                                        height: 20

                                        Rectangle {
                                            anchors {
                                                bottom: parent.bottom
                                                horizontalCenter: parent.horizontalCenter
                                            }
                                            width: 4
                                            height: Math.max(3, (modelData / 7) * parent.height)
                                            radius: 2
                                            color: modelData >= 6 ? root.fg
                                                : modelData >= 3 ? root.accent
                                                : root.bright

                                            Behavior on height {
                                                NumberAnimation {
                                                    duration: 65
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                            Behavior on color {
                                                ColorAnimation { duration: 80 }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.preferredWidth: workspaceRow.implicitWidth + 10
                            Layout.fillHeight: true
                            radius: 9
                            color: root.surface
                            border.width: 1
                            border.color: Qt.rgba(0.73, 0.42, 1, 0.26)

                            Row {
                                id: workspaceRow
                                anchors.centerIn: parent
                                spacing: 3

                                Repeater {
                                    model: root.workspacesFor(bar.modelData.name)

                                    Rectangle {
                                        required property var modelData
                                        width: modelData.is_focused ? 34 : 25
                                        height: 24
                                        radius: 7
                                        color: modelData.is_focused ? root.accent
                                            : workspaceMouse.containsMouse ? root.surfaceRaised
                                            : "transparent"

                                        Behavior on width {
                                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                        }
                                        Behavior on color {
                                            ColorAnimation { duration: 120 }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.name || (modelData.idx >= 10 ? "9+" : modelData.idx)
                                            color: modelData.is_focused ? root.bg
                                                : modelData.active_window_id === null ? Qt.rgba(0.97, 0.92, 1, 0.30)
                                                : root.fg
                                            font.family: root.fontFamily
                                            font.pixelSize: 11
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: workspaceMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: root.run(["niri", "msg", "action", "focus-workspace", String(modelData.idx)])
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            id: vpnPill
                            Layout.preferredWidth: vpnText.implicitWidth + 16
                            Layout.fillHeight: true
                            radius: 9
                            color: vpnMouse.containsMouse ? root.surfaceRaised : root.surface

                            Text {
                                id: vpnText
                                anchors.centerIn: parent
                                text: root.system.vpnText
                                color: root.system.vpnClass === "inactive" ? root.muted : root.accent
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                id: vpnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton)
                                        root.run(["nm-connection-editor"]);
                                    else
                                        root.run([Qt.resolvedUrl("scripts/wireguard.sh").toString().replace("file://", ""), "menu"]);
                                }
                            }
                        }

                        Rectangle {
                            visible: root.system.backlightPresent
                            Layout.preferredWidth: visible ? backlightText.implicitWidth + 16 : 0
                            Layout.fillHeight: true
                            radius: 9
                            color: backlightMouse.containsMouse ? root.surfaceRaised : root.surface

                            Text {
                                id: backlightText
                                anchors.centerIn: parent
                                text: "  " + root.system.backlightPercent + "%"
                                color: root.fg
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                id: backlightMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onWheel: wheel => {
                                    root.run(["brightnessctl", "set", wheel.angleDelta.y > 0 ? "+5%" : "5%-"]);
                                    systemProcess.running = true;
                                }
                            }
                        }

                        Rectangle {
                            id: batteryPill
                            visible: root.system.batteryPresent
                            Layout.preferredWidth: visible ? batteryText.implicitWidth + 16 : 0
                            Layout.fillHeight: true
                            radius: 9
                            color: root.surface

                            Text {
                                id: batteryText
                                anchors.centerIn: parent
                                readonly property int level: root.system.batteryCapacity
                                text: {
                                    const charging = root.system.batteryStatus === "Charging";
                                    const icon = charging ? "󰂄"
                                        : level > 80 ? ""
                                        : level > 60 ? ""
                                        : level > 40 ? ""
                                        : level > 20 ? "" : "";
                                    return icon + " " + level + "%";
                                }
                                color: level <= 15 ? root.critical : level <= 30 ? root.warning : root.fg
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.RightButton
                                onClicked: root.run(["sh", "-c", "upower -i \"$(upower -e | grep BAT | head -n1)\" | notify-send -u low \"Batterie\" -"])
                            }
                        }

                        Rectangle {
                            id: volumePill
                            Layout.preferredWidth: volumeText.implicitWidth + 16
                            Layout.fillHeight: true
                            radius: 9
                            color: volumeMouse.containsMouse ? root.surfaceRaised : root.surface

                            Text {
                                id: volumeText
                                anchors.centerIn: parent
                                readonly property var audio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
                                readonly property int volume: audio ? Math.round(audio.volume * 100) : 0
                                text: !audio || audio.muted ? "" : (volume < 35 ? " " : volume < 70 ? " " : " ") + volume + "%"
                                color: audio && audio.muted ? root.muted : root.fg
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                id: volumeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: mouse => {
                                    const audio = Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null;
                                    if (mouse.button === Qt.RightButton) {
                                        if (audio) audio.muted = !audio.muted;
                                    } else {
                                        root.run(["pavucontrol"]);
                                    }
                                }
                                onWheel: wheel => {
                                    const audio = Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null;
                                    if (audio)
                                        audio.volume = Math.max(0, Math.min(1.5, audio.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05)));
                                }
                            }
                        }

                        Rectangle {
                            id: statsPill
                            Layout.preferredWidth: statsRow.implicitWidth + 18
                            Layout.fillHeight: true
                            radius: 9
                            color: statsMouse.containsMouse ? root.surfaceRaised : root.surface

                            Row {
                                id: statsRow
                                anchors.centerIn: parent
                                spacing: 9

                                Text {
                                    text: " " + root.system.memoryUsed + "G"
                                    color: root.system.memoryPercent >= 80 ? root.critical
                                        : root.system.memoryPercent >= 50 ? root.warning : root.fg
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                Text {
                                    text: " " + root.system.cpu + "%"
                                    color: root.system.cpu >= 80 ? root.critical
                                        : root.system.cpu >= 50 ? root.warning : root.fg
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                id: statsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.run(["kitty", "top"])
                            }
                        }

                        Rectangle {
                            visible: root.updatesText !== ""
                            Layout.preferredWidth: visible ? updatesLabel.implicitWidth + 16 : 0
                            Layout.fillHeight: true
                            radius: 9
                            color: updatesMouse.containsMouse ? root.surfaceRaised : root.surface

                            Text {
                                id: updatesLabel
                                anchors.centerIn: parent
                                text: root.updatesText
                                color: root.bright
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                id: updatesMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.run(["kitty", "sudo", "dnf", "upgrade", "--refresh"])
                            }
                        }

                        Rectangle {
                            id: clockPill
                            Layout.preferredWidth: clockColumn.implicitWidth + 18
                            Layout.fillHeight: true
                            radius: 9
                            color: clockMouse.containsMouse ? root.surfaceRaised : root.surface

                            SystemClock {
                                id: clock
                                precision: SystemClock.Seconds
                            }

                            Column {
                                id: clockColumn
                                anchors.centerIn: parent
                                spacing: -2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Qt.formatDateTime(clock.date, "HH:mm")
                                    color: root.accent
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Qt.formatDateTime(clock.date, "ddd dd")
                                    color: root.muted
                                    font.family: root.fontFamily
                                    font.pixelSize: 8
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                id: clockMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton)
                                        root.run(["kitty", "timedatectl"]);
                                    else
                                        root.run(["/home/Ugzher/.local/bin/waybar-calendar"]);
                                }
                            }
                        }

                        Row {
                            visible: SystemTray.items.values.length > 0
                            spacing: 5

                            Repeater {
                                model: SystemTray.items

                                Item {
                                    required property var modelData
                                    id: trayItem
                                    width: 20
                                    height: 30

                                    IconImage {
                                        anchors.centerIn: parent
                                        width: 16
                                        height: 16
                                        source: modelData.icon
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                                        onClicked: mouse => {
                                            // Several StatusNotifier apps (including
                                            // NetworkManager and Codex) expose their usable
                                            // actions through a DBus menu. Display it when it
                                            // is available; otherwise preserve their native
                                            // left/right-click activation.
                                            if (modelData.hasMenu) {
                                                const rect = bar.itemRect(trayItem);
                                                modelData.display(bar, rect.x + mouse.x, rect.y + mouse.y);
                                            } else if (mouse.button === Qt.RightButton) {
                                                modelData.secondaryActivate();
                                            } else {
                                                modelData.activate();
                                            }
                                        }
                                        onWheel: wheel => modelData.scroll(wheel.angleDelta.y, false)
                                    }
                                }
                            }
                        }
                    }
                }

                PopupWindow {
                    id: mediaPopup
                    visible: bar.mediaPopupOpen && root.selectedPlayer !== null
                    color: "transparent"
                    implicitWidth: 440
                    implicitHeight: 250

                    anchor.window: bar
                    anchor.rect.x: bar.itemRect(mediaPill).x
                    anchor.rect.y: bar.height + 10

                    Rectangle {
                        anchors.fill: parent
                        radius: 18
                        color: root.bg
                        border.width: 1
                        border.color: root.border

                        Rectangle {
                            anchors {
                                fill: parent
                                margins: 7
                            }
                            radius: 13
                            color: root.surface
                            border.width: 1
                            border.color: Qt.rgba(1, 0.31, 0.85, 0.16)

                            RowLayout {
                                anchors {
                                    fill: parent
                                    margins: 14
                                }
                                spacing: 16

                                Rectangle {
                                    Layout.preferredWidth: 170
                                    Layout.fillHeight: true
                                    radius: 12
                                    color: root.surfaceRaised
                                    clip: true

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰎆"
                                        color: root.muted
                                        font.family: root.fontFamily
                                        font.pixelSize: 42
                                    }

                                    Image {
                                        anchors.fill: parent
                                        source: root.selectedPlayer ? root.selectedPlayer.trackArtUrl : ""
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 5

                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            Layout.fillWidth: true
                                            text: root.selectedPlayer
                                                ? (root.selectedPlayer.trackTitle || root.selectedPlayer.identity)
                                                : ""
                                            color: root.fg
                                            font.family: root.fontFamily
                                            font.pixelSize: 15
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 24
                                            Layout.preferredHeight: 24
                                            radius: 8
                                            color: closePopupMouse.containsMouse ? root.accent : root.surfaceRaised

                                            Text {
                                                anchors.centerIn: parent
                                                text: "󰅖"
                                                color: closePopupMouse.containsMouse ? root.bg : root.muted
                                                font.family: root.fontFamily
                                                font.pixelSize: 12
                                            }

                                            MouseArea {
                                                id: closePopupMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: bar.mediaPopupOpen = false
                                            }
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: root.selectedPlayer
                                            ? (root.selectedPlayer.trackArtist || "Artiste inconnu")
                                            : ""
                                        color: root.accent
                                        font.family: root.fontFamily
                                        font.pixelSize: 11
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: root.selectedPlayer ? root.selectedPlayer.trackAlbum : ""
                                        visible: text !== ""
                                        color: root.muted
                                        font.family: root.fontFamily
                                        font.pixelSize: 9
                                        elide: Text.ElideRight
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 64

                                        Row {
                                            anchors {
                                                centerIn: parent
                                                bottom: parent.bottom
                                            }
                                            height: 58
                                            spacing: 8

                                            Repeater {
                                                model: root.cavaLevels

                                                Item {
                                                    required property real modelData
                                                    width: 12
                                                    height: 58

                                                    Rectangle {
                                                        anchors {
                                                            bottom: parent.bottom
                                                            horizontalCenter: parent.horizontalCenter
                                                        }
                                                        width: 9
                                                        height: Math.max(5, (modelData / 7) * parent.height)
                                                        radius: 5
                                                        color: modelData >= 6 ? root.fg
                                                            : modelData >= 3 ? root.accent
                                                            : root.bright

                                                        Behavior on height {
                                                            NumberAnimation {
                                                                duration: 65
                                                                easing.type: Easing.OutCubic
                                                            }
                                                        }
                                                        Behavior on color {
                                                            ColorAnimation { duration: 80 }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 4
                                        radius: 2
                                        color: root.surfaceRaised

                                        Rectangle {
                                            width: {
                                                if (!root.selectedPlayer || !root.selectedPlayer.lengthSupported
                                                        || root.selectedPlayer.length <= 0)
                                                    return 0;
                                                return parent.width * Math.min(1,
                                                    root.selectedPlayer.position / root.selectedPlayer.length);
                                            }
                                            height: parent.height
                                            radius: 2
                                            color: root.accent
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true

                                        Item { Layout.fillWidth: true }

                                        Text {
                                            text: "󰒮"
                                            visible: root.selectedPlayer && root.selectedPlayer.canGoPrevious
                                            color: root.fg
                                            font.family: root.fontFamily
                                            font.pixelSize: 18
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: if (root.selectedPlayer) root.selectedPlayer.previous()
                                            }
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 38
                                            Layout.preferredHeight: 30
                                            radius: 10
                                            color: root.accent

                                            Text {
                                                anchors.centerIn: parent
                                                text: root.selectedPlayer && root.selectedPlayer.isPlaying ? "󰏤" : "󰐊"
                                                color: root.bg
                                                font.family: root.fontFamily
                                                font.pixelSize: 17
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: if (root.selectedPlayer && root.selectedPlayer.canTogglePlaying)
                                                    root.selectedPlayer.togglePlaying()
                                            }
                                        }

                                        Text {
                                            text: "󰒭"
                                            visible: root.selectedPlayer && root.selectedPlayer.canGoNext
                                            color: root.fg
                                            font.family: root.fontFamily
                                            font.pixelSize: 18
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: if (root.selectedPlayer) root.selectedPlayer.next()
                                            }
                                        }

                                        Item { Layout.fillWidth: true }
                                    }
                                }
                            }
                        }
                    }

                    Timer {
                        interval: 1000
                        running: mediaPopup.visible && root.selectedPlayer !== null
                            && root.selectedPlayer.isPlaying
                        repeat: true
                        onTriggered: if (root.selectedPlayer) root.selectedPlayer.positionChanged()
                    }
                }
            }
        }
    }
}
