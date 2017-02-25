# frozen_string_literal: true
def choice(arr, num)
  arrlen = arr.length
  if num >= arrlen
    arr
  else
    new_arr = []
    idxs = (0..arrlen - 1).to_a
    num_left = idxs.length
    while num > 0 && num_left > 0
      ii = rand(num_left)
      idx = idxs.delete_at(ii)
      new_arr << arr[idx]
      num -= 1
      num_left -= 1
      idx
    end
    new_arr
  end
end
