import SwiftUI

struct FinancesView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if authViewModel.isAdminOrManager() {
                        Picker("", selection: $selectedTab) {
                            Text("Finances").tag(0)
                            Text("Purchase Requests").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    if authViewModel.isAdminOrManager() {
                        if selectedTab == 0 {
                            FinanceListView(viewModel: viewModel)
                        } else {
                            FinanceRequestView(viewModel: viewModel)
                        }
                    } else {
                        FinanceRequestView(viewModel: viewModel)
                    }
                }
            }
            .navigationTitle(authViewModel.isAdminOrManager() ? "Finances" : "Purchase Requests")
        }
    }
}

struct FinancesView_Previews: PreviewProvider {
    static var previews: some View {
        FinancesView(viewModel: FinanceViewModel())
            .environmentObject(AuthViewModel())
    }
}
