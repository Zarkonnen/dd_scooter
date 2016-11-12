import QtQuick 2.0

Rectangle {
	signal crashScreenTimeout

	color: "black"

	onVisibleChanged: { if (visible) crashTimer.start(); }

	Text {
		anchors.centerIn: parent
		font.pixelSize: screen.sizeUnit
		color: "white"
		text: "Crash animation"
	}
	Timer {
		id: crashTimer
		interval: 1000; running: false; repeat: false;
		onTriggered: parent.crashScreenTimeout()
	}
}
