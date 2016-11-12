import QtQuick 2.0
import QtQuick.Particles 2.0

Rectangle {
	id: crashScreen

	signal shown
	signal crashScreenTimeout

	property int screenDuration: 1500

	property real animationAngle: 0

	property int starCount: 7

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

	Repeater {
		model: crashScreen.starCount
		Item {
			x: crashScreen.width/2 + 2*screen.sizeUnit*Math.cos(crashScreen.animationAngle + index*2*Math.PI/crashScreen.starCount)
			y: crashScreen.height/2 + screen.sizeUnit + 2*screen.sizeUnit*Math.sin(crashScreen.animationAngle + index*2*Math.PI/crashScreen.starCount)
			Image {
				source: "qrc:/assets/gfx/crash/star.png"
				width: screen.sizeUnit
				height: width
				x: -width/2
				y: -height/2
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

	SequentialAnimation on animationAngle {
		loops: Animation.Infinite
		PropertyAnimation { to: 2*Math.PI; duration: 10000 }
	}

	Timer {
		id: crashTimer
		interval: screenDuration; running: false; repeat: false;
		onTriggered: parent.crashScreenTimeout()
	}
}
