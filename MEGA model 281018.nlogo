;MEGA model
;Computational model in NetLogo to study bacterial adaptation and 
;evolution in an spatially structured environment, following the characteristics of the MEGA model
;Copyright (c) 2018 Bioresearch, Inc.
;Licensed under the MIT License (see LICENSE for details)
;Written by Rubén Castañeda with contributions from Carlos Castro

breed [bacterium bacteria]

;;turtles-own [energy antibiotic-resistance alive age]
;;patches-own [antibiotic nutrients]

turtles-own [energy dhfr-affinity alive age]
patches-own [tmp-affinity nutrients]

to setup
  ;; Clear previous conditions, set the environment and initial inoculum.
  __clear-all-and-reset-ticks
  set-petri
  set-bacterium
end

to set-petri
  ;; Here I create the environment, in this case is a giant Petri plate.
  ;; First the nutrients.
  ask patches
  [
    ;set nutrients initial-media-nutrients
    ;; Calibrar
    set nutrients 520
  ]

  ;; Set the concentration of antibiotic that each landscape has. Each lanscape
  ;; has 10 times the concentration that the previous landscape has. I made the
  ;; code somewhat robust, so you can change the size of the world and still
  ;; get equally distributed landscapes. The colors are for visualization only.
  ask patches with [pxcor <= (max-pxcor / 9) or pxcor >= (8 * max-pxcor / 9)]
  [
    set tmp-affinity 10
    set pcolor 0
  ]
  ask patches with [pxcor > (max-pxcor / 9) and pxcor <= (2 * max-pxcor / 9) or pxcor > (7 * max-pxcor / 9) and pxcor <= (8 * max-pxcor / 9)]
  [
    ;set tmp-affinity 1 * antibiotic-concentration
    set tmp-affinity 1
    set pcolor 1
  ]
  ask patches with [pxcor > (2 * max-pxcor / 9) and pxcor <= (3 * max-pxcor / 9) or pxcor > (6 * max-pxcor / 9) and pxcor <= (7 * max-pxcor / 9)]
  [
    ;set tmp-affinity 0.1 * antibiotic-concentration
    set tmp-affinity 0.1
    set pcolor 2
  ]
  ask patches with [pxcor > (3 * max-pxcor / 9) and pxcor <= (4 * max-pxcor / 9) or pxcor > (5 * max-pxcor / 9) and pxcor <= (6 * max-pxcor / 9)]
  [
    ;set tmp-affinity 0.01 * antibiotic-concentration
    set tmp-affinity 0.01
    set pcolor 3
  ]
  ask patches with [pxcor > (4 * max-pxcor / 9) and pxcor <= (5 * max-pxcor / 9)]
  [
    ;set tmp-affinity 0.001 * antibiotic-concentration
    set tmp-affinity 0.001
    set pcolor 4
  ]
end


to set-bacterium
  ;; An initial inoculum of bacteria is placed on the left and right ends of
  ;; the plate with the initial properties. I equally split the initial number
  ;; of bacterium into the left and right ends. Note that the initial antibiotic
  ;; resistance is barely less than the needed to move to the second
  ;; landscape, so they necessarily need to mutate to go ahead.
  create-bacterium (initial-inoculum / 2)
  [
    set shape "circle"
    set color white
    set size 0.275
    setxy min-pxcor random-ycor
    set energy 60
    ;set dhfr-affinity antibiotic-concentration + 0.08
    set dhfr-affinity 1.08
    set alive true
    set age 0
  ]
  create-bacterium (initial-inoculum / 2)
  [
    set shape "circle"
    set color white
    set size 0.275
    setxy max-pxcor random-ycor
    set energy 60
    ;set dhfr-affinity antibiotic-concentration + 0.08
    set dhfr-affinity 1.08
    set alive true
    set age 0
  ]
end

to go
  ;; If there are no bacterias alive left, the simulation stops.
  if count bacterium with [ alive = true ] = 0 [ stop ]

  ;; The bacterium in this model can move, mutate, feed, death and reproduce.
  ask bacterium with [ alive = true ]
  [
    move
    mutate
    feed
    death
    reproduce
  ;; And they have age.
    set age age + 1
    if gene-transfer? = TRUE
    [
      gene-transfer
    ]
  ]

  tick ;; One tick is equal to two hours.
end

