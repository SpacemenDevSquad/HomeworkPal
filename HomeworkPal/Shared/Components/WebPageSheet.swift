import SwiftUI
import WebKit

/// A web page shown inside the app in a sheet, so the student stays in HomeworkPal instead of leaving for Safari.
struct WebPageSheet: View {
    let url: URL

    @State private var page = WebPage()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            WebView(page)
                .overlay {
                    if page.isLoading {
                        ProgressView()
                            .controlSize(.large)
                    }
                }
                .navigationTitle(page.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                            .foregroundStyle(Theme.primaryText)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        ShareLink(item: page.url ?? url)
                            .foregroundStyle(Theme.primaryText)
                    }
                }
                .task {
                    page.load(URLRequest(url: url))
                }
        }
        .tint(Theme.primaryText)
    }
}

/// A web page waiting to be shown in a `WebPageSheet`. Wraps the URL so it can drive `.sheet(item:)`.
struct PresentedWebPage: Identifiable {
    let url: URL

    var id: URL { url }
}

#if DEBUG
#Preview {
    WebPageSheet(url: AppLinks.sourceCode)
}
#endif
