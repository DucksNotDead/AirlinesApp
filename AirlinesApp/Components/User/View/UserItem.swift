import SwiftUI

struct UserItem: View {
	@Binding var user: User
	
    var body: some View {
		Spacer(minLength: 30)
		VStack {
			
		}
		Spacer()
    }
}

#Preview {
	@Previewable @State var user: User = testAdmin
	
	UserItem(user: $user)
}
