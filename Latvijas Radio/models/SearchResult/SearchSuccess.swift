/* 
Copyright (c) 2024 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct SearchSuccess : Codable {
	let facet_counts : [String]?
	let found : Int?
	let hits : [Hits]?
	let out_of : Int?
	let page : Int?
	let request_params : Request_params?
	let search_cutoff : Bool?
	let search_time_ms : Int?

	enum CodingKeys: String, CodingKey {

		case facet_counts = "facet_counts"
		case found = "found"
		case hits = "hits"
		case out_of = "out_of"
		case page = "page"
		case request_params = "request_params"
		case search_cutoff = "search_cutoff"
		case search_time_ms = "search_time_ms"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		facet_counts = try values.decodeIfPresent([String].self, forKey: .facet_counts)
		found = try values.decodeIfPresent(Int.self, forKey: .found)
		hits = try values.decodeIfPresent([Hits].self, forKey: .hits)
		out_of = try values.decodeIfPresent(Int.self, forKey: .out_of)
		page = try values.decodeIfPresent(Int.self, forKey: .page)
		request_params = try values.decodeIfPresent(Request_params.self, forKey: .request_params)
		search_cutoff = try values.decodeIfPresent(Bool.self, forKey: .search_cutoff)
		search_time_ms = try values.decodeIfPresent(Int.self, forKey: .search_time_ms)
	}

}
