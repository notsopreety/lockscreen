import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import Quickshell.Services.UPower
import Quickshell.Bluetooth
import Quickshell.Services.Mpris
import Quickshell.Io

Rectangle {
	id: root
	required property LockContext context
	readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive

	// Semi-transparent background
	color: "transparent"

	// Wallpaper image
	Image {
		id: wallpaper
		anchors.fill: parent
		source: "/home/sawmer/.cache/awww-wal/wall.jpg"
		fillMode: Image.PreserveAspectCrop
		visible: false
	}

	// Blur effect on wallpaper
	FastBlur {
		anchors.fill: parent
		source: wallpaperSource
		radius: 30
	}

	// Source for blur
	ShaderEffectSource {
		id: wallpaperSource
		sourceItem: wallpaper
		visible: false
	}

	// Semi-transparent overlay for readability
	Rectangle {
		anchors.fill: parent
		color: Qt.rgba(0, 0, 0, 0.3)
	}


	ColumnLayout {
		id: clockContainer
		property var date: new Date()

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: 120
		}

		// ============================================
		// CLOCK CONFIGURATION - Customize these values
		// ============================================
		// Global settings
		property string clockFontFamily: "Anurati"
		property int containerSpacing: 12

		// Day settings
		property int dayFontSize: 56
		property double dayOpacity: 1.0
		property int dayLetterSpacing: 20
		property int dayTopMargin: 0

		// Date settings
		property int dateFontSize: 20
		property double dateOpacity: 0.9
		property int dateLetterSpacing: 5
		property int dateTopMargin: 8

		// Time settings
		property int timeFontSize: 16
		property double timeOpacity: 0.8
		property int timeLetterSpacing: 5
		property int timeTopMargin: 12
		// ============================================

		spacing: containerSpacing

		// updates the clock every second
		Timer {
			running: true
			repeat: true
			interval: 1000
			onTriggered: clockContainer.date = new Date();
		}

		// Day name - Large futuristic style
		Label {
			renderType: Text.NativeRendering
			font.pointSize: clockContainer.dayFontSize
			font.family: clockContainer.clockFontFamily
			font.weight: Font.Bold
			font.letterSpacing: clockContainer.dayLetterSpacing
			color: "#ffffff"
			Layout.alignment: Qt.AlignHCenter
			Layout.topMargin: clockContainer.dayTopMargin
			opacity: clockContainer.dayOpacity
			style: Text.Outline
			styleColor: Qt.rgba(0, 0, 0, 0.3)

			text: {
				const days = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
				return days[clockContainer.date.getDay()];
			}
		}

		// Date - Medium size
		Label {
			renderType: Text.NativeRendering
			font.pointSize: clockContainer.dateFontSize
			font.family: clockContainer.clockFontFamily
			font.weight: Font.Normal
			font.letterSpacing: clockContainer.dateLetterSpacing
			color: "#ffffff"
			Layout.alignment: Qt.AlignHCenter
			Layout.topMargin: clockContainer.dateTopMargin
			opacity: clockContainer.dateOpacity

			text: {
				const months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 
								'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
				const month = months[clockContainer.date.getMonth()];
				const day = clockContainer.date.getDate();
				const year = clockContainer.date.getFullYear();
				return `${month} ${day}, ${year}`;
			}
		}

		// Time - Small with decorative dashes
		Label {
			renderType: Text.NativeRendering
			font.pointSize: clockContainer.timeFontSize
			font.family: clockContainer.clockFontFamily
			font.weight: Font.Normal
			font.letterSpacing: clockContainer.timeLetterSpacing
			color: "#ffffff"
			Layout.alignment: Qt.AlignHCenter
			Layout.topMargin: clockContainer.timeTopMargin
			opacity: clockContainer.timeOpacity

			text: {
				let hours = clockContainer.date.getHours();
				const minutes = clockContainer.date.getMinutes().toString().padStart(2, '0');
				const ampm = hours >= 12 ? 'PM' : 'AM';
				hours = hours % 12;
				hours = hours ? hours : 12;
				return `- ${hours}:${minutes} ${ampm} -`;
			}
		}
	}

	// ============================================
	// STATUS BAR - Top of screen
	// ============================================
	Row {
		id: statusBar
		anchors {
			top: parent.top
			topMargin: 20
			horizontalCenter: parent.horizontalCenter
		}
		spacing: 12

		// Battery
		Rectangle {
			id: batteryPill
			property var battery: UPower.displayDevice
			property bool hasBattery: battery && battery.ready
			property int pct: hasBattery ? Math.round(battery.percentage * 100) : 0
			property bool charging: hasBattery && (
				battery.state === UPowerDeviceState.Charging ||
				battery.state === UPowerDeviceState.FullyCharged
			)

			width: battMouseArea.containsMouse ? (batteryLabel.implicitWidth + 24) : 44
			height: 36
			radius: 12
			color: Qt.rgba(0.1, 0.1, 0.12, 0.8)
			border.color: Qt.rgba(1, 1, 1, 0.1)
			border.width: 1
			clip: true

			Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

			Label {
				id: batteryLabel
				anchors.centerIn: parent
				font.family: "JetBrainsMono Nerd Font"
				font.pointSize: 12
				color: "#ffffff"
				text: {
					if (!batteryPill.hasBattery) return "󰚥"
					var sym = ""
					if (batteryPill.charging) {
						if (batteryPill.pct >= 90) sym = "󰂅"
						else if (batteryPill.pct >= 80) sym = "󰂋"
						else if (batteryPill.pct >= 70) sym = "󰂊"
						else if (batteryPill.pct >= 60) sym = "󰢞"
						else if (batteryPill.pct >= 50) sym = "󰂉"
						else if (batteryPill.pct >= 40) sym = "󰢝"
						else if (batteryPill.pct >= 30) sym = "󰂈"
						else if (batteryPill.pct >= 20) sym = "󰂇"
						else if (batteryPill.pct >= 10) sym = "󰂆"
						else sym = "󰢜"
					} else {
						if (batteryPill.pct >= 90) sym = "󰁹"
						else if (batteryPill.pct >= 80) sym = "󰂂"
						else if (batteryPill.pct >= 70) sym = "󰂁"
						else if (batteryPill.pct >= 60) sym = "󰂀"
						else if (batteryPill.pct >= 50) sym = "󰁿"
						else if (batteryPill.pct >= 40) sym = "󰁾"
						else if (batteryPill.pct >= 30) sym = "󰁽"
						else if (batteryPill.pct >= 20) sym = "󰁼"
						else if (batteryPill.pct >= 10) sym = "󰁻"
						else sym = "󰁺"
					}

					if (battMouseArea.containsMouse) {
						var status = batteryPill.charging ? " Charging" : ""
						return sym + " " + batteryPill.pct + "%" + status
					}
					return sym
				}
			}

			MouseArea {
				id: battMouseArea
				anchors.fill: parent
				hoverEnabled: true
			}
		}

		// WiFi
		Rectangle {
			id: wifiPill
			width: wifiMouseArea.containsMouse ? (wifiLabel.implicitWidth + 24) : 44
			height: 36
			radius: 12
			color: Qt.rgba(0.1, 0.1, 0.12, 0.8)
			border.color: Qt.rgba(1, 1, 1, 0.1)
			border.width: 1
			clip: true

			Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

			property bool wifiEnabled: true
			property string wifiSSID: ""
			property int wifiSignal: 0
			property bool wifiConnected: false
			property string connectivity: "none"

			Label {
				id: wifiLabel
				anchors.centerIn: parent
				font.family: "JetBrainsMono Nerd Font"
				font.pointSize: 12
				color: "#ffffff"

				text: {
					var icon = ""
					if (!wifiPill.wifiEnabled) icon = "󰤭"
					else if (!wifiPill.wifiConnected) icon = "󰤯"
					else {
						var signal = wifiPill.wifiSignal
						if (wifiPill.connectivity === "full" || wifiPill.connectivity === "unknown") {
							if (signal >= 80) icon = "󰤨"
							else if (signal >= 60) icon = "󰤥"
							else if (signal >= 40) icon = "󰤢"
							else if (signal >= 20) icon = "󰤟"
							else icon = "󰤯"
						} else {
							icon = "󰤫"
						}
					}

					if (wifiMouseArea.containsMouse) {
						if (!wifiPill.wifiEnabled) return icon + " WiFi Off"
						if (!wifiPill.wifiConnected) return icon + " Disconnected"
						return icon + " " + (wifiPill.wifiSSID || "Connected")
					}
					return icon
				}
			}

			MouseArea {
				id: wifiMouseArea
				anchors.fill: parent
				hoverEnabled: true
			}

			Timer {
				interval: 3000
				running: true
				repeat: true
				onTriggered: {
					wifiCheckProc.running = true
					connectivityProc.running = true
				}
			}

			Process {
				id: wifiCheckProc
				command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"]
				running: false
				stdout: SplitParser {
					onRead: function(line) {
						var parts = line.trim().split(":")
						if (parts.length >= 3 && parts[0] === "yes") {
							wifiPill.wifiConnected = true
							wifiPill.wifiSSID = parts[1]
							wifiPill.wifiSignal = parseInt(parts[2]) || 0
						}
					}
				}
				onRunningChanged: {
					if (running) {
						wifiPill.wifiConnected = false
						wifiPill.wifiSSID = ""
					}
				}
			}

			Process {
				id: connectivityProc
				command: ["nmcli", "-t", "networking", "connectivity"]
				running: false
				stdout: SplitParser {
					onRead: line => wifiPill.connectivity = line.trim()
				}
			}

			Timer {
				interval: 10000
				running: true
				repeat: true
				onTriggered: wifiRadioProc.running = true
			}

			Process {
				id: wifiRadioProc
				command: ["nmcli", "radio", "wifi"]
				running: false
				stdout: SplitParser {
					onRead: line => wifiPill.wifiEnabled = line.trim() === "enabled"
				}
			}

			Component.onCompleted: {
				wifiCheckProc.running = true
				wifiRadioProc.running = true
				connectivityProc.running = true
			}
		}

		// Bluetooth
		Rectangle {
			id: bluetoothPill
			property var adapter: Bluetooth.defaultAdapter
			property var connectedDevices: Bluetooth.devices

			width: btMouseArea.containsMouse ? (btLabel.implicitWidth + 24) : 44
			height: 36
			radius: 12
			color: Qt.rgba(0.1, 0.1, 0.12, 0.8)
			border.color: Qt.rgba(1, 1, 1, 0.1)
			border.width: 1
			clip: true

			Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

			Label {
				id: btLabel
				anchors.centerIn: parent
				font.family: "JetBrainsMono Nerd Font"
				font.pointSize: 12
				color: "#ffffff"
				text: {
					var icon = ""
					var name = ""
					if (!bluetoothPill.adapter || !bluetoothPill.adapter.enabled) {
						icon = "󰂲"
						name = "Bluetooth Off"
					} else {
						var connected = bluetoothPill.connectedDevices.values.filter(d => d.state === BluetoothDeviceState.Connected)
						if (connected.length > 0) {
							icon = "󰂱"
							name = connected[0].name
						} else {
							icon = "󰂯"
							name = "Disconnected"
						}
					}

					if (btMouseArea.containsMouse) return icon + " " + name
					return icon
				}
			}

			MouseArea {
				id: btMouseArea
				anchors.fill: parent
				hoverEnabled: true
			}
		}
	}

	// ============================================
	// MEDIA PLAYER - Dynamic Island Style
	// ============================================
	property string lastPlayerDbusName: ""
	readonly property var activePlayer: {
		const players = Mpris.players.values;
		if (players.length === 0) return null;
		
		// 1. Prioritize currently playing
		let p = players.find(p => p.playbackState === MprisPlaybackState.Playing);
		if (p) return p;
		
		// 2. Fallback to the last active player if it's paused
		if (lastPlayerDbusName !== "") {
			p = players.find(p => p.dbusName === lastPlayerDbusName);
			if (p && p.playbackState === MprisPlaybackState.Paused) return p;
		}
		
		// 3. Fallback to any paused player
		p = players.find(p => p.playbackState === MprisPlaybackState.Paused);
		if (p) return p;
		
		// 4. Default to first available
		return players[0];
	}

	onActivePlayerChanged: {
		if (activePlayer && activePlayer.dbusName) {
			lastPlayerDbusName = activePlayer.dbusName;
		}
	}

	property real trackProgress: 0
	property string timePlayed: "0:00"
	property string timeTotal: "0:00"
	property real totalLengthRaw: 0

	Timer {
		id: mprisPoller
		interval: 500
		running: !!activePlayer
		repeat: true
		onTriggered: {
			positionProc.running = true
		}
	}

	Process {
		id: positionProc
		command: ["playerctl", "metadata", "--format", "{{duration(position)}}|{{duration(mpris:length)}}|{{position}}|{{mpris:length}}"]
		running: false
		stdout: SplitParser {
			onRead: function(line) {
				var parts = line.split("|")
				if (parts.length >= 4) {
					root.timePlayed = parts[0] || "0:00"
					root.timeTotal = parts[1] || "0:00"
					let pos = parseFloat(parts[2]) || 0
					let len = parseFloat(parts[3]) || 0
					root.totalLengthRaw = len
					if (len > 0) root.trackProgress = pos / len
					else root.trackProgress = 0
				}
			}
		}
	}

	Process {
		id: seekProc
		property real targetPos: 0
		command: ["playerctl", "position", targetPos.toString()]
		running: false
	}

	// Power Commands
	Process { id: shutdownProc; command: ["systemctl", "poweroff"]; running: false }
	Process { id: rebootProc; command: ["systemctl", "reboot"]; running: false }
	Process { id: logoutProc; command: ["hyprctl", "dispatch", "exit"]; running: false }
	Process { id: sleepProc; command: ["sh", "-c", "loginctl lock-session && systemctl suspend"]; running: false }

	Rectangle {
		id: mediaPlayer
		property bool isActive: {
			if (!activePlayer) return false;
			const state = activePlayer.playbackState;
			return state === MprisPlaybackState.Playing || state === MprisPlaybackState.Paused;
		}
		property real visualizerPhase: 0

		function visualizerLevel(index) {
			const phase = visualizerPhase + index * 0.78;
			const primary = (Math.sin(phase) + 1) * 0.5;
			const secondary = (Math.sin(phase * 2 + index * 0.95) + 1) * 0.5;
			return 0.22 + primary * 0.42 + secondary * 0.24;
		}

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: clockContainer.bottom
			topMargin: isActive ? 40 : 0
		}

		width: isActive ? 440 : 0
		height: isActive ? 160 : 0
		radius: 32
		color: Qt.rgba(0, 0, 0, 0.6)
		border.color: Qt.rgba(1, 1, 1, 0.1)
		border.width: 1
		opacity: isActive ? 1 : 0
		visible: opacity > 0
		clip: true

		Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
		Behavior on width { NumberAnimation { duration: 450; easing.type: Easing.OutBack } }
		Behavior on height { NumberAnimation { duration: 450; easing.type: Easing.OutBack } }

		Timer {
			interval: 32
			repeat: true
			running: mediaPlayer.isActive && activePlayer.playbackState === MprisPlaybackState.Playing
			onTriggered: {
				mediaPlayer.visualizerPhase += 0.15;
				if (mediaPlayer.visualizerPhase > Math.PI * 2) mediaPlayer.visualizerPhase -= Math.PI * 2;
			}
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: 16
			spacing: 8

			// Top row: Art, Info, Visualizer
			RowLayout {
				Layout.fillWidth: true
				spacing: 16

				Rectangle {
					Layout.preferredWidth: 80
					Layout.preferredHeight: 80
					radius: 8
					color: "#1a1a1a"
					clip: true
					Image {
						anchors.fill: parent
						source: activePlayer ? (activePlayer.trackArtUrl || activePlayer.artUrl || "") : ""
						fillMode: Image.PreserveAspectCrop
						visible: source.toString() !== ""
					}
					Label {
						anchors.centerIn: parent
						font.family: "JetBrainsMono Nerd Font"
						font.pointSize: 28
						color: "#333333"
						text: "󰎇"
						visible: !parent.children[0].visible
					}
				}

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 2
					Label {
						Layout.fillWidth: true
						text: activePlayer ? (activePlayer.trackTitle || activePlayer.title || "No Title") : "No Title"
						color: "white"
						font.pixelSize: 22
						font.weight: Font.Bold
						elide: Text.ElideRight
					}
					Label {
						Layout.fillWidth: true
						text: activePlayer ? (activePlayer.trackArtist || activePlayer.artist || "Unknown Artist") : "Unknown Artist"
						color: "#8e8e93"
						font.pixelSize: 16
						elide: Text.ElideRight
					}
				}

				Row {
					spacing: 4
					Repeater {
						model: 5
						delegate: Rectangle {
							width: 4
							height: activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing
								? 6 + 18 * mediaPlayer.visualizerLevel(index)
								: 8
							radius: 2
							color: "#b56cff"
							anchors.verticalCenter: parent.verticalCenter
							Behavior on height { NumberAnimation { duration: 150 } }
						}
					}
				}
			}

			// Middle row: Timestamps and Progress
			RowLayout {
				Layout.fillWidth: true
				Layout.leftMargin: 4
				Layout.rightMargin: 4
				spacing: 12
				Label {
					text: root.timePlayed
					color: "white"
					font.pixelSize: 13
					Layout.preferredWidth: 36
				}
				Rectangle {
					Layout.fillWidth: true
					Layout.preferredHeight: 12 // Slightly taller for better touch/mouse target
					radius: 6
					color: "transparent"

					// Background track
					Rectangle {
						anchors.centerIn: parent
						width: parent.width
						height: 4
						radius: 2
						color: "#333333"
					}

					// Progress track
					Rectangle {
						anchors.verticalCenter: parent.verticalCenter
						height: 4
						radius: 2
						color: "#ffffff"
						width: parent.width * root.trackProgress

						Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
					}

					MouseArea {
						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						onClicked: (mouse) => {
							if (root.totalLengthRaw > 0) {
								let pct = mouse.x / width
								let seekTo = (pct * root.totalLengthRaw) / 1000000 // playerctl expects seconds
								seekProc.targetPos = seekTo
								seekProc.running = true
							}
						}
					}
				}
				Label {
					text: root.timeTotal
					color: "white"
					font.pixelSize: 14
					Layout.preferredWidth: 40
					horizontalAlignment: Text.AlignRight
				}
			}

			// Bottom row: Controls
			RowLayout {
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
				Layout.topMargin: -15
				Layout.bottomMargin: 4
				spacing: 40
				Label {
					text: "󰼨"
					font.family: "JetBrainsMono Nerd Font"
					font.pixelSize: 26
					color: "white"
					MouseArea { anchors.fill: parent; onClicked: if (activePlayer) activePlayer.previous() }
				}
				Label {
					text: activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
					font.family: "JetBrainsMono Nerd Font"
					font.pixelSize: 34
					color: "white"
					MouseArea { anchors.fill: parent; onClicked: if (activePlayer) activePlayer.togglePlaying() }
				}
				Label {
					text: "󰼧"
					font.family: "JetBrainsMono Nerd Font"
					font.pixelSize: 26
					color: "white"
					MouseArea { anchors.fill: parent; onClicked: if (activePlayer) activePlayer.next() }
				}
			}
		}
	}

	ColumnLayout {
		// Uncommenting this will make the password entry invisible except on the active monitor.
		// visible: Window.active

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: mediaPlayer.bottom
			topMargin: 40
		}

		RowLayout {
			spacing: 10

			TextField {
				id: passwordBox

				implicitWidth: 400
				padding: 15

				focus: true
				enabled: !root.context.unlockInProgress
				echoMode: showPassword.checked ? TextInput.Normal : TextInput.Password
				inputMethodHints: Qt.ImhSensitiveData

				placeholderText: "Enter Password"
				placeholderTextColor: Qt.rgba(1, 1, 1, 0.3)

				// Glassmorphism styling
				background: Rectangle {
					color: Qt.rgba(0.1, 0.1, 0.12, 0.8)
					border.color: Qt.rgba(1, 1, 1, 0.1)
					border.width: 1
					radius: 12
				}
				
				color: "#ffffff"
				font.family: "sans-serif"
				selectByMouse: true

				// Update the text in the context when the text in the box changes.
				onTextChanged: root.context.currentText = this.text;

				// Try to unlock when enter is pressed.
				onAccepted: root.context.tryUnlock();

				// Eye icon toggle
				Label {
					id: eyeIcon
					anchors.right: parent.right
					anchors.rightMargin: 15
					anchors.verticalCenter: parent.verticalCenter
					font.family: "JetBrainsMono Nerd Font"
					font.pointSize: 14
					color: showPassword.containsMouse ? "#ffffff" : "#888888"
					text: showPassword.checked ? "󰈈" : "󰈉"
					
					MouseArea {
						id: showPassword
						anchors.fill: parent
						hoverEnabled: true
						property bool checked: false
						onClicked: checked = !checked
					}
				}

				// Update the text in the box to match the text in the context.
				// This makes sure multiple monitors have the same text.
				Connections {
					target: root.context

					function onCurrentTextChanged() {
						passwordBox.text = root.context.currentText;
					}
				}
			}

			Button {
				id: unlockButton
				implicitWidth: 54
				implicitHeight: 54
				
				// don't steal focus from the text box
				focusPolicy: Qt.NoFocus

				enabled: !root.context.unlockInProgress && root.context.currentText !== "";
				onClicked: root.context.tryUnlock();

				// Glassmorphism styling
				background: Rectangle {
					color: unlockButton.enabled ? (unlockButton.hovered ? Qt.rgba(0.4, 0.4, 0.6, 0.7) : Qt.rgba(0.3, 0.3, 0.5, 0.6)) : Qt.rgba(0.2, 0.2, 0.3, 0.3)
					border.color: unlockButton.hovered ? Qt.rgba(0.8, 0.8, 1.0, 0.6) : Qt.rgba(0.6, 0.6, 0.8, 0.4)
					border.width: 1.5
					radius: 10
					
					Behavior on color { ColorAnimation { duration: 200 } }
					Behavior on border.color { ColorAnimation { duration: 200 } }
				}
				
				contentItem: Text {
					text: (unlockButton.hovered && root.context.currentText !== "") ? "󰌿" : "󰌾"
					color: unlockButton.enabled ? "#ffffff" : "#aaaaaa"
					font.family: "JetBrainsMono Nerd Font"
					font.pointSize: 20
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					
					Behavior on text { 
						SequentialAnimation {
							NumberAnimation { target: unlockButton.contentItem; property: "opacity"; to: 0; duration: 50 }
							PropertyAction { target: unlockButton.contentItem; property: "text" }
							NumberAnimation { target: unlockButton.contentItem; property: "opacity"; to: 1; duration: 50 }
						}
					}
				}
			}
		}

		Label {
			visible: root.context.showFailure
			text: "Incorrect password"
			color: "#ff6b6b"
			font.family: "sans-serif"
			font.pointSize: 12
		}
	}

	// Power Options Row
	Row {
		anchors {
			bottom: parent.bottom
			bottomMargin: 40
			horizontalCenter: parent.horizontalCenter
		}
		spacing: 24

		Repeater {
			model: [
				{ icon: "󰒲", proc: sleepProc, color: "#81a1c1" },
				{ icon: "󰜉", proc: rebootProc, color: "#ebcb8b" },
				{ icon: "󰐥", proc: shutdownProc, color: "#bf616a" },
				{ icon: "󰍃", proc: logoutProc, color: "#a3be8c" }
			]

			delegate: Rectangle {
				width: 48
				height: 48
				radius: 12
				color: powerMouse.containsMouse ? Qt.rgba(0.2, 0.2, 0.25, 0.8) : Qt.rgba(0.1, 0.1, 0.12, 0.7)
				border.color: powerMouse.containsMouse ? modelData.color : Qt.rgba(1, 1, 1, 0.1)
				border.width: 1.5

				Behavior on color { ColorAnimation { duration: 200 } }
				Behavior on border.color { ColorAnimation { duration: 200 } }

				Label {
					anchors.centerIn: parent
					text: modelData.icon
					font.family: "JetBrainsMono Nerd Font"
					font.pointSize: 18
					color: powerMouse.containsMouse ? modelData.color : "#ffffff"
					Behavior on color { ColorAnimation { duration: 200 } }
				}

				MouseArea {
					id: powerMouse
					anchors.fill: parent
					hoverEnabled: true
					onClicked: modelData.proc.running = true
				}
			}
		}
	}
}
