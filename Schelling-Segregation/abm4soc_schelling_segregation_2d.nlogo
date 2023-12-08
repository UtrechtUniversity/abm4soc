globals [
  percent-similar  ;; on the average, what percent of a turtle's neighbors
                   ;; are the same color as that turtle?
  percent-unhappy  ;; what percent of the turtles are unhappy?
  perc-unhappy-red ;; what percent of the red turtles are unhappy?
  perc-unhappy-blue ;; what percent of the blue turtles are unhappy?
  place-for-red
  place-for-blue
  haltt
  time
  exact
  rule-code-red
  rule-code-blue
  n-blue
]

turtles-own [
  happy?       ;; for each turtle, indicates whether at least %-similar-wanted percent of
               ;; that turtles' neighbors are the same color as the turtle
  similar-nearby   ;; how many neighboring patches have a turtle with my color?
  other-nearby ;; how many have a turtle of another color?
  total-nearby  ;; sum of previous two variables
  turn ;; true if it's this turtle's turn to move
  rule
]

patches-own [
  red-nearby
  all-nearby
  blue-nearby
  ok-for-red
  ok-for-blue
  rrule
]


breed [ blues a-blue]
breed [ reds a-red]


to setup
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set exact false
  set haltt 0
  set time 0
  if number > count patches
    [ user-message (word "This pond only has room for "  count patches  " turtles.")
      stop ]

;;change rule descriptions from chooser to codes for convenience
  if rule-red = "1: any mixture"[set rule-code-red 1]
  if rule-red = "2: majority of blues"[set rule-code-red 2]
  if rule-red = "3: reds not minority"[set rule-code-red 3]
  if rule-red = "4: reds are majority"[set rule-code-red 4]
  if rule-red = "5: no blues"[set rule-code-red 5]
  if rule-red = "6: full of reds"[set rule-code-red 6]
  if rule-red = "7: equal numbers of reds and blues"[set rule-code-red 7]
  if rule-red = "8: percentages"[set rule-code-red 8]

  if rule-blue = "1: any mixture"[set rule-code-blue 1]
  if rule-blue = "2: majority of reds"[set rule-code-blue 2]
  if rule-blue = "3: blues not minority"[set rule-code-blue 3]
  if rule-blue = "4: blues are majority"[set rule-code-blue 4]
  if rule-blue = "5: no reds"[set rule-code-blue 5]
  if rule-blue = "6: full of blues"[set rule-code-blue 6]
  if rule-blue = "7: equal numbers of reds and blues"[set rule-code-blue 7]
  if rule-blue = "8: percentages"[set rule-code-blue 8]


  ;; create turtles on random patches.
  ask n-of number patches
    [ sprout-reds 1
      [ set color red
      set shape "face happy"]
      ]
  ;; turn part of the turtles blue

  set n-blue ((number * %-blue) / 100)  ; number of blues
  if n-blue < 1 [
    set n-blue 1            ; make sure that we have at least one blue
    ]
  if n-blue > (number - 1) [
    set n-blue (number - 1) ; .... and at least one red
    ]
  ask n-of n-blue turtles
    [ set breed blues set color blue set shape "face happy"]
  update-variables
  do-plots


end

to set-sequence ;procedure to determine the sequence of moves among the turtles. Samples only among unhappy turtles to speed up the procedure
  ask turtles [
    set turn false
    ]
  if count turtles with [happy? = false] > 0 [
    ask one-of turtles with [happy? = false][
      set turn true
      ]
    ]
end

