## Chapter 8 - Generating random rooms

Generating random rooms is one of the most complicated and interesting parts of writing a roguelike. You want each level of a dungeon to feel unique. At the same time, you want it to feel very random.

Rooms in nethack are fairly simple. They are always rectangles. A room in NetHack is represented by horizontal walls `-`, vertical walls `|` and the floor `.`. Let's start by figuring out how we're going to randomly generate a rectangle. What we're going to do is start by treating the entire screen as an initial rectangle. In NetHack this rectangle is 80 columns by 21 rows. Then we'll try to find a random rectangle that fits inside of it.

We're going to need to set some rules for the rooms though. We want our rectangles to have a random width and height, but we don't want them to be too big or too small. In order to make this work we'll need to use `rand` to get some reasonable values:

```ruby
width = 2 + rand((rect.right - rect.left > 28) ? 12 : 8)
height = 2 + rand(4)
```

Here you can see that our rectangle has a minimum width and height of 2. The maximum width is either 14 or 10 depending on how big the containing rectangle is.

The usage or rectangles simplifies a lot of equations for us. For one, it's very easy to tell if two rectangles overlap using axis-aligned bounding boxes or AABBs. AABBs see frequent usage in shoot-em up games, due to the simplicity of the equation involved. Basically, in order to check if two triangles overlap you have to make the following 4 checks:

1. The top of triangle A is higher than the bottom of triangle B
2. The bottom of triangle A is lower than the top of triangle B
3. The left side of triangle A is to the left side of the right side of triangle B
4. The right side of triangle A is to the right side of the left side of triangle B

![Axis Aligned Bounding Boxes](images/aabbs.png?raw=true =600x)

An algorithm in Ruby, might looks something like this.

```ruby
def intersects?(rect)
  top > rect.bottom &&
    bottom < rect.top &&
    left < rect.right &&
    right > rect.left
end
```

So as you can see it simply checks the 4 conditions we've specified using `>` and `<`. Now that we know how to check if two rectangles overlap, let's discuss how we'll apply this. A fairly naive program would generate a random rectangle and if it didn't intersect any other rectangles we'd place it in the room. Rinse and repeat for the desired number of rooms. 
