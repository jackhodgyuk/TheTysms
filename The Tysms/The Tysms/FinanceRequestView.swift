import SwiftUI

struct FinanceRequestView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddRequest = false

    var body: some View {
        List {
            ForEach(viewModel.purchaseRequests) { request in
                NavigationLink(destination: PurchaseRequestDetailView(request: request, viewModel: viewModel)) {
                    PurchaseRequestRow(request: request)
                }
            }
        }
        .navigationTitle("Purchase Requests")
        .navigationBarItems(trailing: Button(action: { showingAddRequest = true }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showingAddRequest) {
            AddPurchaseRequestView(viewModel: viewModel)
        }
    }
}

#Preview {
    FinanceRequestView(viewModel: FinanceViewModel())
        .environmentObject(AuthViewModel())
}