to CheckSpaceRed   ;procedure to check whether there is at least one place to move to for a red turtle
  ask patches[
    set red-nearby count (reds-on neighbors )
    set blue-nearby count (blues-on neighbors)
    set all-nearby count (turtles-on neighbors)


      if rule-code-red = 1[
        set ok-for-red (count turtles-here = 0) ; any mixture
        ]
      if rule-code-red = 2[
        set ok-for-red (blue-nearby > (all-nearby / 2) and (count turtles-here = 0)); blues majority
        ]
      if rule-code-red = 3[
        set ok-for-red (red-nearby >= (all-nearby / 2) and (count turtles-here = 0)) ; reds not minority
        ]
      if rule-code-red = 4[
        set ok-for-red (red-nearby > (all-nearby / 2) and (count turtles-here = 0)) ; reds majority
        ]

      if rule-code-red = 5[
        set ok-for-red (blue-nearby = 0 and (count turtles-here = 0)) ; no blues
        ]

      if rule-code-red = 6[
        set ok-for-red (red-nearby = 8 and (count turtles-here = 0)) ; full of reds
        ]
      if rule-code-red = 7[
        set ok-for-red (red-nearby = blue-nearby and (count turtles-here = 0)) ; equal numbers
        ]
      if rule-code-red = 8[
      set ok-for-red (red-nearby >= ( %-similar-wanted-by-red * all-nearby / 100 )) and (count turtles-here = 0)
       ]
    ]

  set place-for-red count patches with [ok-for-red = true]
end

to CheckSpaceBlue   ;procedure to check whether there is at least one place to move to for a blue turtle
  ask patches[
    set blue-nearby count (blues-on neighbors )
    set red-nearby count (reds-on neighbors)
    set all-nearby count (turtles-on neighbors)
      if rule-code-blue = 1[
        set ok-for-blue (count turtles-here = 0) ; any mixture
        ]
      if rule-code-blue = 2[
        set ok-for-blue (red-nearby > ( all-nearby / 2 ) and (count turtles-here = 0)) ; reds majority
        ]
      if rule-code-blue = 3[
        set ok-for-blue (blue-nearby >= ( all-nearby / 2 ) and (count turtles-here = 0)) ; blues not minority
        ]
      if rule-code-blue = 4[
        set ok-for-blue (blue-nearby > ( all-nearby / 2 ) and (count turtles-here = 0)); blues majority
        ]

      if rule-code-blue = 5[
        set ok-for-blue (red-nearby = 0 and (count turtles-here = 0)) ; no reds
        ]
      if rule-code-blue = 6[
        set ok-for-blue (blue-nearby = 8 and (count turtles-here = 0)) ; all blues
        ]
      if rule-code-blue = 7[
        set ok-for-blue (blue-nearby = red-nearby and (count turtles-here = 0)) ; equal numbers
        ]
      if rule-code-blue = 8[
        set ok-for-blue (blue-nearby >= ( %-similar-wanted-by-blue * all-nearby / 100 )) and (count turtles-here = 0)
        ]

  ]
  set place-for-blue count patches with [ok-for-blue = true]
end

to go
  ;if not any? turtles with [not happy?] [ user-message "everybody is happy" ]
  ;if not any? turtles with [not happy?] [ stop ]
  update-variables
  do-plots
  set haltt 0
  if all? turtles [happy?] [stop]
  if (place-for-red = 0 or perc-unhappy-red = 0) and (place-for-blue = 0 or perc-unhappy-blue = 0 )[stop]

  update-variables
  move-unhappy-turtles
  do-plots
  set time time + 1

  if haltt = 1 [
  update-variables
  stop ]

end

to halt
  set haltt 1
end


to move-unhappy-turtles
  ask reds with [ not happy? and turn = true] [
     if place-for-red > 0 [
       find-new-spot
       ]
     ]
  ask blues with [ not happy? and turn = true] [
     if place-for-blue > 0 [
       find-new-spot
       ]
     ]
end

to find-new-spot
  rt random-float 360
  fd random-float 1
  if color = red[
      if any? other turtles-here or [not ok-for-red] of(patch-here)
          [ find-new-spot ]          ;; keep going until we find an unoccupied patch
  ]
  if color = blue[
      if any? other turtles-here or [not ok-for-blue] of(patch-here)
          [ find-new-spot ]          ;; keep going until we find an unoccupied patch
  ]
  setxy pxcor pycor  ;; move to center of patch
