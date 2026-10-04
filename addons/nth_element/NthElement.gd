## When you need a to get the best N elements that fit a sorting criteria in O(n)
## time rather than sort's O(n log n) time. What you give up is that you're only
## guarenteed that the N elemnents are better than all the other elements in the
## array, not that they are sorted within their own subset.
## NOTE: This is quickselect, and although the average is O(n), a worst-case 
## list could be O(n^2) just like quicksort.
class_name NthElement extends RefCounted


## Given an array, move the best N elements to the front of the array. This
## function requires a comparison function that takes two arguments and returns
## true if the first argument should never come after the second argument.
## For instance: NthElement(span, 3, func(a,b): return a <= b)
static func NthElement(span: Array, nth: int, isLessOrEqual: Callable) -> void:
	_nthElementInternal(span, nth, isLessOrEqual, 0, span.size())


static func _nthElementInternal(span: Array, nth: int, isLessOrEqual: Callable, start: int, count: int) -> void:
	if count < 2:
		return
	
	var pivot: int = _partition(span, isLessOrEqual, start, count)
	if pivot == nth + start:
		return
	
	if pivot < nth + start:
		var new_start: int = pivot + 1
		var new_count: int = count - (new_start - start)
		_nthElementInternal(span, nth, isLessOrEqual, new_start, new_count)
	else: # pivot > nth + start
		_nthElementInternal(span, nth, isLessOrEqual, start, pivot - start)


static func _partition(span: Array, isLessOrEqual: Callable, start: int, count: int) -> int:
	var i: int = 0
	var j: int = count - 1
	while i < j:
		
		while (i <= count - 2) and isLessOrEqual.call(span[i + start], span[start]):
			i += 1
		
		while (j >= 1) and isLessOrEqual.call(span[start], span[j + start]):
			j -= 1
		
		if i < j:
			var t = span[j + start]
			span[j + start] = span[i + start]
			span[i + start] = t
	
	var t = span[start]
	span[start] = span[j + start]
	span[j + start] = t
	
	return j + start
