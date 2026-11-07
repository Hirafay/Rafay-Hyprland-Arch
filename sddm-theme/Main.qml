// ──────────────────────────────────────────────────────────────
//  NIGHTWIRE — SDDM greeter for Rafay-Hyprland-Arch
//  Terminal-HUD login. Scanlines, CRT vignette, matrix rain,
//  boot-log cold-start, box-drawing frame around the prompt.
//  Qt5 + Qt6 SDDM builds. No QML modules beyond QtQuick core.
//
//  Globals from SDDM: config, userModel, sessionModel, sddm
// ──────────────────────────────────────────────────────────────

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: cfgVoid

    // ── palette (overrideable via theme.conf) ─────────────────
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

    // ── boot-sequence state ───────────────────────────────────
    property bool   bootDone: false
    property real   contentOpacity: 0.0

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
            // low-alpha dark overlay to fade previous frame
            ctx.fillStyle = "rgba(5, 7, 10, 0.08)"
            ctx.fillRect(0, 0, width, height)

            ctx.font = "13px " + root.fontFamily
            for (var i = 0; i < drops.length; i++) {
                var ch = chars.charAt(Math.floor(Math.random() * chars.length))
                var x = i * 14
                var y = drops[i] * 18
                // leading char brighter
                ctx.fillStyle = root.cfgPhosphor
                ctx.fillText(ch, x, y)
                // trail
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
        radius: 0
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
        Rectangle {
            id: topBar
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 28
            color: "transparent"

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                spacing: 18

                Text {
                    text: "╔═ NIGHTWIRE ══ rafay-hyprland-arch ═╗"
                    color: root.cfgPhosphor
                    font.family: root.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }
                Text {
                    text: "[ sddm-greeter · qt6 ]"
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
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                Text {
                    id: caps
                    text: "[ CAPS·OFF ]"
                    color: root.cfgTextDim
                    font.family: root.fontFamily
                    font.pixelSize: 11
                    property bool on: false
                    // SDDM doesn't give us caps-lock reliably; placeholder slot
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
            width: 540
            height: 310
            transform: Translate { id: shakeT; x: 0 }

            // box outline
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0.02, 0.05, 0.04, 0.78)
                border.color: root.cfgPhosphor
                border.width: 1
                radius: 0
            }

            // header strip — sits over the top border, void bg masks the line behind the text
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

            // corner tick marks (inside corners)
            Repeater {
                model: [
                    [8, 8],   [loginFrame.width - 14, 8],
                    [8, loginFrame.height - 14],
                    [loginFrame.width - 14, loginFrame.height - 14]
                ]
                delegate: Text {
                    x: modelData[0]; y: modelData[1]
                    text: "+"
                    color: root.cfgMagenta
                    font.family: root.fontFamily
                    font.pixelSize: 10
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 14

                // user line
                Row {
                    spacing: 0
                    Text {
                        text: "> login as "
                        color: root.cfgTextDim
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ComboBox {
                        id: userList
                        width: 240
                        height: 26
                        model: userModel
                        textRole: "name"
                        currentIndex: userModel.lastIndex !== undefined && userModel.lastIndex >= 0
                                      ? userModel.lastIndex : 0

                        contentItem: Text {
                            text: "[ " + userList.displayText + " ]"
                            color: root.cfgPhosphor
                            font.family: root.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 4
                        }
                        background: Rectangle {
                            color: "transparent"
                        }
                        indicator: Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            text: "▼"
                            color: root.cfgMagenta
                            font.family: root.fontFamily
                            font.pixelSize: 10
                        }
                    }
                }

                // prompt separator line
                Text {
                    width: parent.width
                    text: "─────────────────────────────────────────────────"
                    color: root.cfgDim
                    font.family: root.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }

                // password line
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
                    TextField {
                        id: pwField
                        width: parent.width - 100
                        echoMode: TextInput.Password
                        passwordCharacter: "●"
                        placeholderText: "_"
                        placeholderTextColor: root.cfgTextDim
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
                        background: Rectangle {
                            color: "transparent"
                            // thin underline, phosphor when focused
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 1
                                color: pwField.activeFocus ? root.cfgPhosphor : root.cfgDim
                            }
                        }
                        Keys.onReturnPressed: loginButton.clicked()
                        Keys.onEnterPressed:  loginButton.clicked()
                    }
                }

                // session cycle
                Row {
                    spacing: 0
                    Text {
                        text: "> session: "
                        color: root.cfgTextDim
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ComboBox {
                        id: sessionList
                        width: 200
                        height: 26
                        model: sessionModel
                        textRole: "name"
                        currentIndex: sessionModel.lastIndex !== undefined && sessionModel.lastIndex >= 0
                                      ? sessionModel.lastIndex : 0

                        contentItem: Text {
                            text: "[ " + sessionList.displayText + " ]"
                            color: root.cfgCyan
                            font.family: root.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 4
                        }
                        background: Rectangle { color: "transparent" }
                        indicator: Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            text: "▼"
                            color: root.cfgMagenta
                            font.family: root.fontFamily
                            font.pixelSize: 10
                        }
                    }
                }

                // separator
                Text {
                    text: "─────────────────────────────────────────────────"
                    color: root.cfgDim
                    font.family: root.fontFamily
                    font.pixelSize: 11
                }

                // login button line
                Row {
                    spacing: 18
                    width: parent.width

                    Button {
                        id: loginButton
                        height: 32
                        text: "[ EXEC · login ]"

                        background: Rectangle {
                            color: loginButton.hovered
                                ? root.cfgPhosphor
                                : Qt.rgba(0, 1, 0.61, 0.08)
                            border.color: root.cfgPhosphor
                            border.width: 1
                            radius: 0
                        }
                        contentItem: Text {
                            text: loginButton.text
                            color: loginButton.hovered ? root.cfgVoid : root.cfgPhosphor
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 16
                            rightPadding: 16
                        }
                        onClicked: sddm.login(userList.currentText,
                                              pwField.text,
                                              sessionList.currentIndex)
                    }

                    // reboot
                    Button {
                        height: 32
                        contentItem: Text {
                            text: "[ R ]"
                            color: parent.hovered ? root.cfgVoid : root.cfgCyan
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12; rightPadding: 12
                        }
                        background: Rectangle {
                            color: parent.hovered ? root.cfgCyan : Qt.rgba(0, 0.89, 1, 0.07)
                            border.color: root.cfgCyan
                            border.width: 1
                            radius: 0
                        }
                        onClicked: sddm.reboot()
                    }

                    // shutdown
                    Button {
                        height: 32
                        contentItem: Text {
                            text: "[ ⏻ ]"
                            color: parent.hovered ? root.cfgVoid : root.cfgCrit
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12; rightPadding: 12
                        }
                        background: Rectangle {
                            color: parent.hovered ? root.cfgCrit : Qt.rgba(1, 0, 0.24, 0.08)
                            border.color: root.cfgCrit
                            border.width: 1
                            radius: 0
                        }
                        onClicked: sddm.powerOff()
                    }
                }

                // error line
                Text {
                    id: errorText
                    width: parent.width
                    color: root.cfgCrit
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignLeft
                    text: ""
                    visible: text.length > 0
                }
            }
        }

        // ── shake animation on fail ───────────────────────────
        // Translate the frame via an item translation so centerIn anchors
        // keep working. Always returns to 0 so repeated fails don't drift.
        SequentialAnimation {
            id: shakeAnim
            PropertyAnimation { target: shakeT; property: "x"; to: -10; duration: 45; easing.type: Easing.OutQuad }
            PropertyAnimation { target: shakeT; property: "x"; to:  10; duration: 45; easing.type: Easing.OutQuad }
            PropertyAnimation { target: shakeT; property: "x"; to:  -7; duration: 45; easing.type: Easing.OutQuad }
            PropertyAnimation { target: shakeT; property: "x"; to:   7; duration: 45; easing.type: Easing.OutQuad }
            PropertyAnimation { target: shakeT; property: "x"; to:   0; duration: 45; easing.type: Easing.OutQuad }
        }

        // ── BOTTOM HUD STRIP ──────────────────────────────────
        Row {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.bottomMargin: 18
            spacing: 22

            Text {
                text: "╚═ nightwire · build 2.0.0 ·  " + userList.currentText + "@multan"
                color: root.cfgPhosphor
                font.family: root.fontFamily
                font.pixelSize: 11
            }
            Text {
                text: "// hyprland-session · qt6-declarative · phosphor-rev-04"
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

    // ── live clock tick ───────────────────────────────────────
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var d = new Date()
            if (bigClock.visible) {
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

    // ── keyboard shortcut handling (ESC clears, F-keys cycle) ──
    Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                pwField.text = ""
                errorText.text = ""
            } else if (event.key === Qt.Key_F1) {
                sessionList.currentIndex =
                    (sessionList.currentIndex + 1) % sessionModel.rowCount()
            } else if (event.key === Qt.Key_F2) {
                userList.currentIndex =
                    (userList.currentIndex + 1) % userModel.rowCount()
            }
        }
    }

    Component.onCompleted: pwField.forceActiveFocus()
}