end

to update-variables
   update-rules
   update-turtles
   update-globals
end

to update-turtles
    ask turtles with [color = red][
    ;; in next two lines, we use "neighbors" to test the eight patches
    ;; surrounding the current patch
    set rule rule-code-red
    set similar-nearby count (turtles-on neighbors)
      with [color = [color] of myself]
    set other-nearby count (turtles-on neighbors)
      with [color != [color] of myself]
    set total-nearby similar-nearby + other-nearby
        if rule = 1[
        set happy? true
        ]
      if rule = 2[
        set happy? (other-nearby > (total-nearby / 2))
        ]
      if rule = 3[
        set happy? (similar-nearby >= ( total-nearby / 2 ))
        ]
      if rule = 4[
        set happy? (similar-nearby > ( total-nearby / 2 ))
        ]

      if rule = 5[
        set happy? (other-nearby = 0)
        ]

      if rule = 6[
        set happy? (similar-nearby = 8)
        ]

      if rule = 7[
        set happy? (similar-nearby = other-nearby)
        ]

    if rule = 8[
      set happy? similar-nearby >= ( %-similar-wanted-by-red * total-nearby / 100)
    ]
  ]

    ask turtles with [color = blue][
    ;; in next two lines, we use "neighbors" to test the eight patches
    ;; surrounding the current patch
    set rule rule-code-blue
    set similar-nearby count (turtles-on neighbors)
      with [color = [color] of myself]
    set other-nearby count (turtles-on neighbors)
      with [color != [color] of myself]
    set total-nearby similar-nearby + other-nearby
       if rule = 1[
        set happy? true
        ]
      if rule = 2[
        set happy? (other-nearby > (total-nearby / 2))
        ]
      if rule = 3[
        set happy? (similar-nearby >= (total-nearby / 2))
        ]
      if rule = 4[
        set happy? (similar-nearby > (total-nearby / 2))
        ]

      if rule = 5[
        set happy? (other-nearby = 0)
        ]

      if rule = 6[
        set happy? (similar-nearby = 8)
        ]

      if rule = 7[
        set happy? (similar-nearby = other-nearby)
        ]


    if rule = 8[
      set happy? similar-nearby >= ( %-similar-wanted-by-blue * total-nearby / 100)
    ]

  ]
  ask turtles with [happy?][
    set shape "face happy"
    ]
  ask turtles with [not happy?][
    set shape "face sad"
    ]
  set-sequence
end



to update-globals
  let similar-neighbors sum [similar-nearby] of turtles
  let total-neighbors sum [total-nearby] of turtles
  if total-neighbors = 0 [
    set percent-similar 0
    ]
  if total-neighbors > 0 [
    set percent-similar (similar-neighbors / total-neighbors) * 100
  ]
  set percent-unhappy (count turtles with [not happy?]) / (count turtles) * 100

  set perc-unhappy-red (count turtles with [not happy? and color = red]) / (count turtles with [color = red]) * 100
  set perc-unhappy-blue (count turtles with [not happy? and color = blue]) / (count turtles with [color = blue]) * 100
  CheckSpaceRed
  CheckSpaceBlue
end

