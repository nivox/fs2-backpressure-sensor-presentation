// Targets Scala3 LTS
val scala3Version = "3.3.5"

ThisBuild / resolvers += Resolver.githubPackages("nivox")

lazy val root = project
  .in(file("."))
  .settings(
    name := "fs2-backpressure-sensor-examples",
    scalaVersion := scala3Version,
    
    libraryDependencies ++= Seq(
      "com.github.nivox" %% "fs2-backpressure-sensor" % "0.0.0+3-bc192bc0",
      "org.jline" % "jline" % "3.25.1"
    )
  )
