class_name StateMachineState_NthElement extends StateMachineState_PressAnyKey

const _source_words: Array[String] = [
	"Resolutely",
	"Telephone",
	"Apple",
	"Misinterpretation",
	"Crackerjack",
	"Banana",
	"Transformation",
	"Fortress",
	"Annihilation",
	"Sanctimonious",
	"Oz",
	"Ford",
	"Thunder",
	"Ape",
]

func _ready() -> void:
	_repopulate()

func _on_elements_selector_item_selected(_index: int) -> void:
	_repopulate()

static func _isSortedBeforeOrEqual(left: String, right: String) -> bool:
	return not (right < left)

static func _isNotLarger(left: String, right: String) -> bool:
	return left.length() <= right.length()

func _repopulate() -> void:
	var nth: int = %ElementsSelector.get_selected_id()
	_populate(%SourceList, Callable(), nth, "Source List")
	_populate(%Alphabetical, Callable(_isSortedBeforeOrEqual), nth, "Alphabetical")
	_populate(%WordLength, func(left: String, right: String): return left.length() <= right.length(), nth, "Word Length")

func _populate(c: Container, isLessThan: Callable, nth: int, title: String) -> void:
	for child in c.get_children():
		c.remove_child(child)
		child.queue_free()
	var title_node: Label = Label.new()
	title_node.text = title
	c.add_child(title_node)
	var title_sep: HSeparator = HSeparator.new()
	c.add_child(title_sep)
	var our_list: Array = _source_words.duplicate()
	var seperator_index: int = our_list.size() + 2
	if isLessThan.is_valid():
		seperator_index = nth
		NthElement.NthElement(our_list, nth, isLessThan)
	for t: String in our_list:
		var n: Label = Label.new()
		n.text = t
		c.add_child(n)
		seperator_index -= 1
		if seperator_index == 0:
			c.add_child(HSeparator.new())