to move
  ;; If the bacteria is stuck, turn back.
  if not can-move? 0.1 [ rt 180 ]

  ;; Sense where are more nutrients.
  let nutrients-ahead nutrients-at-angle   0
  let nutrients-right nutrients-at-angle  45
  let nutrients-left  nutrients-at-angle -45

  ;; Chemotaxis-guided movement.
  ifelse (nutrients-right > nutrients-ahead) or (nutrients-left > nutrients-ahead)
  [
    ifelse nutrients-right > nutrients-left
    [ rt 45 ]
    [ lt 45 ]
    fd 0.1
  ]

  ;; If there are equal amounts of nutrients, guide with
  ;; Brownian (random) movement.
  [
    rt random-float 360
    fd 0.1
  ]

  ;; Moving depletes energy.
  set energy energy - 1
end

to mutate
  ;; There is a chance of bacteria to mutate and become more or less resistant
  ;; to antibiotics. According to molecular biology, mutations are random and
  ;; spontaneous, and can be for better or for worse of the organism. That is
  ;; why it sums and subtracts a random number.

  ;; Tasa de mutación cuando hay antibiótico
  ;; Se multiplica por el valor del alelo.

  ;; Dos tasas de mutación diferentes para cuando exista cantidad de antibiótico presente y cuando no.

  ask bacterium with [pxcor >= 6 and pxcor <= 53] [
     if random-float 100 <= (mutation-rate * allele)
  [
    set dhfr-affinity (dhfr-affinity * random-float 1 - random-float 1 + random-float 0.5)
      ;set color red
  ]
  ]

;; Tasa de mutación cuando no hay antibiótico
  ask bacterium with [pxcor <= 5 or pxcor >= 54] [
    if random-float 100 <= mutation-rate
  [
    set dhfr-affinity (dhfr-affinity * random-float 1 - random-float 1 + random-float 1)
      ;set color green
  ]]



end

to feed
  ;; There are still nutrients on the media?
  ;if nutrients > feeding-energy
  ;; Calibrar
  if nutrients > 40
  [
  ;; If yes, get energy from them.
    set energy (energy + 40)
    ;set nutrients (nutrients - feeding-energy)
    set nutrients (nutrients - 40)
  ]
end

to death
  ;; When a bacteria dies, the agent doesn't die, just stop doing actions.
  ;; This is because I wanted to visualize the colonies formed along the plate,
  ;; keeping the dead ones in the model with a color change.

  ;; There are three rules of death on this model. If a bacteria runs out of
  ;; energy, it dies.
  if energy < 0
  [
    ;die
    set alive false
    set color 44
  ]

  ;; If the amount of antibiotic of the patch on which a bacteria stands in, is
  ;; more than the amount that can resist, it dies.
  if tmp-affinity < dhfr-affinity
  [
    ;die
    set alive false
    set color 54

    ;; Esta parte es para reducir en una pequeña cantidad, la cantidad de antibiótico
    ;; presente en un patch cuando una bacteria muere en él. Esto para representar
    ;; la inactivación del antibiótico al unirse a la enzima DHFR.
    let tile patch-here
    ask tile
    [
      set tmp-affinity tmp-affinity + 0.1
      set pcolor green
    ]
  ]

  ;; And if the age of the bacteria exceeds the maximum longevity, it dies.
  if age > max-bacteria-longevity
  [
    ;die
    set alive false
    set color 44
  ]
end

to reproduce
  ;; Flip a coin. If the random number is lower than the reproduction rate,
  ;; and if the energy allows to reproduce without dying, go ahead.
  if random-float 100 < reproduction-rate and energy > 30
  [
  ;; Reproducing depletes energy, and a new bacteria is created with the
  ;; initial energy and age, keeping only the antibiotic resistance, which
  ;; is inherited from his parent. This allows the mutation to fix on the
  ;; cell line, as happens in real life.

    hatch 1
    [
      ;;create-link-with myself
      rt random-float 360
      fd 0.1
      set energy (energy / 2)
      set age 0
    ]
    set energy (energy / 2)
  ]
end

to gene-transfer
  let predator one-of bacterium-here
  let prey one-of bacterium-here
  let plasmid [dhfr-affinity] of predator
  if prey != nobody
  [
    if [dhfr-affinity] of prey < [dhfr-affinity] of predator
    [
      ask prey
      [
        set dhfr-affinity plasmid
        set color red
      ]
    ]
  ]
end

to-report nutrients-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [nutrients] of p
end

to-report MAR
  ;; This is for plot the mean of the overall antibiotic resistance.
  let prom ((sum [dhfr-affinity] of bacterium with [ alive = true ]) / (count bacterium with [ alive = true ] + 1))
  report prom
