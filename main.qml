import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Particles 2.0
import QtQuick.Layouts 1.1

Window {
	id: screen
	visible: true
	width: 480
	height: 720
	contentOrientation: Qt.PortraitOrientation
	title: qsTr("DareDevil Scooter")

	property int initialFruitCount: 2
	property int fruitCount: initialFruitCount
	property int score: 0

	property real scooterX: width/2

	property real sizeUnit: width / 6
	property real sceneMargin: sizeUnit*0.5

	Item
	{
		id: game
		anchors.fill: parent

		state: "splash"

		property bool playing: state === "playing"

		function crash() {
			state = "crash";
			fruitCount -= 1;
		}

		function startPlaying() {
			particleSystem.reset();
			state = "playing";
		}


		Repeater {
			model: (Math.ceil(screen.height / screen.width) | 0) + 1
			Image {
				source: "content/gfx/road.png"
				width: screen.width
				height: width
				y: startY
				property real startY: index * width - width

				SequentialAnimation on y {
					loops: Animation.Infinite
					PropertyAnimation {
						to: startY + width
						duration: 1000
					}
				}
			}
		}

		ParticleSystem {
			id: particleSystem
			anchors.fill: parent

			property real speedUnit: screen.height / 300
			property real maxCarSpeed: sizeUnit * 70

			Emitter {
				id: emitter
				group: "car"

				width: parent.width
				height: screen.sizeUnit*3
				anchors.bottom: parent.bottom
				anchors.bottomMargin: -4*screen.sizeUnit
				startTime: 2000

				maximumEmitted: 100
				emitRate: 2.+score * 0.02
				lifeSpan: Emitter.InfiniteLife

				velocity: PointDirection{ y: -40*particleSystem.speedUnit; xVariation: 2*particleSystem.speedUnit; yVariation: 30*particleSystem.speedUnit }
				acceleration: PointDirection{ y: -10*particleSystem.speedUnit; xVariation: particleSystem.speedUnit; yVariation: 3*particleSystem.speedUnit }

				size: screen.sizeUnit
			}

			Wander {
				groups: ["car"]
				xVariance: particleSystem.speedUnit * 10
				pace: particleSystem.speedUnit * 10
				affectedParameter: Wander.Acceleration
			}

			Affector {
				groups: ["car"]
				enabled: game.playing
				onAffectParticles: {
					// collision detection
					for (var i=0; i<particles.length; i++) {
						// other cars
						var thisCar = particles[i];
						for (var j=0; j<i; j++) {
							var thatCar = particles[j];
							if (Math.abs(thisCar.x - thatCar.x) < screen.sizeUnit * 0.5 &&
								Math.abs(thisCar.y - thatCar.y) < screen.sizeUnit * 1.3) {
								// we have a collision, find which car is front/back
								var frontCar = null;
								var backCar = null;
								//console.log("collision " + i + " with " + j + ": " + thisCar.y + " " + thatCar.y);
								if (thisCar.y < thatCar.y) {
									frontCar = thisCar;
									backCar = thatCar;
								} else {
									frontCar = thatCar;
									backCar = thisCar;
								}
								// slow down back car
								backCar.vy *= 0.9;
								backCar.vx = 0;
								backCar.ax = 0;
								backCar.update = true;
								frontCar.vy *= 1.05; //2 * particleSystem.speedUnit;
								frontCar.update = true;
							}
						}
						// scooter
						if (Math.abs(thisCar.x - scooter.x) < screen.sizeUnit * (0.25+0.125) &&
							Math.abs(thisCar.y - scooter.y) < screen.sizeUnit * (0.5+0.25)) {
							console.log("Collision");
							game.crash();
							return;
						}
					}
					// bound velocity
					for (var i=0; i<particles.length; i++) {
						var car = particles[i];
						if (car.y < -screen.sizeUnit * 0.5) {
							car.lifeSpan = 0;
						} else if (car.vy < -particleSystem.maxCarSpeed) {
							car.vy = -particleSystem.maxCarSpeed;
							car.update = true;
						}
					}
				}
			}

			ImageParticle {
				groups: ["car"]
				source: "content/gfx/car.png"
				colorVariation: 1.0
				entryEffect: ImageParticle.None
			}
		}

		Item {
			id: scooter
			x: scooterX
			y: (parent.height - height) / 3
			visible: parent.playing
			Image {
				source: "content/gfx/bike.png"
				x: -width/2
				y: -height/2
				width: screen.sizeUnit/2
				height: screen.sizeUnit/2
			}
		}

		Text {
			anchors.left: parent.left
			anchors.leftMargin: screen.sizeUnit * 0.5
			anchors.top: parent.top
			anchors.topMargin: screen.sizeUnit * 0.5
			text: score
			font.pixelSize: screen.sizeUnit * 0.5
			visible: parent.playing
		}

		Text {
			anchors.right: parent.right
			anchors.rightMargin: screen.sizeUnit * 0.5
			anchors.top: parent.top
			anchors.topMargin: screen.sizeUnit * 0.5
			text: fruitCount
			font.pixelSize: screen.sizeUnit * 0.5
			color: "yellow"
			visible: parent.playing
		}

		// splash screen

		Text {
			anchors.centerIn: parent
			font.pixelSize: screen.sizeUnit
			text: "New game"
			visible: game.state === "splash"
			MouseArea {
				anchors.fill: parent
				onClicked: game.startPlaying()
			}
		}

		// crash animation screen

		Text {
			anchors.centerIn: parent
			font.pixelSize: screen.sizeUnit
			text: "Crash animation"
			visible: game.state === "crash"
			onVisibleChanged: { if (visible) crashTimer.start(); }

			Timer {
				id: crashTimer
				interval: 1000; running: false; repeat: false;
				onTriggered: {
					if (fruitCount <= 0) {
						game.state = "adds";
					} else {
						game.startPlaying();
					}
				}
			}
		}

		// adds screen

		Item {
			id: addsScreen
			anchors.fill: parent
			visible: game.state === "adds"
			property int counter
			property int initialCounter: 10

			onVisibleChanged: {
				if (visible) {
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
				color: "#d0000000"
			}

			ColumnLayout {
				spacing: 0
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				Image {
					Layout.alignment: Qt.AlignBottom
					source: "content/gfx/adds/oniri.jpg"
					Layout.fillWidth: true
					Layout.preferredHeight: width
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
							fruitCount += 1;
							game.startPlaying();
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
							score = 0;
							fruitCount = initialFruitCount;
							game.startPlaying();
						}
					}
				}
			}
		}

		MouseArea {
			enabled: parent.playing
			anchors.fill: parent
			onMouseXChanged: {
				scooterX = Math.max(sceneMargin, Math.min(mouse.x, screen.width - sceneMargin))
			}
			onReleased: {
				game.crash();
			}
		}

		Timer {
			interval: 1000; running: true; repeat: true
			onTriggered: score += 1
		}

		states: [
			State {
				name: "splash"
			},
			State {
				name: "playing"
			},
			State {
				name: "crash"
			},
			State {
				name: "adds"
			}
		]

	}
}
