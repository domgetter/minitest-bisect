#!/usr/bin/ruby -w

class ComboFinder
  ##
  # Find the minimal combination of a collection of items that satisfy +test+.
  #
  # If you think of the collection as a binary tree, this algorithm
  # does a breadth first search of the combinations that satisfy
  # +test+.
  #--
  #  level   collection
  #
  #  0          A
  #  1      B       C
  #  2    D   E   F   G
  #  3   1 2 3 4 5 6 7 8
  #
  # This assumes that A has already been tested and you're now trying
  # to reduce the match. Starting at level 1, test B & C separately.
  # If either test positive, reduce the search space accordingly. If
  # not, step down to level 2 and search w/ finer granularity (ie, DF,
  # DG, EF--DE and FG were already tested as B & C). Repeat until a
  # minimal combination is found.

  def find_minimal_combination ary
    level, n_combos = 1, 1
    seen = {}

    loop do
      size = 2 ** (Math.log(ary.size) / Math.log(2)).round
      divs = 2 ** level
      done = divs >= size
      divs = size if done

      subsections = ary.each_slice(size/divs).to_a.combination(n_combos)

      found = subsections.find { |a|
        b = a.flatten

        next if seen[b]

        cache_result yield(b), b, seen
      }

      if found then
        ary = found.flatten
        break if done

        seen.delete ary

        level = n_combos = 1
      else
        if done then
          n_combos += 1
          break if n_combos > size
        else
          level += 1
          n_combos = level
        end
      end
    end

    ary
  end

  def cache_result result, data, cache
    cache[data] = true

    return result if result

    unless result or data.size > 128 then
      max = data.size
      subdiv = 2
      until subdiv >= max do
        data.each_slice(max / subdiv) do |sub_data|
          cache[sub_data] = true
        end
        subdiv *= 2
      end
    end

    result
  end
end

class Array
  ##
  # Find the minimal combination of a collection of items that satisfy +test+.

  def find_minimal_combination &test
    ComboFinder.new.find_minimal_combination(self, &test)
  end
end
