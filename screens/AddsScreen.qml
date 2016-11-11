import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1

Item {
	id: addsScreen

	property int counter
	property int initialCounter: 10

	signal newGameButtonClicked
	signal continueButtonClicked

	onVisibleChanged: {
		if (visible) {
			var index = Math.floor(Math.random() * adds.length);
			addImage.source = "qrc:/assets/gfx/adds/" + adds[index].img;
			addImage.url = adds[index].url;
			continueButton.enabled = false;
			continueTimer.start();
			counter = initialCounter;
		}
	}

	Timer {
		id: continueTimer
		interval: 1000; running: false; repeat: true;
		onTriggered: {
			addsScreen.counter -= 1;
			if (addsScreen.counter == 0)
				continueButton.enabled = true;
		}
	}

	Rectangle {
		anchors.fill: parent
		color: "#70000000"
	}

	ColumnLayout {
		spacing: 0
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		Image {
			id: addImage
			Layout.alignment: Qt.AlignBottom
			source: ""
			property string url
			Layout.fillWidth: true
			Layout.preferredHeight: width
			MouseArea {
				anchors.fill: parent
				onClicked: Qt.openUrlExternally(parent.url)
			}
		}
		Item {
			Layout.alignment: Qt.AlignTop
			Layout.preferredHeight: screen.sizeUnit * 0.2
			Layout.fillWidth: true
			Rectangle {
				width: parent.width * addsScreen.counter / addsScreen.initialCounter;
				height: parent.height
				color: "white"
			}
		}
		Text {
			id: continueButton
			Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
			Layout.margins: screen.sizeUnit * 0.1
			Layout.topMargin: screen.sizeUnit * 0.2
			font.pixelSize: screen.sizeUnit * 0.5
			text: "Continue"
			color: enabled ? "white" : "gray"
			MouseArea {
				anchors.fill: parent
				onClicked: {
					addsScreen.continueButtonClicked();
				}
			}
		}
		Text {
			Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
			Layout.margins: screen.sizeUnit * 0.1
			font.pixelSize: screen.sizeUnit * 0.5
			text: "New Game"
			color: "white"
			MouseArea {
				anchors.fill: parent
				onClicked: {
					addsScreen.newGameButtonClicked();
				}
			}
		}
	}
}