to update-rules
  ;;change rule descriptions from chooser to codes for convenience
  if rule-red = "1: any mixture"[set rule-code-red 1]
  if rule-red = "2: majority of blues"[set rule-code-red 2]
  if rule-red = "3: reds not minority"[set rule-code-red 3]
  if rule-red = "4: reds are majority"[set rule-code-red 4]
  if rule-red = "5: no blues"[set rule-code-red 5]
  if rule-red = "6: full of reds"[set rule-code-red 6]
  if rule-red = "7: equal numbers of reds and blues"[set rule-code-red 7]
  if rule-red = "8: percentages"[set rule-code-red 8]

  if rule-blue = "1: any mixture"[set rule-code-blue 1]
  if rule-blue = "2: majority of reds"[set rule-code-blue 2]
  if rule-blue = "3: blues not minority"[set rule-code-blue 3]
  if rule-blue = "4: blues are majority"[set rule-code-blue 4]
  if rule-blue = "5: no reds"[set rule-code-blue 5]
  if rule-blue = "6: full of blues"[set rule-code-blue 6]
  if rule-blue = "7: equal numbers of reds and blues"[set rule-code-blue 7]
  if rule-blue = "8: percentages"[set rule-code-blue 8]
end

to do-plots
  set-current-plot "Percent Similar"
  plot percent-similar
  set-current-plot "Percent Unhappy"
  plot percent-unhappy
end


; *** NetLogo Model Copyright Notice ***
;
; This model was created as part of the project: CONNECTED MATHEMATICS:
; MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL
; MODELS (OBPML).  The project gratefully acknowledges the support of the
; National Science Foundation (Applications of Advanced Technologies
; Program) -- grant numbers RED #9552950 and REC #9632612.
;
; Copyright 1998 by Uri Wilensky. All rights reserved.
;
; Permission to use, modify or redistribute this model is hereby granted,
; provided that both of the following requirements are followed:
; a) this copyright notice is included.
; b) this model will not be redistributed for profit without permission
;    from Uri Wilensky.
; Contact Uri Wilensky for appropriate licenses for redistribution for
; profit.
;
; This model was converted to NetLogo as part of the project:
; PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN
; CLASSROOMS.  The project gratefully acknowledges the support of the
; National Science Foundation (REPP program) -- grant number REC #9814682.
; Converted from StarLogoT to NetLogo, 2001.  Updated 2002.
;
; To refer to this model in academic publications, please use:
; Wilensky, U. (1998).  NetLogo Segregation model.
; http://ccl.northwestern.edu/netlogo/models/Segregation.
; Center for Connected Learning and Computer-Based Modeling,
; Northwestern University, Evanston, IL.
;
; In other publications, please use:
; Copyright 1998 by Uri Wilensky.  All rights reserved.  See
; http://ccl.northwestern.edu/netlogo/models/Segregation
; for terms of use.
;
; *** End of NetLogo Model Copyright Notice ***
@#$#@#$#@
GRAPHICS-WINDOW
613
10
1191
589
-1
-1
30.0
1
10
1
1
1
0
1
1
1
-9
9
-9
9
0
0
1
ticks
30.0

MONITOR
1230
147
1322
192
Percent Unhappy
percent-unhappy
1
1
11

MONITOR
1230
207
1336
252
Percent Similar
percent-similar
1
1
11

PLOT
7
452
256
615
Percent Similar
time
%
0.0
25.0
0.0
100.0
true
false
"" ""
PENS
"percent" 1.0 0 -2674135 true "" ""

PLOT
279
450
528
614
Percent Unhappy
time
%
0.0
25.0
0.0
100.0
true
false
"" ""
PENS
"percent" 1.0 0 -10899396 true "" ""

SLIDER
296
156
536
189
number
number
2
360
336.0
2
1
NIL
HORIZONTAL

BUTTON
199
47
267
80
setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
295
47
364
80
go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

SLIDER
8
155
254
188
%-blue
%-blue
1
99
50.0
1
1
%
HORIZONTAL

SLIDER
324
339
514
372
%-similar-wanted-by-blue
%-similar-wanted-by-blue
0
100
0.0
1
1
%
HORIZONTAL

MONITOR
1330
147
1431
192
% Unhappy red
perc-unhappy-red
1
1
11

MONITOR
1440
147
1545
192
% Unhappy blue
perc-unhappy-blue
1
1
11

MONITOR
1359
207
1450
252
Time
time
0
1
11

MONITOR
1358
272
1449
317
Places for red
place-for-red
1
1
11

