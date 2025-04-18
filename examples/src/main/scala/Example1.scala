import fs2.Stream
import fs2.backpressuresensor.syntax.*

import cats.effect.{IO, IOApp}
import scala.concurrent.duration.*
import fs2.backpressuresensor.Reporter

object Example1 extends ExampleApp:
  val stream = s =>
    s.backpressureSensor(reporter("pre_pipe1"))
      .through(controlledPipe("pipe1"))
      .backpressureSensor(reporter("post_pipe1"))
      .through(controlledPipe("pipe2"))
      .backpressureSensor(reporter("post_pipe2"))
