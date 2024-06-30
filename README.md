# loaded_dice
single file helper library that implements Walker-Vose alias method for efficiently simulating a loaded die

written in lua

useful for rolling loot tables, spinning roulettes with non-even sectors, damage distributed status effects, you name it

# api
import the library
`local ld = require("loaded_dice")`

## create a new loaded die
```lua
local die = ld.new_die()
```
creates a new loaded die

also can take a list of weights or a table as anargument

## add weights
```lua
die:add(weight)
```
add new weighted side to the die, weights are dimensionless and the probablility will be proportional to the total weights sum

## set weights
```lua
die:set(index, weight)
```
replace weight at existing index

## read weights
```lua
die:get(index)
```
returns previously set weight in case you forgot what it was

## generate a weighted random number
```lua
die:random(random1, random2)
```
can also use `die:sample(...)`

takes two random numbers in range `[0,1)` as parameters and returns a weighted random integer between 1 and number of added weights

`die:random()` with no parameters will use `math.random` internally

`die:random_fn(function)` will generate a random number using the provided function

`die:random_gen(rng, [name])` will generate a random number using provided `rng` object, will call it by name like `rng:name()` if provided and assumes `rng:random()` by default

## build alias table
```lua
die:build_alias()
```
the alias table will be built automatically if it's outdated at the time of calling `die:random`

this methods lets you build it manually

# example
```lua
local ld = require("loaded_dice")

local loot = {"dirt","leaf","stick","string","paperclip","copper coin"} -- possible loot

local weights = {50,30,30,10,7,2} -- drop weights, notice how they're specifically not percentages

local loot_die = ld.new_die(weights) -- new shiny loaded die

print(loot[loot_die:random()]) -- roll for loot! possible output: copper coin, lucky
```