MONITOR
1230
272
1334
317
Places for blue
place-for-blue
1
1
11

CHOOSER
14
279
219
324
rule-red
rule-red
"1: any mixture" "2: majority of blues" "3: reds not minority" "4: reds are majority" "5: no blues" "6: full of reds" "7: equal numbers of reds and blues" "8: percentages"
2

CHOOSER
13
337
221
382
rule-blue
rule-blue
"1: any mixture" "2: majority of reds" "3: blues not minority" "4: blues are majority" "5: no reds" "6: full of blues" "7: equal numbers of reds and blues" "8: percentages"
2

SLIDER
322
283
515
316
%-similar-wanted-by-red
%-similar-wanted-by-red
0
100
0.0
1
1
%
HORIZONTAL

TEXTBOX
220
219
370
237
Preference Settings
14
0.0
1

TEXTBOX
98
247
126
265
Rules
11
0.0
1

TEXTBOX
397
248
475
267
Percentages
11
0.0
1

TEXTBOX
327
382
477
410
To activate percentages, select rule 8 in Rules (left)
11
0.0
1

TEXTBOX
248
414
398
432
Output
14
0.0
1

TEXTBOX
239
109
339
127
Basic Settings
14
0.0
1

TEXTBOX
257
15
407
33
Controls
14
0.0
1

TEXTBOX
87
135
237
153
Percentage blue
11
0.0
1

TEXTBOX
372
136
522
154
Number of inhabitants
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This project is another implementation of Schelling's model of social segregation. It is based on the project "Segregation" from netlogo's standard models library, but some respects closer to Schelling's original formulation of the model, and with some added features. As in the original version the basic assumption is that each inhabitant wants to live next to at least a given number of inhabitants of the same colour. However, in this version the inhabitants move sequentially rather then simultaniously. Moreover, inhabitants only start moving if there is a satisfactory place (patch) available for them somewhere, and settle only at places that meet their requirements. Added features are separate sliders for the preferences of both colors, and the possibility to change parameters and restart the process from an equilibrium situation.

## HOW IT WORKS

The program is a rather close imitation of Schellings original model. It  
consists of a "city" made of a square grid, in which two groups of  
"inhabitants" (or actors) live, the Reds and the Blues.  Initially, all  
inhabitants are randomly distributed around the city. Each inhabitant has a  
certain number of "neighbors"; these are the actors occupying the eight squares  
surrounding the square on which the actor "lives". Thus, each inhabitant can  
have between zero and eight neighbors.  Actually, the city is not a square but  
a 3-dimensional "torus", which means that the upper edge touches to lower edges  
and the right edge touches the left edge, such that the city has no borders. 

Now, as in Schelling's model, we let the inhabitants evaluate there current location, based on a certain preference rules.  
These rules determine whether an actor is happy with his current location or not.   
In this simulation, we implemented eight different preference rules.   
What follows is a short description of the rules for the BLUE actors, but they are symmetric for the Reds.

"1: any mixture"  
According to this rule, the blue actors are happy with every mixtures of neighbors.

"2: majority of reds"  
Blue actors are happy if the majority of their neighbors are red.

"3: blues not minority"  
Blue actors are happy if at least half of their neighbors are blue.

"4: blues are majority"  
Blue actors are happy if more than half of their neighbors are blue.

"5: no reds"  
Blue actors are happy only if they have no red neighbors at all.

"6: full of blues"  
Blue actors are happy only if they have eight blue neighbors.

"7: egual numbers of reds and blues"  
Blue actors are happy only if they have as many blue neighbors as they have red neighbors. 

