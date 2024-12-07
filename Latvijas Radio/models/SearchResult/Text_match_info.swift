/* 
Copyright (c) 2024 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Text_match_info : Codable {
	let best_field_score : String?
	let best_field_weight : Int?
	let fields_matched : Int?
	let num_tokens_dropped : Int?
	let score : String?
	let tokens_matched : Int?
	let typo_prefix_score : Int?

	enum CodingKeys: String, CodingKey {

		case best_field_score = "best_field_score"
		case best_field_weight = "best_field_weight"
		case fields_matched = "fields_matched"
		case num_tokens_dropped = "num_tokens_dropped"
		case score = "score"
		case tokens_matched = "tokens_matched"
		case typo_prefix_score = "typo_prefix_score"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		best_field_score = try values.decodeIfPresent(String.self, forKey: .best_field_score)
		best_field_weight = try values.decodeIfPresent(Int.self, forKey: .best_field_weight)
		fields_matched = try values.decodeIfPresent(Int.self, forKey: .fields_matched)
		num_tokens_dropped = try values.decodeIfPresent(Int.self, forKey: .num_tokens_dropped)
		score = try values.decodeIfPresent(String.self, forKey: .score)
		tokens_matched = try values.decodeIfPresent(Int.self, forKey: .tokens_matched)
		typo_prefix_score = try values.decodeIfPresent(Int.self, forKey: .typo_prefix_score)
	}

}