end

to-report population
  ;; And this is for plot the alive bacterium population.
  let pop (log (count bacterium with [ alive = true ] + 1) 10)
  report pop
end

to-report ab-quantity
  ;; This is for plot the mean of the overall antibiotic resistance.
  let prom (sum [tmp-affinity] of patches)
  report prom
end
@#$#@#$#@
GRAPHICS-WINDOW
241
10
918
359
-1
-1
10.97
1
10
1
1
1
0
0
0
1
0
60
0
30
0
0
1
ticks
30.0

BUTTON
41
18
108
51
SETUP
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

BUTTON
115
18
178
51
GO
go
T
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
75
237
108
initial-inoculum
initial-inoculum
2
200
20.0
2
1
bacteria
HORIZONTAL

SLIDER
7
162
235
195
mutation-rate
mutation-rate
0.000001
0.000032
1.6E-5
0.000001
1
%
HORIZONTAL

PLOT
918
250
1486
590
Bacteria population
Tiime (ticks)
log (Bacteria)
0.0
10.0
0.0
6.0
true
true
"" ""
PENS
"Population" 1.0 0 -16777216 true "" "plot population"

SLIDER
7
197
234
230
reproduction-rate
reproduction-rate
1
40
5.0
1
1
%
HORIZONTAL

PLOT
917
10
1486
245
Mutation
Time (ticks)
Mean antibiotic resistance
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"MAR" 1.0 0 -2674135 true "" "plot MAR"

SLIDER
7
232
234
265
max-bacteria-longevity
max-bacteria-longevity
60
400
150.0
5
1
ticks
HORIZONTAL

MONITOR
810
440
891
485
No. bacteria
count turtles with [ alive = true]
17
1
11

TEXTBOX
9
57
159
75
Initial conditions
13
0.0
1

TEXTBOX
6
140
246
158
Behaviour and lifespan-related conditions
13
0.0
1

TEXTBOX
283
369
303
387
0
11
0.0
1

TEXTBOX
870
372
887
390
0
11
0.0
1

TEXTBOX
357
370
380
388
1 X
11
0.0
1

TEXTBOX
788
372
806
390
1 X
11
0.0
1

TEXTBOX
427
371
455
389
10 X
11
0.0
1

TEXTBOX
712
371
735
389
10 X
11
0.0
1

TEXTBOX
499
371
531
389
100 X
11
0.0
1

TEXTBOX
639
371
671
389
100 X
11
0.0
1

TEXTBOX
562
372
596
390
1000 X
11
0.0
1

SWITCH
620
444
759
477
gene-transfer?
gene-transfer?
1
1
-1000

CHOOSER
28
387
166
432
allele
allele
1 20 312 1108 1695 5700
2

TEXTBOX
176
388
326
458
Wild-type   1\nV96G        20\nT151       312\nD103G   1108\nD12G     1695 
11
0.0
1

PLOT
300
514
880
816
Overall antibiotic quantity
Time (ticks)
Antibiotic quantity
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot ab-quantity"

MONITOR
504
406
610
451
Antibiotic affinity
sum [tmp-affinity] of patches
5
1
11

@#$#@#$#@
## WHAT IS IT?

In this model, the spatiotemporal microbial evolution of bacteria moving through medium with an ascendent antibiotic concentration is explored.

In natural and clinical settings, bacteria does not move through a region without gradients of antibiotic or other properties, also known as well-mixed environments. Instead, they migrate between spatially distinct regions of selection with different conditions on each one (Baym et al., 2016).

This model try to show how bacteria can evolve through a medium with different concentration of antibiotic that allows motility, as they mutate and become more resistant to the antibiotic.

## HOW IT WORKS

The model starts with a giant Petri plate, filled with medium (semi-solid agar) divided into nine regions. Each region has 10 X the antibiotic concentration of the previous one.  The outside regions (first and last ones) does not have any antibiotic. The following after these have barely more antibiotic that bacteria can survive (known as minimun inhibitory concentration), in from that there is 10 times as much, then 100 times and in the central band there is 1000 X. Each region has a different color to make it easier to visualize. Each patch also has an initial concentration of nutrients that is the same for all patches, which can be depleted by bacteria. An initial inoculum of bacteria is placed at the left and right ends of the plate.

This model uses only one class of agent: bacteria. Every bacteria is represented by a single agent. Bacteria has the following properties:

