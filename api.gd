extends Node

signal pages_stocked

var random_wiki_content = HTTPRequest.new()
var pages: Array[Dictionary]

func _make_request():
	random_wiki_content.request("https://en.wikipedia.org/w/api.php?format=json&action=query&generator=random&grnnamespace=0&prop=revisions|images&rvprop=content&grnlimit=100")

func _ready() -> void:
	self.add_child(random_wiki_content)
	
	random_wiki_content.request_completed.connect(_on_request_completed)
	_make_request()
	
func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		_make_request()
	else:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json:
			var _pages = json["query"]["pages"]
			for k in _pages.keys():
				self.pages.push_back(_pages[k])
			pages_stocked.emit()
		else:
			_make_request()