"8: percentages"  
This is actually not really a rule. It means that the preference is determined by a certain percentage, which you have to set separately (as we'll explain below).  
Blue actors are happy only if the share of similar (=blue) neighbors is AT LEAST this percentage. Thus, if the percentage is set at 40%, Blues are happy with their location if 40% or more of their neighbors are also Blues.

The dynamic process works as follows: In every step, every inhabitant decides  
whether she is happy with her current location or not (you will see their faces  
change accordingly). Then, the computer checks how many empty places exist that  
would satisfy the preferences of Reds and Blues, respectively. Next, one  
unhappy actor is randomly selected. If there are places available, she will  
start to move around in a random fashion until she has found a place that  
satisfies her preferences. This process is repeated until:  
- There are no good places for Blue Left, OR all Blues are happy  
AND  
- There are no good places for Red Left, OR all Reds are happy.  
(Verify for yourself that this is indeed an equilibrium).



## HOW TO USE IT

## 1. CHOOSE THE BASIC SETTINGS

Use the slider labeled "Number of inhabitants" to set the total number of inhabitants in the city, and the %-BLUE slider to change the percentage of blue inhabitants. Use the "rule-red" and "rule-blue" buttons to choose the preferences of the red and blue inhabitants, respectively. If you change the "Type of rule" button to "%-(Left)",  you can use the sliders on the left to choose the preferences as percentages rather than rules. When you're done, click the SETUP button once, which creates a random starting situation.   
(This will not change anything on the screen yet). When you're done, press the "Setup" button in the section "Controls" (pressing "s" on your keyboard also works).   
This will create a starting situation according to your specifications, with the blue and red inhabitants distributed randomly across the city.

## 2. CHOOSE THE INHABITANTS' PREFERENCES

Now choose how the inhabitants evaluate  
their neighborhoods. You can change the preferences of both the red and blue  
inhabitants separately, using the drop-down menus named "rule-red" and  
"rule-blue", under "Rules" in the section "Preference Settings". If you want to  
use precentages rather than fixed rules (see above), you first need to select  
Rule 8 under rules. Then, you can select a percentage using the percentage  
sliders on the right. If Rule 8 is not selected, the percentage sliders have no effect.


## 3. RUN THE SIMULATION

Now you are ready to start the simulation. Click GO (or press "g") under  
"Controls" to start the simulation. One by one unhappy inhabitants move to a  
patch that meets their requirements, as long as suitable places are available.  
To stop the process, you can click the GO button again.  After the process has  
settled down, you may change the preferences of the inhabitants, and continue  
the simulation to by pressing GO again. 

## 4. READ THE RESULTS

The "Percent Similar" monitor shows the average percentage of same-color  
neighbors for each inhabitant; this is our measure of segregation. It starts at  
about 0.5, since each inhabitant starts (on average) with an equal number of red  
and blue inhabitants as neighbors. The "Percent Unhappy" monitors show the percent  
of inhabitants that have fewer same-color neighbors than they want (and thus want  
to move) for each. The total percentage unhappy is plotted. Moreover, each  
inhabitant also shows it's mood. "Places for red" and "Places for blue" show the  
number of satisfactory places available for each color. It may happen that some  
inhabitants are still unhappy while there are no longer any places available for  
them. It that case they just don't move. 


## CREDITS AND REFERENCES

Schelling, T. (1978). Micromotives and Macrobehavior. New York: Norton.

This model is inspired on:  
Wilensky, U. (1998).  NetLogo Segregation model. http://ccl.northwestern.edu/netlogo/models/Segregation. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

This adaptation by Rense Corten (2008), Utrecht University

## VERSION HISTORY

segregation_2019: small changes in the code to be compatible with Netlogo 6.0.4
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
Circle -7500403 true true 30 30 240

circle 2
false
0
Circle -7500403 true true 16 16 270
Circle -16777216 true false 46 46 210

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

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
Polygon -7500403 true true 60 270 150 0 240 270 15 105 285 105
Polygon -7500403 true true 75 120 105 210 195 210 225 120 150 75

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
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-similar</metric>
    <enumeratedValueSet variable="%-similar-wanted-by-blue">
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
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
