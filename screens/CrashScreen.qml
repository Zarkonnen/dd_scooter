import QtQuick 2.0
import QtQuick.Particles 2.0

Rectangle {
	id: crashScreen

	signal shown
	signal crashScreenTimeout

	property int screenDuration: 1500

	color: "black"

	onVisibleChanged: {
		if (visible) {
			crashTimer.start();
			shown();
		}
	}

	property var foods: ["curry.png", "dabba-top.png", "rice.png", "roti.png"]

	ParticleSystem {
		anchors.fill: parent

		Repeater {
			model: 4
			Emitter {
				id: crashContentEmitter
				anchors.centerIn: parent
				width: screen.sizeUnit
				height: width

				group: foods[index]

				emitRate: 0
				lifeSpan: screenDuration

				velocity: AngleDirection { angleVariation: 180; magnitude: screen.sizeUnit*2; magnitudeVariation: screen.sizeUnit; }

				size: screen.sizeUnit

				Connections {
					target: crashScreen
					onShown: {
						crashContentEmitter.burst(4);
					}
				}
			}
		}

		Friction {
			factor: 0.98
		}

		Repeater {
			model: 4
			ImageParticle {
				groups: [ foods[index] ]
				source: "qrc:/assets/gfx/crash/" + foods[index]
				entryEffect: ImageParticle.None
			}
		}
	}

	Text {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: screen.sizeUnit
		font.pixelSize: screen.sizeUnit
		color: "white"
		text: "Crash"
	}

	Timer {
		id: crashTimer
		interval: screenDuration; running: false; repeat: false;
		onTriggered: parent.crashScreenTimeout()
	}
}
