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
		{ img: "ethgtc.png", url: "http://gtc.ethz.ch" },
		{ img: "helleluja.jpg", url: "http://oniroforge.ch/hell-eluja" }
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
				source: "assets/gfx/road/road" + Math.floor(Math.random() * 3) + ".png"
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


			Repeater {
				model: 4
				Emitter {
					group: "pothole" + index
					width: parent.width - screen.sizeUnit * 2
					anchors.left: parent.left
					anchors.leftMargin: screen.sizeUnit
					height: screen.sizeUnit*3
					anchors.bottom: parent.top
					anchors.bottomMargin: height
					startTime: 0

					maximumEmitted: 20
					emitRate: 0.5
					lifeSpan: (screen.height + 2*height) * 1000 / (70*particleSystem.speedUnit)

					velocity: PointDirection{ y: 70*particleSystem.speedUnit; }
					acceleration: PointDirection{ }

					size: screen.sizeUnit * 0.5
				}
			}

			Emitter {
				group: "car"

				width: parent.width
				height: screen.sizeUnit*3
				anchors.bottom: parent.bottom
				anchors.bottomMargin: -(height + size)
				startTime: 2000

				maximumEmitted: 50
				emitRate: 1. + game.score * 0.02
				lifeSpan: Emitter.InfiniteLife

				velocity: PointDirection{ y: -40*particleSystem.speedUnit; xVariation: 2*particleSystem.speedUnit; yVariation: 30*particleSystem.speedUnit }
				acceleration: PointDirection{ y: -10*particleSystem.speedUnit; xVariation: particleSystem.speedUnit; yVariation: 3*particleSystem.speedUnit }

				size: screen.sizeUnit
			}

			Emitter {
				group: "tuktuk"

				width: parent.width
				height: screen.sizeUnit*3
				anchors.bottom: parent.bottom
				anchors.bottomMargin: -(height + size)
				startTime: 2000

				maximumEmitted: 50
				emitRate: 1. + game.score * 0.02
				lifeSpan: Emitter.InfiniteLife

				velocity: PointDirection{ y: -10*particleSystem.speedUnit; xVariation: 2*particleSystem.speedUnit; yVariation: 7*particleSystem.speedUnit }
				acceleration: PointDirection{ y: -3*particleSystem.speedUnit; xVariation: 1.5*particleSystem.speedUnit; yVariation: 1*particleSystem.speedUnit }

				size: screen.sizeUnit * 0.7
			}

            Emitter {
                group: "scooter"

                width: parent.width
                height: screen.sizeUnit*3
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -(height + size)
                startTime: 2000

                maximumEmitted: 50
                emitRate: 1. + game.score * 0.02
                lifeSpan: Emitter.InfiniteLife

                velocity: PointDirection{ y: -20*particleSystem.speedUnit; xVariation: 2*particleSystem.speedUnit; yVariation: 7*particleSystem.speedUnit }
                acceleration: PointDirection{ y: -5*particleSystem.speedUnit; xVariation: 1.5*particleSystem.speedUnit; yVariation: 1*particleSystem.speedUnit }

                size: screen.sizeUnit * 0.5
            }

			Wander {
                groups: ["car", "tuktuk", "scooter"]
				xVariance: particleSystem.speedUnit * 10
				pace: particleSystem.speedUnit * 10
				affectedParameter: Wander.Acceleration
			}

			Affector {
                groups: ["car", "tuktuk", "scooter"]
				onAffectParticles: {
					// collision detection
					//console.log(particles.length);
					for (var i=0; i<particles.length; i++) {
						// other cars
						var thisCar = particles[i];
						//console.log(thisCar.startSize);
						for (var j=0; j<i; j++) {
							var thatCar = particles[j];
							if (Math.abs(thisCar.x - thatCar.x) < (thisCar.startSize*0.3 + thatCar.startSize*0.3) &&
								Math.abs(thisCar.y - thatCar.y) < (thisCar.startSize*0.7 + thatCar.startSize*0.7)) {
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
							Math.abs(thisCar.x - scooter.x) < (thisCar.startSize*0.25 + screen.sizeUnit *0.125) &&
							Math.abs(thisCar.y - scooter.y) < (thisCar.startSize*0.5 + screen.sizeUnit *0.25)) {
							console.log("Collision");
							game.crashScooter();
							return;
						}
					}
					// bound velocity and kill old particles
					for (var i=0; i<particles.length; i++) {
						var car = particles[i];
						var thisCarMaxSpeed = particleSystem.maxCarSpeed * car.startSize / 50.;
						if (car.y < -screen.sizeUnit * 0.5) {
							car.lifeSpan = 0;
						} else if (car.vy < -thisCarMaxSpeed) {
							car.vy = -thisCarMaxSpeed;
							car.update = true;
						}
					}
				}
			}

			Repeater {
				model: 4
				ImageParticle {
					groups: ["pothole" + index]
					source: "assets/gfx/obstacles/pothole" + index + ".png"
					entryEffect: ImageParticle.None
				}
			}

			ImageParticle {
				groups: ["car"]
				source: "assets/gfx/vehicles/car.png"
				colorVariation: 1.0
				entryEffect: ImageParticle.None
			}

			ImageParticle {
				groups: ["tuktuk"]
				source: "assets/gfx/vehicles/tuktuk.png"
				colorVariation: 0.1
				entryEffect: ImageParticle.None
			}

            ImageParticle {
                groups: ["scooter"]
                source: "assets/gfx/vehicles/scooter.png"
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
				source: "assets/gfx/vehicles/scooter-colored.png"
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
			color: "white"
			visible: game.state === "splash"
			MouseArea {
				anchors.fill: parent
				onClicked: game.startPlaying()
			}
		}

		// crash animation screen
		CrashScreen {
			anchors.fill: parent
			visible: game.state === "crash"

			onCrashScreenTimeout: {
				if (game.fruitCount <= 0) {
					game.state = "adds";
				} else {
					game.startPlaying();
				}
			}
		}

		// adds screen
		AddsScreen {
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
