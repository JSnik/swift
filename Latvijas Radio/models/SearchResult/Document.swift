/* 
Copyright (c) 2024 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Document : Codable {
	let authors : [String]?
	let categories : [String]?
	let description : String?
	let document_type : String?
	let episode_title : String?
	let id : String?
	let image : String?
	let show_name : String?

	enum CodingKeys: String, CodingKey {

		case authors = "authors"
		case categories = "categories"
		case description = "description"
		case document_type = "document_type"
		case episode_title = "episode_title"
		case id = "id"
		case image = "image"
		case show_name = "show_name"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		authors = try values.decodeIfPresent([String].self, forKey: .authors)
		categories = try values.decodeIfPresent([String].self, forKey: .categories)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		document_type = try values.decodeIfPresent(String.self, forKey: .document_type)
		episode_title = try values.decodeIfPresent(String.self, forKey: .episode_title)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		image = try values.decodeIfPresent(String.self, forKey: .image)
		show_name = try values.decodeIfPresent(String.self, forKey: .show_name)
	}

}