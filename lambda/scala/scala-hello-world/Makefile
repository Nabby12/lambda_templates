SCALA=scala-2.13

build:
	sbt assembly

copy:
	cp ./target/${SCALA}/scala-hello-world-assembly-0.1.0-SNAPSHOT.jar $(ARTIFACTS_DIR)/bootstrap

build-ScalaHelloWorld: build copy
