//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets
import "theme.js" as Theme

Scope {
    id: root

    readonly property color bg: Theme.bg
    readonly property color surface: Theme.surface
    readonly property color surfaceRaised: Theme.surfaceRaised
    readonly property color fg: Theme.fg
    readonly property color accent: Theme.accent
    readonly property color bright: Theme.bright
    readonly property color border: Theme.border
    readonly property color muted: Theme.fgDim
    readonly property color warning: Theme.warning
    readonly property color critical: Theme.critical
    readonly property string fontFamily: Theme.fontFamily
    readonly property real fontScale: 1.25

    function fontSize(pixelSize) {
        return Math.round(pixelSize * fontScale);
    }

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
    property var niriWindows: []
    property var bluetooth: ({ powered: false, discovering: false, devices: [] })
    property string updatesText: ""
    property var cavaLevels: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    property bool batteryAlert15Sent: false
    property bool batteryAlert10Sent: false
    property bool batteryAlert5Sent: false
    readonly property var defaultAudio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    readonly property int audioVolume: defaultAudio ? Math.round(defaultAudio.volume * 100) : 0
    readonly property bool audioMuted: defaultAudio ? defaultAudio.muted : false

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

    function run(command) {
        Quickshell.execDetached(command);
    }

    function checkBatteryAlert() {
        if (!root.system.batteryPresent)
            return;

        const level = root.system.batteryCapacity;
        const status = root.system.batteryStatus;
        if (status === "Charging" || status === "Full") {
            root.batteryAlert15Sent = false;
            root.batteryAlert10Sent = false;
            root.batteryAlert5Sent = false;
            return;
        }

        let threshold = 0;
        let urgency = "normal";
        if (level <= 5 && !root.batteryAlert5Sent) {
            threshold = 5;
            urgency = "critical";
            root.batteryAlert15Sent = true;
            root.batteryAlert10Sent = true;
            root.batteryAlert5Sent = true;
        } else if (level <= 10 && !root.batteryAlert10Sent) {
            threshold = 10;
            urgency = "critical";
            root.batteryAlert15Sent = true;
            root.batteryAlert10Sent = true;
        } else if (level <= 15 && !root.batteryAlert15Sent) {
            threshold = 15;
            root.batteryAlert15Sent = true;
        }

        if (threshold > 0) {
            root.run([
                "notify-send", "-a", "Batterie", "-u", urgency,
                "-i", "battery-caution", "Batterie faible — " + threshold + "%",
                "Il reste " + level + "% de batterie. Branche le chargeur."
            ]);
        }
    }

    function audioIcon() {
        if (!root.defaultAudio || root.audioMuted)
            return "";
        if (root.audioVolume < 35)
            return "";
        if (root.audioVolume < 70)
            return "";
        return "";
    }

    function setAudioVolume(volume) {
        if (!root.defaultAudio)
            return;
        root.defaultAudio.volume = Math.max(0, Math.min(1.5, volume));
        if (root.defaultAudio.volume > 0 && root.defaultAudio.muted)
            root.defaultAudio.muted = false;
    }

    function changeAudioVolume(delta) {
        if (root.defaultAudio)
            root.setAudioVolume(root.defaultAudio.volume + delta);
    }

    function toggleAudioMute() {
        if (root.defaultAudio)
            root.defaultAudio.muted = !root.defaultAudio.muted;
    }

    function vpnAction(action) {
        root.run([Qt.resolvedUrl("scripts/wireguard.sh").toString().replace("file://", ""), action]);
        vpnRefresh.restart();
    }

    function bluetoothAction(action, address) {
        const command = [Qt.resolvedUrl("scripts/bluetooth.sh").toString().replace("file://", ""), action];
        if (address)
            command.push(address);
        root.run(command);
        bluetoothRefresh.restart();
    }

    function networkTrayItem() {
        for (const item of SystemTray.items.values) {
            const key = ((item.id || "") + " " + (item.title || "") + " "
                + (item.tooltipTitle || "") + " " + (item.tooltipDescription || "")).toLowerCase();
            if (key.includes("networkmanager") || key.includes("network-manager") || key.includes("nm-applet")
                    || key.includes("network manager") || key.includes("wi-fi") || key.includes("wifi"))
                return item;
        }
        return null;
    }

    function showNetworkMenu(parentWindow, anchorItem) {
        const item = networkTrayItem();
        if (item !== null) {
            if (item.hasMenu) {
                const rect = parentWindow.itemRect(anchorItem);
                item.display(parentWindow, Math.round(rect.x + rect.width / 2), Math.round(rect.y + rect.height));
            } else {
                item.activate();
            }
            return;
        }
        root.run(["nm-connection-editor"]);
    }

    function workspacesFor(screenName) {
        const local = root.workspaces.filter(workspace => workspace.output === screenName);
        const chosen = local.length > 0 ? local : root.workspaces;
        return chosen.slice().sort((a, b) => a.idx - b.idx);
    }

    function windowsForWorkspace(workspaceId) {
        return root.niriWindows
            .filter(window => window.workspace_id === workspaceId)
            .slice()
            .sort((a, b) => {
                const aPosition = a.layout && a.layout.pos_in_scrolling_layout
                    ? a.layout.pos_in_scrolling_layout : [999, 999];
                const bPosition = b.layout && b.layout.pos_in_scrolling_layout
                    ? b.layout.pos_in_scrolling_layout : [999, 999];
                return aPosition[0] === bPosition[0]
                    ? aPosition[1] - bPosition[1]
                    : aPosition[0] - bPosition[0];
            })
            .slice(0, 5);
    }

    Process {
        id: systemProcess
        command: [Qt.resolvedUrl("scripts/status.sh").toString().replace("file://", "")]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.system = JSON.parse(text);
                    root.checkBatteryAlert();
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
        onTriggered: if (!systemProcess.running) systemProcess.running = true
    }

    Timer {
        id: vpnRefresh
        interval: 1600
        repeat: false
        onTriggered: if (!systemProcess.running) systemProcess.running = true
    }

    Process {
        id: bluetoothStatusProcess
        command: [Qt.resolvedUrl("scripts/bluetooth.sh").toString().replace("file://", ""), "status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.bluetooth = JSON.parse(text);
                } catch (error) {
                    console.warn("bluetooth.sh:", error);
                }
            }
        }
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: if (!bluetoothStatusProcess.running) bluetoothStatusProcess.running = true
    }

    Timer {
        id: bluetoothRefresh
        interval: 1400
        repeat: false
        onTriggered: if (!bluetoothStatusProcess.running) bluetoothStatusProcess.running = true
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
        onTriggered: if (!workspacesProcess.running) workspacesProcess.running = true
    }

    Process {
        id: windowsProcess
        command: ["niri", "msg", "-j", "windows"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.niriWindows = JSON.parse(text) || [];
                } catch (error) {
                    console.warn("niri windows:", error);
                }
            }
        }
    }

    Timer {
        interval: 650
        running: true
        repeat: true
        onTriggered: if (!windowsProcess.running) windowsProcess.running = true
    }

    Process {
        id: updatesProcess
        command: [Qt.resolvedUrl("scripts/updates.sh").toString().replace("file://", "")]
        running: true
        stdout: StdioCollector { onStreamFinished: root.updatesText = text.trim() }
    }

    Timer {
        interval: 21600000
        running: true
        repeat: true
        onTriggered: if (!updatesProcess.running) updatesProcess.running = true
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

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: bar
                required property var modelData
                property bool controlCenterOpen: false
                property bool controlCenterHoverOpened: false
                property int controlCenterTab: 0
                property real tabSwipeAccumulator: 0
                property bool tabSwipeLocked: false
                screen: modelData

                Timer {
                    id: tabSwipeUnlock
                    interval: 360
                    repeat: false
                    onTriggered: {
                        bar.tabSwipeLocked = false;
                        bar.tabSwipeAccumulator = 0;
                    }
                }

                Timer {
                    id: controlCenterHoverClose
                    interval: 220
                    repeat: false
                    onTriggered: {
                        if (bar.controlCenterHoverOpened
                                && !centerMouse.containsMouse
                                && !controlCardHover.containsMouse) {
                            bar.controlCenterOpen = false;
                            bar.controlCenterHoverOpened = false;
                        }
                    }
                }

                function showControlCenter(tabIndex) {
                    controlCenterHoverClose.stop();
                    controlCenterHoverOpened = false;
                    controlCenterTab = tabIndex;
                    controlCenterOpen = true;
                }

                function showControlCenterOnHover() {
                    controlCenterHoverClose.stop();
                    controlCenterTab = 0;
                    controlCenterHoverOpened = true;
                    controlCenterOpen = true;
                }

                function scheduleControlCenterHoverClose() {
                    if (controlCenterHoverOpened)
                        controlCenterHoverClose.restart();
                }

                function closeControlCenter() {
                    controlCenterHoverClose.stop();
                    controlCenterOpen = false;
                    controlCenterHoverOpened = false;
                }

                function launchFromControlCenter(command) {
                    closeControlCenter();
                    root.run(command);
                }

                function handleTabSwipe(wheel) {
                    const pixelX = wheel.pixelDelta ? wheel.pixelDelta.x : 0;
                    const pixelY = wheel.pixelDelta ? wheel.pixelDelta.y : 0;
                    const angleX = wheel.angleDelta ? wheel.angleDelta.x : 0;
                    const angleY = wheel.angleDelta ? wheel.angleDelta.y : 0;
                    const dx = pixelX !== 0 ? pixelX : angleX;
                    const dy = pixelY !== 0 ? pixelY : angleY;

                    if (Math.abs(dx) < 2 || Math.abs(dx) < Math.abs(dy) * 0.65)
                        return;

                    wheel.accepted = true;
                    if (tabSwipeLocked)
                        return;

                    tabSwipeAccumulator += dx;
                    if (Math.abs(tabSwipeAccumulator) < 28)
                        return;

                    controlCenterTab = tabSwipeAccumulator < 0
                        ? Math.min(4, controlCenterTab + 1)
                        : Math.max(0, controlCenterTab - 1);
                    tabSwipeAccumulator = 0;
                    tabSwipeLocked = true;
                    tabSwipeUnlock.restart();
                }

                anchors { top: true; left: true; right: true }
                margins { top: 0; left: 5; right: 5 }
                implicitHeight: 36
                exclusiveZone: 36
                color: "transparent"

                Item {
                    anchors.fill: parent

                    Shape {
                        id: leftIsland
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                        width: leftCluster.implicitWidth + 20
                        height: 36
                        antialiasing: true

                        ShapePath {
                            strokeWidth: 1
                            strokeColor: Qt.rgba(root.border.r, root.border.g, root.border.b, 0.68)
                            fillColor: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.96)
                            startX: 0
                            startY: 0
                            PathLine { x: leftIsland.width; y: 0 }
                            PathLine { x: leftIsland.width - 6; y: leftIsland.height - 12 }
                            PathQuad { x: leftIsland.width - 19; y: leftIsland.height; controlX: leftIsland.width - 9; controlY: leftIsland.height }
                            PathLine { x: 19; y: leftIsland.height }
                            PathQuad { x: 6; y: leftIsland.height - 12; controlX: 9; controlY: leftIsland.height }
                            PathLine { x: 0; y: 0 }
                        }
                    }

                    Shape {
                        id: rightIsland
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        width: rightCluster.implicitWidth + 20
                        height: 36
                        antialiasing: true

                        ShapePath {
                            strokeWidth: 1
                            strokeColor: Qt.rgba(root.border.r, root.border.g, root.border.b, 0.68)
                            fillColor: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.96)
                            startX: 0
                            startY: 0
                            PathLine { x: rightIsland.width; y: 0 }
                            PathLine { x: rightIsland.width - 6; y: rightIsland.height - 12 }
                            PathQuad { x: rightIsland.width - 19; y: rightIsland.height; controlX: rightIsland.width - 9; controlY: rightIsland.height }
                            PathLine { x: 19; y: rightIsland.height }
                            PathQuad { x: 6; y: rightIsland.height - 12; controlX: 9; controlY: rightIsland.height }
                            PathLine { x: 0; y: 0 }
                        }
                    }

                    Row {
                        id: leftCluster
                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                        height: 30
                        spacing: 5

                        Rectangle {
                            width: workspaceRow.implicitWidth + 10
                            height: 30
                            radius: 11
                            color: "transparent"

                            Row {
                                id: workspaceRow
                                anchors.centerIn: parent
                                spacing: 3

                                Repeater {
                                    model: root.workspacesFor(bar.modelData.name)

                                    Rectangle {
                                        id: workspaceDelegate
                                        required property var modelData
                                        required property int index
                                        readonly property bool iconAfter: index >= Math.floor(root.workspacesFor(bar.modelData.name).length / 2)
                                        readonly property var workspaceWindows: root.windowsForWorkspace(modelData.id)
                                        readonly property int activeWindowIndex: {
                                            const found = workspaceWindows.findIndex(window => window.id === modelData.active_window_id);
                                            return found >= 0 ? found : (workspaceWindows.length > 0 ? 0 : -1);
                                        }
                                        readonly property var windowsBefore: activeWindowIndex > 0 ? workspaceWindows.slice(0, activeWindowIndex) : []
                                        readonly property var activeWorkspaceWindow: activeWindowIndex >= 0 ? workspaceWindows[activeWindowIndex] : null
                                        readonly property var windowsAfter: activeWindowIndex >= 0 ? workspaceWindows.slice(activeWindowIndex + 1) : []
                                        width: workspaceWindows.length > 0 ? workspaceContent.implicitWidth + 12 : (modelData.is_focused ? 28 : 20)
                                        height: 20
                                        radius: 8
                                        color: modelData.is_focused && workspaceWindows.length === 0
                                            ? root.accent
                                            : workspaceMouse.containsMouse ? root.surfaceRaised : "transparent"

                                        Row {
                                            id: workspaceContent
                                            anchors.centerIn: parent
                                            spacing: workspaceWindows.length > 0 ? 4 : 0

                                            Repeater {
                                                model: windowsBefore

                                                Item {
                                                    required property var modelData
                                                    readonly property var entry: DesktopEntries.heuristicLookup(modelData.app_id || "")
                                                    width: 20
                                                    height: 20
                                                    IconImage { anchors.centerIn: parent; width: 14; height: 14; visible: entry !== null; source: entry ? Quickshell.iconPath(entry.icon) : "" }
                                                    Text { anchors.centerIn: parent; visible: entry === null; text: "•"; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(9) }
                                                }
                                            }

                                            Item {
                                                visible: activeWorkspaceWindow !== null && !iconAfter
                                                readonly property var entry: activeWorkspaceWindow
                                                    ? DesktopEntries.heuristicLookup(activeWorkspaceWindow.app_id || "") : null
                                                width: 20
                                                height: 20
                                                Rectangle { anchors.fill: parent; radius: 7; color: modelData.is_focused ? root.accent : "transparent" }
                                                IconImage { anchors.fill: parent; anchors.margins: 3; visible: parent.entry !== null; source: parent.entry ? Quickshell.iconPath(parent.entry.icon) : "" }
                                                Text { anchors.centerIn: parent; visible: parent.entry === null; text: "󰍹"; color: modelData.is_focused ? root.bg : root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(11) }
                                            }

                                            Item {
                                                width: 20
                                                height: 20

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.name || modelData.idx
                                                    color: modelData.is_focused && workspaceWindows.length === 0
                                                        ? root.bg
                                                        : modelData.is_focused ? root.accent : root.muted
                                                    font.family: root.fontFamily
                                                    font.pixelSize: root.fontSize(9)
                                                    font.bold: true
                                                }
                                            }

                                            Item {
                                                visible: activeWorkspaceWindow !== null && iconAfter
                                                readonly property var entry: activeWorkspaceWindow
                                                    ? DesktopEntries.heuristicLookup(activeWorkspaceWindow.app_id || "") : null
                                                width: 20
                                                height: 20
                                                Rectangle { anchors.fill: parent; radius: 7; color: modelData.is_focused ? root.accent : "transparent" }
                                                IconImage { anchors.fill: parent; anchors.margins: 3; visible: parent.entry !== null; source: parent.entry ? Quickshell.iconPath(parent.entry.icon) : "" }
                                                Text { anchors.centerIn: parent; visible: parent.entry === null; text: "󰍹"; color: modelData.is_focused ? root.bg : root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(11) }
                                            }

                                            Repeater {
                                                model: windowsAfter

                                                Item {
                                                    required property var modelData
                                                    readonly property var entry: DesktopEntries.heuristicLookup(modelData.app_id || "")
                                                    width: 20
                                                    height: 20
                                                    IconImage { anchors.centerIn: parent; width: 14; height: 14; visible: entry !== null; source: entry ? Quickshell.iconPath(entry.icon) : "" }
                                                    Text { anchors.centerIn: parent; visible: entry === null; text: "•"; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(9) }
                                                }
                                            }
                                        }

                                        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

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
                    }

                    Item {
                        id: centerPill
                        anchors.centerIn: parent
                        width: root.selectedPlayer ? 345 : centerContent.implicitWidth + 28
                        height: 36
                        clip: true

                        Shape {
                            id: centerIsland
                            anchors.fill: parent
                            antialiasing: true

                            ShapePath {
                                strokeWidth: 1
                                strokeColor: bar.controlCenterOpen ? root.accent : Qt.rgba(root.border.r, root.border.g, root.border.b, 0.68)
                                fillColor: centerMouse.containsMouse || bar.controlCenterOpen
                                    ? root.surfaceRaised
                                    : Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.96)
                                startX: 0
                                startY: 0
                                PathLine { x: centerIsland.width; y: 0 }
                                PathLine { x: centerIsland.width - 6; y: centerIsland.height - 12 }
                                PathQuad { x: centerIsland.width - 19; y: centerIsland.height; controlX: centerIsland.width - 9; controlY: centerIsland.height }
                                PathLine { x: 19; y: centerIsland.height }
                                PathQuad { x: 6; y: centerIsland.height - 12; controlX: 9; controlY: centerIsland.height }
                                PathLine { x: 0; y: 0 }
                            }
                        }

                        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                        RowLayout {
                            id: centerContent
                            anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                            spacing: root.selectedPlayer !== null ? 7 : 12

                            Text {
                                visible: root.selectedPlayer !== null
                                text: root.selectedPlayer && root.selectedPlayer.isPlaying ? "󰏤" : "󰐊"
                                color: root.accent
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize(12)
                            }

                            Text {
                                visible: root.selectedPlayer !== null
                                Layout.fillWidth: true
                                text: root.selectedPlayer ? (root.selectedPlayer.trackTitle || root.selectedPlayer.identity) : ""
                                color: root.fg
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize(10)
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                visible: root.selectedPlayer !== null
                                width: 1
                                height: 14
                                color: root.border
                            }

                            SystemClock { id: clock; precision: SystemClock.Seconds }

                            Text {
                                text: Qt.formatDateTime(clock.date, "HH:mm")
                                color: root.accent
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize(10)
                                font.bold: true
                            }

                            Text {
                                text: Qt.formatDateTime(clock.date, "ddd dd MMM")
                                color: root.muted
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize(9)
                            }
                        }

                        MouseArea {
                            id: centerMouse
                            anchors.fill: parent
                            hoverEnabled: false  
                            onEntered: {
                                controlCenterHoverClose.stop();
                                if (!bar.controlCenterOpen)
                                    bar.showControlCenterOnHover();
                            }
                            onExited: bar.scheduleControlCenterHoverClose()
                            onClicked: {
                                if (bar.controlCenterOpen && !bar.controlCenterHoverOpened)
                                    bar.closeControlCenter();
                                else
                                    bar.showControlCenter(0);
                            }
                        }
                    }

                    Row {
                        id: rightCluster
                        anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                        height: 30
                        spacing: 0

                        Rectangle {
                            width: volumeRow.implicitWidth + 10
                            height: 30
                            radius: 11
                            color: volumeMouse.containsMouse ? root.surfaceRaised : "transparent"

                            Row {
                                id: volumeRow
                                anchors.centerIn: parent
                                spacing: 5
                                Text {
                                    text: root.audioIcon()
                                    color: root.audioMuted || !root.defaultAudio ? root.muted : root.accent
                                    font.family: root.fontFamily
                                    font.pixelSize: root.fontSize(10)
                                }
                                Text {
                                    text: root.defaultAudio ? root.audioVolume + "%" : "—"
                                    color: root.audioMuted || !root.defaultAudio ? root.muted : root.fg
                                    font.family: root.fontFamily
                                    font.pixelSize: root.fontSize(10)
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                id: volumeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton)
                                        root.toggleAudioMute();
                                    else
                                        bar.showControlCenter(3);
                                }
                                onWheel: wheel => root.changeAudioVolume(wheel.angleDelta.y > 0 ? 0.05 : -0.05)
                            }
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 1
                            height: 11
                            color: root.border
                        }

                        Rectangle {
                            width: performanceRow.implicitWidth + 10
                            height: 30
                            radius: 11
                            color: performanceMouse.containsMouse ? root.surfaceRaised : "transparent"

                            Row {
                                id: performanceRow
                                anchors.centerIn: parent
                                spacing: 5

                                Text { text: "CPU"; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(9) }
                                Text { text: root.system.cpu + "%"; color: root.accent; font.family: root.fontFamily; font.pixelSize: root.fontSize(10); font.bold: true }
                                Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 1; height: 11; color: root.border }
                                Text { text: "RAM"; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(9) }
                                Text { text: root.system.memoryUsed + "G"; color: root.accent; font.family: root.fontFamily; font.pixelSize: root.fontSize(10); font.bold: true }
                            }

                            MouseArea {
                                id: performanceMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: bar.showControlCenter(0)
                            }
                        }

                        Rectangle {
                            visible: root.system.batteryPresent
                            anchors.verticalCenter: parent.verticalCenter
                            width: 1
                            height: 11
                            color: root.border
                        }

                        Rectangle {
                            visible: root.system.batteryPresent
                            width: batteryRow.implicitWidth + 10
                            height: 30
                            radius: 11
                            color: batteryMouse.containsMouse ? root.surfaceRaised : "transparent"

                            Row {
                                id: batteryRow
                                anchors.centerIn: parent
                                spacing: 5
                                Text { text: root.system.batteryStatus === "Charging" ? "BAT+" : "BAT"; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(9) }
                                Text { text: root.system.batteryCapacity + "%"; color: root.system.batteryCapacity <= 15 ? root.critical : root.accent; font.family: root.fontFamily; font.pixelSize: root.fontSize(10); font.bold: true }
                            }

                            MouseArea {
                                id: batteryMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: bar.showControlCenter(0)
                            }
                        }

                        Rectangle {
                            visible: root.updatesText.length > 0
                            width: updatesLabel.implicitWidth + 16
                            height: 30
                            radius: 11
                            color: updatesMouse.containsMouse ? root.surfaceRaised : "transparent"

                            Text {
                                id: updatesLabel
                                anchors.centerIn: parent
                                text: root.updatesText
                                color: root.warning
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize(10)
                                font.bold: true
                            }

                            MouseArea {
                                id: updatesMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.run(["kitty", "--class", "system-updates", "-e", "sudo", "dnf", "upgrade", "--refresh"])
                            }
                        }
                    }
                }

                PanelWindow {
                    id: controlCenter
                    visible: bar.controlCenterOpen
                    screen: bar.modelData
                    color: "transparent"
                    exclusiveZone: 0
                    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

                    anchors { top: true; bottom: true; left: true; right: true }

                    Shortcut {
                        sequence: "Escape"
                        context: Qt.WindowShortcut
                        enabled: bar.controlCenterOpen
                        onActivated: bar.closeControlCenter()
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: bar.closeControlCenter()
                    }

                    Rectangle {
                        id: controlCard
                        width: Math.min(700, bar.width * 0.74)
                        height: Math.min(470, bar.modelData.height * 0.74)
                        anchors { top: parent.top; topMargin: 4; horizontalCenter: parent.horizontalCenter }
                        radius: 18
                        color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.97)
                        border.width: 1
                        border.color: root.border

                        MouseArea {
                            anchors.fill: parent
                        }

                        ColumnLayout {
                            anchors { fill: parent; margins: 12 }
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                Layout.minimumHeight: 42
                                Layout.maximumHeight: 42
                                spacing: 6

                                Repeater {
                                    model: [
                                        { icon: "󰕮", label: "Accueil" },
                                        { icon: "󰎆", label: "Média" },
                                        { icon: "󰖂", label: "VPN" },
                                        { icon: root.audioIcon(), label: "Audio" },
                                        { icon: "󰂯", label: "Bluetooth" }
                                    ]

                                    Rectangle {
                                        required property var modelData
                                        required property int index
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 42
                                        Layout.minimumHeight: 42
                                        Layout.maximumHeight: 42
                                        radius: 10
                                        color: bar.controlCenterTab === index ? root.accent : tabMouse.containsMouse ? root.surfaceRaised : root.surface

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 7
                                            Text {
                                                text: modelData.icon
                                                color: bar.controlCenterTab === index ? root.bg : root.fg
                                                font.family: root.fontFamily
                                                font.pixelSize: root.fontSize(13)
                                            }
                                            Text {
                                                text: modelData.label
                                                color: bar.controlCenterTab === index ? root.bg : root.fg
                                                font.family: root.fontFamily
                                                font.pixelSize: root.fontSize(10)
                                                font.bold: true
                                            }
                                        }

                                        MouseArea {
                                            id: tabMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: bar.controlCenterTab = index
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 42
                                    Layout.preferredHeight: 42
                                    Layout.minimumHeight: 42
                                    Layout.maximumHeight: 42
                                    radius: 10
                                    color: closeMouse.containsMouse ? root.critical : root.surface

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰅖"
                                        color: closeMouse.containsMouse ? root.bg : root.muted
                                        font.family: root.fontFamily
                                        font.pixelSize: root.fontSize(13)
                                    }

                                        MouseArea {
                                            id: closeMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: bar.closeControlCenter()
                                    }
                                }
                            }

                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: root.border }

                            StackLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                currentIndex: bar.controlCenterTab

                                Item {
                                    Row {
                                        anchors.fill: parent
                                        spacing: 10

                                        ColumnLayout {
                                            id: overviewLeftColumn
                                            width: parent.width * 0.34
                                            height: parent.height
                                            spacing: 10

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 142
                                                radius: 14
                                                color: root.surface

                                                Column {
                                                    anchors {
                                                        horizontalCenter: parent.horizontalCenter
                                                        verticalCenter: parent.verticalCenter
                                                        verticalCenterOffset: -8
                                                    }
                                                    spacing: -10

                                                    Text {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: Qt.formatDateTime(clock.date, "HH")
                                                        color: root.accent
                                                        font.family: root.fontFamily
                                                        font.pixelSize: root.fontSize(42)
                                                        font.bold: true
                                                    }
                                                    Text {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: Qt.formatDateTime(clock.date, "mm")
                                                        color: root.fg
                                                        font.family: root.fontFamily
                                                        font.pixelSize: root.fontSize(42)
                                                        font.bold: true
                                                    }
                                                }

                                                Text {
                                                    anchors {
                                                        horizontalCenter: parent.horizontalCenter
                                                        bottom: parent.bottom
                                                        bottomMargin: 2
                                                    }
                                                    text: Qt.formatDateTime(clock.date, "dddd d MMMM")
                                                    color: root.muted
                                                    font.family: root.fontFamily
                                                    font.pixelSize: root.fontSize(10)
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                radius: 14
                                                color: root.surface

                                                Column {
                                                    anchors { fill: parent; margins: 16 }
                                                    spacing: 12

                                                    Text {
                                                        text: "État du système"
                                                        color: root.fg
                                                        font.family: root.fontFamily
                                                        font.pixelSize: root.fontSize(12)
                                                        font.bold: true
                                                    }

                                                    Repeater {
                                                        model: [
                                                            { icon: "", label: "CPU", value: root.system.cpu + "%", percent: root.system.cpu },
                                                            { icon: "", label: "Mémoire", value: root.system.memoryUsed + "G", percent: root.system.memoryPercent },
                                                            { icon: root.system.networkText, label: "Réseau", value: root.system.networkTooltip, percent: 100 }
                                                        ]

                                                        Column {
                                                            required property var modelData
                                                            width: parent.width
                                                            spacing: 4
                                                            Item {
                                                                width: parent.width
                                                                height: 12
                                                                Text { anchors.left: parent.left; text: modelData.icon + "  " + modelData.label; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(9) }
                                                                Text { anchors.right: parent.right; text: modelData.value; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(9); font.bold: true }
                                                            }
                                                            Rectangle {
                                                                width: parent.width
                                                                height: 5
                                                                radius: 3
                                                                color: root.surfaceRaised
                                                                Rectangle { width: parent.width * Math.min(1, modelData.percent / 100); height: parent.height; radius: 3; color: modelData.percent >= 80 ? root.critical : root.accent }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        ColumnLayout {
                                            width: parent.width - overviewLeftColumn.width - parent.spacing
                                            height: parent.height
                                            spacing: 10

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 164
                                                radius: 14
                                                color: root.surface

                                                RowLayout {
                                                    anchors { fill: parent; margins: 14 }
                                                    spacing: 14

                                                    Rectangle {
                                                        Layout.preferredWidth: 132
                                                        Layout.fillHeight: true
                                                        radius: 12
                                                        color: root.surfaceRaised
                                                        clip: true

                                                        Text { anchors.centerIn: parent; text: "󰎆"; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(40) }
                                                        Image { anchors.fill: parent; source: root.selectedPlayer ? root.selectedPlayer.trackArtUrl : ""; fillMode: Image.PreserveAspectCrop; asynchronous: true }
                                                    }

                                                    ColumnLayout {
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true
                                                        spacing: 6

                                                        Text { text: "EN ÉCOUTE"; color: root.accent; font.family: root.fontFamily; font.pixelSize: root.fontSize(8); font.bold: true }
                                                        Text { Layout.fillWidth: true; text: root.selectedPlayer ? (root.selectedPlayer.trackTitle || root.selectedPlayer.identity) : "Aucun média"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(15); font.bold: true; elide: Text.ElideRight }
                                                        Text { Layout.fillWidth: true; text: root.selectedPlayer ? (root.selectedPlayer.trackArtist || "Lecteur multimédia") : "Lance un lecteur compatible MPRIS"; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(10); elide: Text.ElideRight }

                                                        Item { Layout.fillHeight: true }

                                                        Row {
                                                            Layout.alignment: Qt.AlignHCenter
                                                            spacing: 18
                                                            Text { text: "󰒮"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(18); MouseArea { anchors.fill: parent; onClicked: if (root.selectedPlayer) root.selectedPlayer.previous() } }
                                                            Rectangle {
                                                                width: 42; height: 36; radius: 11; color: root.accent
                                                                Text { anchors.centerIn: parent; text: root.selectedPlayer && root.selectedPlayer.isPlaying ? "󰏤" : "󰐊"; color: root.bg; font.family: root.fontFamily; font.pixelSize: root.fontSize(18) }
                                                                MouseArea { anchors.fill: parent; onClicked: if (root.selectedPlayer && root.selectedPlayer.canTogglePlaying) root.selectedPlayer.togglePlaying() }
                                                            }
                                                            Text { text: "󰒭"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(18); MouseArea { anchors.fill: parent; onClicked: if (root.selectedPlayer) root.selectedPlayer.next() } }
                                                        }
                                                    }
                                                }
                                            }

                                            GridLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                columns: 2
                                                rowSpacing: 10
                                                columnSpacing: 10

                                                Repeater {
                                                    model: [
                                                        { icon: root.system.networkText, title: "Réseau", detail: root.system.networkTooltip, action: "network" },
                                                        { icon: root.system.vpnText, title: "VPN", detail: root.system.vpnTooltip, action: "vpn" },
                                                        { icon: root.audioIcon(), title: "Audio", detail: root.audioMuted ? "Son coupé" : "Volume " + root.audioVolume + "%", action: "audio" },
                                                        { icon: root.bluetooth.powered ? "󰂯" : "󰂲", title: "Bluetooth", detail: root.bluetooth.powered ? "Adaptateur activé" : "Adaptateur désactivé", action: "bluetooth" }
                                                    ]

                                                    Rectangle {
                                                        id: quickCard
                                                        required property var modelData
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true
                                                        radius: 14
                                                        color: quickMouse.containsMouse ? root.surfaceRaised : root.surface
                                                        border.width: modelData.action === "vpn" && root.system.vpnClass !== "inactive" ? 1 : 0
                                                        border.color: root.accent

                                                        Item {
                                                            anchors { fill: parent; margins: 14 }

                                                            Item {
                                                                id: quickIconSlot
                                                                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                                                                width: 28
                                                                height: 28
                                                                Text { anchors.centerIn: parent; text: modelData.icon; color: modelData.action === "vpn" && root.system.vpnClass !== "inactive" ? root.accent : root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(20) }
                                                            }

                                                            Column {
                                                                anchors { left: quickIconSlot.right; leftMargin: 12; right: parent.right; verticalCenter: parent.verticalCenter }
                                                                spacing: 3
                                                                Text { width: parent.width; text: modelData.title; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(11); font.bold: true }
                                                                Text { width: parent.width; text: modelData.detail; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(8); elide: Text.ElideRight }
                                                            }
                                                        }

                                                        MouseArea {
                                                            id: quickMouse
                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            onClicked: {
                                                                if (modelData.action === "vpn") bar.controlCenterTab = 2;
                                                                else if (modelData.action === "bluetooth") bar.controlCenterTab = 4;
                                                                else if (modelData.action === "audio") bar.controlCenterTab = 3;
                                                                else root.showNetworkMenu(controlCenter, quickCard);
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Item {
                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 16

                                        Rectangle {
                                            Layout.preferredWidth: controlCard.width * 0.42
                                            Layout.fillHeight: true
                                            radius: 16
                                            color: root.surface
                                            clip: true
                                            Text { anchors.centerIn: parent; text: "󰎆"; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(64) }
                                            Image { anchors.fill: parent; source: root.selectedPlayer ? root.selectedPlayer.trackArtUrl : ""; fillMode: Image.PreserveAspectCrop; asynchronous: true }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            spacing: 10

                                            Item { Layout.fillHeight: true }
                                            Text { Layout.fillWidth: true; text: root.selectedPlayer ? (root.selectedPlayer.trackTitle || root.selectedPlayer.identity) : "Aucun média"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(22); font.bold: true; elide: Text.ElideRight }
                                            Text { Layout.fillWidth: true; text: root.selectedPlayer ? (root.selectedPlayer.trackArtist || root.selectedPlayer.trackAlbum || "Lecteur multimédia") : "Les lecteurs MPRIS apparaîtront ici"; color: root.accent; font.family: root.fontFamily; font.pixelSize: root.fontSize(11); elide: Text.ElideRight }

                                            Row {
                                                Layout.preferredHeight: 70
                                                Layout.fillWidth: true
                                                spacing: 7
                                                Repeater {
                                                    model: root.cavaLevels
                                                    Item {
                                                        required property real modelData
                                                        width: 19
                                                        height: 70
                                                        Rectangle {
                                                            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                                                            width: 13
                                                            height: Math.max(6, modelData / 7 * parent.height)
                                                            radius: 7
                                                            color: modelData >= 5 ? root.accent : root.bright
                                                            Behavior on height { NumberAnimation { duration: 70 } }
                                                        }
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 5
                                                radius: 3
                                                color: root.surfaceRaised
                                                Rectangle {
                                                    width: !root.selectedPlayer || !root.selectedPlayer.lengthSupported || root.selectedPlayer.length <= 0 ? 0 : parent.width * Math.min(1, root.selectedPlayer.position / root.selectedPlayer.length)
                                                    height: parent.height
                                                    radius: 3
                                                    color: root.accent
                                                }
                                            }

                                            Row {
                                                Layout.alignment: Qt.AlignHCenter
                                                spacing: 26
                                                Text { text: "󰒮"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(24); MouseArea { anchors.fill: parent; onClicked: if (root.selectedPlayer) root.selectedPlayer.previous() } }
                                                Rectangle {
                                                    width: 56
                                                    height: 46
                                                    radius: 14
                                                    color: root.accent
                                                    Text { anchors.centerIn: parent; text: root.selectedPlayer && root.selectedPlayer.isPlaying ? "󰏤" : "󰐊"; color: root.bg; font.family: root.fontFamily; font.pixelSize: root.fontSize(22) }
                                                    MouseArea { anchors.fill: parent; onClicked: if (root.selectedPlayer && root.selectedPlayer.canTogglePlaying) root.selectedPlayer.togglePlaying() }
                                                }
                                                Text { text: "󰒭"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(24); MouseArea { anchors.fill: parent; onClicked: if (root.selectedPlayer) root.selectedPlayer.next() } }
                                            }
                                            Item { Layout.fillHeight: true }
                                        }
                                    }
                                }

                                Item {
                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 12

                                        RowLayout {
                                            Layout.fillWidth: true
                                                Layout.preferredHeight: 62
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                radius: 14
                                                color: root.system.vpnClass === "inactive" ? root.surface : Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18)
                                                border.width: root.system.vpnClass === "inactive" ? 0 : 1
                                                border.color: root.accent
                                                Row {
                                                    anchors { fill: parent; margins: 16 }
                                                    spacing: 14
                                                    Text { anchors.verticalCenter: parent.verticalCenter; text: root.system.vpnClass === "inactive" ? "󰖂" : "󰌾"; color: root.system.vpnClass === "inactive" ? root.muted : root.accent; font.family: root.fontFamily; font.pixelSize: root.fontSize(28) }
                                                    Column {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        spacing: 4
                                                        Text { text: root.system.vpnClass === "inactive" ? "VPN déconnecté" : "VPN protégé"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(14); font.bold: true }
                                                        Text { text: root.system.vpnTooltip; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(9) }
                                                    }
                                                }
                                            }
                                            Rectangle {
                                                Layout.preferredWidth: 150
                                                Layout.fillHeight: true
                                                radius: 14
                                                color: disconnectMouse.containsMouse ? root.critical : root.surface
                                                Text { anchors.centerIn: parent; text: "󰅖  Tout couper"; color: disconnectMouse.containsMouse ? root.bg : root.critical; font.family: root.fontFamily; font.pixelSize: root.fontSize(10); font.bold: true }
                                                MouseArea { id: disconnectMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.vpnAction("disconnect") }
                                            }
                                        }

                                        Text { text: "Choisir un profil WireGuard"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(12); font.bold: true }

                                        Repeater {
                                            model: [
                                                { name: "ugo-public", subtitle: "Sortie internet publique", activeClass: "active-public", action: "toggle-public", icon: "󰖟" },
                                                { name: "ugo-gpu", subtitle: "Accès au réseau GPU", activeClass: "active-gpu", action: "toggle-gpu", icon: "󰢮" }
                                            ]

                                            Rectangle {
                                                required property var modelData
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 82
                                                readonly property bool active: root.system.vpnClass === modelData.activeClass
                                                radius: 15
                                                color: active ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.17) : profileMouse.containsMouse ? root.surfaceRaised : root.surface
                                                border.width: active ? 2 : 1
                                                border.color: active ? root.accent : root.border

                                                Item {
                                                    anchors.fill: parent

                                                    Rectangle {
                                                        id: profileIcon
                                                        anchors { left: parent.left; leftMargin: 17; verticalCenter: parent.verticalCenter }
                                                        width: 46
                                                        height: 46
                                                        radius: 13
                                                        color: active ? root.accent : root.surfaceRaised
                                                        Text { anchors.centerIn: parent; text: modelData.icon; color: active ? root.bg : root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(20) }
                                                    }

                                                    Rectangle {
                                                        id: profileButton
                                                        anchors { right: parent.right; rightMargin: 17; verticalCenter: parent.verticalCenter }
                                                        width: 94
                                                        height: 34
                                                        radius: 10
                                                        color: active ? root.accent : root.surfaceRaised
                                                        Text { anchors.centerIn: parent; text: active ? "Connecté" : "Connecter"; color: active ? root.bg : root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(9); font.bold: true }
                                                    }

                                                    Column {
                                                        anchors { left: profileIcon.right; leftMargin: 16; right: profileButton.left; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                                        spacing: 4
                                                        Text { width: parent.width; text: modelData.name; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(15); font.bold: true }
                                                        Text { width: parent.width; text: modelData.subtitle; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(9); elide: Text.ElideRight }
                                                    }
                                                }

                                                MouseArea { id: profileMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.vpnAction(modelData.action) }
                                            }
                                        }

                                        Item { Layout.fillHeight: true }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 40
                                            radius: 12
                                            color: editorMouse.containsMouse ? root.surfaceRaised : root.surface
                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 8
                                                IconImage {
                                                    width: 16
                                                    height: 16
                                                    readonly property var tray: root.networkTrayItem()
                                                    visible: tray !== null
                                                    source: tray ? tray.icon : ""
                                                }
                                                Text { text: "Menu réseau"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(10); font.bold: true }
                                            }
                                            MouseArea { id: editorMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.showNetworkMenu(controlCenter, parent) }
                                        }
                                    }
                                }

                                Item {
                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 12

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 86
                                            radius: 15
                                            color: root.audioMuted
                                                ? root.surface
                                                : Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.16)
                                            border.width: root.audioMuted ? 0 : 1
                                            border.color: root.accent

                                            RowLayout {
                                                anchors { fill: parent; margins: 16 }
                                                spacing: 14
                                                Text {
                                                    text: root.audioIcon()
                                                    color: root.audioMuted ? root.muted : root.accent
                                                    font.family: root.fontFamily
                                                    font.pixelSize: root.fontSize(32)
                                                }
                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 3
                                                    Text { text: root.defaultAudio ? (root.audioMuted ? "Son coupé" : "Sortie audio active") : "Aucune sortie audio"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(15); font.bold: true }
                                                    Text { text: root.defaultAudio ? "Volume général · clic droit sur l’indicateur pour couper le son" : "Vérifie PipeWire ou ouvre le mixeur"; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(9) }
                                                }
                                                Text { text: root.defaultAudio ? root.audioVolume + "%" : "—"; color: root.audioMuted ? root.muted : root.accent; font.family: root.fontFamily; font.pixelSize: root.fontSize(28); font.bold: true }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 150
                                            radius: 15
                                            color: root.surface

                                            ColumnLayout {
                                                anchors { fill: parent; margins: 18 }
                                                spacing: 12

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    Text { text: "Volume"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(12); font.bold: true }
                                                    Item { Layout.fillWidth: true }
                                                    Text { text: "0–150 %"; color: root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(9) }
                                                }

                                                Rectangle {
                                                    id: audioVolumeTrack
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 14
                                                    radius: 7
                                                    color: root.surfaceRaised
                                                    clip: true

                                                    Rectangle {
                                                        width: parent.width * Math.min(1, root.audioVolume / 150)
                                                        height: parent.height
                                                        radius: parent.radius
                                                        color: root.audioMuted ? root.muted : root.accent
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        enabled: root.defaultAudio !== null
                                                        onPressed: mouse => root.setAudioVolume(mouse.x / width * 1.5)
                                                        onPositionChanged: mouse => {
                                                            if (pressed)
                                                                root.setAudioVolume(mouse.x / width * 1.5);
                                                        }
                                                        onWheel: wheel => root.changeAudioVolume(wheel.angleDelta.y > 0 ? 0.05 : -0.05)
                                                    }
                                                }

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 10
                                                    Rectangle {
                                                        Layout.preferredWidth: 78
                                                        Layout.preferredHeight: 36
                                                        radius: 10
                                                        color: audioMinusMouse.containsMouse ? root.surfaceRaised : root.bg
                                                        Text { anchors.centerIn: parent; text: "− 5 %"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(10); font.bold: true }
                                                        MouseArea { id: audioMinusMouse; anchors.fill: parent; hoverEnabled: true; enabled: root.defaultAudio !== null; onClicked: root.changeAudioVolume(-0.05) }
                                                    }
                                                    Rectangle {
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: 36
                                                        radius: 10
                                                        color: audioMuteMouse.containsMouse ? root.accent : root.surfaceRaised
                                                        Text { anchors.centerIn: parent; text: root.audioMuted ? "󰖁  Réactiver le son" : "󰖁  Couper le son"; color: audioMuteMouse.containsMouse ? root.bg : root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(10); font.bold: true }
                                                        MouseArea { id: audioMuteMouse; anchors.fill: parent; hoverEnabled: true; enabled: root.defaultAudio !== null; onClicked: root.toggleAudioMute() }
                                                    }
                                                    Rectangle {
                                                        Layout.preferredWidth: 78
                                                        Layout.preferredHeight: 36
                                                        radius: 10
                                                        color: audioPlusMouse.containsMouse ? root.surfaceRaised : root.bg
                                                        Text { anchors.centerIn: parent; text: "+ 5 %"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(10); font.bold: true }
                                                        MouseArea { id: audioPlusMouse; anchors.fill: parent; hoverEnabled: true; enabled: root.defaultAudio !== null; onClicked: root.changeAudioVolume(0.05) }
                                                    }
                                                }
                                            }
                                        }

                                        Item { Layout.fillHeight: true }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 42
                                            radius: 12
                                            color: audioMixerMouse.containsMouse ? root.surfaceRaised : root.surface
                                            Text { anchors.centerIn: parent; text: "󰒓  Ouvrir le mixeur et choisir les sorties"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(10); font.bold: true }
                                            MouseArea { id: audioMixerMouse; anchors.fill: parent; hoverEnabled: true; onClicked: bar.launchFromControlCenter(["pavucontrol"]) }
                                        }
                                    }
                                }

                                Item {
                                    Column {
                                        anchors.fill: parent
                                        spacing: 10

                                        Row {
                                            width: parent.width
                                            height: 72
                                            spacing: 10

                                            Rectangle {
                                                width: parent.width - 300
                                                height: parent.height
                                                radius: 14
                                                color: root.bluetooth.powered
                                                    ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.16)
                                                    : root.surface
                                                border.width: root.bluetooth.powered ? 1 : 0
                                                border.color: root.accent

                                                Row {
                                                    anchors { fill: parent; margins: 14 }
                                                    spacing: 13
                                                    Text {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        text: root.bluetooth.powered ? "󰂯" : "󰂲"
                                                        color: root.bluetooth.powered ? root.accent : root.muted
                                                        font.family: root.fontFamily
                                                        font.pixelSize: root.fontSize(24)
                                                    }
                                                    Column {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        spacing: 3
                                                        Text { text: root.bluetooth.powered ? "Bluetooth activé" : "Bluetooth désactivé"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(13); font.bold: true }
                                                        Text { text: root.bluetooth.discovering ? "Recherche en cours…" : root.bluetooth.devices.length + " appareil(s) détecté(s)"; color: root.bluetooth.discovering ? root.accent : root.muted; font.family: root.fontFamily; font.pixelSize: root.fontSize(9) }
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                width: 140
                                                height: parent.height
                                                radius: 14
                                                color: scanMouse.containsMouse || root.bluetooth.discovering ? root.accent : root.surface
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: root.bluetooth.discovering ? "󰑐  Arrêter" : "󰑐  Rechercher"
                                                    color: scanMouse.containsMouse || root.bluetooth.discovering ? root.bg : (root.bluetooth.powered ? root.accent : root.muted)
                                                    font.family: root.fontFamily
                                                    font.pixelSize: root.fontSize(10)
                                                    font.bold: true
                                                }
                                                MouseArea { id: scanMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.bluetoothAction("toggle-scan", "") }
                                            }

                                            Rectangle {
                                                width: 140
                                                height: parent.height
                                                radius: 14
                                                color: powerMouse.containsMouse
                                                    ? (root.bluetooth.powered ? root.critical : root.accent)
                                                    : root.surface
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: root.bluetooth.powered ? "󰐥  Désactiver" : "󰐥  Activer"
                                                    color: powerMouse.containsMouse ? root.bg : (root.bluetooth.powered ? root.critical : root.accent)
                                                    font.family: root.fontFamily
                                                    font.pixelSize: root.fontSize(10)
                                                    font.bold: true
                                                }
                                                MouseArea { id: powerMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.bluetoothAction("toggle-power", "") }
                                            }
                                        }

                                        Text { width: parent.width; height: 18; text: root.bluetooth.discovering ? "Appareils à proximité · recherche en cours" : "Appareils connus et à proximité"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(12); font.bold: true }

                                        Item {
                                            width: parent.width
                                            height: parent.height - 160

                                            Text {
                                                anchors.centerIn: parent
                                                visible: root.bluetooth.devices.length === 0
                                                text: root.bluetooth.powered
                                                    ? "Aucun appareil détecté\nLance une recherche pour trouver les appareils à proximité"
                                                    : "Active le Bluetooth pour voir les appareils"
                                                horizontalAlignment: Text.AlignHCenter
                                                color: root.muted
                                                font.family: root.fontFamily
                                                font.pixelSize: root.fontSize(11)
                                            }

                                            Column {
                                                anchors.fill: parent
                                                spacing: 8

                                                Repeater {
                                                    model: root.bluetooth.devices.slice(0, 4)

                                                    Rectangle {
                                                        required property var modelData
                                                        width: parent.width
                                                        height: Math.min(62,
                                                            (parent.height - (Math.min(root.bluetooth.devices.length, 4) - 1) * 8)
                                                            / Math.max(1, Math.min(root.bluetooth.devices.length, 4)))
                                                        radius: 14
                                                        color: modelData.connected
                                                            ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.16)
                                                            : root.surface
                                                        border.width: modelData.connected ? 1 : 0
                                                        border.color: root.accent

                                                        RowLayout {
                                                            anchors { fill: parent; margins: 12 }
                                                            spacing: 12
                                                            Rectangle {
                                                                Layout.preferredWidth: 38
                                                                Layout.preferredHeight: 38
                                                                radius: 11
                                                                color: modelData.connected ? root.accent : root.surfaceRaised
                                                                Text { anchors.centerIn: parent; text: "󰂯"; color: modelData.connected ? root.bg : root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(17) }
                                                            }
                                                            ColumnLayout {
                                                                Layout.fillWidth: true
                                                                spacing: 2
                                                                Text { Layout.fillWidth: true; text: modelData.name; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(11); font.bold: true; elide: Text.ElideRight }
                                                                Text {
                                                                    text: modelData.connected
                                                                        ? "Connecté" + (modelData.battery >= 0 ? " · " + modelData.battery + "%" : "")
                                                                        : modelData.paired ? "Jumelé · " + modelData.address : "Détecté · " + modelData.address
                                                                    color: modelData.connected ? root.accent : root.muted
                                                                    font.family: root.fontFamily
                                                                    font.pixelSize: root.fontSize(8)
                                                                }
                                                            }
                                                            Rectangle {
                                                                Layout.preferredWidth: 92
                                                                Layout.preferredHeight: 32
                                                                radius: 10
                                                                color: deviceActionMouse.containsMouse || modelData.connected ? root.accent : root.surfaceRaised
                                                                Text { anchors.centerIn: parent; text: modelData.connected ? "Déconnecter" : modelData.paired ? "Connecter" : "Jumeler"; color: deviceActionMouse.containsMouse || modelData.connected ? root.bg : root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(8); font.bold: true }
                                                                MouseArea { id: deviceActionMouse; anchors.fill: parent; hoverEnabled: true; enabled: root.bluetooth.powered; onClicked: root.bluetoothAction("toggle-device", modelData.address) }
                                                            }
                                                            Rectangle {
                                                                visible: modelData.paired
                                                                Layout.preferredWidth: visible ? 34 : 0
                                                                Layout.preferredHeight: 32
                                                                radius: 10
                                                                color: removeDeviceMouse.containsMouse ? root.critical : root.surfaceRaised
                                                                Text { anchors.centerIn: parent; text: "󰆴"; color: removeDeviceMouse.containsMouse ? root.bg : root.critical; font.family: root.fontFamily; font.pixelSize: root.fontSize(11) }
                                                                MouseArea { id: removeDeviceMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.bluetoothAction("remove-device", modelData.address) }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: parent.width
                                            height: 40
                                            radius: 12
                                            color: bluetoothManagerMouse.containsMouse ? root.surfaceRaised : root.surface
                                            Text { anchors.centerIn: parent; text: "󰒓  Gérer et jumeler de nouveaux appareils"; color: root.fg; font.family: root.fontFamily; font.pixelSize: root.fontSize(10); font.bold: true }
                                            MouseArea { id: bluetoothManagerMouse; anchors.fill: parent; hoverEnabled: true; onClicked: bar.launchFromControlCenter(["blueman-manager"]) }
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: controlCardHover
                            anchors.fill: parent
                            z: 100
                            acceptedButtons: Qt.NoButton
                            hoverEnabled: true
                            scrollGestureEnabled: true
                            onEntered: controlCenterHoverClose.stop()
                            onExited: bar.scheduleControlCenterHoverClose()
                            onWheel: wheel => bar.handleTabSwipe(wheel)
                        }
                    }

                    Timer {
                        interval: 1000
                        running: controlCenter.visible && root.selectedPlayer !== null && root.selectedPlayer.isPlaying
                        repeat: true
                        onTriggered: if (root.selectedPlayer) root.selectedPlayer.positionChanged()
                    }
                }
            }
        }
    }
}
