---
author: Andrea Zito
---

# Measuring bottlenecks in fs2 streams

Because you cannot improve what you cannot measure

---

## What is an fs2 stream? (simplification)

Streams can be thought of as a sequence of stages:
- receive a _pull_ from downstream
- _pulls_ data from upstream
- transform the data
- _push_ the transformed data downstream

```
~~~graph-easy --as=boxart
graph { flow: east; }
[upstream]
[stage]
[downstream]

[downstream] -- pull --> [stage] -- pull --> [upstream]
[upstream] -- push --> {start: south, 1;} [stage]
[stage] -- push --> {start: south, 1;} [downstream]

~~~
```

---

## Processing times

In a naive stream, elements are processed in *single threaded* fashion.

The time it takes to process an element is the sum of the processing time of each stage.

- _stage 1_: 2s
- _stage 2_: 5s
- _stage 3_: 3s
- _total_: sum(2 + 5 + 3) = 10s

---
## Pipelining
By introducing async boundaries (e.g. by using `prefetch`) stages can process data concurrently:
- while stage *n* processes element *x*...
- ... stage *n-1* starts working on element *x+1*

With pipelining the flow time of an element *can* be reduced to the max processing time of any stage.
- _stage 1_: 2s
- _stage 2_: 5s
- _stage 3_: 3s
- _total_: max(2 + 5 + 3) = 5s
---

## What is backpressure?

- a stage can only push when downstream is ready to pull
- if downstream is slow, the stage is forced to wait for it before being able to push
- as a conseguence the stage cannot start processing the next element

```
~~~graph-easy --as=boxart
[upstream]
[stage]
[slow downstream]

[upstream] ->{arrowstyle: none} [stage]{border: broad} -- element: x -->{arrowshape: x} [slow downstream]
~~~
```

---
## Backpressure propagates up

- Since the stage is blocked by downstream it cannot pull from upstream
- As a result upstream is backpressured as well
- This propagates all the way up to the source

```
~~~graph-easy --as=boxart
[upstream]
[stage]
[slow downstream]

[upstream]{border: broad} -- element: x+1 -->{arrowshape: x} [stage]{border: broad} -- element: x -->{arrowshape: x} [slow downstream]
~~~
```
---
## Starvation is the dual of backpressure
- When upstream cannot produce elements quickly enough
- The stage is starving, idling in wait of input to process
- Starvation propagates all the way down to the sink

```
~~~graph-easy --as=boxart
[slow upstream]
[stage]
[downstream]

[slow upstream] -- pull -->{arrowshape: x} [stage]{border: broad} -- pull -->{arrowshape: x} [downstream]{border: broad}
~~~
```

---
## Measuring backpressure

- Inserting a sensor between stages
- We can measure:
  - *Starvation*: time between sensor pulling upstream and upstream pushing
  - *Backpressure*: time between upstream pushing to sensor and stage pulling

```
~~~graph-easy --as=boxart
[upstream]
[sensor]
[stage]
[downstream]

[upstream] --> [sensor]{border: broad} --> [stage] --> [downstream]
~~~
```

---
## Isolating backpressure/starvation contributions of a stream section

- Inserting 2 sensors:
  - Before the first section's stage
  - After the last section's stage

- We can isolate how much the section of stream contributes to the overall backpressure/starvation of the stream:
  - *Backpressure*: backpressure(sensor1) - backpressure(sensor2)
  - *Starvation*: starvation(sensor2) - starvation(sensor1)

```
~~~graph-easy --as=boxart
[upstream]
[sensor1]
[stage1]
[stage2]
[sensor2]
[downstream]

[upstream] --> [sensor1]{border: broad} --> [stage1] --> [stage2] --> [sensor2]{border: broad} --> [downstream]
[sensor1] -->{arrowstyle: none; end: north, 1;} [sensor2]
~~~
```

---
## fs2-backpressure-sensor

Micro library to measure fs2 streams backpressure/starvation: https://github.com/nivox/fs2-backpressure-sensor

- **Plain:** measure backpressure at a specific point in the stream
```scala
stream
  .through(pipe1)
  .backpressureSensor(reporter) 
  .through(pipe2)
```

- **Bracketed:** measure only the backpressure contribution of the wrapped pipe
```scala
stream
  .backpressureBracketSensor(reporter1)(pipe1)
  .backpressureBracketSensor(reporter2)(pipe2) 
```

---
# Demo Time

```
~~~toilet --gay Demo Time

~~~
```

---
# Conclusion
- Tuning streams is fundamental to build highly performant processing pipelines
- Backpressure is a powerful signal to help the tuning process
- Measuring backpressure in fs2 is easy, so...
- ... just do it

Presentation and code can be found at:
https://github.com/nivox/fs2-backpressure-sensor-presentation
