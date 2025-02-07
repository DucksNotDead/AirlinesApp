//
//  ReportBuilder.swift
//  AirlinesApp
//
//  Created by Александр Холуенко on 06.02.2025.
//

import SwiftUI

struct ReportBuilder {
	static let padding: CGFloat = 12
	static let innerPadding: CGFloat = 8
	static let sectionPadding: CGFloat = 24
	
	struct Layout<C: View>: View {
		var title: String
		var content: () -> C
		
		init(title: String, @ViewBuilder sections: @escaping () -> C) {
			self.title = title
			self.content = sections
		}
		
		var body: some View {
			VStack {
				Text(title)
					.font(.headline)
					.padding(.vertical)
				
				content()
				
				Spacer()
			}
			.padding(.all, 8)
			.ignoresSafeArea(.all)
		}
	}
	
	struct Section<C: View>: View {
		let content: () -> C
		
		init(@ViewBuilder content: @escaping () -> C) {
			self.content = content
		}
		
		var body: some View {
			VStack(alignment: .leading, spacing: ReportBuilder.padding) {
				Divider()
					.padding(.vertical, ReportBuilder.sectionPadding)
				content()
			}
		}
	}
}