1. Energy. Bacteria uses energy to move and reproduce.
2. Antibiotic resistance. Dictates how much antibiotic it can survive.
3. Organism state. Tells if the bacteria is dead or alive.
4. Age. Tells how old a bacteria is. One tick is equal to one hour.

The command *dead* was not used in this model. The reason for this is that when an agent die, it dissapears. Because this model seeks to visualize the spaciotemporal evolution of antibiotic resistance of bacteria, the dead bacteria leave a yellow trace.

The actions that bacteria can do are:

**MOVEMENT**
Bacteria movement is governed by the following rules:

1. Chemotaxis-guided movement: sense on which direction are more nutrients, then move to the patch that has more (Baym et al., 2016; Lux & Shi, 2004).
2. Brownian movement: if the amount of nutrients is the same, move randomly (Jarrel & McBride, 2008).
3. If the bacteria is stuck, turn back.

Every move that bacteria does, it uses energy. Note that the principal rule that governs movement is the chemotaxis-guided, the other two only happens in specific conditions, this is also true for the motility of bacteria in real life (Jarrell & McBride, 2008).

**FEEDING**
If a bacteria stands on a patch that has nutrients, it consumes a portion of the nutrients and gets energy from it. When the nutrients of a specific patch has completely consumed, bacteria can no longer get energy from it. This forces bacteria to move guided by chemotaxis or die (Baym et al., 2016). Because of this rule, bacteria that can not survive in a specific antibiotic concentration are intended to death, because if they stay where they are, they die. And if they go to the antibiotic region they die too. This causes weak (not resistant) lineages die.

**REPRODUCTION**
If a bacteria has enough energy, it can reproduce asexually by dividing itself. There is a reproduction rate, and bacteria only divide when a random number is lower than the reproduction rate evaluated on every tick.

**DEATH**
There are three rules for the death of bacteria on this model:

1. Starvation: when the energy of a bacteria drops to less than zero, it dies.
2. Life cycle inhibition: if a bacteria stands on a patch that has more antibiotic to which the bacteria can survive, it dies.
3. Old: when the age of a specific bacteria reaches its maximum longevity, it dies.

**MUTATION**
Bacteria can mutate to be more or less resistant to antibiotic. This event is governed by a mutation rate, and the mutation can be for better or worse for the bacteria. When a bacteria that has a greater antibiotic resistance than the wild ones reaches a region with antibiotic and go through it, the other ones die and the mutated bacteria survives and reproduce. This allows the mutation to be fixed in the cell line as it spreads (Lewin, 2008).

The simulation stops when there are no bacteria left alive.

## HOW TO USE IT

Click the `SETUP` button to create the media and initial bacteria inoculum.

There are 11 sliders on this model:
- `initial-inoculum`: Sets the initial number of bacterium that inoculates the medium.
- `initial-media-nutrients`: Sets the initial quantity of nutrients that each patch has.
- `initial-bacteria-energy`: Sets the initial quantity of energy bacteria starts with.
- `antibiotic-concentration`: The antibiotic concentration placed in all the medium.
- `bacteria-movement`: How much distance a bacteria moves with each tick.
- `mutation-rate`: How fast can a bacteria mutate and change its antibiotic resistance.
- `reproduction-rate`: How fast they reproduce.
- `max-bacteria-longevity`: How long they can live.
- `feeding-energy`: How much energy they can get from a patch with every tick.
- `moving-energy`: How much energy they use to move.
- `reproduction-energy`: How much energy cost to divide.

You can adjust the initial conditions, the bacteria behaviour conditions and the energy-related conditions with the sliders at the left. The initial inoculum is equally distributed into both ends of the environment.

The `GO` button starts the movement and action of bacteria.

There are two graphs:

* **Mutation:** Shows the average antibiotic resistance of the actual live bacteria vs. time. You can see how it evolves as bacteria spread through new regions.
* **Bacterium population:** Shows the actual number of live bacteria, in base 10 logarithm vs. time.

Also, a monitor show the actual number of live bacteria.

## THINGS TO NOTICE

The cell division, death and chemotaxis-guided movement is the first thing to notice. As the simulation starts, notice that bacteria reproduce and spreads very fast through the medium. The dead bacteria leave a trail so you can see where they were moving. Notice the chemotaxis-guided movement, which can be very noticeable just at the beginning.

As bacteria reaches the limit of the first region look that some bacteria die, and some go through easily. This is because they mutated to become more resistant to the antibiotic. This phenomenon can be more and more noticeable as bacteria move along the regions. You can see that every time is more difficult to bacteria to move to the next region with antibiotic. This is because they are still not resistant enough. When a mutant cell goes to the next region, a tree-like pattern can be seen sometimes, because is the only bacteria that could go forward and then reproduced.

