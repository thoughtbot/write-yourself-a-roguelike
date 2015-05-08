Now we need to implement our split_rects function:

```ruby
# add this as a private method
def split_rects(r1, r2)
  rects.delete(r1)

  # if any of the rectangles intersect let's delete them and add new ones
  (rects.count-1).downto(0) do |i|
    r = intersect?(rects[i], r2)
    if r
      split_rects(rects[i], r)
    end
  end

  if r2.top - r1.top - 1 > (r1.bottom < ROWNO - 1 ? 2 * YLIM : YLIM + 1) + 4
    r = r1.dup
    r.bottom = r2.top - 2
    add_rect(r)
  end

  if r2.left - r1.left - 1 > (r1.right < COLNO - 1 ? 2 * XLIM : XLIM + 1) + 4
    r = r1.dup
    r.right = r2.left - 2
    add_rect(r)
  end

  if r1.bottom - r2.bottom - 1 > (r1.top > 0 ? 2 * YLIM : YLIM + 1) + 4
    r = r1.dup
    r.top = r2.bottom + 2
    add_rect(r)
  end

  if r1.right - r2.right - 1 > (r1.left > 0 ? 2 * XLIM : XLIM + 1) + 4
    r = r1.dup
    r.left = r2.right + 2
    add_rect(r)
  end
end
```

It's very easy to tell if two rectangles overlap using axis-aligned bounding boxes or AABBs. AABBs see frequent usage in shoot-em up games, due to the simplicity of the equation involved. Basically, in order to check if two triangles overlap you have to make the following 4 checks:

1. The top of triangle A is higher than the bottom of triangle B
2. The bottom of triangle A is lower than the top of triangle B
3. The left side of triangle A is to the left side of the right side of triangle B
4. The right side of triangle A is to the right side of the left side of triangle B

\includegraphics[width=\linewidth]{images/aabbs.png}

Our `intersect?` function will need to check if they intersect and then return the intersection

```ruby
def intersects?(rect)
  top > rect.bottom &&
    bottom < rect.top &&
    left < rect.right &&
    right > rect.left
end
```

So as you can see it simply checks the 4 conditions we've specified using `>` and `<`. Now that we know how to check if two rectangles overlap, let's discuss how we'll apply this. A fairly naive program would generate a random rectangle and if it didn't intersect any other rectangles we'd place it in the room. Rinse and repeat for the desired number of rooms.
