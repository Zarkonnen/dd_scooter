import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Particles 2.0
import "screens"

Window {
	id: screen
	visible: true
	width: 480
	height: 720
	contentOrientation: Qt.PortraitOrientation
	title: qsTr("DareDevil Scooter")

	property real sizeUnit: width / 6
	property real sceneMargin: sizeUnit*0.5

	property var adds: [
		{ img: "oniri.jpg", url: "http://tourmaline-studio.com/" },
		{ img: "swissnexindia.png", url: "http://swissnexindia.org" },
		{ img: "thymio.jpg", url: "http://thymio.org" },
		{ img: "airships.jpg", url: "http://store.steampowered.com/app/342560" },
		{ img: "wvrf.jpg", url: "http://worldvrforum.com" },
		{ img: "ecal.jpg", url: "http://www.ecal.ch" },
		{ img: "scribb.jpg", url: "http://www.mylenedreyer.ch" },
		{ img: "ethgtc.png", url: "http://gtc.ethz.ch" }
	]

	Item
	{
		id: game
		anchors.fill: parent

		property int initialFruitCount: 2
		property int fruitCount: initialFruitCount
		property int score: 0

		property real scooterX: width/2

		state: "splash"

		property bool playing: state === "playing"

		function crashScooter() {
			game.fruitCount -= 1;
			game.state = "crash";
		}

		function startPlaying() {
			particleSystem.reset();
			mouseArea.wasKeyPressendInThisGame = false;
			game.state = "playing";
		}


		Repeater {
			id: roadRepeater
			property int screenTileCount: (Math.ceil(screen.height / (screen.width / 4.)) | 0) + 1
			model: screenTileCount
			Image {
				source: "assets/gfx/road/road" + Math.floor(Math.random() * 3) + ".svg"
				width: screen.width
				sourceSize.width: width
				height: width / 4
				sourceSize.height: height
				y: (((index + time) % roadRepeater.screenTileCount) - 1) * height
				property real time: 0

				SequentialAnimation on time {
					loops: Animation.Infinite
					PropertyAnimation {
						to: roadRepeater.screenTileCount
						duration: 5000
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
				emitRate: 2.+game.score * 0.02
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
						if (game.playing &&
							Math.abs(thisCar.x - scooter.x) < screen.sizeUnit * (0.25+0.125) &&
							Math.abs(thisCar.y - scooter.y) < screen.sizeUnit * (0.5+0.25)) {
							console.log("Collision");
							game.crashScooter();
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
				source: "assets/gfx/car.png"
				colorVariation: 1.0
				entryEffect: ImageParticle.None
			}
		}

		Item {
			id: scooter
			x: game.scooterX
			y: (parent.height - height) / 3
			visible: parent.playing
			Image {
				source: "assets/gfx/scooter.png"
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
			text: game.score
			font.pixelSize: screen.sizeUnit * 0.5
			visible: parent.playing
		}

		Text {
			anchors.right: parent.right
			anchors.rightMargin: screen.sizeUnit * 0.5
			anchors.top: parent.top
			anchors.topMargin: screen.sizeUnit * 0.5
			text: game.fruitCount
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
					if (game.fruitCount <= 0) {
						game.state = "adds";
					} else {
						game.startPlaying();
					}
				}
			}
		}

		// adds screen
		AddsScreen {
			id: addsScreen
			anchors.fill: parent
			visible: game.state === "adds"

			onContinueButtonClicked: {
				game.fruitCount += 1;
				game.startPlaying();
			}

			onNewGameButtonClicked: {
				game.score = 0;
				game.fruitCount = game.initialFruitCount;
				game.startPlaying();
			}
		}

		MouseArea {
			id: mouseArea
			enabled: parent.playing
			anchors.fill: parent
			property bool wasKeyPressendInThisGame: false

			onMouseXChanged: {
				game.scooterX = Math.max(sceneMargin, Math.min(mouse.x, screen.width - sceneMargin))
			}
			onPressed: {
				wasKeyPressendInThisGame = true;
			}

			onReleased: {
				if (wasKeyPressendInThisGame && game.playing)
					game.crashScooter();
			}
		}

		Timer {
			interval: 1000; running: true; repeat: true
			onTriggered: game.score += 1
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
