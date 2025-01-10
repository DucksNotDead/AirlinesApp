import SwiftUI

struct TicketsScreen: View {
	@StateObject var ticketsModel = TicketsViewModel()
	
    var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 10) {
					ForEach(ticketsModel.tickets, id: \.id) { ticket in
						TicketItem(ticket)
					}
				}
			}
			.navigationTitle("билеты")
		}
    }
}

#Preview {
    TicketsScreen()
}
