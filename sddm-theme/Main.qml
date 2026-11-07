// ──────────────────────────────────────────────────────────────
//  NIGHTWIRE — SDDM greeter for Rafay-Hyprland-Arch
//  Terminal-HUD login. Pure QtQuick. No QtQuick.Controls,
//  no Layouts, no Shapes — only core primitives + Canvas +
//  a hand-rolled TextInput for the password field.
//
//  Works on every SDDM build (Qt5 and Qt6) because it needs
//  only QtQuick 2.x — the one module SDDM always ships.
//
//  Globals from SDDM: config, userModel, sessionModel, sddm
// ──────────────────────────────────────────────────────────────

import QtQuick 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: cfgVoid

    // ── palette (theme.conf overrides) ────────────────────────
    property string cfgVoid:      config.backgroundColor !== "" ? config.backgroundColor : "#05070a"
    property string cfgPhosphor:  config.accentColor     !== "" ? config.accentColor     : "#00ff9c"
    property string cfgText:      config.foregroundColor !== "" ? config.foregroundColor : "#d8e3d4"
    property string cfgDim:       config.dimColor        !== "" ? config.dimColor        : "#1b2330"
    property string cfgTextDim:   "#7b8a84"
    property string cfgMagenta:   "#ff2975"
    property string cfgCyan:      "#00e5ff"
    property string cfgCrit:      "#ff003c"
    property string cfgWarn:      "#ffb000"
    property string fontFamily:   config.fontFamily      !== "" ? config.fontFamily      : "JetBrainsMono Nerd Font"
    property int    baseFontSize: config.fontSize        !== "" ? parseInt(config.fontSize) : 12

    // ── selectable session + user (we use SDDM's models manually) ──
    property int sessionIndex: sessionModel && sessionModel.lastIndex !== undefined && sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property int userIndex:    userModel    && userModel.lastIndex    !== undefined && userModel.lastIndex    >= 0 ? userModel.lastIndex    : 0

    function currentUserName() {
        if (!userModel) return ""
        var idx = userModel.index(userIndex, 0)
        return userModel.data(idx, Qt.UserRole + 1) || ""
    }
    function currentSessionName() {
        if (!sessionModel) return ""
        var idx = sessionModel.index(sessionIndex, 0)
        return sessionModel.data(idx, Qt.UserRole + 4) || "Session"
    }

    // ── boot-sequence state ───────────────────────────────────
    property bool bootDone: false
    property real contentOpacity: 0.0

    // ── wallpaper (dim, behind everything) ────────────────────
    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.background !== "" ? config.background : "wall.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        opacity: 0.22
        onStatusChanged: if (status === Image.Error) visible = false
    }

    // void overlay — kill the wallpaper colour; keep just the form
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.02, 0.03, 0.05, 0.92) }
            GradientStop { position: 0.5; color: Qt.rgba(0.02, 0.03, 0.05, 0.85) }
            GradientStop { position: 1.0; color: Qt.rgba(0.02, 0.03, 0.05, 0.95) }
        }
    }

    // ── MATRIX RAIN (behind content, dimly) ───────────────────
    Canvas {
        id: rain
        anchors.fill: parent
        opacity: 0.18
        property var drops: []
        property int columns: Math.floor(width / 14)
        property string chars: "01░▒▓█ΛΔΘΞΠΣΦΨΩабвгдежзиклмн▀▄▌▐│┤┐└┴┬├─┼╬╣║╗╝╚╔"

        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = "rgba(5, 7, 10, 0.08)"
            ctx.fillRect(0, 0, width, height)

            ctx.font = "13px " + root.fontFamily
            for (var i = 0; i < drops.length; i++) {
                var ch = chars.charAt(Math.floor(Math.random() * chars.length))
                var x = i * 14
                var y = drops[i] * 18
                ctx.fillStyle = root.cfgPhosphor
                ctx.fillText(ch, x, y)
                ctx.fillStyle = "rgba(0, 255, 156, 0.35)"
                ctx.fillText(chars.charAt(Math.floor(Math.random() * chars.length)),
                             x, y - 18)
                if (y > height && Math.random() > 0.975) drops[i] = 0
                drops[i] += 1
            }
        }
        Component.onCompleted: {
            drops = []
            for (var i = 0; i < columns; i++)
                drops.push(Math.floor(Math.random() * 60))
        }
        Timer {
            interval: 55; running: true; repeat: true
            onTriggered: rain.requestPaint()
        }
    }

    // ── CRT SCANLINES (animated drift) ────────────────────────
    Canvas {
        id: scan
        anchors.fill: parent
        opacity: 0.35
        property real shift: 0
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = "rgba(0, 255, 156, 0.04)"
            for (var y = (shift % 4); y < height; y += 4)
                ctx.fillRect(0, y, width, 1)
        }
        Timer {
            interval: 50; running: true; repeat: true
            onTriggered: { scan.shift += 1; scan.requestPaint() }
        }
    }

    // ── CRT VIGNETTE ──────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.55) }
            GradientStop { position: 0.4; color: Qt.rgba(0, 0, 0, 0.05) }
            GradientStop { position: 0.6; color: Qt.rgba(0, 0, 0, 0.05) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.55) }
        }
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.45) }
            GradientStop { position: 0.3; color: Qt.rgba(0, 0, 0, 0) }
            GradientStop { position: 0.7; color: Qt.rgba(0, 0, 0, 0) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.45) }
        }
    }

    // ══════════════════════════════════════════════════════════
    //  BOOT SEQUENCE — fake kernel log, then clears
    // ══════════════════════════════════════════════════════════
    Column {
        id: bootLog
        x: 60
        y: 60
        spacing: 2
        visible: !root.bootDone
        opacity: root.bootDone ? 0 : 1

        property var lines: [
            "[ 0.000012] NIGHTWIRE 2.0.0 (nightwire@hirafay)",
            "[ 0.001344] CPU: AMD Ryzen / Intel Core — vendor OK",
            "[ 0.012871] ACPI: _OSC evaluation for CPUs succeeded",
            "[ 0.047120] Memory: lifted / available OK",
            "[ 0.089244] pci 0000:00:02.0 : GPU bridge ready",
            "[ 0.142077] i915/nvidia/amdgpu: KMS enabled",
            "[ 0.189556] systemd[1]: starting Login Service...",
            "[ 0.244012] systemd[1]: starting sddm.service...",
            "[ 0.301477] sddm[912]: QML engine online",
            "[ 0.388210] >>> AUTHORITY HANDOFF > greeter",
            "[ 0.412988] NIGHTWIRE greeter ready. welcome back."
        ]
        property int cursor: 0

        Repeater {
            id: bootRep
            model: bootLog.lines.length
            delegate: Text {
                color: index === bootLog.cursor - 1 ? root.cfgPhosphor : root.cfgText
                font.family: root.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                opacity: index < bootLog.cursor ? 1.0 : 0.0
                text: bootLog.lines[index]
                Behavior on opacity { NumberAnimation { duration: 80 } }
            }
        }
    }

    Timer {
        id: bootTimer
        interval: 110; running: true; repeat: true
        onTriggered: {
            if (bootLog.cursor < bootLog.lines.length) {
                bootLog.cursor += 1
            } else {
                stop()
                finishTimer.start()
            }
        }
    }
    Timer {
        id: finishTimer
        interval: 450; repeat: false
        onTriggered: {
            root.bootDone = true
            contentFade.start()
        }
    }
    PropertyAnimation {
        id: contentFade
        target: root
        property: "contentOpacity"
        from: 0.0; to: 1.0
        duration: 450
    }

    // ══════════════════════════════════════════════════════════
    //  MAIN HUD — opens after boot sequence
    // ══════════════════════════════════════════════════════════
    Item {
        anchors.fill: parent
        opacity: root.contentOpacity
        visible: root.bootDone

        // ── TOP BAR: machine readouts ─────────────────────────
        Row {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 20
            anchors.topMargin: 14
            spacing: 18

            Text {
                text: "╔═ NIGHTWIRE ══ rafay-hyprland-arch ═╗"
                color: root.cfgPhosphor
                font.family: root.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }
            Text {
                text: "[ sddm-greeter · pure-qtquick ]"
                color: root.cfgMagenta
                font.family: root.fontFamily
                font.pixelSize: 11
            }
            Text {
                text: "[ tty: dpy-0 ]"
                color: root.cfgCyan
                font.family: root.fontFamily
                font.pixelSize: 11
            }
        }

        Row {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 20
            anchors.topMargin: 14
            spacing: 14

            Text {
                text: "[ CAPS·OFF ]"
                color: root.cfgTextDim
                font.family: root.fontFamily
                font.pixelSize: 11
            }
            Text {
                id: topClock
                text: Qt.formatTime(new Date(), "hh:mm:ss")
                color: root.cfgPhosphor
                font.family: root.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }
        }

        // ── MONSTER CLOCK (center top) ────────────────────────
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 84
            spacing: 2

            Text {
                id: bigClock
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.cfgPhosphor
                font.family: root.fontFamily
                font.pixelSize: 160
                font.weight: Font.Bold
                text: Qt.formatTime(new Date(), "hh:mm:ss")
            }
            Text {
                id: dateText
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.cfgText
                font.family: root.fontFamily
                font.pixelSize: 16
                font.weight: Font.DemiBold
                text: Qt.formatDate(new Date(), "dddd · dd MMM yyyy").toUpperCase()
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.cfgMagenta
                font.family: root.fontFamily
                font.pixelSize: 11
                text: "// sync ok · drift 0.00ms · cosmic-ok"
            }
        }

        // ══════════════════════════════════════════════════════
        //  LOGIN FRAME — box-drawing terminal card
        // ══════════════════════════════════════════════════════
        Item {
            id: loginFrame
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 0   // shake animates this
            width: 540
            height: 310

            // box outline
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0.02, 0.05, 0.04, 0.78)
                border.color: root.cfgPhosphor
                border.width: 1
                radius: 0
            }

            // header strip — sits over the top border
            Rectangle {
                id: headerBg
                x: 20
                y: -8
                width: headerText.implicitWidth + 16
                height: 16
                color: root.cfgVoid
                z: 2
                Text {
                    id: headerText
                    anchors.centerIn: parent
                    text: "╡ NIGHTWIRE // auth-prompt ╞"
                    color: root.cfgPhosphor
                    font.family: root.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }
            }

            // four corner ticks
            Text { x: 8;                       y: 8;                        text: "+"; color: root.cfgMagenta; font.family: root.fontFamily; font.pixelSize: 10 }
            Text { x: loginFrame.width - 14;   y: 8;                        text: "+"; color: root.cfgMagenta; font.family: root.fontFamily; font.pixelSize: 10 }
            Text { x: 8;                       y: loginFrame.height - 14;   text: "+"; color: root.cfgMagenta; font.family: root.fontFamily; font.pixelSize: 10 }
            Text { x: loginFrame.width - 14;   y: loginFrame.height - 14;   text: "+"; color: root.cfgMagenta; font.family: root.fontFamily; font.pixelSize: 10 }

            Column {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 14

                // ── user line ────────────────────────────────
                Row {
                    spacing: 0
                    Text {
                        text: "> login as "
                        color: root.cfgTextDim
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "[ " + root.currentUserName() + " ]"
                        color: root.cfgPhosphor
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "  [F2 to cycle]"
                        color: root.cfgDim
                        font.family: root.fontFamily
                        font.pixelSize: 11
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // separator
                Text {
                    text: "─────────────────────────────────────────────────"
                    color: root.cfgDim
                    font.family: root.fontFamily
                    font.pixelSize: 11
                }

                // ── password line (hand-rolled TextInput) ────
                Row {
                    spacing: 0
                    width: parent.width

                    Text {
                        text: "> passwd : "
                        color: root.cfgTextDim
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: parent.width - 100
                        height: 28
                        color: "transparent"
                        anchors.verticalCenter: parent.verticalCenter

                        TextInput {
                            id: pwField
                            anchors.fill: parent
                            anchors.leftMargin: 2
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            passwordCharacter: "●"
                            color: root.cfgPhosphor
                            font.family: root.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            focus: true
                            selectByMouse: true
                            cursorDelegate: Rectangle {
                                width: 2
                                color: root.cfgPhosphor
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.0; duration: 500 }
                                    NumberAnimation { to: 1.0; duration: 500 }
                                }
                            }
                            Keys.onReturnPressed: root.submitLogin()
                            Keys.onEnterPressed:  root.submitLogin()
                        }

                        // placeholder when empty
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                            anchors.verticalCenter: parent.verticalCenter
                            text: "_"
                            color: root.cfgTextDim
                            font.family: root.fontFamily
                            font.pixelSize: 14
                            visible: pwField.text.length === 0
                        }

                        // underline
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 1
                            color: pwField.activeFocus ? root.cfgPhosphor : root.cfgDim
                        }
                    }
                }

                // ── session line ─────────────────────────────
                Row {
                    spacing: 0
                    Text {
                        text: "> session: "
                        color: root.cfgTextDim
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "[ " + root.currentSessionName() + " ]"
                        color: root.cfgCyan
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "  [F1 to cycle]"
                        color: root.cfgDim
                        font.family: root.fontFamily
                        font.pixelSize: 11
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // separator
                Text {
                    text: "─────────────────────────────────────────────────"
                    color: root.cfgDim
                    font.family: root.fontFamily
                    font.pixelSize: 11
                }

                // ── button row (Rectangles with MouseAreas, no Controls) ──
                Row {
                    spacing: 18

                    // login
                    Rectangle {
                        width: 180; height: 32
                        color: loginMA.containsMouse ? root.cfgPhosphor : Qt.rgba(0, 1, 0.61, 0.08)
                        border.color: root.cfgPhosphor
                        border.width: 1
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: "[ EXEC · login ]"
                            color: loginMA.containsMouse ? root.cfgVoid : root.cfgPhosphor
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }
                        MouseArea {
                            id: loginMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.submitLogin()
                        }
                    }

                    // reboot
                    Rectangle {
                        width: 48; height: 32
                        color: rebootMA.containsMouse ? root.cfgCyan : Qt.rgba(0, 0.89, 1, 0.07)
                        border.color: root.cfgCyan
                        border.width: 1
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: "[ R ]"
                            color: rebootMA.containsMouse ? root.cfgVoid : root.cfgCyan
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }
                        MouseArea {
                            id: rebootMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: sddm.reboot()
                        }
                    }

                    // shutdown
                    Rectangle {
                        width: 48; height: 32
                        color: offMA.containsMouse ? root.cfgCrit : Qt.rgba(1, 0, 0.24, 0.08)
                        border.color: root.cfgCrit
                        border.width: 1
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: "[ ⏻ ]"
                            color: offMA.containsMouse ? root.cfgVoid : root.cfgCrit
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }
                        MouseArea {
                            id: offMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: sddm.powerOff()
                        }
                    }
                }

                // ── error line ───────────────────────────────
                Text {
                    id: errorText
                    width: parent.width
                    color: root.cfgCrit
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    text: ""
                    visible: text.length > 0
                }
            }
        }

        // ── shake animation on fail ───────────────────────────
        SequentialAnimation {
            id: shakeAnim
            PropertyAnimation { target: loginFrame.anchors; property: "horizontalCenterOffset"; to: -10; duration: 45; easing.type: Easing.OutQuad }
            PropertyAnimation { target: loginFrame.anchors; property: "horizontalCenterOffset"; to:  10; duration: 45; easing.type: Easing.OutQuad }
            PropertyAnimation { target: loginFrame.anchors; property: "horizontalCenterOffset"; to:  -7; duration: 45; easing.type: Easing.OutQuad }
            PropertyAnimation { target: loginFrame.anchors; property: "horizontalCenterOffset"; to:   7; duration: 45; easing.type: Easing.OutQuad }
            PropertyAnimation { target: loginFrame.anchors; property: "horizontalCenterOffset"; to:   0; duration: 45; easing.type: Easing.OutQuad }
        }

        // ── BOTTOM HUD STRIP ──────────────────────────────────
        Row {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.bottomMargin: 18
            spacing: 22

            Text {
                text: "╚═ nightwire · build 2.0.0 · " + root.currentUserName() + "@multan"
                color: root.cfgPhosphor
                font.family: root.fontFamily
                font.pixelSize: 11
            }
            Text {
                text: "// hyprland-session · qt-declarative · phosphor-rev-04"
                color: root.cfgTextDim
                font.family: root.fontFamily
                font.pixelSize: 11
            }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.bottomMargin: 18
            spacing: 22

            Text {
                text: "[ F1 session ]  [ F2 user ]  [ ENTER login ]  [ ESC clear ]"
                color: root.cfgMagenta
                font.family: root.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
        }
    }

    // ── login submit (used by button + Enter in pw) ───────────
    function submitLogin() {
        sddm.login(currentUserName(), pwField.text, sessionIndex)
    }

    // ── live clock tick ───────────────────────────────────────
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var d = new Date()
            if (root.bootDone) {
                bigClock.text = Qt.formatTime(d, "hh:mm:ss")
                dateText.text = Qt.formatDate(d, "dddd · dd MMM yyyy").toUpperCase()
            }
            topClock.text = Qt.formatTime(d, "hh:mm:ss")
        }
    }

    // ── SDDM signal hooks ─────────────────────────────────────
    Connections {
        target: sddm
        function onLoginSucceeded() {
            errorText.text = ""
            successFlash.start()
        }
        function onLoginFailed() {
            errorText.text = ">> ACCESS DENIED · retry_"
            pwField.text = ""
            pwField.focus = true
            shakeAnim.start()
        }
    }

    // ── success phosphor flood ────────────────────────────────
    Rectangle {
        id: successOverlay
        anchors.fill: parent
        color: root.cfgPhosphor
        opacity: 0
        z: 100
    }
    SequentialAnimation {
        id: successFlash
        NumberAnimation { target: successOverlay; property: "opacity"; to: 0.85; duration: 110 }
        NumberAnimation { target: successOverlay; property: "opacity"; to: 0.00; duration: 320 }
    }

    // ── keyboard shortcuts (ESC clears, F-keys cycle) ─────────
    Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                pwField.text = ""
                errorText.text = ""
            } else if (event.key === Qt.Key_F1 && sessionModel) {
                var scount = sessionModel.rowCount ? sessionModel.rowCount() : 1
                if (scount > 0) root.sessionIndex = (root.sessionIndex + 1) % scount
            } else if (event.key === Qt.Key_F2 && userModel) {
                var ucount = userModel.rowCount ? userModel.rowCount() : 1
                if (ucount > 0) root.userIndex = (root.userIndex + 1) % ucount
            }
        }
    }

    Component.onCompleted: pwField.forceActiveFocus()
}