## THINGS TO TRY

Increase the `moving-energy` moving the slider. Watch how small changes in the energy needed to move create different patterns of cell movement and reduces the time it takes to reach to the central band. This is the definition of chaos, when a small change in the conditions creates completely different patterns or events.

Try lowering the `reproduction-energy` and watch how the population behaves completely different. When the energy needed to divide is lower, more bacteria is created behind and it takes more time to go through the media regions.

You can also play with the `mutation-rate`, which is one of the most important variables in this model. If the mutation rate is too low, bacterium dies when they reach the next region an never reach the central band; when it is too high, bacteria go through the regions as if there were no antibiotic on them, so you can not see the patterns and behaviour of the antibiotic resistance evolution.

Play with the energy conditions and the distance that bacteria moves with every tick. Watch how in hostile conditions (when there are few nutrients and the energy cost is high) the population dies withouth reaching the central band, and when there are optimal conditions, there is an overpopulation of bacteria and can also difficult for them to reach the central band.

## EXTENDING THE MODEL

It would be fun and surprising to try with mixes of antibiotics, and see how bacteria can mutate and evolve to different configurations of concentrations and mixtures of antibiotics.

There is a complex phenomenon that occurs in this microbial evolution. Mutational lineages can physically block each other when they are moving towards a new region. The result of this phemonenon is that not always the best mutant (the mutant that has the higher antibiotic resistance) reaches a new region and spreads, because an adapted individual needs only to be the first with the capability to venture and survive in a new region (Baym et al., 2016; Greulich et al., 2012; Hermsen et al., 2012). This event was not taken into account in this model, because agents can overlap and pass through each other. Including this new rule to the motility of bacteria would surely create totally different patterns and behaviours in the population and antibiotic resistance evolution.

Also, a creative way to reduce the quantity of agents without lossing accuracy and detail of the phenomenon would be good for the model.

## CREDITS AND REFERENCES

The creation of this model was inspired by the following video:
- https://vimeo.com/180908160/7a7d12ead6

**References**

* Baym, M., Lieberman, T.D., Kelsic, E.D., Chait, R., Gross, R., Yelind, I., and Kishony, R. (2016). Spatiotemporal microbial evolution on antibiotic landscapes. Science 353, 1147-1151. doi:10.1126/science.aag0822
* Lux, R., Shi, W. (2004). Chemotaxis-guided movements in bacteria. Crit Rev Oral Biol Med 15, 207-220.
* Jarrell, K.F., and McBride, M.J. (2008). The surprisingly diverse ways that prokaryotes move. Nature 6, 466-476. doi:10.1038/nrmicro1900
* Lewin, B. (2008). Genes IX. MA, USA: McGraw-Hill.
* Greulich, P., Waclaw, B., and Allen, R.J. (2012). Mutational pathway determines whether drug gradients accelerate evolution of drug-resistant cells. PRL 109, [088101-1, 088101-5]. doi:10.1103/PhysRevLett.109.088101
* Hermsen, R., Deris, J.B., and Hwa, T. (2012). On the rapidity of antibiotic resistance evolution facilitated by a concentration gradient. PNAS 109(27), 10775-10780. doi:10.1073/pnas.1117716109

Other bibliography consulted:

* Kearns, D.B. (2010). A field guide to bacterial swarming motility. Nature Reviews Microbiology 8, 634-644. doi:10.1038/nrmicro2405
* Hillen, T., and Painter, K.J. (2009). A user's guide to PDE models for chemotaxis. Mathematical Biology 58, 183-217. doi:10.1007/s00285-008-0201-3
* Wielgoss, S., Barrick, J.E., Tenaillon, O., Cruveiller, S., Chane-Woon-Ming, B., Médigue, C., Lenski, R.E., and Schneider, D. (2011). Mutation rate inferred from synonymous substitutions in a long-term evolution experiment with *Escherichia coli*. Genes, Genomes and Genetics 1, 183-186. 10.1534/g3.111.000406
* Berg, H.C. (1975). Bacterial behaviour. Nature 254, 389-392.
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="initial-bacteria-energy">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-bacteria-longevity">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="feeding-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-media-nutrients">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alele">
      <value value="312"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-rate">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-concentration">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-inoculum">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-rate">
      <value value="1.6E-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gene-transfer?">
      <value value="false"/>
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
