globals
[
  num-infected
  infected-size
]

turtles-own
[
  infected?          ;; true if agent has been infected
]


;;;;;;;;;;;;;;;;;;;;;;;
;;; Main Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;

to spread
  ;; or if every agent has already been infected
  if all? turtles [infected?]
    [stop]
  ask turtles with [ infected? = true ]
  [
    ifelse (random-float 1 <= prob-recover) [
      reset-node
    ] [
    ;; infect neighbors
      ask link-neighbors
      [
        if ( random-float 1 <= prob-infection )  ;; infect with probability p
        [
          if not infected?  ;; agents can be infected only once
          [
            set infected? true
             show-turtle
            set color yellow
            set size infected-size

            ;; color the link with the node doing the infection
            ask link-with myself [set color yellow show-link]
            ;; increment the total number of infected agents
          ]
        ]
      ]
    ]
  ]

  do-plotting
  set num-infected count turtles with [infected? = true]
  tick
end

;;layout all nodes and links
to do-layout
  repeat 5 [layout-spring turtles links 0.2 4 0.9]
  display
end



;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to generate-topology
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set infected-size 4
  set-default-shape turtles "outlined circle"
  ;; setup small world topology
  create-turtles num-nodes
  create-lattice
  rewire-network

  setup
end


to setup

  set infected-size 4
  ask turtles
    [reset-node]
  ask links
    [set color gray + 1.5]

  ;; infect a single agent
  ask one-of turtles
  [
    set infected? true
    set color yellow
    set size infected-size
  ]
  set num-infected 1

  ;; Layout turtles:
  layout-circle (sort turtles) max-pxcor - 8
  ;; space out turtles to see clustering
  ask turtles
  [
    facexy 0 0
    if who mod 2 = 0 [fd 4]
  ]
  display
end


to reset-node
    set color gray + 1.5
    set size 3
    set infected? false
end


;; WARNING: the simplified rewiring algorithm does not certain checks (ie disconnected graph)
;; for large networksthis shouldn't be too much of an issue.
to rewire-network
  ask links
  [
    ;; whether to rewire it or not?
    if (random-float 1) < rewiring-probability
    [
      ask end1
      [
        create-link-with one-of other turtles with [not link-neighbor? myself ]
          [set color gray + 1.5]
      ]
      die
    ]
  ]
end


;; creates a new lattice
to create-lattice
  ;; iterate over the nodes
  let n 0
  while [n < count turtles]
  [
    ;; make links with the next two neighbors
    ;; this makes a lattice with average degree of 4
    make-link-between turtle n
              turtle ((n + 1) mod count turtles)
    make-link-between turtle n
              turtle ((n + 2) mod count turtles)
    set n n + 1
  ]
end


;; connects the two nodes
to make-link-between [node1 node2]
  ask node1 [
    create-link-with node2
      [ set color gray + 1.5]
  ]
end


;;;;;;;;;;;;;;;;
;;; Plotting ;;;
;;;;;;;;;;;;;;;;

to do-plotting
     ;; plot the number of infected individuals at each step
     set-current-plot "% infected"
     set-current-plot-pen "inf"

     let percent-inf 100 * (num-infected ) / (count turtles)
     plotxy ticks percent-inf
end
@#$#@#$#@
GRAPHICS-WINDOW
295
10
721
437
-1
-1
2.6
1
10
1
1
1
0
0
0
1
-80
80
-80
80
1
1
1
ticks
30.0

SLIDER
7
122
209
155
num-nodes
num-nodes
100
500
200.0
1
1
NIL
HORIZONTAL

SLIDER
6
158
209
191
rewiring-probability
rewiring-probability
0
1
0.05
0.01
1
NIL
HORIZONTAL

PLOT
6
265
283
459
% infected
time
n
0.0
1.0
0.0
100.0
true
false
"" ""
PENS
"inf" 1.0 0 -2674135 true "" ""

BUTTON
6
47
155
80
reinfect-one
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
6
194
206
227
prob-infection
prob-infection
0
1
0.24
0.01
1
NIL
HORIZONTAL

BUTTON
7
85
123
118
spread once
spread
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
129
85
246
118
spread
spread
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
210
192
292
237
NIL
num-infected
17
1
11

BUTTON
159
47
235
80
layout
do-layout
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
10
245
43
setup a new network
generate-topology
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
6
229
206
262
prob-recover
prob-recover
0
1
0.0
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This is an SIS model on a Watts-Strogatz small world topology. Nodes are either susceptible (S) or infected (I).

## HOW IT WORKS

"This model is an adaptation of a model proposed by Duncan Watts and Steve Strogatz (1998). It begins with a network where each person (or "node") is connected to his or her two neighbors on either side... The REWIRING-PROBABILITY slider determines the probability that an edge will get rewired" (so that one of its endpoints goes to a random node instead of a neighbor).  Clicking the setup button will produce different network configurations, all with the same rewiring probability.

The prob-infection slider determines the probability that an infected individual will infect a susceptible contact at every time step.

The prob-recover slider determines the probability that an infected individual will recover and itself rejoin the susceptible population rather than infecting its neighbors.

## HOW TO USE IT

"The NUM-NODES slider controls the size of the network.  Choose a size and press SETUP.

Changing the REWIRING-PROBABILITY slider changes the fraction of nodes rewired." Press SETUP to generate the new network. SETUP will also infect one node.

Adjust the prob-infection value to determine the infectiousness of the spreading agent.

To re-infect one will infect a single individual while keeping the same topology - press "reinfect-one".

Now to allow the disease to spread, you can advance on time step at a time (each infected node will infect each of its neighbors with probability prob-infection) with the "spread once" button. To let the disease run its full course, you can click the "spread complete" button.

You can also slow down the process using the slower-faster slider at the top of the model interface.

## THINGS TO TRY

Try plotting the values for different rewiring probabilities and observe how long the infection survives in the network, and how far it spreads.

What happens as the probability of recovery increases?
What happens as the probability of infection increases?

Can you find a critical threshold in the infection and recovery probabilities such that for a given rewiring probability, below these threshold values the disease always dies out, and above the threshold value, it tends to persist in the network? In this case you are looking for the conditions under which you will observe epidemics - outbreaks that affect a significant fraction of the network, vs. conditions under which the outbreak remains small and contained.

## RELATED MODELS

See other models in the Networks section of the Models Library, such as Giant Component and Preferential Attachment. Also check out Lada's other NetLogo models:
http://www-personal.umich.edu/~ladamic/netlogo/

## CREDITS AND REFERENCES

This model was adapted from: Wilensky, U. (2005).  NetLogo Small Worlds model.  http://ccl.northwestern.edu/netlogo/models/SmallWorlds.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

It was written by Lada Adamic and Eytan Bakshy in 2007 and 2008. This version adapted for Netlogo 6 by Rense Corten.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

outlined circle
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 false false -1 -1 301

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
setup
repeat 5 [rewire-one]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="vary-rewiring-probability" repetitions="5" runMetricsEveryStep="false">
    <go>rewire-all</go>
    <timeLimit steps="1"/>
    <exitCondition>rewiring-probability &gt; 1</exitCondition>
    <metric>average-path-length</metric>
    <metric>clustering-coefficient</metric>
    <steppedValueSet variable="rewiring-probability" first="0" step="0.025" last="1"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
