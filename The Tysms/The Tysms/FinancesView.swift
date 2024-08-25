import SwiftUI

struct FinancesView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack {
                if authViewModel.isAdminOrManager() {
                    Picker("", selection: $selectedTab) {
                        Text("Finances").tag(0)
                        Text("Purchase Requests").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    if selectedTab == 0 {
                        FinanceListView(viewModel: viewModel)
                    } else {
                        FinanceRequestView(viewModel: viewModel)
                    }
                } else {
                    FinanceRequestView(viewModel: viewModel)
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
